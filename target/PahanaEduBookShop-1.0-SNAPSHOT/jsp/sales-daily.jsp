<%-- 
    Document   : sales-daily
    Created on : Aug 14, 2025, 7:34:41 AM
    Author     : ugdin
--%>

<%-- admin/reports/sales-daily.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%@ page import="models.User,java.sql.*,java.math.BigDecimal,utils.DBconnection,dao.ReportDAO,java.util.*" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }

  String base = request.getContextPath();
  String dateStr = request.getParameter("date"); // YYYY-MM-DD

  Map<String,Object> dailySummary = Collections.emptyMap();
  List<Map<String,Object>> bills = new ArrayList<>();

  if (dateStr != null && !dateStr.isBlank()) {
    try {
      java.sql.Date d = java.sql.Date.valueOf(dateStr);

      // 1) Summary via ReportDAO
      ReportDAO rdao = new ReportDAO();
      dailySummary = rdao.salesDaily(d);

      // 2) Bills list for the day
      String qb = "SELECT bill_id, customer_id, subtotal, tax_rate, tax_amount, total, created_at " +
                  "FROM Bills WHERE DATE(created_at)=? ORDER BY created_at";
      try (Connection c = DBconnection.getConnection();
           PreparedStatement ps = c.prepareStatement(qb)) {
        ps.setDate(1, d);
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            Map<String,Object> m = new HashMap<>();
            m.put("bill_id", rs.getInt("bill_id"));
            m.put("customer_id", rs.getInt("customer_id"));
            m.put("subtotal", rs.getBigDecimal("subtotal"));
            m.put("tax_rate", rs.getBigDecimal("tax_rate"));
            m.put("tax_amount", rs.getBigDecimal("tax_amount"));
            m.put("total", rs.getBigDecimal("total"));
            m.put("created_at", rs.getTimestamp("created_at"));
            bills.add(m);
          }
        }
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Daily Sales Report</title></head>
 
<body>
  <h1>Daily Sales Report</h1>

  <form method="get" action="">
    <label>Date:
      <input type="date" name="date" value="<%= (dateStr==null?"":dateStr) %>" required>
    </label>
    <button type="submit">Load</button>
  </form>

  <%
    if (dateStr != null && !dateStr.isBlank()) {
  %>
  <h3>Summary (<%=dateStr%>)</h3>
  <table border="1" cellpadding="4">
    <tr><th>Date</th><th>Bills</th><th>Subtotal</th><th>Tax</th><th>Total</th></tr>
    <tr>
      <td><%= String.valueOf(dailySummary.getOrDefault("date","-")) %></td>
      <td><%= String.valueOf(dailySummary.getOrDefault("bills",0)) %></td>
      <td><%= String.valueOf(dailySummary.getOrDefault("subtotal",0)) %></td>
      <td><%= String.valueOf(dailySummary.getOrDefault("tax",0)) %></td>
      <td><%= String.valueOf(dailySummary.getOrDefault("total",0)) %></td>
    </tr>
  </table>

  <p>
    Export:
    <a href="<%=base%>/api/reports/sales/daily?date=<%=dateStr%>&format=csv" target="_blank">CSV</a> |
<!--    <a href="<%=base%>/api/reports/sales/daily?date=<%=dateStr%>&format=pdf" target="_blank">PDF</a>-->
  </p>

  <h3>Bills for <%=dateStr%></h3>
  <%
    if (bills.isEmpty()) {
  %>
    <p>No bills found for this date.</p>
  <%
    } else {
      BigDecimal grandSubtotal = BigDecimal.ZERO;
      BigDecimal grandTax = BigDecimal.ZERO;
      BigDecimal grandTotal = BigDecimal.ZERO;
  %>
  <table border="1" cellpadding="4">
    <tr>
      <th>#</th><th>Bill ID</th><th>Customer ID</th><th>Created At</th>
      <th>Subtotal</th><th>Tax %</th><th>Tax Amount</th><th>Total</th>
    </tr>
    <%
      int idx = 0;
      for (Map<String,Object> b : bills) {
        idx++;
        BigDecimal sub = (BigDecimal)b.get("subtotal");
        BigDecimal taxAmt = (BigDecimal)b.get("tax_amount");
        BigDecimal tot = (BigDecimal)b.get("total");
        BigDecimal taxRate = (BigDecimal)b.get("tax_rate");
        grandSubtotal = grandSubtotal.add(sub==null?BigDecimal.ZERO:sub);
        grandTax = grandTax.add(taxAmt==null?BigDecimal.ZERO:taxAmt);
        grandTotal = grandTotal.add(tot==null?BigDecimal.ZERO:tot);
    %>
      <tr>
        <td><%=idx%></td>
        <td><%=b.get("bill_id")%></td>
        <td><%=b.get("customer_id")%></td>
        <td><%=b.get("created_at")%></td>
        <td><%=sub%></td>
        <td><%=taxRate%></td>
        <td><%=taxAmt%></td>
        <td><%=tot%></td>
      </tr>
      <tr>
        <td></td>
        <td colspan="7">
          <strong>Items</strong>
          <table border="1" cellpadding="2" width="100%">
            <tr>
              <th>Item ID</th><th>Item Name</th><th>Unit Price</th><th>Qty</th><th>Line Total</th>
            </tr>
            <%
              // fetch items for this bill
              try (Connection c = DBconnection.getConnection();
                   PreparedStatement ps = c.prepareStatement(
                     "SELECT item_id,item_name,unit_price,quantity,line_total FROM BillItems WHERE bill_id=?"
                   )) {
                ps.setInt(1, (Integer)b.get("bill_id"));
                try (ResultSet rs = ps.executeQuery()) {
                  while (rs.next()) {
            %>
              <tr>
                <td><%=rs.getInt("item_id")%></td>
                <td><%=rs.getString("item_name")%></td>
                <td><%=rs.getBigDecimal("unit_price")%></td>
                <td><%=rs.getInt("quantity")%></td>
                <td><%=rs.getBigDecimal("line_total")%></td>
              </tr>
            <%
                  }
                }
              } catch (Exception iex) { iex.printStackTrace(); }
            %>
          </table>
        </td>
      </tr>
    <%
      } // end for bills
    %>
    <tr>
      <td colspan="4" style="text-align:right;"><strong>Totals:</strong></td>
      <td><strong><%=grandSubtotal%></strong></td>
      <td></td>
      <td><strong><%=grandTax%></strong></td>
      <td><strong><%=grandTotal%></strong></td>
    </tr>
  </table>
  <%
    } // end else bills not empty
  } // end if date provided
  %>
  <p><a href="<%=base%>/jsp/reportMenu.jsp">Back</a></p>
</body>
</html>
