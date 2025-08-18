/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

/**
 *
 * @author ugdin
 */
import dao.BillingDAO;
import dao.CustomerDAO;
import dao.ItemDAO;
import models.Bills;
import models.BillItem;
import models.Customer;
import models.Item;
import services.BillingService;
//import utils.PdfUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/billing")
public class BillingController extends HttpServlet {
    BillingDAO billingDAO;
    BillingService calc;
    CustomerDAO customerDAO;
    ItemDAO itemDAO;

    public BillingController() { // used in real app
        this(new BillingDAO(), new BillingService(), new CustomerDAO(), new ItemDAO());
    }
    // public or package-visible for tests
    public BillingController(BillingDAO billingDAO, BillingService calc, CustomerDAO customerDAO, ItemDAO itemDAO) {
        this.billingDAO = billingDAO;
        this.calc = calc;
        this.customerDAO = customerDAO;
        this.itemDAO = itemDAO;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Cashier guard (simple)
        Object u = req.getSession().getAttribute("user");
        if (u == null || (!"CASHIER".equals(((models.User)u).getRole()) && !"ADMIN".equals(((models.User)u).getRole()))) {
            resp.sendRedirect("jsp/login.jsp"); return;
        }

        try {
            int customerId = Integer.parseInt(req.getParameter("customer_id"));
            double taxRate = Double.parseDouble(req.getParameter("tax_rate")); // e.g. "8.0" or "0"

            // arrays: item_id[], qty[]
            String[] itemIds = req.getParameterValues("item_id");
            String[] qtys    = req.getParameterValues("quantity");

           List<BillItem> lines = new ArrayList<>();
           for (int i = 0; i < itemIds.length; i++) {
                int id = Integer.parseInt(itemIds[i]);
                int q  = Integer.parseInt(qtys[i]);
                if (q <= 0) continue;

            // use your DAO method (instance + String param)
              Item it = itemDAO.getItemById(String.valueOf(id));
               if (it == null) continue;

              BillItem li = new BillItem();
              li.setItemId(it.getItemId());
              li.setItemName(it.getItemName());                // <- use the correct getter name
              li.setUnitPrice(new BigDecimal(it.getPrice()));  // <- your DAO returns price as String
              li.setQuantity(q);
              lines.add(li);
            }
           
             String taxRateStr = req.getParameter("tax_rate");  


            Bills bill = new Bills();
            bill.setCustomerId(customerId);
            // Convert tax rate string/double to BigDecimal (stored as a percent value, e.g., 8.00)
            java.math.BigDecimal taxRateBD = new java.math.BigDecimal(
                (taxRateStr == null || taxRateStr.isBlank()) ? "0" : taxRateStr
             ).setScale(2, java.math.RoundingMode.HALF_UP);

            bill.setTaxRate(taxRateBD);
            bill.setItems(lines);
 
            calc.computeTotals(bill);         // subtotal/tax/total + line totals
            int billId = billingDAO.createBill(bill);
            bill.setBillId(billId);

            // (Optional) fetch created_at from DB if you want exact timestamp shown
            // or simply set now:
            bill.setCreatedAt(Timestamp.valueOf(LocalDateTime.now()));

            Customer c = customerDAO.getCustomerById(customerId); // ✅ now fetched by ID

            String customerDisplay = (c != null)
            ? (c.getAccountNumber() + " - " + c.getFirstName() + " " + c.getLastName())
             : ("Customer #" + customerId);



            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition","inline; filename=invoice_"+billId+".pdf");
            PdfUtils.writeInvoice(resp.getOutputStream(),
            "Pahana Edu Bookshop", "123 Main St, Colombo",
             customerDisplay, bill);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("jsp/adminDashboard.jsp?msg=error");
        }
    }
}
