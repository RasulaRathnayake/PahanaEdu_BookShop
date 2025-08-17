<%@ page import="models.User" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"CASHIER".equals(loggedUser.getRole())) {
        response.sendRedirect("jsp/login.jsp");
        return;
    }
%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Pahana Edu Book Shop</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="header-content">
            <div class="logo">
                <i class="fas fa-book-open"></i>
                Pahana Edu Book Shop
            </div>
            <button class="mobile-nav-toggle" onclick="toggleMobileNav()">
                <i class="fas fa-bars"></i>
            </button>
            <div class="user-info">
                <div class="welcome-text">
                    <i class="fas fa-user-shield"></i>
                    Welcome, <%= loggedUser.getUsername() %>
                </div>
                <form action="<%=request.getContextPath()%>/logout" method="post" style="display: inline;">
                    <button type="submit" class="logout-btn">
                        <i class="fas fa-sign-out-alt"></i>
                        Logout
                    </button>
                </form>
            </div>
        </div>
    </header>

    <!-- Navigation Bar -->
    <nav class="navigation">
        <div class="nav-content" id="navContent">
            <a href="<%=request.getContextPath()%>/jsp/billing.jsp" class="nav-item active" onclick="setActive(this)">
                <i class="fas fa-file-invoice"></i>
                Invoice Management
            </a>
            <a href="<%=request.getContextPath()%>/jsp/customerForm.jsp" class="nav-item" onclick="setActive(this)">
                <i class="fas fa-users"></i>
                Customer Management
            </a>
            <a href="<%=request.getContextPath()%>/jsp/billing-history.jsp" class="nav-item" onclick="setActive(this)">
                <i class="fas fa-chart-line"></i>
                Billing History
            </a>
            <a href="<%=request.getContextPath()%>/jsp/help.jsp" class="nav-item" onclick="setActive(this)">
            <i class="fas fa-question-circle"></i>
                Help & Support
            </a>
              
        </div>
    </nav>

    <!-- Content Container -->
    <div class="content-container">
        <div class="content-frame">
            <iframe id="contentFrame" src="<%=request.getContextPath()%>/jsp/billing.jsp"></iframe>
        </div>
    </div>

    <script>
        // Set active navigation item
        function setActive(element) {
            // Remove active class from all nav items
            document.querySelectorAll('.nav-item').forEach(item => {
                item.classList.remove('active');
            });
            
            // Add active class to clicked item
            element.classList.add('active');
            
            // Load content in iframe
            const href = element.getAttribute('href');
            document.getElementById('contentFrame').src = href;
            
            // Close mobile navigation
            if (window.innerWidth <= 768) {
                document.getElementById('navContent').classList.remove('open');
            }
            
            // Prevent default link behavior
            return false;
        }

        // Update navigation links to use setActive
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', function(e) {
                e.preventDefault();
                setActive(this);
            });
        });

        // Mobile navigation toggle
        function toggleMobileNav() {
            const navContent = document.getElementById('navContent');
            navContent.classList.toggle('open');
        }

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

        // Close mobile nav when clicking outside
        document.addEventListener('click', function(event) {
            const navContent = document.getElementById('navContent');
            const mobileToggle = document.querySelector('.mobile-nav-toggle');
            
            if (!navContent.contains(event.target) && !mobileToggle.contains(event.target)) {
                navContent.classList.remove('open');
            }
        });
    </script>
    <c:if test="${not empty sessionScope.flashSuccess}">
<script>
    showAlert("${fn:escapeXml(sessionScope.flashSuccess)}", "success");
</script>
  <c:remove var="flashSuccess" scope="session"/>
</c:if>
</body>
</html>
