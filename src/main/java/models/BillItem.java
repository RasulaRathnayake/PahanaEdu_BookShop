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

public class BillItem {
    private int billItemId;      // PK
    private int billId;          // FK to Bills
    private int itemId;          // FK to Items (product/service table)
    private String itemName;     // name of the item at purchase time
    private BigDecimal unitPrice; // DECIMAL in DB
    private int quantity;        
    private BigDecimal lineTotal; // unitPrice * quantity

    // Constructors
    public BillItem() {}

    public BillItem(int billItemId, int billId, int itemId, String itemName,
                    BigDecimal unitPrice, int quantity, BigDecimal lineTotal) {
        this.billItemId = billItemId;
        this.billId = billId;
        this.itemId = itemId;
        this.itemName = itemName;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.lineTotal = lineTotal;
    }

    // Getters and Setters
    public int getBillItemId() { return billItemId; }
    public void setBillItemId(int billItemId) { this.billItemId = billItemId; }

    public int getBillId() { return billId; }
    public void setBillId(int billId) { this.billId = billId; }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public BigDecimal getLineTotal() { return lineTotal; }
    public void setLineTotal(BigDecimal lineTotal) { this.lineTotal = lineTotal; }
}
