<%-- 
    Document   : itemForm
    Created on : Aug 8, 2025, 6:33:51 PM
    Author     : ugdin
--%>

<%@ page import="models.User" %>
<%@ page import="dao.ItemDAO" %>
<%@ page import="models.Item" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    // --- Auth guard (ADMIN only) ---
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // --- Load data (server-side search) ---
    String q = request.getParameter("q");
    ItemDAO dao = new ItemDAO();
    List<Item> items = (q != null && !q.trim().isEmpty())
            ? dao.searchItems(q.trim())
            : dao.getAllItems();
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Item Form</title>
 

    <script>
// Creates and shows a sliding alert. type = 'success' | 'error'
function showAlert(message, type) {
  // Debug: see what actually arrives
  console.log('flash ->', type, message);

  // Remove any existing alerts
  document.querySelectorAll('.alert').forEach(a => a.remove());

  const el = document.createElement('div');
  el.className = `alert ${type}`;

  // message in a span so it can't get hidden by pseudo-elements
  const msg = document.createElement('span');
  msg.textContent = message ?? '';

  const close = document.createElement('button');
  close.className = 'close-btn';
  close.type = 'button';
  close.innerHTML = '&times;';
  close.onclick = () => el.remove();

  el.appendChild(msg);
  el.appendChild(close);
  document.body.appendChild(el);

  // animate in
  setTimeout(() => el.classList.add('show'), 20);

  // auto hide
  setTimeout(() => {
    el.classList.remove('show');
    setTimeout(() => el.remove(), 300);
  }, 4000);
}
</script>
<c:if test="${not empty sessionScope.flashSuccess}">
  <!-- Put raw text into DOM safely, no JS quoting needed -->
  <div id="flash-success" hidden><c:out value="${sessionScope.flashSuccess}"/></div>
  <script>
    window.addEventListener('DOMContentLoaded', function () {
      var msg = document.getElementById('flash-success').textContent;
      showAlert(msg, 'success');
    });
  </script>
  <c:remove var="flashSuccess" scope="session"/>
</c:if>

<c:if test="${not empty sessionScope.flashError}">
  <div id="flash-error" hidden><c:out value="${sessionScope.flashError}"/></div>
  <script>
    window.addEventListener('DOMContentLoaded', function () {
      var msg = document.getElementById('flash-error').textContent;
      showAlert(msg, 'error');
    });
  </script>
  <c:remove var="flashError" scope="session"/>
</c:if>

</head>
<body>
    <h2>Add / Edit Item</h2>

    <!-- Add/Edit form -->
    <form action="<%= request.getContextPath() %>/items" method="post">
        <input type="hidden" name="action"
               value="<%= (request.getParameter("action") != null ? request.getParameter("action") : "add") %>" />
        <input type="hidden" name="item_id"
               value="<%= (request.getParameter("item_id") != null ? request.getParameter("item_id") : "") %>" />

        Item Name:       <input type="text"   name="name"           value="<%= (request.getParameter("name")           != null ? request.getParameter("name")           : "") %>" required><br>
        Description:     <input type="text"   name="description"    value="<%= (request.getParameter("description")    != null ? request.getParameter("description")    : "") %>" required><br>
        Price:           <input type="number" step="0.01" name="price" value="<%= (request.getParameter("price")        != null ? request.getParameter("price")        : "") %>" required><br>
        Stock Quantity:  <input type="number" name="stock_quantity" value="<%= (request.getParameter("stock_quantity") != null ? request.getParameter("stock_quantity") : "") %>" required><br>

        <input type="submit" value="<%= "edit".equals(request.getParameter("action")) ? "Update" : "Enter" %> Item">
    </form>

    <!-- Search toolbar: server-side + client-side -->
    <div class="toolbar">
        <form method="get" action="itemForm.jsp">
            <input
                type="text"
                id="itemSearch"
                name="q"
                value="<%= (q != null ? q : "") %>"
                placeholder="Search items… (name, description, price, stock)"
            >
            <button type="submit">Search</button>
        </form>
        <span class="muted">
            Tip: typing filters instantly; submitting reloads from server.
        </span>
    </div>

    <!-- Item list -->
    <h3>Item List <%= (q != null && !q.trim().isEmpty()) ? "(filtered)" : "" %></h3>
    <table>
        <thead>
        <tr>
            <th>Item Name</th>
            <th>Description</th>
            <th style="width:120px;">Price</th>
            <th style="width:140px;">Stock Quantity</th>
            <th style="width:220px;">Actions</th>
        </tr>
        </thead>
        <tbody id="itemRows">
        <%
            for (Item it : items) {
        %>
        <tr>
            <td><%= it.getItemName() %></td>
            <td><%= it.getDescription() %></td>
            <td><%= it.getPrice() %></td>
            <td><%= it.getStockQuantity() %></td>
            <td class="row-actions">
                <!-- Edit: prefill via query params -->
                <form action="itemForm.jsp" method="get">
                    <input type="hidden" name="action" value="edit"/>
                    <input type="hidden" name="item_id"        value="<%= it.getItemId() %>"/>
                    <input type="hidden" name="name"           value="<%= it.getItemName() %>"/>
                    <input type="hidden" name="description"    value="<%= it.getDescription() %>"/>
                    <input type="hidden" name="price"          value="<%= it.getPrice() %>"/>
                    <input type="hidden" name="stock_quantity" value="<%= it.getStockQuantity() %>"/>
                    <input type="submit" value="Edit"/>
                </form>

                <!-- Delete -->
                <form action="<%= request.getContextPath() %>/items" method="post"
                      onsubmit="return confirm('Are you sure to delete?');">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" name="item_id" value="<%= it.getItemId() %>"/>
                    <input type="submit" value="Delete"/>
                </form>
            </td>
        </tr>
        <%
            }
        %>
        <% if (items == null || items.isEmpty()) { %>
        <tr>
            <td colspan="5" style="text-align:center; color:#777;">No items found.</td>
        </tr>
        <% } %>
        </tbody>
    </table>
</body>
</html>
