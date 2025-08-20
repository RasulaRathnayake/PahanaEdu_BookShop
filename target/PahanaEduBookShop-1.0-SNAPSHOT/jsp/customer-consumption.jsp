<%-- 
    Document   : customer-consumption
    Created on : Aug 12, 2025, 7:21:09 AM
    Author     : ugdin
--%>

 
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%@ page import="models.User,dao.ReportDAO,java.util.*,java.math.BigDecimal" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }

  String base   = request.getContextPath();
  String acct   = request.getParameter("account"); // account number (string)
  String fromStr= request.getParameter("from");
  String toStr  = request.getParameter("to");

  List<Map<String,Object>> rows = Collections.emptyList();
  if (acct != null && !acct.isBlank() &&
      fromStr != null && !fromStr.isBlank() &&
      toStr   != null && !toStr.isBlank()) {
    try {
      java.sql.Date from = java.sql.Date.valueOf(fromStr);
      java.sql.Date to   = java.sql.Date.valueOf(toStr);
      ReportDAO rdao = new ReportDAO();
      rows = rdao.customerConsumptionByAccount(acct.trim(), from, to);
    } catch (Exception ex) { ex.printStackTrace(); }
  }
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Customer Consumption Reports</title></head>

<body>
  <h1>Customer Consumption Reports</h1>

  <form method="get" action="">
    <label>Account No:
      <input type="text" name="account" value="<%= (acct==null?"":acct) %>" required>
    </label>
    <label>From:
      <input type="date" name="from" value="<%= (fromStr==null?"":fromStr) %>" required>
    </label>
    <label>To:
      <input type="date" name="to" value="<%= (toStr==null?"":toStr) %>" required>
    </label>
    <button type="submit">Load</button>
  </form>

  <%
    if (acct != null && fromStr != null && toStr != null) {
      if (!rows.isEmpty()) {
        BigDecimal totalAmt = BigDecimal.ZERO;
        int totalQty = 0;
  %>
  <h3>Account: <%=acct%> | Period: <%=fromStr%> to <%=toStr%></h3>
  <table border="1" cellpadding="4">
    <tr><th>Item ID</th><th>Item Name</th><th>Quantity</th><th>Amount</th></tr>
    <%
      for (Map<String,Object> r : rows) {
        BigDecimal amt = (BigDecimal) r.get("amount");
        Integer qty    = (Integer) r.get("quantity");
        totalAmt = totalAmt.add(amt==null?BigDecimal.ZERO:amt);
        totalQty += (qty==null?0:qty);
    %>
      <tr>
        <td><%=r.get("itemId")%></td>
        <td><%=r.get("itemName")%></td>
        <td><%=r.get("quantity")%></td>
        <td><%=r.get("amount")%></td>
      </tr>
    <%
      } // for
    %>
    <tr>
      <td colspan="2" style="text-align:right;"><strong>Totals:</strong></td>
      <td><strong><%=totalQty%></strong></td>
      <td><strong><%=totalAmt%></strong></td>
    </tr>
  </table>

  <p>
    Export:
    <a href="<%=base%>/api/reports/customer/consumption?account=<%=acct%>&from=<%=fromStr%>&to=<%=toStr%>&format=csv" target="_blank">CSV</a> |
<!--    <a href="<%=base%>/api/reports/customer/consumption?account=<%=acct%>&from=<%=fromStr%>&to=<%=toStr%>&format=pdf" target="_blank">PDF</a>-->
  </p>
  <%
      } else {
  %>
    <p>No data for Account <strong><%=acct%></strong> in the selected period.</p>
  <%
      }
    }
  %>

  <p><a href="<%=base%>/jsp/reportMenu.jsp">Back</a></p>
</body>
</html>



