/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import models.Item;
import utils.DBconnection;
import java.sql.*;
import java.util.*;

public class ItemDAO {
    
    public boolean insertItem(Item c) throws SQLException {
        
        String sql = "INSERT INTO items (name, description, price, stock_quantity) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBconnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, c.getItemName());
            stmt.setString(2, c.getDescription());
            stmt.setBigDecimal(3, new java.math.BigDecimal(c.getPrice())); // numeric bind
            stmt.setInt(4, Integer.parseInt(c.getStockQuantity())); 
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean updateItem(Item c) throws SQLException {
        String sql = "UPDATE items SET name=?, description=?, price=?, stock_quantity=? WHERE item_id=?";
        try (Connection conn = DBconnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, c.getItemName());
            stmt.setString(2, c.getDescription());
            stmt.setBigDecimal(3, new java.math.BigDecimal(c.getPrice()));
            stmt.setInt(4, Integer.parseInt(c.getStockQuantity()));
            stmt.setInt(5, c.getItemId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public Item getItemById(String ItemId) throws SQLException {
    String sql = "SELECT * FROM items WHERE item_id = ?";
    try (Connection conn = DBconnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, ItemId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            Item c = new Item();
            c.setItemId(rs.getInt("item_id"));
            c.setItemName(rs.getString("name"));
            c.setDescription(rs.getString("description"));
            c.setPrice(rs.getString("price"));
            c.setStockQuantity(rs.getString("stock_quantity"));
            return c;
        }
    }
    return null;
}

    
    public boolean deleteItem(String  itemId) throws SQLException {
        String sql = "DELETE FROM items WHERE item_id=?";
        try (Connection conn = DBconnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, itemId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public List<Item> getAllItems() throws SQLException {
        List<Item> list = new ArrayList<>();
        String sql = "SELECT * FROM items";
        try (Connection conn = DBconnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Item c = new Item();
                c.setItemId(rs.getInt("item_id"));
                c.setItemName(rs.getString("name"));
                c.setDescription(rs.getString("description"));
                c.setPrice(rs.getString("price"));
                c.setStockQuantity(rs.getString("stock_quantity"));
                list.add(c);
            }
        }
        return list;
    }
    public List<models.Item> searchItems(String q) throws java.sql.SQLException {
    final String sql =
        "SELECT item_id, name, description, price, stock_quantity " +
        "FROM items " +
        "WHERE LOWER(name)        LIKE ? " +
        "   OR LOWER(description) LIKE ? " +
        "   OR LOWER(CAST(price AS VARCHAR)) LIKE ? " +          // <-- CHAR -> VARCHAR + LOWER
        "   OR LOWER(CAST(stock_quantity AS VARCHAR)) LIKE ? " + // <-- CHAR -> VARCHAR + LOWER
        "ORDER BY name";

    List<models.Item> list = new java.util.ArrayList<>();
    try (java.sql.Connection c = DBconnection.getConnection();
         java.sql.PreparedStatement ps = c.prepareStatement(sql)) {

        String like = "%" + q.toLowerCase() + "%";
        ps.setString(1, like);
        ps.setString(2, like);
        ps.setString(3, like);
        ps.setString(4, like);

        try (java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                models.Item it = new models.Item();
                it.setItemId(rs.getInt("item_id"));
                it.setItemName(rs.getString("name"));
                it.setDescription(rs.getString("description"));
                it.setPrice(rs.getString("price"));
                it.setStockQuantity(rs.getString("stock_quantity"));
                list.add(it);
            }
        }
    }
    return list;
    }
}

