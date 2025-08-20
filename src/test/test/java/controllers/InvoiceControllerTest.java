/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import dao.BillingDAO;
import dao.CustomerDAO;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.BillItem;
import models.Bills;
import models.Customer;
import org.junit.jupiter.api.*;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import utils.PdfUtils;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class InvoiceControllerTest {

    InvoiceController controller;
    BillingDAO billingDAO;
    CustomerDAO customerDAO;

    HttpServletRequest req;
    HttpServletResponse resp;

    ByteArrayOutputStream pdfBytes;
    ServletOutputStream out;

    @BeforeEach
    void setUp() throws Exception {
        billingDAO = mock(BillingDAO.class);
        customerDAO = mock(CustomerDAO.class);
        controller = new InvoiceController(billingDAO, customerDAO);

        req = mock(HttpServletRequest.class);
        resp = mock(HttpServletResponse.class);

        // Provide a concrete OutputStream so getOutputStream() works
        pdfBytes = new ByteArrayOutputStream();
        out = new ServletOutputStream() {
            @Override
            public void write(int b) throws IOException {
                pdfBytes.write(b);
            }

            @Override
            public boolean isReady() {
                throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
            }

            @Override
            public void setWriteListener(WriteListener wl) {
                throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
            }
        };
        when(resp.getOutputStream()).thenReturn(out);
    }

    @AfterEach
    void afterEach(TestInfo info) {
        System.out.println("[PASS] " + info.getDisplayName());
    }

    @Test
    @DisplayName("IV-01 Happy path → inline PDF with correct customer display")
    void happyPath_rendersInlinePdf() throws Exception {
        when(req.getParameter("bill_id")).thenReturn("555");

        Bills bill = new Bills();
        bill.setBillId(555);
        bill.setCustomerId(101);
        when(billingDAO.getBillById(555)).thenReturn(bill);

        BillItem li = new BillItem();
        li.setItemId(1);
        li.setItemName("Book");
        li.setQuantity(2);
        when(billingDAO.getBillItems(555)).thenReturn(List.of(li));

        Customer c = new Customer();
        c.setCustomerId(101);
        c.setAccountNumber("C-101");
        c.setFirstName("Nimal");
        c.setLastName("Perera");
        when(customerDAO.getCustomerById(101)).thenReturn(c);

        try (MockedStatic<PdfUtils> mocked = mockStatic(PdfUtils.class)) {
            controller.doGet(req, resp);

            // headers set for inline PDF
            verify(resp).setContentType("application/pdf");
            ArgumentCaptor<String> cd = ArgumentCaptor.forClass(String.class);
            verify(resp).setHeader(eq("Content-Disposition"), cd.capture());
            assertTrue(cd.getValue().startsWith("inline; filename=invoice_"));

            // bill items attached before rendering
            assertEquals(1, bill.getItems().size());

            // PdfUtils called with expected shop info and customer display
            mocked.verify(() -> PdfUtils.writeInvoice(
                any(), // OutputStream
                eq("Pahana Edu Bookshop"),
                eq("123 Main St, Colombo"),
                eq("C-101 - Nimal Perera"),
                same(bill)
            ));
        }
    }

    @Test
    @DisplayName("IV-02 Missing bill_id → HTTP 400")
    void missingBillId_returns400() throws Exception {
        when(req.getParameter("bill_id")).thenReturn(null);

        controller.doGet(req, resp);

        verify(resp).sendError(HttpServletResponse.SC_BAD_REQUEST, "bill_id is required");
        verify(billingDAO, never()).getBillById(anyInt());
        verify(billingDAO, never()).getBillItems(anyInt());
    }

    @Test
    @DisplayName("IV-03 Bill not found → HTTP 404")
    void billNotFound_returns404() throws Exception {
        when(req.getParameter("bill_id")).thenReturn("999");
        when(billingDAO.getBillById(999)).thenReturn(null);

        controller.doGet(req, resp);

        verify(resp).sendError(HttpServletResponse.SC_NOT_FOUND, "Bill not found");
        verify(billingDAO, never()).getBillItems(anyInt());
    }

    @Test
    @DisplayName("IV-04 Exception → HTTP 500")
    void exception_returns500() throws Exception {
        when(req.getParameter("bill_id")).thenReturn("777");
        when(billingDAO.getBillById(777)).thenThrow(new RuntimeException("DB down"));

        controller.doGet(req, resp);

        verify(resp).sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not generate invoice");
    }
}
