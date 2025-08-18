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

        First Name: <input type="text" name="first_name" value="<%= (request.getParameter("first_name") != null ? request.getParameter("first_name") : "") %>" required><br>
        Last Name:  <input type="text" name="last_name"  value="<%= (request.getParameter("last_name")  != null ? request.getParameter("last_name")  : "") %>" required><br>
        Phone:      <input type="text" name="phone"      value="<%= (request.getParameter("phone")      != null ? request.getParameter("phone")      : "") %>" required><br>
        Address:    <input type="text" name="address"    value="<%= (request.getParameter("address")    != null ? request.getParameter("address")    : "") %>" required><br>
        Email:      <input type="email" name="email"     value="<%= (request.getParameter("email")     != null ? request.getParameter("email")     : "") %>" required><br>

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
