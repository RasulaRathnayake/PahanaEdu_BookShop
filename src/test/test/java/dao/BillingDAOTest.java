package dao;

import models.BillItem;
import models.Bills;
import org.junit.jupiter.api.*;
import org.mockito.MockedStatic;
import utils.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class BillingDAOTest {

    private static final String DRIVER = "org.h2.Driver";

    private String dbName;              // unique per test
    private String jdbcUrl;             // jdbc:h2:mem:<dbName>;...
    private Connection controlConn;     // assertion connection we keep open
    private MockedStatic<DBConnection> dbMock;
    private BillingDAO dao;

    @BeforeAll
    static void loadDriver() throws Exception {
        Class.forName(DRIVER);
    }

    @BeforeEach
    void setUp() throws Exception {
        // Unique DB per test
        dbName  = "test_" + UUID.randomUUID().toString().replace("-", "");
        jdbcUrl = "jdbc:h2:mem:" + dbName + ";MODE=MySQL;DB_CLOSE_DELAY=-1";

        // Control connection for schema + assertions
        controlConn = DriverManager.getConnection(jdbcUrl);

        // Fresh schema
        try (Statement st = controlConn.createStatement()) {
            st.execute("DROP TABLE IF EXISTS BillItems");
            st.execute("DROP TABLE IF EXISTS Bills");
            st.execute("DROP TABLE IF EXISTS items");

            st.execute("""
                CREATE TABLE items(
                  item_id INT PRIMARY KEY,
                  item_name VARCHAR(100) NOT NULL,
                  price DECIMAL(12,2) NOT NULL,
                  stock_quantity INT NOT NULL
                )
            """);

            st.execute("""
                CREATE TABLE Bills(
                  bill_id INT AUTO_INCREMENT PRIMARY KEY,
                  customer_id INT NOT NULL,
                  subtotal DECIMAL(12,2) NOT NULL,
                  tax_rate DECIMAL(12,2) NOT NULL,
                  tax_amount DECIMAL(12,2) NOT NULL,
                  total DECIMAL(12,2) NOT NULL,
                  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """);

            st.execute("""
                CREATE TABLE BillItems(
                  bill_item_id INT AUTO_INCREMENT PRIMARY KEY,
                  bill_id INT NOT NULL,
                  item_id INT NOT NULL,
                  item_name VARCHAR(100) NOT NULL,
                  unit_price DECIMAL(12,2) NOT NULL,
                  quantity INT NOT NULL,
                  line_total DECIMAL(12,2) NOT NULL
                )
            """);

            st.execute("INSERT INTO items(item_id,item_name,price,stock_quantity) VALUES " +
                       "(1,'Maths Book',950.00,10),(2,'Pen',45.00,100)");
        }

        // Every DAO call gets a NEW connection to the same DB
        dbMock = mockStatic(DBConnection.class);
        dbMock.when(DBConnection::getConnection)
              .thenAnswer(inv -> DriverManager.getConnection(jdbcUrl));

        dao = new BillingDAO();
    }

    @AfterEach
    void tearDown(TestInfo info) throws Exception {
        if (dbMock != null) dbMock.close();
        if (controlConn != null && !controlConn.isClosed()) controlConn.close();
        System.out.println("[PASS] " + info.getDisplayName());
    }

    private Bills sampleBill() {
        Bills b = new Bills();
        b.setCustomerId(101);

        BillItem i1 = new BillItem();
        i1.setItemId(1);
        i1.setItemName("Maths Book");
        i1.setUnitPrice(new BigDecimal("950.00"));
        i1.setQuantity(2);
        i1.setLineTotal(new BigDecimal("1900.00"));

        BillItem i2 = new BillItem();
        i2.setItemId(2);
        i2.setItemName("Pen");
        i2.setUnitPrice(new BigDecimal("45.00"));
        i2.setQuantity(3);
        i2.setLineTotal(new BigDecimal("135.00"));

        b.setItems(List.of(i1, i2));
        b.setSubtotal(new BigDecimal("2035.00"));
        b.setTaxRate(new BigDecimal("8.00"));
        b.setTaxAmount(new BigDecimal("162.80"));
        b.setTotal(new BigDecimal("2197.80"));
        return b;
    }

    @Test
    @DisplayName("BD-01 createBill inserts bill+items and deducts stock atomically")
    void createBill_inserts_andDeductsStock() throws Exception {
        Bills b = sampleBill();

        int billId = dao.createBill(b);
        assertTrue(billId > 0);

        try (PreparedStatement ps = controlConn.prepareStatement(
                "SELECT subtotal, tax_rate, total FROM Bills WHERE bill_id=?")) {
            ps.setInt(1, billId);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(new BigDecimal("2035.00"), rs.getBigDecimal(1));
                assertEquals(new BigDecimal("8.00"),    rs.getBigDecimal(2));
                assertEquals(new BigDecimal("2197.80"), rs.getBigDecimal(3));
            }
        }
        try (PreparedStatement ps = controlConn.prepareStatement(
                "SELECT COUNT(*) FROM BillItems WHERE bill_id=?")) {
            ps.setInt(1, billId);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals(2, rs.getInt(1));
            }
        }
        try (ResultSet rs = controlConn.createStatement()
                .executeQuery("SELECT stock_quantity FROM items WHERE item_id=1")) {
            assertTrue(rs.next());
            assertEquals(8, rs.getInt(1));
        }
        try (ResultSet rs = controlConn.createStatement()
                .executeQuery("SELECT stock_quantity FROM items WHERE item_id=2")) {
            assertTrue(rs.next());
            assertEquals(97, rs.getInt(1));
        }
    }

    @Test
    @DisplayName("BD-02 insufficient stock → throws and rolls back (no rows inserted, no stock change)")
    void createBill_insufficientStock_throwsAndRollsBack() throws Exception {
        Bills b = sampleBill();
        b.getItems().get(1).setQuantity(1000);
        b.getItems().get(1).setLineTotal(new BigDecimal("45000.00"));

        SQLException ex = assertThrows(SQLException.class, () -> dao.createBill(b));
        assertTrue(ex.getMessage().toLowerCase().contains("insufficient stock"));

        try (ResultSet rs = controlConn.createStatement()
                .executeQuery("SELECT COUNT(*) FROM Bills")) {
            assertTrue(rs.next());
            assertEquals(0, rs.getInt(1));
        }
        try (ResultSet rs = controlConn.createStatement()
                .executeQuery("SELECT stock_quantity FROM items WHERE item_id=2")) {
            assertTrue(rs.next());
            assertEquals(100, rs.getInt(1)); // unchanged
        }
    }

    @Test
    @DisplayName("BD-03 getBillById + getBillItems return data for an existing bill")
    void getBillById_andItems() throws Exception {
        int id = dao.createBill(sampleBill());

        Bills fetched = dao.getBillById(id);
        assertNotNull(fetched);
        assertEquals(101, fetched.getCustomerId());
        assertEquals(new BigDecimal("2197.80"), fetched.getTotal());

        var items = dao.getBillItems(id);
        assertEquals(2, items.size());
        assertEquals("Maths Book", items.get(0).getItemName());
    }

    @Test
    @DisplayName("BD-04 getBillsByCustomer returns bills newest-first")
    void getBillsByCustomer_orderedDesc() throws Exception {
        int id1 = dao.createBill(sampleBill());

        Bills b = sampleBill();
        b.setTotal(new BigDecimal("3000.00"));
        int id2 = dao.createBill(b);

        var list = dao.getBillsByCustomer(101);
        assertEquals(2, list.size());
        assertEquals(id2, list.get(0).getBillId()); // most recent first
        assertEquals(id1, list.get(1).getBillId());
    }
}
