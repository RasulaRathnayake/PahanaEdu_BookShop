/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package dao;

/**
 *
 * @author ugdin
 */
import models.Bills;
import models.BillItem;
import utils.DBconnection;

import java.sql.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

public class BillingDAO {

    // dao/BillingDAO.java
public int createBill(Bills bill) throws SQLException {
    final String insertBill =
        "INSERT INTO Bills (customer_id, subtotal, tax_rate, tax_amount, total) VALUES (?,?,?,?,?)";
    final String insertItem =
        "INSERT INTO BillItems (bill_id, item_id, item_name, unit_price, quantity, line_total) VALUES (?,?,?,?,?,?)";

    // Lock & check stock; then deduct; then write bill
    final String lockSql = "SELECT stock_quantity FROM items WHERE item_id=? FOR UPDATE";
    final String updSql  = "UPDATE items SET stock_quantity = stock_quantity - ? WHERE item_id=?";

    try (Connection conn = DBConnection.getConnection()) {
        conn.setAutoCommit(false);
        try {
            // 1) Lock each item row and validate stock
            try (PreparedStatement lock = conn.prepareStatement(lockSql)) {
                for (BillItem li : bill.getItems()) {
                    lock.setInt(1, li.getItemId());
                    try (ResultSet rs = lock.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException("Item not found: ID " + li.getItemId());
                        }
                        int current = rs.getInt(1);
                        if (current < li.getQuantity()) {
                            throw new SQLException(
                                "Insufficient stock for item! " + li.getItemName() +
                                " (ID " + li.getItemId() + "): need " + li.getQuantity() +
                                ", available " + current
                            );
                        }
                    }
                }
            }

            // 2) Deduct stock for each item
            try (PreparedStatement upd = conn.prepareStatement(updSql)) {
                for (BillItem li : bill.getItems()) {
                    upd.setInt(1, li.getQuantity());
                    upd.setInt(2, li.getItemId());
                    upd.addBatch();
                }
                upd.executeBatch();
            }

            // 3) Insert bill
            int billId;
            try (PreparedStatement ps = conn.prepareStatement(insertBill, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, bill.getCustomerId());
                ps.setBigDecimal(2, nz(bill.getSubtotal()));
                ps.setBigDecimal(3, nz(bill.getTaxRate()));
                ps.setBigDecimal(4, nz(bill.getTaxAmount()));
                ps.setBigDecimal(5, nz(bill.getTotal()));
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) throw new SQLException("Creating bill failed: no ID returned.");
                    billId = rs.getInt(1);
                }
            }

            // 4) Insert bill items
            try (PreparedStatement pi = conn.prepareStatement(insertItem)) {
                for (BillItem li : bill.getItems()) {
                    pi.setInt(1, billId);
                    pi.setInt(2, li.getItemId());
                    pi.setString(3, li.getItemName());
                    pi.setBigDecimal(4, nz(li.getUnitPrice()));
                    pi.setInt(5, li.getQuantity());
                    pi.setBigDecimal(6, nz(li.getLineTotal()));
                    pi.addBatch();
                }
                pi.executeBatch();
            }

            conn.commit();
            return billId;
        } catch (SQLException ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.setAutoCommit(true);
        }
    }
}


    public List<Bills> getBillsByCustomer(int customerId) throws SQLException {
        final String q = "SELECT bill_id, subtotal, tax_rate, tax_amount, total, created_at " +
                         "FROM Bills WHERE customer_id=? ORDER BY created_at DESC";
        List<Bills> list = new ArrayList<>();

        try (Connection c = DBconnection.getConnection();
             PreparedStatement ps = c.prepareStatement(q)) {

            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Bills b = new Bills();
                    b.setBillId(rs.getInt("bill_id"));
                    b.setCustomerId(customerId);
                    b.setSubtotal(nz(rs.getBigDecimal("subtotal")));
                    b.setTaxRate(nz(rs.getBigDecimal("tax_rate")));
                    b.setTaxAmount(nz(rs.getBigDecimal("tax_amount")));
                    b.setTotal(nz(rs.getBigDecimal("total")));

                    Timestamp ts = rs.getTimestamp("created_at");
                    b.setCreatedAt(ts);

                    list.add(b);
                }
            }
        }
        return list;
    }
    public Bills getBillById(int billId) throws SQLException {
    final String q = "SELECT bill_id, customer_id, subtotal, tax_rate, tax_amount, total, created_at " +
                     "FROM Bills WHERE bill_id=?";
    try (Connection c = DBconnection.getConnection();
         PreparedStatement ps = c.prepareStatement(q)) {
        ps.setInt(1, billId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Bills b = new Bills();
                b.setBillId(rs.getInt("bill_id"));
                b.setCustomerId(rs.getInt("customer_id"));
                b.setSubtotal(rs.getBigDecimal("subtotal"));
                b.setTaxRate(rs.getBigDecimal("tax_rate"));
                b.setTaxAmount(rs.getBigDecimal("tax_amount"));
                b.setTotal(rs.getBigDecimal("total"));
                b.setCreatedAt(rs.getTimestamp("created_at"));
                return b;
            }
        }
    }
    return null;
}


    public List<BillItem> getBillItems(int billId) throws SQLException {
        final String q = "SELECT bill_item_id, bill_id, item_id, item_name, unit_price, quantity, line_total " +
                         "FROM BillItems WHERE bill_id=?";
        List<BillItem> items = new ArrayList<>();

        try (Connection c = DBconnection.getConnection();
             PreparedStatement ps = c.prepareStatement(q)) {

            ps.setInt(1, billId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BillItem li = new BillItem();
                    li.setBillItemId(rs.getInt("bill_item_id"));
                    li.setBillId(rs.getInt("bill_id"));
                    li.setItemId(rs.getInt("item_id"));
                    li.setItemName(rs.getString("item_name"));
                    li.setUnitPrice(nz(rs.getBigDecimal("unit_price")));
                    li.setQuantity(rs.getInt("quantity"));
                    li.setLineTotal(nz(rs.getBigDecimal("line_total")));
                    items.add(li);
                }
            }
        }
        return items;
    }
    

    // Helper: avoid nulls; normalize scale for money if you prefer
    private static BigDecimal nz(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}
