/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import dao.CustomerDAO;
import models.Customer;
import utils.EmailServices;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/customer")
public class CustomerController extends HttpServlet {
    

    CustomerDAO dao;

    public CustomerController() {              // used by servlet container at runtime
        this(new CustomerDAO());
    }

    public CustomerController(CustomerDAO dao) { // used by tests
        this.dao = dao;
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        Customer c = new Customer();
         
        c.setFirstName(request.getParameter("first_name"));
        c.setLastName(request.getParameter("last_name"));
        c.setPhone(request.getParameter("phone"));
        c.setAddress(request.getParameter("address"));
        c.setEmail(request.getParameter("email"));
        HttpSession session = request.getSession();
        try {
            boolean success = false;
            if ("add".equals(action)) {
                success = dao.insertCustomer(c);
                if (success) {
                    session.setAttribute("flashSuccess", "Customer saved successfully");
                    try {
                        EmailServices.sendEmail(c.getEmail(), "Welcome to Pahana Edu Bookshop",
                                "Dear " + c.getFirstName() + ",\n\nWelcome to Pahana Edu Bookshop! You have been registered successfully.\n\nBest regards,\nPahana Edu Bookshop Team");
                        System.out.println("Email sent successfully to: " + c.getEmail());
                    } catch (Exception emailEx) {
                        System.err.println("Email sending failed: " + emailEx.getMessage());
                        emailEx.printStackTrace();
                        // Don't fail the entire operation if email fails
                    }
                }
            } else if ("edit".equals(action)) {
                c.setAccountNumber(request.getParameter("account_number"));  
                 session.setAttribute("flashSuccess", "Customer edit successfully");
                success = dao.updateCustomer(c);
            } else if ("delete".equals(action)) {
                String accountNumber = request.getParameter("account_number");
                 session.setAttribute("flashSuccess", "Customer delete successfully");
                success = dao.deleteCustomer(accountNumber);
            }
            
            if (success) {
                response.sendRedirect("jsp/customerForm.jsp?msg=success");
            } else {
                response.sendRedirect("jsp/customerForm.jsp?msg=error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/customerForm.jsp?msg=error");
        }
    }
}

