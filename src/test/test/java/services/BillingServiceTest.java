/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package services;

import models.BillItem;
import models.Bills;
import org.junit.jupiter.api.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class BillingServiceTest {

    BillingService svc;

    @BeforeEach
    void setUp() {
        svc = new BillingService();
    }

    @AfterEach
    void pass(TestInfo info) {
        System.out.println("[PASS] " + info.getDisplayName());
    }

    // ---------- helpers ----------
    private Bills makeBill(BigDecimal taxRatePct, BillItem... items) {
        Bills b = new Bills();
        b.setItems(new ArrayList<>(List.of(items)));
        b.setTaxRate(taxRatePct);
        return b;
    }

    private BillItem li(int itemId, String name, String unitPrice, int qty) {
        BillItem i = new BillItem();
        i.setItemId(itemId);
        i.setItemName(name);
        i.setUnitPrice(unitPrice == null ? null : new BigDecimal(unitPrice));
        i.setQuantity(qty);
        return i;
    }

    // ---------- tests ----------

    @Test
    @DisplayName("BS-01 happy path: computes line totals, subtotal, tax and total (8%)")
    void computesTotals_happyPath() {
        Bills b = makeBill(
                new BigDecimal("8.00"),
                li(1, "Maths Book", "950.00", 2),   // 1900.00
                li(2, "Pen",        "45.00",  3)    // 135.00
        );

        svc.computeTotals(b);

        assertEquals(new BigDecimal("1900.00"), b.getItems().get(0).getLineTotal());
        assertEquals(new BigDecimal("135.00"),  b.getItems().get(1).getLineTotal());
        assertEquals(new BigDecimal("2035.00"), b.getSubtotal());
        assertEquals(new BigDecimal("162.80"),  b.getTaxAmount());
        assertEquals(new BigDecimal("2197.80"), b.getTotal());
    }

    @Test
    @DisplayName("BS-02 zero tax: total == subtotal, taxAmount == 0.00")
    void zeroTax() {
        Bills b = makeBill(
                new BigDecimal("0.00"),
                li(1, "Notebook", "120.50", 1),
                li(2, "Marker",   "150.00", 2)
        );

        svc.computeTotals(b);

        assertEquals(new BigDecimal("420.50"), b.getSubtotal()); // 120.50 + 300.00
        assertEquals(new BigDecimal("0.00"),   b.getTaxAmount());
        assertEquals(new BigDecimal("420.50"), b.getTotal());
    }

    @Test
    @DisplayName("BS-03 rounding: line totals rounded HALF_UP to 2dp; tax computed on subtotal")
    void roundingBehavior() {
        // one item 19.995 rounds to 20.00 (line), qty 2 → 39.99
        // tax 5% of 39.99 = 2.00 (1.9995 → 2.00), total 41.99
        Bills b = makeBill(
                new BigDecimal("5.00"),
                li(1, "RoundingItem", "19.995", 2)
        );

        svc.computeTotals(b);

        assertEquals(new BigDecimal("39.99"), b.getSubtotal());
        assertEquals(new BigDecimal("2.00"),  b.getTaxAmount());
        assertEquals(new BigDecimal("41.99"), b.getTotal());
        assertEquals(new BigDecimal("39.99"), b.getItems().get(0).getLineTotal());
    }

    @Test
    @DisplayName("BS-04 null safety: null unitPrice → treated as 0; null taxRate → treated as 0")
    void nullSafety() {
        Bills b = makeBill(
                null,                                  // null taxRate -> 0%
                li(1, "Freebie", null, 5),       // unitPrice null -> 0
                li(2, "Pen",     "45.00", 1)
        );

        svc.computeTotals(b);

        assertEquals(new BigDecimal("0.00"),  b.getItems().get(0).getLineTotal());
        assertEquals(new BigDecimal("45.00"), b.getItems().get(1).getLineTotal());
        assertEquals(new BigDecimal("45.00"), b.getSubtotal());
        assertEquals(new BigDecimal("0.00"),  b.getTaxAmount());
        assertEquals(new BigDecimal("45.00"), b.getTotal());
    }

    @Test
    @DisplayName("BS-05 empty items: subtotal/tax/total all 0.00")
    void emptyItems() {
        Bills b = makeBill(new BigDecimal("8.00")); // no items

        // ensure items list is non-null even if model default is null
        if (b.getItems() == null) b.setItems(new ArrayList<>());

        svc.computeTotals(b);

        assertEquals(new BigDecimal("0.00"), b.getSubtotal());
        assertEquals(new BigDecimal("0.00"), b.getTaxAmount());
        assertEquals(new BigDecimal("0.00"), b.getTotal());
    }
}

