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
<head><meta charset="UTF-8"><title>Customer Consumption Reports</title>
    <style>
        /* Customer Consumption Report Styles - Modern Animated Theme */

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
    content: '👤';
    font-size: 2.5rem;
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.1); }
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
    position: relative;
    overflow: hidden;
}

form::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(100, 181, 246, 0.1), transparent);
    animation: shimmer 3s ease-in-out infinite;
}

@keyframes shimmer {
    0% { left: -100%; }
    50% { left: 100%; }
    100% { left: 100%; }
}

form {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 2rem;
    align-items: end;
}

form label {
    color: #94a3b8;
    font-weight: 600;
    font-size: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    position: relative;
}

form label::before {
    font-family: 'Font Awesome 6 Free';
    font-weight: 900;
    color: #64b5f6;
    font-size: 1.1rem;
    position: absolute;
    top: 0;
    left: 0;
}

/*form label:has(input[name="account"])::before {
    content: '\f007';  user icon 
}

form label:has(input[name="from"])::before {
    content: '\f133';  calendar-check icon 
}

form label:has(input[name="to"])::before {
    content: '\f073';  calendar-days icon 
}*/

form input[type="text"],
form input[type="date"] {
    background: rgba(0, 0, 0, 0.4);
    border: 2px solid rgba(100, 181, 246, 0.2);
    border-radius: 12px;
    padding: 1rem 1.25rem;
    color: #e2e8f0;
    font-family: 'Poppins', sans-serif;
    font-size: 1.1rem;
    font-weight: 500;
    transition: all 0.3s ease;
    width: 100%;
}

form input[type="text"]:focus,
form input[type="date"]:focus {
    outline: none;
    border-color: #64b5f6;
    box-shadow: 0 0 0 4px rgba(100, 181, 246, 0.15);
    background: rgba(0, 0, 0, 0.6);
    transform: translateY(-2px);
}

/* Date input styling */
input[type="date"]::-webkit-calendar-picker-indicator {
    background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="15" viewBox="0 0 24 24"><path fill="%2364b5f6" d="M20 3h-1V1h-2v2H7V1H5v2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 18H4V8h16v13z"/></svg>');
    background-repeat: no-repeat;
    background-position: center;
    background-size: 16px;
    cursor: pointer;
    opacity: 0.7;
    transition: opacity 0.3s ease;
}

input[type="date"]::-webkit-calendar-picker-indicator:hover {
    opacity: 1;
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
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    grid-column: span 1;
    justify-self: center;
    min-width: 150px;
}

button[type="submit"]::before {
    content: '🔍';
    font-size: 1rem;
}

button[type="submit"]::after {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
    transition: left 0.5s;
}

button[type="submit"]:hover::after {
    left: 100%;
}

button[type="submit"]:hover {
    transform: translateY(-3px);
    box-shadow: 0 15px 40px rgba(100, 181, 246, 0.4);
}

button[type="submit"]:active {
    transform: translateY(-1px);
}

/* Report Header */
h3 {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    padding: 1.5rem 2rem;
    margin: 2rem 0 1rem 0;
    border: 1px solid rgba(255, 255, 255, 0.1);
    color: #64b5f6;
    font-weight: 600;
    font-size: 1.3rem;
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
    animation: slideUp 0.8s ease-out 0.3s both;
    position: relative;
}

h3::before {
    content: '📊';
    margin-right: 1rem;
    font-size: 1.5rem;
}

h3::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 2rem;
    right: 2rem;
    height: 2px;
    background: linear-gradient(90deg, #64b5f6, #42a5f5, #64b5f6);
    border-radius: 1px;
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
    border-collapse: separate;
    border-spacing: 0;
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

table[border="1"] th:first-child {
    border-top-left-radius: 16px;
}

table[border="1"] th:last-child {
    border-top-right-radius: 16px;
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

table[border="1"] tbody tr:nth-child(even) {
    background: rgba(255, 255, 255, 0.02);
}

/* Special styling for total row */
table[border="1"] tr:last-child {
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.15), rgba(66, 165, 245, 0.1)) !important;
    font-weight: 700;
    transform: none !important;
    position: relative;
}

table[border="1"] tr:last-child::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: linear-gradient(90deg, #64b5f6, #42a5f5, #64b5f6);
}

