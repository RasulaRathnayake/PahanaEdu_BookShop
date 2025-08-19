/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

/**
 *
 * @author ugdin
 */
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class Bills {
    private int billId;
    private int customerId;
    private BigDecimal subtotal;
    private BigDecimal taxRate;    // percentage (e.g., 8.00 for 8%)
    private BigDecimal taxAmount;
    private BigDecimal total;
    private Timestamp createdAt;   // matches TIMESTAMP column
    private List<BillItem> items;  // child items in the bill
      
   
    
    // Constructors
    public Bills() {}

    public Bills(int billId, int customerId, BigDecimal subtotal, BigDecimal taxRate,
                BigDecimal taxAmount, BigDecimal total, Timestamp createdAt, List<BillItem> items) {
        this.billId = billId;
        this.customerId = customerId;
        this.subtotal = subtotal;
        this.taxRate = taxRate;
        this.taxAmount = taxAmount;
        this.total = total;
        this.createdAt = createdAt;
        this.items = items;
    }

    // Getters & Setters
    public int getBillId() { return billId; }
    public void setBillId(int billId) { this.billId = billId; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getTaxRate() { return taxRate; }
    public void setTaxRate(BigDecimal taxRate) { this.taxRate = taxRate; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public List<BillItem> getItems() { return items; }
    public void setItems(List<BillItem> items) { this.items = items; }
}

