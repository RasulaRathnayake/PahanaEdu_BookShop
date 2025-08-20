<%-- 
    Document   : billing-history
    Created on : Aug 11, 2025, 4:27:06 PM
    Author     : ugdin
--%>

<%@page import="models.Bills"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="models.User,dao.BillingDAO,dao.CustomerDAO,models.Bills,models.Customer,java.util.*" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || (!"CASHIER".equals(u.getRole()) && !"ADMIN".equals(u.getRole()))) { response.sendRedirect("../login.jsp"); return; }

  String account = request.getParameter("account");
  List<Bills> bills = java.util.Collections.emptyList();
  Customer customer = null;
  if (account != null && !account.isBlank()) {
      try {
          CustomerDAO cdao = new CustomerDAO();
          customer = cdao.getCustomerByAccount(account);
          if (customer != null) {
              BillingDAO bdao = new BillingDAO();
              bills = bdao.getBillsByCustomer(customer.getCustomerId());
          }
      } catch (Exception e) {
          e.printStackTrace(); // or log it; optionally show a friendly message
      }
  }
%>
<!DOCTYPE html>
<html>
<head><title>Billing History (Admin)</title>
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
    overflow-x: hidden;
    color: #e2e8f0;
    line-height: 1.6;
    padding: 2rem;
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
/* Continue from where your CSS was cut off */
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
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(100, 181, 246, 0.4);
}

button[type="submit"]:active {
    transform: translateY(0);
}

/* Customer info header */
h3 {
    font-size: 1.6rem;
    font-weight: 600;
    color: #e2e8f0;
    margin-bottom: 2rem;
    padding: 1.5rem 2rem;
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 20px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.3);
    animation: slideUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) 0.4s both;
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.1), rgba(168, 85, 247, 0.1));
    border-left: 4px solid #64b5f6;
}

/* Table styles */
table {
    width: 100%;
    border-collapse: collapse;
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 20px;
    overflow: hidden;
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
    animation: slideUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) 0.6s both;
    margin-bottom: 2rem;
}

/* Remove default table borders */
table[border],
table[cellpadding] {
    border: none !important;
}

thead {
    background: rgba(0, 0, 0, 0.4);
}

th {
    padding: 1.5rem 1.5rem;
    text-align: left;
    font-weight: 600;
    color: #94a3b8;
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    position: relative;
    border: none;
}

th::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: linear-gradient(90deg, transparent, #64b5f6, transparent);
    opacity: 0.3;
}

td {
    padding: 1.25rem 1.5rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    color: #e2e8f0;
    transition: all 0.3s ease;
    border: none;
}

tbody tr {
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
}

tbody tr:hover {
    background: rgba(100, 181, 246, 0.08);
    transform: translateX(6px);
}

tbody tr:hover::before {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 4px;
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    border-radius: 0 2px 2px 0;
}

/* Special styling for monetary values */
td:nth-child(3), td:nth-child(4), td:nth-child(5) {
    font-family: 'Monaco', 'Consolas', monospace;
    font-weight: 500;
}

/* Bold total amount */
td b {
    color: #64b5f6;
    font-size: 1.1em;
}

/* Tax display styling */
td:nth-child(4) {
    font-size: 0.9em;
    line-height: 1.4;
}

/* Invoice button in table */
td form {
    background: transparent !important;
    border: none !important;
    box-shadow: none !important;
    padding: 0 !important;
    margin: 0 !important;
    animation: none !important;
    display: inline-block !important;
    backdrop-filter: none !important;
    border-radius: 0 !important;
    overflow: visible !important;
    flex-wrap: nowrap !important;
    gap: 0 !important;
}

td form::before {
    display: none !important;
}

td button {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
    color: #e2e8f0;
    padding: 0.6rem 1.2rem;
    border-radius: 10px;
    cursor: pointer;
    font-weight: 500;
    font-size: 0.85rem;
    font-family: inherit;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    backdrop-filter: blur(10px);
    position: relative;
    overflow: hidden;
    text-transform: none;
    letter-spacing: normal;
    border-color: rgba(100, 181, 246, 0.3);
    color: #64b5f6;
}

