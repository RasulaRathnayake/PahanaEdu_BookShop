<%-- 
    Document   : login
    Created on : Aug 6, 2025, 11:11:55 PM
    Author     : ugdin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:if test="${not empty sessionScope.flashSuccess}">
  <script>showAlert("${fn:escapeXml(sessionScope.flashSuccess)}", "success");</script>
  <c:remove var="flashSuccess" scope="session"/>
</c:if>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - PahanaEduBookShop</title>

  
</head>
<body>
  <div class="login-container">
    <div class="login-header">
      <h1>Pahana Edu Book Shop</h1>
      <p>Welcome back! Please sign in to your account</p>
    </div>
    
    <form method="post" action="${pageContext.request.contextPath}/login" id="loginForm">
      <div class="form-group">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required />
      </div>
      
      <div class="form-group">
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required />
      </div>
      
      <button type="submit" id="loginBtn">Login</button>
    </form>
  </div>

  <script>
    // Enhanced form submission with loading state
    document.getElementById('loginForm').addEventListener('submit', function() {
      const btn = document.getElementById('loginBtn');
      btn.classList.add('btn-loading');
      btn.disabled = true;
    });

    // Custom alert function
     function showAlert(message, type) {
    console.log('showAlert message:', message); // <-- debug: see what arrives

    const alertDiv = document.createElement('div');
    alertDiv.className = `alert ${type}`;

    // message span (use textContent so nothing gets stripped)
    const msgSpan = document.createElement('span');
    msgSpan.textContent = message ?? '';

    // close button
    const btn = document.createElement('button');
    btn.className = 'close-btn';
    btn.type = 'button';
    btn.textContent = '×';
    btn.onclick = () => alertDiv.remove();

    alertDiv.appendChild(msgSpan);
    alertDiv.appendChild(btn);
    document.body.appendChild(alertDiv);

    setTimeout(() => alertDiv.classList.add('show'), 50);
    setTimeout(() => { alertDiv.classList.remove('show'); setTimeout(() => alertDiv.remove(), 300); }, 5000);
  }
  </script>

  <c:if test="${not empty requestScope.error}">
    <script>
      showAlert("${fn:escapeXml(requestScope.error)}", "error");
    </script>
  </c:if>
  
  <c:if test="${not empty requestScope.success}">
    <script>
      showAlert("${fn:escapeXml(requestScope.success)}", "success");
    </script>
  </c:if>
</body>
</html>