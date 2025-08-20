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
    max-width: 1400px;
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
.header {
    text-align: center;
    margin-bottom: 2rem;
    animation: slideDown 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

.header h1 {
    font-size: 2.5rem;
    font-weight: 700;
    background: linear-gradient(135deg, #64b5f6, #42a5f5, #a855f7);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    margin-bottom: 0.5rem;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 1rem;
}

.header h1 i {
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

/* Form Card */
.form-card {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 20px;
    padding: 2rem;
    margin-bottom: 2rem;
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(255, 255, 255, 0.1);
    animation: slideUp 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) 0.2s both;
}

.form-group {
    display: flex;
    align-items: center;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
}

.form-group label {
    color: #94a3b8;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.form-group input[type="date"] {
    background: rgba(0, 0, 0, 0.3);
    border: 2px solid rgba(100, 181, 246, 0.2);
    border-radius: 12px;
    padding: 0.75rem 1rem;
    color: #e2e8f0;
    font-family: 'Poppins', sans-serif;
    font-size: 1rem;
    transition: all 0.3s ease;
    min-width: 200px;
}

.form-group input[type="date"]:focus {
    outline: none;
    border-color: #64b5f6;
    box-shadow: 0 0 0 3px rgba(100, 181, 246, 0.2);
}

.load-btn, button[type="submit"] {
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    color: white;
    border: none;
    padding: 0.75rem 2rem;
    border-radius: 12px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 0.5rem;
    box-shadow: 0 8px 25px rgba(100, 181, 246, 0.3);
    font-family: 'Poppins', sans-serif;
    font-size: 1rem;
}

.load-btn:hover, button[type="submit"]:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 35px rgba(100, 181, 246, 0.4);
}

/* Summary Cards */
.summary-section {
    margin-bottom: 2rem;
}

.summary-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1.5rem;
    margin-bottom: 1.5rem;
}

.summary-card {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    padding: 1.5rem;
    border: 1px solid rgba(255, 255, 255, 0.1);
    transition: all 0.3s ease;
    animation: slideUp 0.6s ease-out both;
}

.summary-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
    border-color: rgba(100, 181, 246, 0.3);
}

.summary-card h3 {
    color: #94a3b8;
    font-size: 0.9rem;
    font-weight: 500;
    margin-bottom: 0.5rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.summary-card .value {
    font-size: 1.8rem;
    font-weight: 700;
    color: #64b5f6;
}

.summary-card .icon {
    float: right;
    font-size: 2rem;
    opacity: 0.3;
}

/* Export Section */
.export-section {
    text-align: center;
    margin: 2rem 0;
}

.export-links {
    display: flex;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
}

.export-btn {
    background: rgba(100, 181, 246, 0.1);
    border: 1px solid rgba(100, 181, 246, 0.3);
    color: #64b5f6;
    padding: 0.75rem 1.5rem;
    border-radius: 12px;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.export-btn:hover {
    background: rgba(100, 181, 246, 0.2);
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(100, 181, 246, 0.2);
}

/* Bills Section */
.bills-section {
    margin-top: 2rem;
}

.section-title {
    font-size: 1.5rem;
    font-weight: 600;
    color: #e2e8f0;
    margin-bottom: 1.5rem;
    display: flex;
    align-items: center;
    gap: 0.75rem;
}

.section-title i {
    color: #64b5f6;
}

/* Table Styles */
.table-container {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
    animation: slideUp 0.8s ease-out 0.4s both;
}

.data-table, table {
    width: 100%;
    border-collapse: collapse;
}

.data-table th, table th {
    background: rgba(0, 0, 0, 0.4);
    color: #64b5f6;
    font-weight: 600;
    padding: 1rem;
    text-align: left;
    border-bottom: 2px solid rgba(100, 181, 246, 0.2);
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border: none;
}

.data-table td, table td {
    padding: 1rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    color: #e2e8f0;
    border: none;
}

.data-table tr, table tr {
    transition: all 0.3s ease;
}

.data-table tbody tr:hover, table tbody tr:hover {
    background: rgba(100, 181, 246, 0.05);
    transform: scale(1.01);
}

.bill-row {
    position: relative;
}

.bill-row.expanded {
    background: rgba(100, 181, 246, 0.02);
}

/* Items Table */
.items-table {
    width: 100%;
    margin-top: 0.5rem;
    background: rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    overflow: hidden;
}

.items-table th {
    background: rgba(0, 0, 0, 0.4);
    color: #94a3b8;
    font-weight: 500;
    padding: 0.75rem;
    font-size: 0.8rem;
}

.items-table td {
    padding: 0.75rem;
    font-size: 0.9rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.03);
}

/* Totals Row */
.totals-row {
    background: rgba(100, 181, 246, 0.1) !important;
    font-weight: 600;
}

.totals-row td {
    color: #64b5f6 !important;
    border-top: 2px solid rgba(100, 181, 246, 0.3);
}

/* No Data Message */
.no-data {
    text-align: center;
    padding: 3rem;
    color: #94a3b8;
    font-size: 1.1rem;
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.1);
}

