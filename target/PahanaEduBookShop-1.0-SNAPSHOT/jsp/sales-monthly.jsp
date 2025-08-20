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
<head><meta charset="UTF-8"><title>Monthly Sales Report</title>

    <style>
        /* Reset and base styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Poppins', sans-serif;
    background: linear-gradient(45deg, #1a1a2e, #16213e, #0f3460, #1a1a2e);
    background-size: 400% 400%;
    animation: gradientShift 15s ease infinite;
    min-height: 100vh;
    color: #e2e8f0;
    overflow-x: hidden;
    padding: 2rem 1rem;
}

@keyframes gradientShift {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
}

/* Animated background elements */
body::before {
    content: '';
    position: fixed;
    width: 200%;
    height: 200%;
    background-image: 
        radial-gradient(circle at 25% 25%, rgba(100, 181, 246, 0.05) 0%, transparent 25%),
        radial-gradient(circle at 75% 75%, rgba(168, 85, 247, 0.05) 0%, transparent 25%);
    animation: float 20s ease-in-out infinite;
    z-index: -1;
    pointer-events: none;
}

@keyframes float {
    0%, 100% { transform: translate(-50%, -50%) rotate(0deg); }
    50% { transform: translate(-60%, -40%) rotate(180deg); }
}

/* Container */
.container {
    max-width: 1200px;
    margin: 0 auto;
    animation: fadeIn 0.8s ease-out;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* Header */
h1 {
    font-size: 2.8rem;
    font-weight: 700;
    background: linear-gradient(135deg, #64b5f6, #42a5f5, #a855f7);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    text-align: center;
    margin-bottom: 2rem;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    animation: slideDown 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

h1::before {
    content: '📊';
    font-size: 2.5rem;
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

@keyframes slideDown {
    from {
        opacity: 0;
        transform: translateY(-30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* Form Styling */
form {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 20px;
    padding: 2.5rem;
    margin-bottom: 2rem;
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(255, 255, 255, 0.1);
    animation: slideUp 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) 0.2s both;
}

.form-group {
    display: flex;
    align-items: center;
    gap: 1.5rem;
    justify-content: center;
    flex-wrap: wrap;
    margin-bottom: 1.5rem;
}

form label {
    color: #94a3b8;
    font-weight: 600;
    font-size: 1rem;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    min-width: 120px;
}

form label::before {
    font-family: 'Font Awesome 6 Free';
    font-weight: 900;
    color: #64b5f6;
    font-size: 1.1rem;
}

form label:first-of-type::before {
    content: '\f133'; /* calendar icon */
}

form label:last-of-type::before {
    content: '\f073'; /* calendar-days icon */
}

form input[type="number"] {
    background: rgba(0, 0, 0, 0.4);
    border: 2px solid rgba(100, 181, 246, 0.2);
    border-radius: 12px;
    padding: 1rem 1.25rem;
    color: #e2e8f0;
    font-family: 'Poppins', sans-serif;
    font-size: 1.1rem;
    font-weight: 500;
    transition: all 0.3s ease;
    min-width: 150px;
    text-align: center;
}

form input[type="number"]:focus {
    outline: none;
    border-color: #64b5f6;
    box-shadow: 0 0 0 4px rgba(100, 181, 246, 0.15);
    background: rgba(0, 0, 0, 0.6);
}

form input[type="number"]::-webkit-outer-spin-button,
form input[type="number"]::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

form input[type="number"] {
    -moz-appearance: textfield;
}

button[type="submit"] {
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    color: white;
    border: none;
    padding: 1rem 2.5rem;
    border-radius: 12px;
    font-weight: 600;
    font-size: 1.1rem;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 8px 25px rgba(100, 181, 246, 0.3);
    font-family: 'Poppins', sans-serif;
    position: relative;
    overflow: hidden;
}

button[type="submit"]::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
    transition: left 0.5s;
}

button[type="submit"]:hover::before {
    left: 100%;
}

button[type="submit"]:hover {
    transform: translateY(-3px);
    box-shadow: 0 15px 40px rgba(100, 181, 246, 0.4);
}

button[type="submit"]:active {
    transform: translateY(-1px);
}

/* Table Styling */
table[border="1"] {
    width: 100%;
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 255, 255, 0.1);
    margin: 2rem 0;
    animation: slideUp 0.8s ease-out 0.4s both;
}

table[border="1"] th {
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.2), rgba(66, 165, 245, 0.1));
    color: #64b5f6;
    font-weight: 700;
    padding: 1.5rem 1rem;
    text-align: left;
    border-bottom: 2px solid rgba(100, 181, 246, 0.3);
    font-size: 1rem;
    text-transform: uppercase;
    letter-spacing: 1px;
    position: relative;
}

table[border="1"] th::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: linear-gradient(90deg, #64b5f6, #42a5f5, #64b5f6);
}

table[border="1"] td {
    padding: 1.25rem 1rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    color: #e2e8f0;
    font-weight: 500;
    font-size: 1rem;
    transition: all 0.3s ease;
}

table[border="1"] tbody tr {
    transition: all 0.3s ease;
    position: relative;
}

table[border="1"] tbody tr::before {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 4px;
    background: transparent;
    transition: background 0.3s ease;
}

table[border="1"] tbody tr:hover {
    background: rgba(100, 181, 246, 0.08);
    transform: translateX(8px);
}

table[border="1"] tbody tr:hover::before {
    background: linear-gradient(180deg, #64b5f6, #42a5f5);
}

/* Special styling for total row */
table[border="1"] tr:last-child {
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.15), rgba(66, 165, 245, 0.1)) !important;
    font-weight: 700;
    transform: none !important;
}

table[border="1"] tr:last-child td {
    color: #64b5f6 !important;
    border-top: 2px solid rgba(100, 181, 246, 0.4);
    padding: 1.5rem 1rem;
    font-size: 1.1rem;
}

/* Links in table */
table[border="1"] a {
    color: #64b5f6;
    text-decoration: none;
    font-weight: 600;
    padding: 0.5rem 1rem;
    border-radius: 8px;
    background: rgba(100, 181, 246, 0.1);
    border: 1px solid rgba(100, 181, 246, 0.2);
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
}

table[border="1"] a::after {
    content: '→';
    font-weight: bold;
    opacity: 0;
    transform: translateX(-10px);
    transition: all 0.3s ease;
}

table[border="1"] a:hover {
    background: rgba(100, 181, 246, 0.2);
    border-color: rgba(100, 181, 246, 0.4);
    transform: translateX(4px);
    box-shadow: 0 4px 15px rgba(100, 181, 246, 0.2);
}

table[border="1"] a:hover::after {
    opacity: 1;
    transform: translateX(0);
}

/* Export Section */
.export-section {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    padding: 2rem;
    margin: 2rem 0;
    border: 1px solid rgba(255, 255, 255, 0.1);
    text-align: center;
    animation: slideUp 0.8s ease-out 0.6s both;
}

.export-section p {
    color: #94a3b8;
    font-weight: 600;
    margin-bottom: 1rem;
    font-size: 1.1rem;
}

.export-section p::before {
    content: '📤 ';
    margin-right: 0.5rem;
}

p a {
    color: #64b5f6;
    text-decoration: none;
    font-weight: 600;
    padding: 0.75rem 1.5rem;
    margin: 0 0.5rem;
    border-radius: 12px;
    background: rgba(100, 181, 246, 0.1);
    border: 1px solid rgba(100, 181, 246, 0.3);
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
}

p a:hover {
    background: rgba(100, 181, 246, 0.2);
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(100, 181, 246, 0.25);
}

/* Back Button */
p a[href*="reportMenu"] {
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.15), rgba(66, 165, 245, 0.1));
    border-color: rgba(100, 181, 246, 0.4);
    margin-top: 2rem;
    display: inline-flex;
    padding: 1rem 2rem;
    font-size: 1.1rem;
}

