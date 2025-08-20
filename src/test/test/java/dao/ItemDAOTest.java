/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import models.Item;
import org.junit.jupiter.api.*;
import org.mockito.MockedStatic;
import utils.DBConnection;

import java.sql.*;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ItemDAOTest {

    private static final String DRIVER = "org.h2.Driver";

    private String dbName;
    private String jdbcUrl;
    private Connection controlConn;   // kept open for schema + assertions
    private MockedStatic<DBConnection> dbMock;
    private ItemDAO dao;

    @BeforeAll
    static void loadDriver() throws Exception {
        Class.forName(DRIVER);
    }

    @BeforeEach
    void setUp() throws Exception {
        // fresh DB per test
        dbName  = "items_" + UUID.randomUUID().toString().replace("-", "");
        jdbcUrl = "jdbc:h2:mem:" + dbName + ";MODE=MySQL;DB_CLOSE_DELAY=-1";

        controlConn = DriverManager.getConnection(jdbcUrl);
        try (Statement st = controlConn.createStatement()) {
            st.execute("DROP TABLE IF EXISTS items");
            st.execute("""
                CREATE TABLE items(
                  item_id INT AUTO_INCREMENT PRIMARY KEY,
                  name VARCHAR(120) NOT NULL,
                  description VARCHAR(255),
                  price DECIMAL(12,2) NOT NULL,
                  stock_quantity INT NOT NULL
                )
            """);
        }

        // every DAO call gets a NEW connection to this DB
        dbMock = mockStatic(DBConnection.class);
        dbMock.when(DBConnection::getConnection)
              .thenAnswer(inv -> DriverManager.getConnection(jdbcUrl));

        dao = new ItemDAO();
    }

    @AfterEach
    void tearDown(TestInfo info) throws Exception {
        if (dbMock != null) dbMock.close();
        if (controlConn != null && !controlConn.isClosed()) controlConn.close();
        System.out.println("[PASS] " + info.getDisplayName());
    }

    // ---------- helpers ----------
    private Item make(String name, String desc, String price, String stock) {
        Item it = new Item();
        it.setItemName(name);
        it.setDescription(desc);
        it.setPrice(price);           // your DAO expects String for price
        it.setStockQuantity(stock);   // and String for stock
        return it;
    }

    private int idByName(String name) throws Exception {
        try (PreparedStatement ps = controlConn.prepareStatement(
                "SELECT item_id FROM items WHERE name=?")) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                return rs.getInt(1);
            }
        }
    }

    private int countItems() throws Exception {
        try (ResultSet rs = controlConn.createStatement()
                .executeQuery("SELECT COUNT(*) FROM items")) {
            rs.next(); return rs.getInt(1);
        }
    }

    // ---------- tests ----------

    @Test
    @DisplayName("ID-01 insertItem persists row with numeric bindings")
    void insertItem_persists() throws Exception {
        Item a = make("Maths Book", "A/L", "950.00", "10");
        assertTrue(dao.insertItem(a));
        assertEquals(1, countItems());

        try (PreparedStatement ps = controlConn.prepareStatement(
                "SELECT name, description, price, stock_quantity FROM items WHERE name='Maths Book'")) {
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("Maths Book", rs.getString(1));
                assertEquals("A/L", rs.getString(2));
                assertEquals("950.00", rs.getBigDecimal(3).toPlainString());
                assertEquals(10, rs.getInt(4));
            }
        }
    }

    @Test
    @DisplayName("ID-02 updateItem updates name/desc/price/stock by item_id")
    void updateItem_updates() throws Exception {
        // seed one
        assertTrue(dao.insertItem(make("Pen", "Blue", "45.00", "100")));
        int id = idByName("Pen");

        Item upd = new Item();
        upd.setItemId(id);
        upd.setItemName("Blue Pen");
        upd.setDescription("Fine tip");
        upd.setPrice("50.00");
        upd.setStockQuantity("120");

        assertTrue(dao.updateItem(upd));

        try (PreparedStatement ps = controlConn.prepareStatement(
                "SELECT name, description, price, stock_quantity FROM items WHERE item_id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                assertTrue(rs.next());
                assertEquals("Blue Pen", rs.getString(1));
                assertEquals("Fine tip", rs.getString(2));
                assertEquals("50.00", rs.getBigDecimal(3).toPlainString());
                assertEquals(120, rs.getInt(4));
            }
        }
    }

    @Test
    @DisplayName("ID-03 getItemById returns full row")
    void getItemById_returnsRow() throws Exception {
        assertTrue(dao.insertItem(make("Ruler", "30cm", "120.00", "5")));
        int id = idByName("Ruler");

        Item got = dao.getItemById(String.valueOf(id));
        assertNotNull(got);
        assertEquals("Ruler", got.getItemName());
        assertEquals("30cm", got.getDescription());
        assertEquals("120.00", got.getPrice());
        assertEquals("5", got.getStockQuantity());
    }

    @Test
    @DisplayName("ID-04 deleteItem removes row")
    void deleteItem_removes() throws Exception {
        assertTrue(dao.insertItem(make("Pencil", "HB", "25.00", "50")));
        int id = idByName("Pencil");

        assertTrue(dao.deleteItem(String.valueOf(id)));
        assertEquals(0, countItems());
    }

    @Test
    @DisplayName("ID-05 getAllItems returns all rows")
    void getAllItems_returnsAll() throws Exception {
        dao.insertItem(make("A", "d1", "10.00", "1"));
        dao.insertItem(make("B", "d2", "20.00", "2"));
        dao.insertItem(make("C", "d3", "30.00", "3"));

        List<Item> all = dao.getAllItems();
        assertEquals(3, all.size());
    }

    @Test
    @DisplayName("ID-06 searchItems matches by name/description and stringified price/stock (case-insensitive)")
    void searchItems_matches() throws Exception {
        dao.insertItem(make("Notebook", "200 pages", "350.00", "20"));
        dao.insertItem(make("Marker", "BLACK", "150.00", "15"));

        // by partial name
        var s1 = dao.searchItems("note");
        assertEquals(1, s1.size());
        assertEquals("Notebook", s1.get(0).getItemName());

        // by description (case-insensitive)
        var s2 = dao.searchItems("black");
        assertEquals(1, s2.size());
        assertEquals("Marker", s2.get(0).getItemName());

        // by price fragment
        var s3 = dao.searchItems("350");
        assertEquals(1, s3.size());
        assertEquals("Notebook", s3.get(0).getItemName());

        // by stock fragment
        var s4 = dao.searchItems("15");
        assertEquals(1, s4.size());
        assertEquals("Marker", s4.get(0).getItemName());
    }
}

