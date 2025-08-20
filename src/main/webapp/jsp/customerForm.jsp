<%-- 
    Document   : customerForm
    Created on : Aug 7, 2025, 1:36:44 PM
    Author     : ugdin
--%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ page import="models.User" %>
<%@ page import="dao.CustomerDAO" %>
<%@ page import="models.Customer" %>
<%@ page import="java.util.*" %>

<%
    // --- Auth guard (ADMIN or CASHIER only) ---
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || (!"ADMIN".equals(loggedUser.getRole()) && !"CASHIER".equals(loggedUser.getRole()))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // --- Load data (server-side search) ---
    String q = request.getParameter("q");
    CustomerDAO dao = new CustomerDAO();
    List<Customer> customers = (q != null && !q.trim().isEmpty())
            ? dao.searchCustomers(q.trim())
            : dao.getAllCustomers();
%>
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

/* Form container */
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
input[type="text"],
input[type="email"] {
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 1rem 1.5rem;
    font-size: 1rem;
    color: #e2e8f0;
    font-family: inherit;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    backdrop-filter: blur(10px);
    width: 300px;
    margin-left: 1rem;
    margin-bottom: 1.5rem;
}

input[type="text"]:focus,
input[type="email"]:focus {
    outline: none;
    border-color: #64b5f6;
    box-shadow: 0 0 0 3px rgba(100, 181, 246, 0.2);
    background: rgba(0, 0, 0, 0.4);
    transform: translateY(-2px);
}

input[type="text"]::placeholder,
input[type="email"]::placeholder {
    color: #64748b;
}

/* Form labels */
form label,
form > text {
    display: inline-block;
    min-width: 120px;
    font-weight: 600;
    color: #94a3b8;
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    vertical-align: top;
    padding-top: 1rem;
}
form .form-row {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}

form .form-row label {
  min-width: 150px; /* label column width */
  font-weight: 600;
  color: #94a3b8;
}

form .form-row input {
  flex: 1;  /* input expands */
}

/* Submit button */
input[type="submit"] {
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    color: white;
    border: none;
    padding: 1.25rem 2.5rem;
    border-radius: 16px;
    cursor: pointer;
    font-weight: 600;
    font-size: 1.1rem;
    font-family: inherit;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 8px 25px rgba(100, 181, 246, 0.3);
    position: relative;
    overflow: hidden;
    margin-top: 1rem;
    text-transform: uppercase;
    letter-spacing: 1px;
}

input[type="submit"]::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
    transition: left 0.5s;
}

input[type="submit"]:hover::before {
    left: 100%;
}

input[type="submit"]:hover {
    transform: translateY(-3px);
    box-shadow: 0 15px 40px rgba(100, 181, 246, 0.4);
}

input[type="submit"]:active {
    transform: translateY(-1px);
}

/* Toolbar styles */
.toolbar {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 20px;
    padding: 2rem;
    margin-bottom: 2rem;
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.3);
    animation: slideUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) 0.4s both;
}

.toolbar form {
    background: transparent;
    border: none;
    box-shadow: none;
    padding: 0;
    margin: 0;
    margin-bottom: 1rem;
    display: flex;
    gap: 1rem;
    align-items: center;
    animation: none;
}

.toolbar form::before {
    display: none;
}

.toolbar input[type="text"] {
    flex: 1;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 1rem 1.5rem;
    font-size: 1rem;
    color: #e2e8f0;
    font-family: inherit;
    transition: all 0.3s ease;
    backdrop-filter: blur(10px);
    width: auto;
    margin: 0;
}

.toolbar input[type="text"]:focus {
    outline: none;
    border-color: #64b5f6;
    box-shadow: 0 0 0 3px rgba(100, 181, 246, 0.2);
    background: rgba(0, 0, 0, 0.4);
    transform: none;
}

.toolbar button {
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    color: white;
    border: none;
    padding: 1rem 1.5rem;
    border-radius: 12px;
    cursor: pointer;
    font-weight: 600;
    font-family: inherit;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(100, 181, 246, 0.3);
}

.toolbar button:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(100, 181, 246, 0.4);
}

.muted {
    color: #64748b;
    font-size: 0.85rem;
    font-style: italic;
    display: block;
    margin-top: 0.5rem;
}

