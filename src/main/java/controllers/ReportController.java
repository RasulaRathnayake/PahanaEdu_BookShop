/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

/**
 *
 * @author ugdin
 */
import dao.ReportDAO;
import utils.Security;
import utils.PdfUtils; // you already have one; you can add report-specific writer if needed

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.*;

@WebServlet("/api/reports/*")
public class ReportController extends HttpServlet {
  private final ReportDAO dao = new ReportDAO();

  @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    if (!Security.isAdmin(req)) { resp.sendError(403, "Admin only"); return; }

    String path = req.getPathInfo(); // e.g., /sales/daily
    String format = Optional.ofNullable(req.getParameter("format")).orElse("json"); // json|csv|pdf

    try {
      switch (path) {
        case "/sales/daily" -> handleSalesDaily(req, resp, format);
        case "/sales/monthly" -> handleSalesMonthly(req, resp, format);
        case "/customer/consumption" -> handleCustomerConsumption(req, resp, format);
        default -> resp.sendError(404, "Not found");
      }
    } catch (Exception e) {
      e.printStackTrace();
      resp.sendError(500, "Report error");
    }
  }

  // ---------- Handlers ----------
  private void handleSalesDaily(HttpServletRequest req, HttpServletResponse resp, String format) throws Exception {
    Date date = Date.valueOf(req.getParameter("date")); // YYYY-MM-DD
    Map<String,Object> m = dao.salesDaily(date);
    if ("csv".equalsIgnoreCase(format)) {
      resp.setContentType("text/csv");
      resp.setHeader("Content-Disposition", "attachment; filename=daily-sales.csv");
      try (PrintWriter out = resp.getWriter()) {
        out.println("date,bills,subtotal,tax,total");
        if (!m.isEmpty()) out.printf("%s,%s,%s,%s,%s%n",
          m.get("date"), m.get("bills"), m.get("subtotal"), m.get("tax"), m.get("total"));
      }
    } else if ("pdf".equalsIgnoreCase(format)) {
      resp.setContentType("application/pdf");
      resp.setHeader("Content-Disposition","inline; filename=daily-sales.pdf");
      // Minimal example: reuse your PdfUtils; implement a simple writer for key-values
      PdfUtils.writeSimpleKeyValueReport(resp.getOutputStream(), "Daily Sales", m);
    } else {
      json(resp, m);
    }
  }

  private void handleSalesMonthly(HttpServletRequest req, HttpServletResponse resp, String format) throws Exception {
    int year = Integer.parseInt(req.getParameter("year"));
    int month = Integer.parseInt(req.getParameter("month"));
    List<Map<String,Object>> list = dao.salesMonthly(year, month);
    exportList(resp, format, "monthly-sales", List.of("date","bills","total"), list);
  }

  // controllers/ReportController.java  (replace handleCustomerConsumption)
private void handleCustomerConsumption(HttpServletRequest req, HttpServletResponse resp, String format) throws Exception {
  String account = req.getParameter("account"); // NEW: account number
  String cidStr  = req.getParameter("customerId"); // legacy fallback
  Date from = Date.valueOf(req.getParameter("from"));
  Date to   = Date.valueOf(req.getParameter("to"));

  List<Map<String,Object>> list;

  if (account != null && !account.isBlank()) {
    list = dao.customerConsumptionByAccount(account.trim(), from, to);
    exportList(resp, format, "customer-consumption",
        List.of("itemId","itemName","quantity","amount"), list);
  } else if (cidStr != null && !cidStr.isBlank()) {
    int customerId = Integer.parseInt(cidStr);
    list = dao.customerConsumption(customerId, from, to);
    exportList(resp, format, "customer-consumption",
        List.of("itemId","itemName","quantity","amount"), list);
  } else {
    resp.sendError(400, "Provide either 'account' or 'customerId' plus from/to dates");
  }
}


  // ---------- helpers ----------
  private void json(HttpServletResponse resp, Object o) throws IOException {
    resp.setContentType("application/json");
    try (PrintWriter out = resp.getWriter()) { out.print(toJson(o)); }
  }

  private String toJson(Object o) {
    // very tiny JSON (for demo). Use a real lib (Jackson/Gson) in production.
    if (o == null) return "null";
    if (o instanceof Map<?,?> m) {
      StringBuilder sb = new StringBuilder("{"); boolean first=true;
      for (var e: m.entrySet()) {
        if (!first) sb.append(',');
        sb.append('"').append(e.getKey()).append("\":").append(value(e.getValue()));
        first=false;
      }
      return sb.append('}').toString();
    } else if (o instanceof List<?> list) {
      StringBuilder sb = new StringBuilder("["); boolean first=true;
      for (var v: list) {
        if (!first) sb.append(',');
        sb.append(value(v)); first=false;
      }
      return sb.append(']').toString();
    } else return value(o);
  }
  private String value(Object v) {
    if (v==null) return "null";
    if (v instanceof Number || v instanceof Boolean) return v.toString();
    return "\"" + String.valueOf(v).replace("\"","\\\"") + "\"";
  }

  private void exportList(HttpServletResponse resp, String format, String name, List<String> headers, List<Map<String,Object>> rows) throws IOException {
    if ("csv".equalsIgnoreCase(format)) {
      resp.setContentType("text/csv");
      resp.setHeader("Content-Disposition","attachment; filename="+name+".csv");
      try (PrintWriter out = resp.getWriter()) {
        out.println(String.join(",", headers));
        for (var r: rows) {
          List<String> line = new ArrayList<>();
          for (String h: headers) line.add(String.valueOf(r.get(h)));
          out.println(String.join(",", line));
        }
      }
    } else if ("pdf".equalsIgnoreCase(format)) {
      resp.setContentType("application/pdf");
      resp.setHeader("Content-Disposition","inline; filename="+name+".pdf");
      PdfUtils.writeSimpleTable(resp.getOutputStream(), name, headers, rows);
    } else {
      json(resp, rows);
    }
  }
  
}


