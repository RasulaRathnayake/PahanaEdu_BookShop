<%-- 
    Document   : reportMenu
    Created on : Aug 13, 2025, 10:03:21 PM
    Author     : ugdin
--%>


<%-- admin/reports/reportMenu.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%@ page import="models.User" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }
  String base = request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reports - Admin</title>

</head>
<body>
    <div class="container">
        <h1>Reports Dashboard</h1>
        

        <div class="tree-container">
            <ul class="tree">
                <li>
                    <div class="tree-node category-node">
                        <span class="tree-node-icon">📈</span>
                        <span class="tree-node-text">Sales Reports</span>
                    </div>
                    <ul>
                        <li>
                            <a href="<%=base%>/jsp/sales-daily.jsp" class="tree-node">
                                <span class="tree-node-icon">📅</span>
                                <span class="tree-node-text">Daily Sales Report</span>
                                <span class="tree-node-arrow">→</span>
                            </a>
                        </li>
                        <li>
                            <a href="<%=base%>/jsp/sales-monthly.jsp" class="tree-node">
                                <span class="tree-node-icon">🗓️</span>
                                <span class="tree-node-text">Monthly Sales Report</span>
                                <span class="tree-node-arrow">→</span>
                            </a>
                        </li>
                    </ul>
                </li>
                <li>
                    <div class="tree-node category-node">
                        <span class="tree-node-icon">👥</span>
                        <span class="tree-node-text">Customer Reports</span>
                    </div>
                    <ul>
                        <li>
                            <a href="<%=base%>/jsp/customer-consumption.jsp" class="tree-node">
                                <span class="tree-node-icon">🔋</span>
                                <span class="tree-node-text">Customer Consumption Report</span>
                                <span class="tree-node-arrow">→</span>
                            </a>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</body>
</html>