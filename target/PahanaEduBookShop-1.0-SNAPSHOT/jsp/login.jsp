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
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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
      display: flex;
      position: relative;
      overflow: hidden;
    }

    @keyframes gradientShift {
      0% { background-position: 0% 50%; }
      50% { background-position: 100% 50%; }
      100% { background-position: 0% 50%; }
    }

    /* Floating shapes background */
    body::before, body::after {
      content: '';
      position: absolute;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.45);
      animation: float 6s ease-in-out infinite;
    }

    body::before {
      width: 300px;
      height: 300px;
      top: -150px;
      right: -150px;
      animation-delay: -3s;
    }

    body::after {
      width: 200px;
      height: 200px;
      bottom: -100px;
      left: -100px;
      animation-delay: -1s;
    }

    @keyframes float {
      0%, 100% { transform: translateY(0px) rotate(0deg); }
      50% { transform: translateY(-20px) rotate(180deg); }
    }

    /* Split layout */
    .login-wrapper {
      display: flex;
      width: 100%;
      min-height: 100vh;
    }

    /* Left side - Brand section */
    .brand-section {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      padding: 4rem 2rem;
      background: rgba(0, 0, 0, 0.4);
      backdrop-filter: blur(20px);
      position: relative;
    }

    .brand-content {
      text-align: center;
      color: white;
      z-index: 1;
    }

    .brand-logo {
      width: 120px;
      height: 120px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 30px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 2rem;
      backdrop-filter: blur(10px);
      border: 2px solid rgba(255, 255, 255, 0.2);
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    }

    .brand-logo::before {
      content: '📚';
      font-size: 3rem;
    }

    .brand-title {
      font-size: 2.8rem;
      font-weight: 700;
      margin-bottom: 1rem;
      text-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
      line-height: 1.2;
    }

    .brand-subtitle {
      font-size: 1.2rem;
      font-weight: 300;
      opacity: 0.9;
      margin-bottom: 2rem;
    }

    .brand-features {
      list-style: none;
      text-align: left;
    }

    .brand-features li {
      margin: 1rem 0;
      padding-left: 2rem;
      position: relative;
      font-size: 1rem;
      opacity: 0.8;
    }

    .brand-features li::before {
      content: '✓';
      position: absolute;
      left: 0;
      color: #64b5f6;
      font-weight: bold;
      font-size: 1.2rem;
    }

    /* Right side - Login form */
    .login-section {
      flex: 1;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 2rem;
      background: rgba(0, 0, 0, 0.6);
      backdrop-filter: blur(20px);
    }

    .login-container {
      width: 100%;
      max-width: 400px;
      padding: 3rem 2.5rem;
      background: rgba(30, 30, 50, 0.95);
      border-radius: 24px;
      box-shadow: 
        0 20px 40px rgba(0, 0, 0, 0.5),
        0 0 0 1px rgba(255, 255, 255, 0.1);
      position: relative;
      animation: slideUp 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
      backdrop-filter: blur(20px);
      border: 1px solid rgba(255, 255, 255, 0.1);
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

    .login-header {
      text-align: center;
      margin-bottom: 2.5rem;
    }

    .login-header h1 {
      font-size: 2rem;
      font-weight: 600;
      color: #e2e8f0;
      margin-bottom: 0.5rem;
    }

    .login-header p {
      color: #a0aec0;
      font-size: 0.95rem;
      font-weight: 400;
    }

    /* Form styles */
    .form-group {
      margin-bottom: 1.8rem;
      position: relative;
    }

    .form-group label {
      display: block;
      margin-bottom: 0.7rem;
      color: #cbd5e1;
      font-weight: 500;
      font-size: 0.9rem;
    }

    .input-wrapper {
      position: relative;
    }

    .form-group input {
      width: 100%;
      padding: 1rem 1rem 1rem 3rem;
      border: 2px solid rgba(255, 255, 255, 0.1);
      border-radius: 16px;
      font-size: 1rem;
      background: rgba(255, 255, 255, 0.05);
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      color: #e2e8f0;
    }

    .input-icon {
      position: absolute;
      left: 1rem;
      top: 50%;
      transform: translateY(-50%);
      color: #64748b;
      font-size: 1.1rem;
      transition: color 0.3s ease;
    }

    .form-group input:focus {
      outline: none;
      border-color: #64b5f6;
      background: rgba(255, 255, 255, 0.1);
      box-shadow: 0 0 0 4px rgba(100, 181, 246, 0.1);
    }

    .form-group input:focus + .input-icon {
      color: #64b5f6;
    }

    .form-group input:hover {
      border-color: rgba(255, 255, 255, 0.2);
    }

    /* Button styles */
    .btn-container {
      margin-top: 2rem;
    }

    button[type="submit"] {
      width: 100%;
      padding: 1rem 2rem;
      background: linear-gradient(135deg, #64b5f6 0%, #42a5f5 100%);
      color: white;
      border: none;
      border-radius: 16px;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;
      position: relative;
      overflow: hidden;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      box-shadow: 0 4px 15px rgba(100, 181, 246, 0.3);
    }

    button[type="submit"]:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(100, 181, 246, 0.4);
    }

    button[type="submit"]:active {
      transform: translateY(0);
    }

    /* Loading state */
    .btn-loading {
      background: #4a5568 !important;
      cursor: not-allowed !important;
      transform: none !important;
      pointer-events: none;
    }

    .btn-loading::after {
      content: '';
      position: absolute;
      width: 20px;
      height: 20px;
      top: 50%;
      left: 50%;
      margin-left: -10px;
      margin-top: -10px;
      border: 2px solid rgba(255, 255, 255, 0.3);
      border-top-color: white;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    /* Alert styles */
    .alert {
      position: fixed;
      top: 2rem;
      right: 2rem;
      padding: 1.25rem 1.5rem;
      border-radius: 16px;
      color: white;
      font-weight: 500;
      z-index: 1000;
      min-width: 320px;
      max-width: 400px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      transform: translateX(120%);
      opacity: 0;
      transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
      backdrop-filter: blur(20px);
      box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
    }

    .alert.show {
      transform: translateX(0);
      opacity: 1;
    }

    .alert.success {
      background: linear-gradient(135deg, #48bb78, #38a169);
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .alert.error {
      background: linear-gradient(135deg, #f56565, #e53e3e);
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

    /* Input validation */
    .form-group input.error {
      border-color: #f56565;
      background: rgba(245, 101, 101, 0.1);
    }

    .form-group input.error:focus {
      border-color: #f56565;
      box-shadow: 0 0 0 4px rgba(245, 101, 101, 0.1);
    }

    /* Responsive design */
    @media (max-width: 768px) {
      .login-wrapper {
        flex-direction: column;
      }
      
      .brand-section {
        flex: none;
        min-height: 40vh;
        padding: 2rem 1rem;
      }

      .brand-title {
        font-size: 2.2rem;
      }

      .brand-features {
        display: none;
      }
      
      .login-section {
        flex: none;
        min-height: 60vh;
        padding: 1rem;
      }
      
      .login-container {
        padding: 2rem 1.5rem;
        margin-top: -2rem;
        border-radius: 24px 24px 0 0;
      }
      
      .alert {
        right: 1rem;
        left: 1rem;
        min-width: auto;
      }
    }

    @media (max-width: 480px) {
      .brand-section {
        min-height: 35vh;
      }

      .login-section {
        min-height: 65vh;
      }
      
      .login-container {
        padding: 1.5rem 1rem;
      }
      
      .brand-title {
        font-size: 1.8rem;
      }
    }

    /* Focus states for accessibility */
    button:focus-visible {
      outline: 2px solid #64b5f6;
      outline-offset: 2px;
    }

    input:focus-visible {
      outline: none;
    }

    /* Additional animations */
    .brand-content > * {
      animation: fadeInUp 1s ease-out forwards;
      opacity: 0;
    }

    .brand-logo { animation-delay: 0.1s; }
    .brand-title { animation-delay: 0.3s; }
    .brand-subtitle { animation-delay: 0.5s; }
    .brand-features { animation-delay: 0.7s; }

    @keyframes fadeInUp {
      from {
        opacity: 0;
        transform: translateY(30px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }
  </style>
</head>
<body>
  <div class="login-wrapper">
    <!-- Brand Section -->
    <div class="brand-section">
      <div class="brand-content">
        <div class="brand-logo"></div>
        <h1 class="brand-title">Pahana Edu<br>Book Shop</h1>
        <p class="brand-subtitle">Your gateway to knowledge and learning</p>
<!--        <ul class="brand-features">
          <li>Extensive collection of educational books</li>
          <li>Easy online ordering and delivery</li>
          <li>Expert recommendations and reviews</li>
          <li>Student-friendly pricing</li>
        </ul>-->
      </div>
    </div>

    <!-- Login Section -->
    <div class="login-section">
      <div class="login-container">
        <div class="login-header">
          <h1>Welcome Back</h1>
          <p>Sign in to access your account</p>
        </div>
        
        <form method="post" action="${pageContext.request.contextPath}/login" id="loginForm">
          <div class="form-group">
            <label for="username">Username</label>
            <div class="input-wrapper">
              <input type="text" id="username" name="username" required />
              <div class="input-icon">👤</div>
            </div>
          </div>
          
          <div class="form-group">
            <label for="password">Password</label>
            <div class="input-wrapper">
              <input type="password" id="password" name="password" required />
              <div class="input-icon">🔒</div>
            </div>
          </div>
          
          <div class="btn-container">
            <button type="submit" id="loginBtn">Sign In</button>
          </div>
        </form>
      </div>
    </div>
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
      console.log('showAlert message:', message);

      const alertDiv = document.createElement('div');
      alertDiv.className = `alert ${type}`;

      const msgSpan = document.createElement('span');
      msgSpan.textContent = message ?? '';

      const btn = document.createElement('button');
      btn.className = 'close-btn';
      btn.type = 'button';
      btn.textContent = '×';
      btn.onclick = () => alertDiv.remove();

      alertDiv.appendChild(msgSpan);
      alertDiv.appendChild(btn);
      document.body.appendChild(alertDiv);

      setTimeout(() => alertDiv.classList.add('show'), 50);
      setTimeout(() => { 
        alertDiv.classList.remove('show'); 
        setTimeout(() => alertDiv.remove(), 300); 
      }, 5000);
    }

    // Add input focus effects
    document.querySelectorAll('input').forEach(input => {
      input.addEventListener('focus', function() {
        this.parentElement.classList.add('focused');
      });
      
      input.addEventListener('blur', function() {
        this.parentElement.classList.remove('focused');
      });
    });
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