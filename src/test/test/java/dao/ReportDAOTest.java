/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import org.junit.jupiter.api.*;
import org.mockito.MockedStatic;
import utils.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ReportDAOTest {

    private static final String DRIVER = "org.h2.Driver";

    private String dbName;
    private String jdbcUrl;
    private Connection controlConn;     // kept open for schema + seed + assertions
    private MockedStatic<DBConnection> dbMock;
    private ReportDAO dao;

    @BeforeAll
    static void load() throws Exception {
        Class.forName(DRIVER);
    }

    @BeforeEach
    void setUp() throws Exception {
        // unique DB per test; MySQL mode enables DATE(), YEAR(), MONTH()
        dbName  = "rep_" + UUID.randomUUID().toString().replace("-", "");
        jdbcUrl = "jdbc:h2:mem:" + dbName + ";MODE=MySQL;DB_CLOSE_DELAY=-1";

        controlConn = DriverManager.getConnection(jdbcUrl);
        try (Statement st = controlConn.createStatement()) {
            st.execute("DROP TABLE IF EXISTS BillItems");
            st.execute("DROP TABLE IF EXISTS Bills");
            st.execute("DROP TABLE IF EXISTS Customers");

            st.execute("""
                CREATE TABLE Customers(
                  customer_id INT AUTO_INCREMENT PRIMARY KEY,
                  account_number VARCHAR(32) NOT NULL UNIQUE
                )
            """);

            st.execute("""
                CREATE TABLE Bills(
                  bill_id INT AUTO_INCREMENT PRIMARY KEY,
                  customer_id INT NOT NULL,
                  subtotal DECIMAL(12,2) NOT NULL,
                  tax_rate DECIMAL(12,2) DEFAULT 0,
                  tax_amount DECIMAL(12,2) NOT NULL,
                  total DECIMAL(12,2) NOT NULL,
                  created_at TIMESTAMP NOT NULL
                )
            """);

            st.execute("""
                CREATE TABLE BillItems(
                  bill_item_id INT AUTO_INCREMENT PRIMARY KEY,
                  bill_id INT NOT NULL,
                  item_id INT NOT NULL,
                  item_name VARCHAR(120) NOT NULL,
                  unit_price DECIMAL(12,2) NOT NULL,
                  quantity INT NOT NULL,
                  line_total DECIMAL(12,2) NOT NULL
                )
            """);
        }

        seedSampleData(controlConn);

        // Every DAO call should get a NEW connection to the same DB
        dbMock = mockStatic(DBConnection.class);
        dbMock.when(DBConnection::getConnection)
              .thenAnswer(inv -> DriverManager.getConnection(jdbcUrl));

        dao = new ReportDAO();
    }

    @AfterEach
    void tearDown(TestInfo info) throws Exception {
        if (dbMock != null) dbMock.close();
        if (controlConn != null && !controlConn.isClosed()) controlConn.close();
        System.out.println("[PASS] " + info.getDisplayName());
    }

    // ---------- seed helpers ----------

    private void seedSampleData(Connection c) throws Exception {
        // Customers
        try (PreparedStatement ps = c.prepareStatement(
                "INSERT INTO Customers(account_number) VALUES (?), (?)")) {
            ps.setString(1, "ACC0001");
            ps.setString(2, "ACC0002");
            ps.executeUpdate();
        }

        int cust1Id, cust2Id;
        try (Statement st = c.createStatement()) {
            try (ResultSet rs = st.executeQuery(
                    "SELECT customer_id FROM Customers WHERE account_number='ACC0001'")) {
                rs.next(); cust1Id = rs.getInt(1);
            }
            try (ResultSet rs = st.executeQuery(
                    "SELECT customer_id FROM Customers WHERE account_number='ACC0002'")) {
                rs.next(); cust2Id = rs.getInt(1);
            }
        }

        // Bills: 2025-08-05 (2 bills: cust1 + cust2), 2025-08-06 (1 bill: cust1)
        int b1 = insertBill(c, cust1Id, "2025-08-05 10:00:00", "100.00", "8.00", "108.00");
        int b2 = insertBill(c, cust2Id, "2025-08-05 11:00:00", "50.00",  "4.00", "54.00");
        int b3 = insertBill(c, cust1Id, "2025-08-06 09:30:00", "200.00", "16.00","216.00");

        // BillItems
        insertItem(c, b1, 1, "Book",  "30.00", 2, "60.00");
        insertItem(c, b1, 2, "Cover", "48.00", 1, "48.00");

        insertItem(c, b2, 3, "Pen",   "54.00", 1, "54.00");

        insertItem(c, b3, 1, "Book",  "36.00", 3, "108.00");
        insertItem(c, b3, 4, "Bag",   "108.00",1, "108.00");
    }

    private int insertBill(Connection c, int customerId, String ts,
                           String subtotal, String taxAmount, String total) throws Exception {
        try (PreparedStatement ps = c.prepareStatement(
                "INSERT INTO Bills(customer_id, subtotal, tax_amount, total, created_at) VALUES (?,?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            ps.setBigDecimal(2, new BigDecimal(subtotal));
            ps.setBigDecimal(3, new BigDecimal(taxAmount));
            ps.setBigDecimal(4, new BigDecimal(total));
            ps.setTimestamp(5, Timestamp.valueOf(ts));
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    private void insertItem(Connection c, int billId, int itemId, String name,
                            String unitPrice, int qty, String lineTotal) throws Exception {
        try (PreparedStatement ps = c.prepareStatement(
                "INSERT INTO BillItems(bill_id, item_id, item_name, unit_price, quantity, line_total) VALUES (?,?,?,?,?,?)")) {
            ps.setInt(1, billId);
            ps.setInt(2, itemId);
            ps.setString(3, name);
            ps.setBigDecimal(4, new BigDecimal(unitPrice));
            ps.setInt(5, qty);
            ps.setBigDecimal(6, new BigDecimal(lineTotal));
            ps.executeUpdate();
        }
    }

    // ------------------ Tests ------------------

    @Test
    @DisplayName("RP-01 salesDaily: sums for 2025-08-05 (2 bills)")
    void salesDaily_works() throws Exception {
        var map = dao.salesDaily(java.sql.Date.valueOf("2025-08-05"));
        assertEquals("2025-08-05", map.get("date"));
        assertEquals(2, ((Number) map.get("bills")).intValue());
        assertEquals(new BigDecimal("150.00"), map.get("subtotal"));
        assertEquals(new BigDecimal("12.00"),  map.get("tax"));
        assertEquals(new BigDecimal("162.00"), map.get("total"));
    }

    @Test
    @DisplayName("RP-02 salesMonthly: two rows (05 and 06) with correct totals")
    void salesMonthly_works() throws Exception {
        var list = dao.salesMonthly(2025, 8);
        assertEquals(2, list.size());

        var first = list.get(0); // 2025-08-05
        assertEquals("2025-08-05", first.get("date"));
        assertEquals(2, ((Number) first.get("bills")).intValue());
        assertEquals(new BigDecimal("162.00"), first.get("total"));

        var second = list.get(1); // 2025-08-06
        assertEquals("2025-08-06", second.get("date"));
        assertEquals(1, ((Number) second.get("bills")).intValue());
        assertEquals(new BigDecimal("216.00"), second.get("total"));
    }

    @Test
    @DisplayName("RP-03 customerConsumption: groups by item for customer 1 between 05..06")
    void customerConsumption_byId() throws Exception {
        var rows = dao.customerConsumption(1,
        java.sql.Date.valueOf("2025-08-05"),
        java.sql.Date.valueOf("2025-08-06"));
        assertTrue(rows.size() >= 2);

        Map<String,Object> book = rows.stream()
            .filter(m -> "Book".equals(m.get("itemName")))
            .findFirst().orElseThrow();
        assertEquals(5, ((Number) book.get("quantity")).intValue());

        Map<String,Object> bag = rows.stream()
            .filter(m -> "Bag".equals(m.get("itemName")))
            .findFirst().orElseThrow();
        assertEquals(1, ((Number) bag.get("quantity")).intValue());
    }

    @Test
    @DisplayName("RP-04 customerConsumptionByAccount: same result for ACC0001")
    void customerConsumption_byAccount() throws Exception {
        var rows = dao.customerConsumptionByAccount("ACC0001",
        java.sql.Date.valueOf("2025-08-05"),
        java.sql.Date.valueOf("2025-08-06"));
        assertTrue(rows.size() >= 2);

        Map<String,Object> book = rows.stream()
            .filter(m -> "Book".equals(m.get("itemName")))
            .findFirst().orElseThrow();
        assertEquals(5, ((Number) book.get("quantity")).intValue());
    }
}
