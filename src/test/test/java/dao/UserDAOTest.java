/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import models.User;
import org.junit.jupiter.api.*;
import org.mockito.MockedStatic;
import utils.DBConnection;

import java.sql.*;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserDAOTest {

    private static final String DRIVER = "org.h2.Driver";

    private String dbName;
    private String jdbcUrl;
    private Connection controlConn;     // kept open for schema + seed + assertions
    private MockedStatic<DBConnection> dbMock;
    private UserDAO dao;

    @BeforeAll
    static void loadDriver() throws Exception {
        Class.forName(DRIVER);
    }

    @BeforeEach
    void setUp() throws Exception {
        // unique DB per test
        dbName  = "users_" + UUID.randomUUID().toString().replace("-", "");
        jdbcUrl = "jdbc:h2:mem:" + dbName + ";MODE=MySQL;DB_CLOSE_DELAY=-1";

        controlConn = DriverManager.getConnection(jdbcUrl);

        try (Statement st = controlConn.createStatement()) {
            st.execute("DROP TABLE IF EXISTS Users");
            st.execute("""
                CREATE TABLE Users(
                  user_id INT AUTO_INCREMENT PRIMARY KEY,
                  username VARCHAR(100) NOT NULL UNIQUE,
                  password_hash VARCHAR(255) NOT NULL,
                  role VARCHAR(30) NOT NULL
                )
            """);
            // seed a couple test users
            st.execute("""
                INSERT INTO Users(username, password_hash, role) VALUES
                ('admin',  '$2a$10$adminhash',  'ADMIN'),
                ('cashier','$2a$10$cashhash',   'CASHIER')
            """);
        }

        // give DAO a NEW connection on every call
        dbMock = mockStatic(DBConnection.class);
        dbMock.when(DBConnection::getConnection)
              .thenAnswer(inv -> DriverManager.getConnection(jdbcUrl));

        dao = new UserDAO();
    }

    @AfterEach
    void tearDown(TestInfo info) throws Exception {
        if (dbMock != null) dbMock.close();
        if (controlConn != null && !controlConn.isClosed()) controlConn.close();
        System.out.println("[PASS] " + info.getDisplayName());
    }

    @Test
    @DisplayName("UD-01 findByUsername returns user row when present")
    void findByUsername_found() throws Exception {
        User u = dao.findByUsername("admin");
        assertNotNull(u);
        assertEquals("admin", u.getUsername());
        assertEquals("$2a$10$adminhash", u.getPasswordHash());
        assertEquals("ADMIN", u.getRole());
        assertTrue(u.getUserId() > 0);
    }

    @Test
    @DisplayName("UD-02 findByUsername returns null when not found")
    void findByUsername_notFound() throws Exception {
        User u = dao.findByUsername("no_such_user");
        assertNull(u);
    }
}

