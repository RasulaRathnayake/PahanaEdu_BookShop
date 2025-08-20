/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import dao.BillingDAO;
import dao.CustomerDAO;
import dao.ItemDAO;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.*;
import models.BillItem;
import models.Bills;
import models.Customer;
import models.Item;
import models.User;
import org.junit.jupiter.api.*;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import services.BillingService;
import utils.PdfUtils;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class BillingControllerTest {

    BillingDAO billingDAO;
    BillingService calc;
    CustomerDAO customerDAO;
    ItemDAO itemDAO;

    BillingController controller;

    HttpServletRequest req;
    HttpServletResponse resp;
    HttpSession session;

    ByteArrayOutputStream baos;
    ServletOutputStream servletOut;

    // print a [PASS] line after each test
    @AfterEach
    void afterEach(TestInfo info) {
        System.out.println("[PASS] " + info.getDisplayName());
    }

    @BeforeEach
    void setUp() throws Exception {
        billingDAO = mock(BillingDAO.class);
        calc       = spy(new BillingService()); // let it run or stub as needed
        customerDAO= mock(CustomerDAO.class);
        itemDAO    = mock(ItemDAO.class);

        controller = new BillingController(billingDAO, calc, customerDAO, itemDAO);

        req = mock(HttpServletRequest.class);
        resp = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);

        when(req.getSession()).thenReturn(session);

        // capture written PDF bytes (so servlet doesn't NPE)
        baos = new ByteArrayOutputStream();
        servletOut = new ServletOutputStream() {
            @Override public void write(int b) throws IOException { baos.write(b); }

            @Override
            public boolean isReady() {
                throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
            }

            @Override
            public void setWriteListener(WriteListener wl) {
                throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
            }
        };
        when(resp.getOutputStream()).thenReturn(servletOut);
    }

    @Test
    @DisplayName("BT-01 Happy path → creates bill, computes totals, writes PDF inline")
    void happyPath_createsBillAndWritesPdf() throws Exception {
        // ---- logged-in user with role ADMIN (or CASHIER)
        User u = new User();
        u.setRole("ADMIN");
        when(session.getAttribute("user")).thenReturn(u);

        // ---- request params
        when(req.getParameter("customer_id")).thenReturn("101");
        when(req.getParameter("tax_rate")).thenReturn("8.0");

        when(req.getParameterValues("item_id")).thenReturn(new String[]{"1","2"});
        when(req.getParameterValues("quantity")).thenReturn(new String[]{"2","3"}); // 2x item1, 3x item2

        // ---- item DAO returns Items (your code calls getItemById(String))
        Item i1 = new Item(); i1.setItemId(1); i1.setItemName("Maths Book"); i1.setPrice("950.00");
        Item i2 = new Item(); i2.setItemId(2); i2.setItemName("Pen");        i2.setPrice("45.00");
        when(itemDAO.getItemById("1")).thenReturn(i1);
        when(itemDAO.getItemById("2")).thenReturn(i2);

        // ---- customer lookup
        Customer c = new Customer();
        c.setCustomerId(101);
        c.setAccountNumber("C-101");
        c.setFirstName("Nimal");
        c.setLastName("Perera");
        when(customerDAO.getCustomerById(101)).thenReturn(c);

        // ---- billingDAO.createBill returns new id
        when(billingDAO.createBill(any(Bills.class))).thenReturn(555);

        // ---- optionally: stub computeTotals if needed (example ensures totals look right)
        doAnswer(inv -> {
            Bills b = inv.getArgument(0);
            // simple compute similar to your BillingService
            BigDecimal subtotal = BigDecimal.ZERO;
            for (BillItem li : b.getItems()) {
                BigDecimal line = li.getUnitPrice().multiply(BigDecimal.valueOf(li.getQuantity()));
                li.setLineTotal(line);
                subtotal = subtotal.add(line);
            }
            b.setSubtotal(subtotal.setScale(2));
            BigDecimal tax = subtotal.multiply(new BigDecimal("0.08")).setScale(2);
            b.setTaxAmount(tax);
            b.setTotal(subtotal.add(tax).setScale(2));
            return null;
        }).when(calc).computeTotals(any(Bills.class));

        // ---- mock static PdfUtils.writeInvoice (so we don't actually render a PDF)
        try (MockedStatic<PdfUtils> mocked = mockStatic(PdfUtils.class)) {
            controller.doPost(req, resp);

            // verify headers set for inline pdf
            verify(resp).setContentType("application/pdf");
            verify(resp).setHeader(eq("Content-Disposition"), contains("inline; filename=invoice_"));

            // verify bill was created with computed totals and id used
            ArgumentCaptor<Bills> billCap = ArgumentCaptor.forClass(Bills.class);
            verify(billingDAO).createBill(billCap.capture());
            Bills saved = billCap.getValue();

            assertEquals(101, saved.getCustomerId());
            assertEquals(new BigDecimal("8.00"), saved.getTaxRate()); // your controller sets scale(2)
            assertEquals(2, saved.getItems().size());

            // after computeTotals (our stub), totals should be set
            assertEquals(new BigDecimal("2035.00"), saved.getSubtotal()); // 2*950 + 3*45
            assertEquals(new BigDecimal("162.80"), saved.getTaxAmount());
            assertEquals(new BigDecimal("2197.80"), saved.getTotal());

            // verify we attempted to render PDF once
            mocked.verify(() ->
                PdfUtils.writeInvoice(any(), eq("Pahana Edu Bookshop"), eq("123 Main St, Colombo"),
                                      contains("C-101 - Nimal Perera"), any(Bills.class))
            );
        }
    }

    @Test
    @DisplayName("BT-02 Not logged in → redirect to login")
    void notLoggedIn_redirectsToLogin() throws Exception {
        when(session.getAttribute("user")).thenReturn(null); // no user

        controller.doPost(req, resp);

        verify(resp).sendRedirect("jsp/login.jsp");
        // ensure nothing else attempted
        verify(resp, never()).setContentType(anyString());
        verify(billingDAO, never()).createBill(any());
    }
}