p a[href*="reportMenu"]::before {
    content: '← ';
    font-weight: bold;
    margin-right: 0.5rem;
}

p a[href*="reportMenu"]:hover {
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.25), rgba(66, 165, 245, 0.15));
    border-color: rgba(100, 181, 246, 0.6);
}

/* No Data Message */
p:not([class]):not(:last-child) {
    text-align: center;
    padding: 3rem;
    color: #94a3b8;
    font-size: 1.2rem;
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    margin: 2rem 0;
    animation: slideUp 0.8s ease-out 0.4s both;
}

p:not([class]):not(:last-child)::before {
    content: '📊';
    display: block;
    font-size: 3rem;
    margin-bottom: 1rem;
    opacity: 0.5;
}

/* Loading State */
.loading {
    position: relative;
}

.loading::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 40px;
    height: 40px;
    border: 3px solid rgba(100, 181, 246, 0.3);
    border-top-color: #64b5f6;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: translate(-50%, -50%) rotate(0deg); }
    100% { transform: translate(-50%, -50%) rotate(360deg); }
}

/* Animations */
@keyframes slideUp {
    from {
        opacity: 0;
        transform: translateY(30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* Hover effects for interactive elements */
*:focus-visible {
    outline: 2px solid #64b5f6;
    outline-offset: 2px;
    border-radius: 4px;
}

/* Responsive Design */
@media (max-width: 768px) {
    body {
        padding: 1rem 0.5rem;
    }

    h1 {
        font-size: 2.2rem;
        flex-direction: column;
        gap: 0.5rem;
    }

    form {
        padding: 2rem 1.5rem;
    }

    .form-group {
        flex-direction: column;
        gap: 1rem;
        align-items: stretch;
    }

    form label {
        justify-content: center;
        min-width: auto;
    }

    form input[type="number"] {
        min-width: auto;
        width: 100%;
    }

    button[type="submit"] {
        width: 100%;
        padding: 1.25rem;
    }

    table[border="1"] {
        font-size: 0.9rem;
        overflow-x: auto;
        display: block;
        white-space: nowrap;
    }

    table[border="1"] th,
    table[border="1"] td {
        padding: 1rem 0.75rem;
    }

    table[border="1"] a {
        padding: 0.4rem 0.8rem;
        font-size: 0.9rem;
    }

    p a {
        display: block;
        margin: 0.5rem 0;
        text-align: center;
    }
}

@media (max-width: 480px) {
    h1 {
        font-size: 1.8rem;
    }

    form {
        padding: 1.5rem 1rem;
    }

    table[border="1"] th,
    table[border="1"] td {
        padding: 0.75rem 0.5rem;
        font-size: 0.8rem;
    }

    .export-section {
        padding: 1.5rem;
    }
}

/* Custom Scrollbar */
::-webkit-scrollbar {
    width: 8px;
    height: 8px;
}

::-webkit-scrollbar-track {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 4px;
}

::-webkit-scrollbar-thumb {
    background: rgba(100, 181, 246, 0.3);
    border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
    background: rgba(100, 181, 246, 0.5);
}

/* Print Styles */
@media print {
    body {
        background: white;
        color: black;
    }
    
    body::before {
        display: none;
    }
    
    .export-section,
    p a[href*="reportMenu"] {
        display: none;
    }
}
    </style>
</head>
 
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

