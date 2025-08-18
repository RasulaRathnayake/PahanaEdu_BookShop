/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package services;

/**
 *
 * @author ugdin
 */


import models.Bills;
import models.BillItem;

import java.math.BigDecimal;
import java.math.RoundingMode;
 

public class BillingService {
    private static final int MONEY_SCALE = 2;
    private static final RoundingMode MONEY_RM = RoundingMode.HALF_UP;

    public void computeTotals(Bills bill) {
        BigDecimal subtotal = BigDecimal.ZERO;

        for (BillItem li : bill.getItems()) {
            BigDecimal unitPrice = nvl(li.getUnitPrice());
            BigDecimal qty = BigDecimal.valueOf(li.getQuantity()); // quantity is int in your model
            BigDecimal lineTotal = unitPrice.multiply(qty).setScale(MONEY_SCALE, MONEY_RM);

            li.setLineTotal(lineTotal);
            subtotal = subtotal.add(lineTotal);
        }

        subtotal = subtotal.setScale(MONEY_SCALE, MONEY_RM);
        bill.setSubtotal(subtotal);

        // Expect taxRate as a percent (e.g., 8.5 means 8.5%)
        BigDecimal taxRatePct = nvl(bill.getTaxRate());
        BigDecimal taxFraction = taxRatePct.divide(BigDecimal.valueOf(100), 6, MONEY_RM);

        BigDecimal taxAmount = subtotal.multiply(taxFraction).setScale(MONEY_SCALE, MONEY_RM);
        bill.setTaxAmount(taxAmount);

        BigDecimal total = subtotal.add(taxAmount).setScale(MONEY_SCALE, MONEY_RM);
        bill.setTotal(total);
    }

    private static BigDecimal nvl(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}