td button::before {
    display: none;
}

td button:hover {
    background: rgba(100, 181, 246, 0.15);
    border-color: #64b5f6;
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(100, 181, 246, 0.2);
}

/* No customer found message */
p {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    padding: 2rem;
    margin: 2rem 0;
    border: 1px solid rgba(245, 101, 101, 0.3);
    color: #f56565;
    text-align: center;
    font-size: 1.1rem;
    font-weight: 500;
    animation: slideUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) 0.4s both;
    background: linear-gradient(135deg, rgba(245, 101, 101, 0.1), rgba(239, 68, 68, 0.1));
    border-left: 4px solid #f56565;
}

/* Responsive design */
@media (max-width: 768px) {
    body {
        padding: 1rem;
    }

    h2 {
        font-size: 2rem;
        margin-bottom: 2rem;
    }

    form {
        padding: 1.5rem;
        border-radius: 16px;
        flex-direction: column;
        align-items: stretch;
        gap: 1rem;
    }

    input[name="account"] {
        min-width: auto;
        width: 100%;
    }

    button[type="submit"] {
        width: 100%;
        padding: 1.25rem;
    }

    h3 {
        padding: 1rem;
        font-size: 1.4rem;
        border-radius: 16px;
    }

    table {
        border-radius: 16px;
        font-size: 0.9rem;
        display: block;
        overflow-x: auto;
        white-space: nowrap;
    }

    th, td {
        padding: 1rem 0.75rem;
        font-size: 0.85rem;
    }

    /* Mobile table transformation */
    thead, tbody, th, td, tr {
        display: block;
    }

    thead tr {
        position: absolute;
        top: -9999px;
        left: -9999px;
    }

    tr {
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 12px;
        margin-bottom: 1.5rem;
        padding: 1rem;
        background: rgba(0, 0, 0, 0.2);
        display: block;
        white-space: normal;
    }

    td {
        border: none;
        position: relative;
        padding: 0.75rem 0;
        padding-left: 45%;
        display: block;
        text-align: right;
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    }

    td:last-child {
        border-bottom: none;
    }

    td::before {
        content: attr(data-label);
        position: absolute;
        left: 0;
        width: 40%;
        padding-right: 10px;
        white-space: nowrap;
        font-weight: 600;
        color: #94a3b8;
        text-transform: uppercase;
        font-size: 0.75rem;
        letter-spacing: 0.5px;
        text-align: left;
        padding-top: 0.25rem;
    }

    /* Mobile data labels */
    td:nth-child(1)::before { content: "Bill #"; }
    td:nth-child(2)::before { content: "Date"; }
    td:nth-child(3)::before { content: "Subtotal"; }
    td:nth-child(4)::before { content: "Tax"; }
    td:nth-child(5)::before { content: "Total"; }
    td:nth-child(6)::before { content: "Invoice"; }

    td:nth-child(6) {
        padding-left: 0;
        text-align: center;
    }

    p {
        padding: 1.5rem;
        font-size: 1rem;
    }
}

@media (max-width: 480px) {
    body {
        padding: 0.5rem;
    }

    h2 {
        font-size: 1.6rem;
    }

    form {
        padding: 1rem;
    }

    h3 {
        font-size: 1.2rem;
        padding: 1rem;
    }

    input[name="account"] {
        padding: 0.875rem 1rem;
        font-size: 0.9rem;
    }

    button[type="submit"] {
        padding: 1rem 1.5rem;
        font-size: 0.9rem;
    }

    td {
        padding-left: 50%;
    }

    td::before {
        width: 45%;
    }
}

/* Custom scrollbar */
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
button:focus-visible {
    outline: 2px solid #64b5f6;
    outline-offset: 2px;
}

/* Animation delays for staggered loading */
form { animation-delay: 0.2s; }
h3 { animation-delay: 0.4s; }
table { animation-delay: 0.6s; }
p { animation-delay: 0.4s; }

/* Hover effects for interactive elements */
input[name="account"]:hover {
    border-color: rgba(100, 181, 246, 0.3);
    background: rgba(0, 0, 0, 0.35);
}

