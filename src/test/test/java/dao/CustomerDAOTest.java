/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import models.Customer;
import org.junit.jupiter.api.*;
import org.mockito.MockedStatic;
import utils.DBConnection;

import java.sql.*;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CustomerDAOTest {

    private static final String DRIVER = "org.h2.Driver";

    private String dbName;
    private String jdbcUrl;
    private Connection controlConn;           // kept open for schema + assertions
    private MockedStatic<DBConnection> dbMock;
    private CustomerDAO dao;

    @BeforeAll
    static void loadDriver() throws Exception {
        Class.forName(DRIVER);
    }

    @BeforeEach
    void setUp() throws Exception {
        // unique DB per test, MySQL mode for compatibility
        dbName  = "cust_" + UUID.randomUUID().toString().replace("-", "");
        jdbcUrl = "jdbc:h2:mem:" + dbName + ";MODE=MySQL;DB_CLOSE_DELAY=-1";

        controlConn = DriverManager.getConnection(jdbcUrl);
        try (Statement st = controlConn.createStatement()) {
            st.execute("DROP TABLE IF EXISTS Customers");

            // minimal schema matching your DAO usage
            st.execute("""
                CREATE TABLE Customers(
                  customer_id INT AUTO_INCREMENT PRIMARY KEY,
                  account_number VARCHAR(32) NOT NULL UNIQUE,
                  first_name VARCHAR(100) NOT NULL,
                  last_name  VARCHAR(100) NOT NULL,
                  phone      VARCHAR(50),
                  address    VARCHAR(255),
                  email      VARCHAR(150)
                )
            """);
        }

        // give DAO a NEW connection each time it calls DBConnection.getConnection()
        dbMock = mockStatic(DBConnection.class);
        dbMock.when(DBConnection::getConnection)
              .thenAnswer(inv -> DriverManager.getConnection(jdbcUrl));

        dao = new CustomerDAO();
    }

    @AfterEach
    void tearDown(TestInfo info) throws Exception {
        if (dbMock != null) dbMock.close();
        if (controlConn != null && !controlConn.isClosed()) controlConn.close();
        System.out.println("[PASS] " + info.getDisplayName());
    }

    // ---------- helpers ----------
    private Customer make(String fn, String ln, String email) {
        Customer c = new Customer();
        c.setFirstName(fn); c.setLastName(ln);
        c.setPhone("0712345678"); c.setAddress("Colombo");
        c.setEmail(email);
        return c;
    }

    private int countCustomers() throws Exception {
        try (ResultSet rs = controlConn.createStatement()
                .executeQuery("SELECT COUNT(*) FROM Customers")) {
            rs.next(); return rs.getInt(1);
        }
    }

    // ---------- tests ----------

    @Test
    @DisplayName("CD-01 insertCustomer generates ACC0001 then ACC0002 and persists data")
    void insertCustomer_generatesAccountNumber() throws Exception {
        Customer a = make("Nimal", "Perera", "nimal@example.com");
        assertTrue(dao.insertCustomer(a));
        assertEquals("ACC0001", a.getAccountNumber());

        Customer b = make("Sunil", "Fernando", "sunil@example.com");
        assertTrue(dao.insertCustomer(b));
        assertEquals("ACC0002", b.getAccountNumber());

        assertEquals(2, countCustomers());

        // last inserted should be ACC0002
        try (PreparedStatement ps = controlConn.prepareStatement(
                "SELECT account_number, first_name FROM Customers ORDER BY customer_id DESC LIMIT 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("ACC0002", rs.getString(1));
                assertEquals("Sunil", rs.getString(2));
            }
        }
    }

    @Test
    @DisplayName("CD-02 getCustomerByAccount and getCustomerById return correct row")
    void getByAccount_andById() throws Exception {
        Customer a = make("Kamal", "Silva", "kamal@example.com");
        dao.insertCustomer(a); // ACC0001
        Customer b = make("Amali", "Jayasinghe", "amali@example.com");
        dao.insertCustomer(b); // ACC0002

        Customer byAcc = dao.getCustomerByAccount("ACC0002");
        assertNotNull(byAcc);
        assertEquals("Amali", byAcc.getFirstName());

        // fetch id to test getCustomerById
        int id;
        try (PreparedStatement ps = controlConn.prepareStatement(
                "SELECT customer_id FROM Customers WHERE account_number='ACC0001'")) {
            try (ResultSet rs = ps.executeQuery()) { rs.next(); id = rs.getInt(1); }
        }
        Customer byId = dao.getCustomerById(id);
        assertNotNull(byId);
        assertEquals("ACC0001", byId.getAccountNumber());
        assertEquals("Kamal", byId.getFirstName());
    }

    @Test
    @DisplayName("CD-03 updateCustomer updates fields by account_number")
    void updateCustomer_updatesFields() throws Exception {
        Customer a = make("Ravi", "De Silva", "ravi@ex.com");
        dao.insertCustomer(a); // ACC0001

        // update
        Customer upd = new Customer();
        upd.setAccountNumber("ACC0001");
        upd.setFirstName("Ravindra");
        upd.setLastName("De Silva");
        upd.setPhone("0770000000");
        upd.setAddress("Kandy");
        upd.setEmail("ravindra@ex.com");

        assertTrue(dao.updateCustomer(upd));

        try (PreparedStatement ps = controlConn.prepareStatement(
                "SELECT first_name, phone, address, email FROM Customers WHERE account_number='ACC0001'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("Ravindra", rs.getString(1));
                assertEquals("0770000000", rs.getString(2));
                assertEquals("Kandy", rs.getString(3));
                assertEquals("ravindra@ex.com", rs.getString(4));
            }
        }
    }

    @Test
    @DisplayName("CD-04 deleteCustomer removes row by account_number")
    void deleteCustomer_removesRow() throws Exception {
        Customer a = make("Ishara", "Perera", "ishara@ex.com");
        dao.insertCustomer(a); // ACC0001
        assertEquals(1, countCustomers());

        assertTrue(dao.deleteCustomer("ACC0001"));
        assertEquals(0, countCustomers());
    }

    @Test
    @DisplayName("CD-05 getAllCustomers returns all rows")
    void getAllCustomers_returnsAll() throws Exception {
        dao.insertCustomer(make("A", "A", "a@ex.com"));
        dao.insertCustomer(make("B", "B", "b@ex.com"));
        dao.insertCustomer(make("C", "C", "c@ex.com"));

        List<Customer> all = dao.getAllCustomers();
        assertEquals(3, all.size());
    }

    @Test
    @DisplayName("CD-06 searchCustomers matches across account/first/last/phone/email (case-insensitive)")
    void searchCustomers_matches() throws Exception {
        Customer a = make("Nimal", "Perera", "nimal@ex.com");   dao.insertCustomer(a); // ACC0001
        Customer b = make("Sunil", "Fernando", "sunil@ex.com"); dao.insertCustomer(b); // ACC0002

        // quick phone tweak to prove phone LIKE works
        try (PreparedStatement ps = controlConn.prepareStatement(
                "UPDATE Customers SET phone='071-ABC-999' WHERE account_number='ACC0002'")) {
            ps.executeUpdate();
        }

        // search by part of first name
        var s1 = dao.searchCustomers("nim");
        assertEquals(1, s1.size());
        assertEquals("ACC0001", s1.get(0).getAccountNumber());

        // search by part of email
        var s2 = dao.searchCustomers("@ex.com");
        assertEquals(2, s2.size());

        // search by phone fragment
        var s3 = dao.searchCustomers("abc");
        assertEquals(1, s3.size());
        assertEquals("ACC0002", s3.get(0).getAccountNumber());
    }
}

