/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author ugdin
 */
import utils.DBconnection;
import java.sql.*;
import java.util.*;

public class ReportDAO {

  // -------- Sales: Daily (one date) --------
  public Map<String,Object> salesDaily(java.sql.Date date) throws SQLException {
    String q = """
      SELECT DATE(created_at) AS d, COUNT(*) bills, SUM(subtotal) subtotal,
             SUM(tax_amount) tax, SUM(total) total
      FROM Bills
      WHERE DATE(created_at)=?
      GROUP BY DATE(created_at)
    """;
    try (Connection c = DBconnection.getConnection();
         PreparedStatement ps = c.prepareStatement(q)) {
      ps.setDate(1, date);
      try (ResultSet rs = ps.executeQuery()) {
        Map<String,Object> m = new HashMap<>();
        if (rs.next()) {
          m.put("date", rs.getDate("d").toString());
          m.put("bills", rs.getInt("bills"));
          m.put("subtotal", rs.getBigDecimal("subtotal"));
          m.put("tax", rs.getBigDecimal("tax"));
          m.put("total", rs.getBigDecimal("total"));
        }
        return m;
      }
    }
  }

  // -------- Sales: Monthly (YYYY, MM) with per-day breakdown --------
  public List<Map<String,Object>> salesMonthly(int year, int month) throws SQLException {
    String q = """
      SELECT DATE(created_at) AS d, COUNT(*) bills, SUM(total) total
      FROM Bills
      WHERE YEAR(created_at)=? AND MONTH(created_at)=?
      GROUP BY DATE(created_at) ORDER BY d
    """;
    try (Connection c = DBconnection.getConnection();
         PreparedStatement ps = c.prepareStatement(q)) {
      ps.setInt(1, year); ps.setInt(2, month);
      try (ResultSet rs = ps.executeQuery()) {
        List<Map<String,Object>> list = new ArrayList<>();
        while (rs.next()) {
          Map<String,Object> m = new HashMap<>();
          m.put("date", rs.getDate("d").toString());
          m.put("bills", rs.getInt("bills"));
          m.put("total", rs.getBigDecimal("total"));
          list.add(m);
        }
        return list;
      }
    }
  }

  // -------- Customer consumption summary (items bought) --------
  public List<Map<String,Object>> customerConsumption(int customerId, java.sql.Date from, java.sql.Date to) throws SQLException {
    String q = """
      SELECT bi.item_id, bi.item_name,
             SUM(bi.quantity) qty, SUM(bi.line_total) amount
      FROM BillItems bi
      JOIN Bills b ON b.bill_id = bi.bill_id
      WHERE b.customer_id=? AND DATE(b.created_at) BETWEEN ? AND ?
      GROUP BY bi.item_id, bi.item_name
      ORDER BY amount DESC
    """;
    try (Connection c = DBconnection.getConnection();
         PreparedStatement ps = c.prepareStatement(q)) {
      ps.setInt(1, customerId);
      ps.setDate(2, from); ps.setDate(3, to);
      try (ResultSet rs = ps.executeQuery()) {
        List<Map<String,Object>> list = new ArrayList<>();
        while (rs.next()) {
          Map<String,Object> m = new HashMap<>();
          m.put("itemId", rs.getInt("item_id"));
          m.put("itemName", rs.getString("item_name"));
          m.put("quantity", rs.getInt("qty"));
          m.put("amount", rs.getBigDecimal("amount"));
          list.add(m);
        }
        return list;
      }
    }
    
    
  }
  // dao/ReportDAO.java  (add this alongside existing methods)

public List<Map<String,Object>> customerConsumptionByAccount(String accountNumber,
                                                             java.sql.Date from,
                                                             java.sql.Date to) throws SQLException {
  String q = """
    SELECT bi.item_id, bi.item_name,
           SUM(bi.quantity) qty, SUM(bi.line_total) amount
    FROM BillItems bi
    JOIN Bills b      ON b.bill_id = bi.bill_id
    JOIN Customers c  ON c.customer_id = b.customer_id
    WHERE c.account_number = ? AND DATE(b.created_at) BETWEEN ? AND ?
    GROUP BY bi.item_id, bi.item_name
    ORDER BY amount DESC
  """;
  try (Connection c = DBconnection.getConnection();
       PreparedStatement ps = c.prepareStatement(q)) {
    ps.setString(1, accountNumber);
    ps.setDate(2, from);
    ps.setDate(3, to);
    try (ResultSet rs = ps.executeQuery()) {
      List<Map<String,Object>> list = new ArrayList<>();
      while (rs.next()) {
        Map<String,Object> m = new HashMap<>();
        m.put("itemId",    rs.getInt("item_id"));
        m.put("itemName",  rs.getString("item_name"));
        m.put("quantity",  rs.getInt("qty"));
        m.put("amount",    rs.getBigDecimal("amount"));
        list.add(m);
      }
      return list;
    }
  }
}




  
}
