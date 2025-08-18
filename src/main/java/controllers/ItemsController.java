/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

/**
 *
 * @author ugdin
 */
import dao.ItemDAO;
import models.Item;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/items")
public class ItemsController extends HttpServlet {
    private final ItemDAO dao = new ItemDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action   = trim(request.getParameter("action"));
        String itemId   = trim(request.getParameter("item_id"));
        String name     = trim(request.getParameter("name"));
        String desc     = trim(request.getParameter("description"));
        String priceStr = trim(request.getParameter("price"));
        String stockStr = trim(request.getParameter("stock_quantity"));
        HttpSession session = request.getSession();
        boolean success = false;
        try {
            if (action == null) throw new IllegalArgumentException("Missing action");

            switch (action.toLowerCase()) {
                case "add": {
                    if (name == null || desc == null || priceStr == null || stockStr == null)
                        throw new IllegalArgumentException("Required fields missing");
                    // parse only here
                    new java.math.BigDecimal(priceStr);
                    Integer.parseInt(stockStr);

                    models.Item it = new models.Item();
                    it.setItemName(name);
                    it.setDescription(desc);
                    it.setPrice(priceStr);
                    it.setStockQuantity(stockStr);
                     session.setAttribute("flashSuccess", "Item add successfully");
                    success = dao.insertItem(it);
                    break;
                }
                case "edit": {
                    if (itemId == null || name == null || desc == null || priceStr == null || stockStr == null)
                        throw new IllegalArgumentException("Required fields missing");
                    new java.math.BigDecimal(priceStr);
                    Integer.parseInt(stockStr);

                    models.Item it = new models.Item();
                    it.setItemId(Integer.parseInt(itemId));
                    it.setItemName(name);
                    it.setDescription(desc);
                    it.setPrice(priceStr);
                    it.setStockQuantity(stockStr);
                     session.setAttribute("flashSuccess", "Item edit successfully");
                    success = dao.updateItem(it);
                    break;
                }
                case "delete": {
                    if (itemId == null) throw new IllegalArgumentException("Missing item_id");
                     session.setAttribute("flashSuccess", "Item delete successfully");
                    success = dao.deleteItem(itemId); // your DAO handles child deletes or FK cascade
                    break;
                }
                default: throw new IllegalArgumentException("Unknown action: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("lastError", e.getClass().getSimpleName()+": "+e.getMessage());
        }
        response.sendRedirect(request.getContextPath()+"/jsp/itemForm.jsp?msg="+(success?"success":"error"));
    }

    private static String trim(String s){ return s==null?null:s.trim(); }
}