/* Section headers */
h3 {
    font-size: 1.6rem;
    font-weight: 600;
    color: #e2e8f0;
    margin-bottom: 1.5rem;
    display: flex;
    align-items: center;
    gap: 0.75rem;
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

/* Row actions */
.row-actions {
    display: flex;
    gap: 0.75rem;
    align-items: center;
    justify-content: flex-start;
}

.row-actions form {
    background: transparent;
    border: none;
    box-shadow: none;
    padding: 0;
    margin: 0;
    animation: none;
    display: inline-block;
}

.row-actions form::before {
    display: none;
}

.row-actions input[type="submit"] {
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
    margin: 0;
    text-transform: none;
    letter-spacing: normal;
}

.row-actions input[type="submit"]::before {
    display: none;
}

/* Edit button styling */
.row-actions form:first-child input[type="submit"] {
    border-color: rgba(100, 181, 246, 0.3);
    color: #64b5f6;
}

.row-actions form:first-child input[type="submit"]:hover {
    background: rgba(100, 181, 246, 0.15);
    border-color: #64b5f6;
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(100, 181, 246, 0.2);
}

/* Delete button styling */
.row-actions form:last-child input[type="submit"] {
    border-color: rgba(245, 101, 101, 0.3);
    color: #f56565;
}

.row-actions form:last-child input[type="submit"]:hover {
    background: rgba(245, 101, 101, 0.15);
    border-color: #f56565;
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(245, 101, 101, 0.2);
}

/* Empty state */
td[colspan="6"] {
    text-align: center;
    color: #64748b !important;
    font-style: italic;
    padding: 3rem;
    background: rgba(0, 0, 0, 0.2);
}

/* Alert styles */
.alert {
    position: fixed;
    top: 100px;
    right: 2rem;
    padding: 1.25rem 1.5rem;
    border-radius: 16px;
    color: white;
    font-weight: 600;
    z-index: 1001;
    min-width: 320px;
    max-width: 400px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    transform: translateX(120%);
    opacity: 0;
    transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
    backdrop-filter: blur(20px);
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}

.alert.show {
    transform: translateX(0);
    opacity: 1;
}

.alert.success {
/*    background: linear-gradient(135deg, #48bb78, #38a169);*/
    border: 1px solid rgba(255, 255, 255, 0.2);
}

.alert.error {
/*    background: linear-gradient(135deg, #f56565, #e53e3e);*/
    border: 1px solid rgba(255, 255, 255, 0.2);
}

.close-btn {
    background: rgba(255, 255, 255, 0.2);
    border: none;
    color: white;
    font-size: 1.2rem;
    font-weight: bold;
    cursor: pointer;
    padding: 0.5rem;
    margin-left: 1rem;
    width: 2rem;
    height: 2rem;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    transition: all 0.3s ease;
}

.close-btn:hover {
    background: rgba(255, 255, 255, 0.3);
    transform: scale(1.1);
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
    }

    .toolbar {
        border-radius: 16px;
        padding: 1.5rem;
    }

    table {
        border-radius: 16px;
        font-size: 0.9rem;
    }

    th, td {
        padding: 1rem;
    }

    input[type="text"],
    input[type="email"] {
        width: 100%;
        margin-left: 0;
        margin-bottom: 1rem;
        display: block;
    }

    form label,
    form > text {
        display: block;
        margin-bottom: 0.5rem;
        min-width: auto;
    }

    .row-actions {
        flex-direction: column;
        gap: 0.5rem;
        align-items: stretch;
    }

    .row-actions input[type="submit"] {
        text-align: center;
        width: 100%;
    }

    .alert {
        right: 1rem;
        left: 1rem;
        min-width: auto;
        top: 80px;
    }

    /* Make table horizontally scrollable on mobile */
    table {
        display: block;
        overflow-x: auto;
        white-space: nowrap;
    }

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
        margin-bottom: 1rem;
        padding: 1rem;
        background: rgba(0, 0, 0, 0.2);
        display: block;
        white-space: normal;
    }

    td {
        border: none;
        position: relative;
        padding: 0.75rem 0;
        padding-left: 50%;
        display: block;
        text-align: right;
    }

    td::before {
        content: attr(data-label);
        position: absolute;
        left: 0;
        width: 45%;
        padding-right: 10px;
        white-space: nowrap;
        font-weight: 600;
        color: #94a3b8;
        text-transform: uppercase;
        font-size: 0.8rem;
        letter-spacing: 0.5px;
        text-align: left;
        padding-top: 0.25rem;
    }

    .row-actions {
        padding-left: 0;
        justify-content: flex-end;
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

    .toolbar {
        padding: 1rem;
    }

    input[type="text"],
    input[type="email"] {
        padding: 0.875rem 1rem;
    }

    input[type="submit"] {
        padding: 1rem 1.5rem;
        font-size: 1rem;
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
.toolbar { animation-delay: 0.4s; }
table { animation-delay: 0.6s; }

/* Hover effects for interactive elements */
input[type="text"]:hover,
input[type="email"]:hover {
    border-color: rgba(100, 181, 246, 0.3);
    background: rgba(0, 0, 0, 0.35);
}

button:hover,
input[type="submit"]:hover {
    cursor: pointer;
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
</style>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Form</title>
    <meta charset="UTF-8" />

</head>
<body>
    <h2>Customer Registration</h2>

    <!-- Registration / Edit form -->
    <form action="../customer" method="post">
        <input type="hidden" name="action" value="<%= (request.getParameter("action") != null ? request.getParameter("action") : "add") %>" />
        <input type="hidden" name="account_number" value="<%= (request.getParameter("account_number") != null ? request.getParameter("account_number") : "") %>" />

        <div class="form-row">
  <label for="first_name">First Name:</label>
  <input type="text" id="first_name" name="first_name" value="<%= (request.getParameter("first_name") != null ? request.getParameter("first_name") : "") %>" required>
</div>

<div class="form-row">
  <label for="last_name">Last Name:</label>
  <input type="text" id="last_name" name="last_name" value="<%= (request.getParameter("last_name") != null ? request.getParameter("last_name") : "") %>" required>
</div>

<div class="form-row">
  <label for="phone">Phone:</label>
  <input type="text" id="phone" name="phone" value="<%= (request.getParameter("phone") != null ? request.getParameter("phone") : "") %>" required>
</div>

<div class="form-row">
  <label for="address">Address:</label>
  <input type="text" id="address" name="address" value="<%= (request.getParameter("address") != null ? request.getParameter("address") : "") %>" required>
</div>

<div class="form-row">
  <label for="email">Email:</label>
  <input type="email" id="email" name="email" value="<%= (request.getParameter("email") != null ? request.getParameter("email") : "") %>" required>
</div>


        <input type="submit" value="<%= "edit".equals(request.getParameter("action")) ? "Update" : "Register" %> Customer">
    </form>

    <!-- Search toolbar: server-side + client-side -->
    <div class="toolbar">
        <form method="get" action="customerForm.jsp">
            <input
                type="text"
                id="custSearch"
                name="q"
                value="<%= (q != null ? q : "") %>"
                placeholder="Search customers… (name, phone, account, email)"
            >
            <button type="submit">Search</button>
        </form>
        <span class="muted">
            Tip: typing here filters instantly; submitting reloads from server.
        </span>
    </div>

    <!-- Customer list -->
    <h3>Customer List <%= (q != null && !q.trim().isEmpty()) ? "(filtered)" : "" %></h3>
    <table>
        <thead>
            <tr>
                <th>Account No</th>
                <th>Name</th>
                <th>Phone</th>
                <th>Email</th>
                <th>Address</th>
                <th style="width:220px;">Actions</th>
            </tr>
        </thead>
        <tbody id="customerRows">
            <%
                for (Customer c : customers) {
            %>
            <tr>
                <td><%= c.getAccountNumber() %></td>
                <td><%= c.getFirstName() + " " + c.getLastName() %></td>
                <td><%= c.getPhone() %></td>
                <td><%= c.getEmail() %></td>
                <td><%= c.getAddress() %></td>
                <td class="row-actions">
                    <!-- Edit: prefill via query params -->
                    <form action="customerForm.jsp" method="get">
                        <input type="hidden" name="action" value="edit"/>
                        <input type="hidden" name="account_number" value="<%= c.getAccountNumber() %>"/>
                        <input type="hidden" name="first_name"     value="<%= c.getFirstName() %>"/>
                        <input type="hidden" name="last_name"      value="<%= c.getLastName() %>"/>
                        <input type="hidden" name="phone"          value="<%= c.getPhone() %>"/>
                        <input type="hidden" name="address"        value="<%= c.getAddress() %>"/>
                        <input type="hidden" name="email"          value="<%= c.getEmail() %>"/>
                        <input type="submit" value="Edit"/>
                    </form>

                    <!-- Delete -->
                    <form action="../customer" method="post" onsubmit="return confirm('Are you sure to delete?');">
                        <input type="hidden" name="action" value="delete"/>
                        <input type="hidden" name="account_number" value="<%= c.getAccountNumber() %>"/>
                        <input type="submit" value="Delete"/>
                    </form>
                </td>
            </tr>
            <%
                } // end for
            %>
            <% if (customers == null || customers.isEmpty()) { %>
            <tr>
                <td colspan="6" style="text-align:center; color:#777;">No customers found.</td>
            </tr>
            <% } %>
        </tbody>
    </table>
        <script>
  function showAlert(message, type) {
    if (!message) return;

    const el = document.createElement('div');
    el.className = 'alert ' + (type === 'error' ? 'error' : 'success');
    el.innerHTML =
      '<span>' + String(message).replace(/</g, '&lt;') + '</span>' +
      '<button class="close-btn" type="button" aria-label="Close">&times;</button>';

    document.body.appendChild(el);

    // animate in
    requestAnimationFrame(() => el.classList.add('show'));

    // auto-close after 4s
    const hide = () => {
      el.classList.remove('show');
      setTimeout(() => el.remove(), 400);
    };
    el.querySelector('.close-btn').addEventListener('click', hide);
    setTimeout(hide, 4000);
  }
</script>


<c:if test="${not empty sessionScope.flashSuccess}">
  <script>
    window.addEventListener('DOMContentLoaded', function () {
      showAlert('<c:out value="${sessionScope.flashSuccess}"/>', 'success');
    });
  </script>
  <c:remove var="flashSuccess" scope="session"/>
</c:if>

<c:if test="${not empty sessionScope.flashError}">
  <script>
    window.addEventListener('DOMContentLoaded', function () {
      showAlert('<c:out value="${sessionScope.flashError}"/>', 'error');
    });
  </script>
  <c:remove var="flashError" scope="session"/>
</c:if>
</body>

</html>