/* Loading state */
.loading {
    position: relative;
    pointer-events: none;
    opacity: 0.7;
}

.loading::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 32px;
    height: 32px;
    border: 3px solid rgba(100, 181, 246, 0.3);
    border-top-color: #64b5f6;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    z-index: 1;
}

@keyframes spin {
    0% { transform: translate(-50%, -50%) rotate(0deg); }
    100% { transform: translate(-50%, -50%) rotate(360deg); }
}

@keyframes float {
    0%, 100% { transform: translate(-50%, -50%) rotate(0deg); }
    50% { transform: translate(-60%, -40%) rotate(180deg); }
}

/* Page header */
h2 {
    font-size: 2.5rem;
    font-weight: 700;
    color: #e2e8f0;
    text-align: center;
    margin-bottom: 3rem;
    background: linear-gradient(135deg, #64b5f6, #42a5f5, #a855f7);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    animation: slideDown 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
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

/* Search form */
form {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 24px;
    padding: 2.5rem;
    margin-bottom: 3rem;
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
    animation: slideUp 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) 0.2s both;
    position: relative;
    overflow: hidden;
    display: flex;
    align-items: center;
    gap: 1.5rem;
    flex-wrap: wrap;
}

@keyframes slideUp {
    from {
        opacity: 0;
        transform: translateY(40px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

form::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg, #64b5f6, #42a5f5, #a855f7, #64b5f6);
    background-size: 200% 100%;
    animation: shimmer 3s ease-in-out infinite;
}

@keyframes shimmer {
    0%, 100% { background-position: 0% 0%; }
    50% { background-position: 200% 0%; }
}

/* Form inputs */
input[name="account"] {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 1rem 1.5rem;
    font-size: 1rem;
    color: #e2e8f0;
    font-family: inherit;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    backdrop-filter: blur(10px);
    flex: 1;
    min-width: 250px;
}

input[name="account"]:focus {
    outline: none;
    border-color: #64b5f6;
    box-shadow: 0 0 0 3px rgba(100, 181, 246, 0.2);
    background: rgba(0, 0, 0, 0.4);
    transform: translateY(-2px);
}

input[name="account"]::placeholder {
    color: #64748b;
}

/* Search button */
button[type="submit"] {
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    color: white;
    border: none;
    padding: 1rem 2rem;
    border-radius: 12px;
    cursor: pointer;
    font-weight: 600;
    font-size: 1rem;
    font-family: inherit;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 4px 15px rgba(100, 181, 246, 0.3);
    position: relative;
    overflow: hidden;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

button[type="submit"]::before {
    content: '';
    position: absolute;
    
    </style>
</head>

<body>
<h2>Billing History</h2>

<form method="get">
  Account No: <input name="account" value="<%= account==null? "": account %>"/>
  <button type="submit">Search</button>
</form>

<% if (customer != null) { %>
  <h3>Customer: <%= customer.getAccountNumber() %> — <%= customer.getFirstName()+" "+customer.getLastName() %></h3>
  <table border="1" cellpadding="6">
    <tr><th>Bill #</th><th>Date</th><th>Subtotal</th><th>Tax</th><th>Total</th><th>Invoice</th></tr>
    <% for (Bills b : bills) { %>
      <tr>
        <td><%= b.getBillId() %></td>
        <td><%= b.getCreatedAt() %></td>
        <td>Rs <%= String.format("%.2f", b.getSubtotal()) %></td>
        <td><%= b.getTaxRate() %>% (Rs <%= String.format("%.2f", b.getTaxAmount()) %>)</td>
        <td><b>Rs <%= String.format("%.2f", b.getTotal()) %></b></td>
        <td>
          <!-- Re-generate PDF by calling a small invoice servlet if you want; or store PDFs server-side. -->
          <form action="<%=request.getContextPath()%>/invoice" method="get" target="_blank" style="display:inline;">
            <input type="hidden" name="bill_id" value="<%= b.getBillId() %>"/>
            <button type="submit">Open</button>
          </form>
        </td>
      </tr>
    <% } %>
  </table>
<% } else if (account != null) { %>
  <p>No customer found for account.</p>
<% } %>

</body>
</html>
