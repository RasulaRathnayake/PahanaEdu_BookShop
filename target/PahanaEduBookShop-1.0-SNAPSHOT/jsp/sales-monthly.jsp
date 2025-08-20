<%-- 
    Document   : sales-monthly
    Created on : Aug 14, 2025, 7:35:20 AM
    Author     : ugdin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%@ page import="models.User,dao.ReportDAO,java.util.*,java.math.BigDecimal" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }

  String base = request.getContextPath();
  String yearStr = request.getParameter("year");
  String monthStr = request.getParameter("month");

  List<Map<String,Object>> rows = Collections.emptyList();
  if (yearStr != null && monthStr != null && !yearStr.isBlank() && !monthStr.isBlank()) {
    try {
      int y = Integer.parseInt(yearStr);
      int m = Integer.parseInt(monthStr);
      ReportDAO rdao = new ReportDAO();
      rows = rdao.salesMonthly(y, m);
    } catch (Exception ex) { ex.printStackTrace(); }
  }
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Monthly Sales Report</title></head>
 
<body>
  <h1>Monthly Sales Report</h1>

  <form method="get" action="">
    <label>Year:
      <input type="number" name="year" min="2000" max="2100" value="<%= (yearStr==null?"":yearStr) %>" required>
    </label>
    <label>Month:
      <input type="number" name="month" min="1" max="12" value="<%= (monthStr==null?"":monthStr) %>" required>
    </label>
    <button type="submit">Load</button>
  </form>

  <%
    if (!rows.isEmpty()) {
      BigDecimal totalAll = BigDecimal.ZERO;
  %>
  <table border="1" cellpadding="4">
    <tr><th>Date</th><th># Bills</th><th>Total</th><th>Actions</th></tr>
    <%
      for (Map<String,Object> r : rows) {
        BigDecimal t = (BigDecimal) r.get("total");
        totalAll = totalAll.add(t==null?BigDecimal.ZERO:t);
    %>
      <tr>
        <td><%=r.get("date")%></td>
        <td><%=r.get("bills")%></td>
        <td><%=r.get("total")%></td>
        <td>
          <a href="<%=base%>/jsp/sales-daily.jsp?date=<%=r.get("date")%>" target="_blank">View bills</a>
        </td>
      </tr>
    <%
      }
    %>
    <tr>
      <td colspan="2" style="text-align:right;"><strong>Monthly Total:</strong></td>
      <td colspan="2"><strong><%=totalAll%></strong></td>
    </tr>
  </table>

  <p>
    Export:
    <a href="<%=base%>/api/reports/sales/monthly?year=<%=yearStr%>&month=<%=monthStr%>&format=csv" target="_blank">CSV</a> |
<!--    <a href="<%=base%>/api/reports/sales/monthly?year=<%=yearStr%>&month=<%=monthStr%>&format=pdf" target="_blank">PDF</a>-->
  </p>
  <%
    } else if (yearStr != null && monthStr != null) {
  %>
    <p>No data for the selected month.</p>
  <%
    }
  %>

  <p><a href="<%=base%>/jsp/reportMenu.jsp">Back</a></p>
</body>
</html>

