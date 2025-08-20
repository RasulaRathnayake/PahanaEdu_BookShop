/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

/**
 *
 * @author ugdin
 */
import jakarta.servlet.http.HttpServletRequest;

public class Security {
  public static boolean isAdmin(HttpServletRequest req) {
    Object u = req.getSession().getAttribute("user");
    if (u == null) return false;
    try { return "ADMIN".equals(((models.User)u).getRole()); } catch (Exception e) { return false; }
  }
}