table[border="1"] tr:last-child td {
    color: #64b5f6 !important;
    border-top: 2px solid rgba(100, 181, 246, 0.4);
    padding: 1.5rem 1rem;
    font-size: 1.1rem;
    font-weight: 700;
}

table[border="1"] tr:last-child td:first-child,
table[border="1"] tr:last-child td:nth-child(2) {
    border-bottom-left-radius: 16px;
}

table[border="1"] tr:last-child td:last-child {
    border-bottom-right-radius: 16px;
}

/* Export Section */
p:has(a[href*="csv"]) {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    padding: 2rem;
    margin: 2rem 0;
    border: 1px solid rgba(255, 255, 255, 0.1);
    text-align: center;
    animation: slideUp 0.8s ease-out 0.6s both;
    position: relative;
}

p:has(a[href*="csv"])::before {
    content: '📤 Export Options:';
    display: block;
    color: #94a3b8;
    font-weight: 600;
    margin-bottom: 1rem;
    font-size: 1.1rem;
}

p a[href*="csv"] {
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
    position: relative;
    overflow: hidden;
}

p a[href*="csv"]::before {
    content: '📊';
    font-size: 1rem;
}

p a[href*="csv"]::after {
    content: '→';
    font-weight: bold;
    opacity: 0;
    transform: translateX(-10px);
    transition: all 0.3s ease;
}

p a[href*="csv"]:hover {
    background: rgba(100, 181, 246, 0.2);
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(100, 181, 246, 0.25);
    border-color: rgba(100, 181, 246, 0.4);
}

p a[href*="csv"]:hover::after {
    opacity: 1;
    transform: translateX(0);
}

/* Back Button */
p:has(a[href*="reportMenu"]) {
    text-align: center;
    margin-top: 3rem;
    animation: slideUp 0.8s ease-out 0.7s both;
}

p a[href*="reportMenu"] {
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.15), rgba(66, 165, 245, 0.1));
    border: 2px solid rgba(100, 181, 246, 0.4);
    color: #64b5f6;
    text-decoration: none;
    font-weight: 600;
    padding: 1rem 2rem;
    border-radius: 12px;
    font-size: 1.1rem;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 0.75rem;
    box-shadow: 0 4px 15px rgba(100, 181, 246, 0.2);
}

p a[href*="reportMenu"]::before {
    content: '← ';
    font-weight: bold;
    font-size: 1.2rem;
    transition: transform 0.3s ease;
}

p a[href*="reportMenu"]:hover {
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.25), rgba(66, 165, 245, 0.15));
    border-color: rgba(100, 181, 246, 0.6);
    transform: translateY(-3px);
    box-shadow: 0 8px 30px rgba(100, 181, 246, 0.3);
}

p a[href*="reportMenu"]:hover::before {
    transform: translateX(-4px);
}

/* No Data Message */
p:not(:has(a)):not([class]) {
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
    position: relative;
}

p:not(:has(a)):not([class])::before {
    content: '📊';
    display: block;
    font-size: 3rem;
    margin-bottom: 1rem;
    opacity: 0.5;
    animation: pulse 2s ease-in-out infinite;
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
        grid-template-columns: 1fr;
        gap: 1.5rem;
    }

    button[type="submit"] {
        width: 100%;
        justify-self: stretch;
    }

    h3 {
        padding: 1.25rem 1.5rem;
        font-size: 1.1rem;
        text-align: center;
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

    h3 {
        padding: 1rem;
        font-size: 1rem;
    }

    table[border="1"] th,
    table[border="1"] td {
        padding: 0.75rem 0.5rem;
        font-size: 0.8rem;
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
        background: white !important;
        color: black !important;
    }
    
    body::before {
        display: none !important;
    }
    
    form,
    p:has(a[href*="csv"]),
    p:has(a[href*="reportMenu"]) {
        display: none !important;
    }
    
    table[border="1"],
    h3 {
        background: white !important;
        color: black !important;
        box-shadow: none !important;
        border: 1px solid #ccc !important;
    }
    
    table[border="1"] th {
        background: #f5f5f5 !important;
        color: #333 !important;
    }
}
    </style>
</head>

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



