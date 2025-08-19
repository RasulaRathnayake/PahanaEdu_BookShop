/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Handles logout by clearing session and redirecting to login.
 */
@WebServlet("/logout")
public class LogOutController extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    // end old session if any
    var old = request.getSession(false);
    if (old != null) old.invalidate();

    // create a fresh session just to carry the flash message
    var flash = request.getSession(true);
    flash.setAttribute("flashSuccess", "You have logged out successfully");

    response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
  }
}

