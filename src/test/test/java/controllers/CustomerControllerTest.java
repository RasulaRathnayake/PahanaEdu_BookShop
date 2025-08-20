/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import dao.CustomerDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Customer;
import org.junit.jupiter.api.*;
import org.mockito.MockedStatic;
import utils.EmailService;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

class CustomerControllerTest {

    CustomerController controller;
    CustomerDAO dao;   // mocked

    HttpServletRequest request;
    HttpServletResponse response;
    HttpSession session;

    @BeforeEach
    void setUp() throws Exception {
        dao = mock(CustomerDAO.class);

        // Use the real no-arg constructor…
        controller = new CustomerController();
        // …then inject our mock DAO via reflection
        var f = CustomerController.class.getDeclaredField("dao");
        f.setAccessible(true);
        f.set(controller, dao);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);

        when(request.getSession()).thenReturn(session);

        // Common fields used by all branches
        when(request.getParameter("first_name")).thenReturn("Nimal");
        when(request.getParameter("last_name")).thenReturn("Perera");
        when(request.getParameter("phone")).thenReturn("0712345678");
        when(request.getParameter("address")).thenReturn("Colombo");
        when(request.getParameter("email")).thenReturn("nimal@example.com");
    }

    @AfterEach
    void printPass(TestInfo info) {
        System.out.println("[PASS] " + info.getDisplayName());
    }

    @Test
    @DisplayName("CT-01 add: success → insert, flash, email attempted, redirect ?msg=success")
    void add_success_redirectsSuccess_andEmails() throws Exception {
        when(request.getParameter("action")).thenReturn("add");
        when(dao.insertCustomer(any(Customer.class))).thenReturn(true);

        try (MockedStatic<EmailService> mocked = mockStatic(EmailService.class)) {
            controller.doPost(request, response);

            verify(dao).insertCustomer(any(Customer.class));
            verify(session).setAttribute(eq("flashSuccess"), contains("saved successfully"));
            mocked.verify(() ->
                EmailService.sendEmail(eq("nimal@example.com"),
                                       contains("Welcome"),
                                       contains("registered successfully"))
            );
            verify(response).sendRedirect("jsp/customerForm.jsp?msg=success");
        }
    }

    @Test
    @DisplayName("CT-02 add: email throws → still redirect ?msg=success")
    void add_emailFailure_stillSuccess() throws Exception {
        when(request.getParameter("action")).thenReturn("add");
        when(dao.insertCustomer(any(Customer.class))).thenReturn(true);

        try (MockedStatic<EmailService> mocked = mockStatic(EmailService.class)) {
            mocked.when(() -> EmailService.sendEmail(anyString(), anyString(), anyString()))
                  .thenThrow(new RuntimeException("SMTP down"));

            controller.doPost(request, response);

            verify(dao).insertCustomer(any(Customer.class));
            verify(response).sendRedirect("jsp/customerForm.jsp?msg=success");
        }
    }

    @Test
    @DisplayName("CT-03 add: DAO false → redirect ?msg=error and no email")
    void add_failure_redirectsError() throws Exception {
        when(request.getParameter("action")).thenReturn("add");
        when(dao.insertCustomer(any(Customer.class))).thenReturn(false);

        try (MockedStatic<EmailService> mocked = mockStatic(EmailService.class)) {
            controller.doPost(request, response);

            verify(dao).insertCustomer(any(Customer.class));
            mocked.verifyNoInteractions(); // no email on failure
            verify(response).sendRedirect("jsp/customerForm.jsp?msg=error");
        }
    }

    @Test
    @DisplayName("CT-04 edit: success → update, flash, redirect ?msg=success")
    void edit_success() throws Exception {
        when(request.getParameter("action")).thenReturn("edit");
        when(request.getParameter("account_number")).thenReturn("C-001");
        when(dao.updateCustomer(any(Customer.class))).thenReturn(true);

        controller.doPost(request, response);

        verify(dao).updateCustomer(argThat(c -> "C-001".equals(c.getAccountNumber())));
        verify(session).setAttribute(eq("flashSuccess"), contains("edit successfully"));
        verify(response).sendRedirect("jsp/customerForm.jsp?msg=success");
    }

    @Test
    @DisplayName("CT-05 delete: success → delete, flash, redirect ?msg=success")
    void delete_success() throws Exception {
        when(request.getParameter("action")).thenReturn("delete");
        when(request.getParameter("account_number")).thenReturn("C-001");
        when(dao.deleteCustomer("C-001")).thenReturn(true);

        controller.doPost(request, response);

        verify(dao).deleteCustomer("C-001");
        verify(session).setAttribute(eq("flashSuccess"), contains("delete successfully"));
        verify(response).sendRedirect("jsp/customerForm.jsp?msg=success");
    }

    @Test
    @DisplayName("CT-06 delete: DAO false → redirect ?msg=error")
    void delete_failure() throws Exception {
        when(request.getParameter("action")).thenReturn("delete");
        when(request.getParameter("account_number")).thenReturn("C-999");
        when(dao.deleteCustomer("C-999")).thenReturn(false);

        controller.doPost(request, response);

        verify(dao).deleteCustomer("C-999");
        verify(response).sendRedirect("jsp/customerForm.jsp?msg=error");
    }

    @Test
    @DisplayName("CT-07 exception anywhere → redirect ?msg=error")
    void exception_redirectsError() throws Exception {
        when(request.getParameter("action")).thenReturn("add");
        when(dao.insertCustomer(any(Customer.class))).thenThrow(new RuntimeException("DB down"));

        controller.doPost(request, response);

        verify(response).sendRedirect("jsp/customerForm.jsp?msg=error");
    }
}

