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
import models.Bills;
import models.BillItem;
import models.Customer;
import utils.PdfUtils;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/invoice")
public class InvoiceController extends HttpServlet {
    BillingDAO billingDAO;
    CustomerDAO customerDAO;

    // used by the servlet container at runtime
    public InvoiceController() {
        this(new BillingDAO(), new CustomerDAO());
    }

    // used by unit tests
    public InvoiceController(BillingDAO billingDAO, CustomerDAO customerDAO) {
        this.billingDAO = billingDAO;
        this.customerDAO = customerDAO;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            String idStr = req.getParameter("bill_id");
            if (idStr == null || idStr.isBlank()) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "bill_id is required");
                return;
            }
            int billId = Integer.parseInt(idStr);

            Bills bill = billingDAO.getBillById(billId);
            if (bill == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Bill not found");
                return;
            }

            List<BillItem> items = billingDAO.getBillItems(billId);
            bill.setItems(items);

            Customer c = customerDAO.getCustomerById(bill.getCustomerId());
            String customerDisplay = (c != null)
                    ? (c.getAccountNumber() + " - " + c.getFirstName() + " " + c.getLastName())
                    : ("Customer #" + bill.getCustomerId());

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "inline; filename=invoice_"+billId+".pdf");

            PdfUtils.writeInvoice(resp.getOutputStream(),
                    "Pahana Edu Bookshop",
                    "123 Main St, Colombo",
                    customerDisplay,
                    bill);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not generate invoice");
        }
    }
}