.no-data i {
    font-size: 3rem;
    margin-bottom: 1rem;
    opacity: 0.3;
}

/* Back Button */
.back-btn, p a {
    background: rgba(100, 181, 246, 0.1);
    border: 1px solid rgba(100, 181, 246, 0.3);
    color: #64b5f6;
    padding: 0.75rem 1.5rem;
    border-radius: 12px;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    margin-top: 2rem;
}

.back-btn:hover, p a:hover {
    background: rgba(100, 181, 246, 0.2);
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(100, 181, 246, 0.2);
}

/* Generic styling for existing tables */
table[border="1"] {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
    margin: 1rem 0;
}

table[border="1"] th {
    background: rgba(0, 0, 0, 0.4);
    color: #64b5f6;
    font-weight: 600;
    padding: 1rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-size: 0.9rem;
}

table[border="1"] td {
    padding: 0.75rem 1rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

table[border="1"] tr:hover {
    background: rgba(100, 181, 246, 0.05);
}

/* Form styling */
form {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    padding: 2rem;
    margin-bottom: 2rem;
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.3);
}

form label {
    color: #94a3b8;
    font-weight: 500;
    margin-right: 1rem;
}

form input[type="date"] {
    background: rgba(0, 0, 0, 0.3);
    border: 2px solid rgba(100, 181, 246, 0.2);
    border-radius: 8px;
    padding: 0.75rem;
    color: #e2e8f0;
    margin-right: 1rem;
    font-family: 'Poppins', sans-serif;
}

form input[type="date"]:focus {
    outline: none;
    border-color: #64b5f6;
    box-shadow: 0 0 0 3px rgba(100, 181, 246, 0.2);
}

/* Headers */
h1 {
    font-size: 2.5rem;
    font-weight: 700;
    background: linear-gradient(135deg, #64b5f6, #42a5f5, #a855f7);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    text-align: center;
    margin-bottom: 2rem;
}

h3 {
    color: #64b5f6;
    font-weight: 600;
    margin: 2rem 0 1rem 0;
    font-size: 1.5rem;
}

/* Paragraph styling */
p {
    margin: 1rem 0;
    color: #94a3b8;
    line-height: 1.6;
}

/* Animations */
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

/* Expandable Items */
.expand-btn {
    background: none;
    border: none;
    color: #64b5f6;
    cursor: pointer;
    font-size: 1rem;
    transition: transform 0.3s ease;
    padding: 0.5rem;
    border-radius: 50%;
}

.expand-btn:hover {
    color: #42a5f5;
    background: rgba(100, 181, 246, 0.1);
}

.expand-btn.expanded {
    transform: rotate(90deg);
}

.items-container {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease;
}

.items-container.expanded {
    max-height: 500px;
}

/* Responsive Design */
@media (max-width: 768px) {
    body {
        padding: 1rem 0.5rem;
    }

    h1, .header h1 {
        font-size: 2rem;
    }

    .form-card, form {
        padding: 1.5rem;
    }

    .form-group {
        flex-direction: column;
        align-items: stretch;
        gap: 1rem;
    }

    .form-group input[type="date"] {
        min-width: auto;
        margin-right: 0;
        margin-bottom: 1rem;
    }

    .summary-cards {
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
        gap: 1rem;
    }

    .data-table, table {
        font-size: 0.8rem;
    }

    .data-table th, .data-table td, table th, table td {
        padding: 0.75rem 0.5rem;
    }

    .table-container {
        overflow-x: auto;
    }

    .export-links {
        flex-direction: column;
        align-items: center;
    }
}

@media (max-width: 480px) {
    h1, .header h1 {
        font-size: 1.5rem;
    }

    .summary-cards {
        grid-template-columns: 1fr;
    }
    
    .data-table th, .data-table td, table th, table td {
        padding: 0.5rem 0.25rem;
        font-size: 0.7rem;
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

/* Focus states for accessibility */
input:focus-visible,
button:focus-visible,
a:focus-visible {
    outline: 2px solid #64b5f6;
    outline-offset: 2px;
}
</style>
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
