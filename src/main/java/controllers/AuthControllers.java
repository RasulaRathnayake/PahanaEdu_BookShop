/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import models.User;
import services.AuthService;

/**
 *
 * @author ugdin
 */
import models.User;
import services.AuthService;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet("/login")
public class AuthControllers extends HttpServlet {
    private AuthService authService;

    public AuthControllers() {                  // used by servlet container
        this(new AuthService());
    }

    // make public (simplest for beginners)
    public AuthControllers(AuthService authService) { // used by tests
        this.authService = authService;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            User user = authService.authenticate(username, password);

            if (user != null) {
                // Create session
                HttpSession session = request.getSession();
                session.setAttribute("user", user);

                // Set cookie
                Cookie loginCookie = new Cookie("username", user.getUsername());
                loginCookie.setMaxAge(60 * 60); // 1 hour
                response.addCookie(loginCookie);

                // Redirect by role
                if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                    session.setAttribute("flashSuccess", "Wellcome to Admin Dashboard");
                    response.sendRedirect("jsp/adminDashboard.jsp");
                } else if ("CASHIER".equalsIgnoreCase(user.getRole())) {
                    session.setAttribute("flashSuccess", "Wellcome to Cashier Dashboard");
                    response.sendRedirect("jsp/cashierDashboard.jsp");
                }
            } else {
                request.setAttribute("error", "Invalid credentials");
                request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error");
            request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
        }
    }
}


