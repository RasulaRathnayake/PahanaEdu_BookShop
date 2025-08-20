<%@ page import="models.User" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
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

/* Layout Structure */
.dashboard-container {
  display: flex;
  min-height: 100vh;
}

/* Sidebar Styles */
.sidebar {
  width: 280px;
  background: rgba(20, 20, 35, 0.95);
  backdrop-filter: blur(20px);
  border-right: 1px solid rgba(255, 255, 255, 0.1);
  position: fixed;
  height: 100vh;
  left: 0;
  top: 0;
  z-index: 1000;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 4px 0 20px rgba(0, 0, 0, 0.3);
  animation: slideInLeft 0.6s ease-out;
  display: flex;
  flex-direction: column;
}

@keyframes slideInLeft {
  from {
    transform: translateX(-100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.sidebar.collapsed {
  width: 80px;
}

/* Logo Section */
.sidebar-header {
  padding: 2rem 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
}

.logo-icon {
  background: linear-gradient(135deg, #64b5f6, #42a5f5);
  width: 48px;
  height: 48px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: white;
  box-shadow: 0 8px 20px rgba(100, 181, 246, 0.3);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.logo-text {
  flex: 1;
  opacity: 1;
  transition: opacity 0.3s ease;
}

.logo-title {
  font-size: 1.3rem;
  font-weight: 700;
  color: #e2e8f0;
  line-height: 1.2;
}

.logo-subtitle {
  font-size: 0.8rem;
  color: #94a3b8;
  font-weight: 400;
}

.sidebar.collapsed .logo-text {
  opacity: 0;
}

/* Navigation Menu */
.sidebar-nav {
  padding: 1.5rem 0;
  flex: 1;
  overflow-y: auto;
  scrollbar-width: none;
}

.sidebar-nav::-webkit-scrollbar {
  display: none;
}

.nav-section {
  margin-bottom: 2rem;
}

.nav-section-title {
  padding: 0 1.5rem 0.75rem;
  font-size: 0.75rem;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 1px;
  opacity: 1;
  transition: opacity 0.3s ease;
}

.sidebar.collapsed .nav-section-title {
  opacity: 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.875rem 1.5rem;
  margin: 0.25rem 1rem;
  text-decoration: none;
  color: #a0aec0;
  font-weight: 500;
  font-size: 0.95rem;
  border-radius: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  border: 1px solid transparent;
}

.nav-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(100, 181, 246, 0.15), transparent);
  transition: left 0.5s;
}

.nav-item:hover::before {
  left: 100%;
}

.nav-item:hover {
  color: #64b5f6;
  background: rgba(100, 181, 246, 0.12);
  border-color: rgba(100, 181, 246, 0.25);
  transform: translateX(4px);
}

.nav-item.active {
  background: linear-gradient(135deg, rgba(100, 181, 246, 0.2), rgba(66, 165, 245, 0.15));
  color: #64b5f6;
  border-color: rgba(100, 181, 246, 0.4);
  box-shadow: 0 8px 25px rgba(100, 181, 246, 0.15);
  transform: translateX(6px);
}

.nav-item-icon {
  font-size: 1.2rem;
  min-width: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-item-text {
  opacity: 1;
  transition: opacity 0.3s ease;
  white-space: nowrap;
}

.sidebar.collapsed .nav-item-text {
  opacity: 0;
}

.sidebar.collapsed .nav-item {
  justify-content: center;
  margin: 0.25rem 0.5rem;
  padding: 0.875rem;
}

/* User Profile Section */
.user-profile {
  padding: 1.5rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(0, 0, 0, 0.2);
}

.user-info-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: rgba(100, 181, 246, 0.1);
  border-radius: 16px;
  border: 1px solid rgba(100, 181, 246, 0.2);
  transition: all 0.3s ease;
}

.user-avatar {
  width: 44px;
  height: 44px;
  background: linear-gradient(135deg, #64b5f6, #42a5f5);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  color: white;
  font-weight: 600;
}

.user-details {
  flex: 1;
  opacity: 1;
  transition: opacity 0.3s ease;
}

.user-name {
  font-size: 0.95rem;
  font-weight: 600;
  color: #e2e8f0;
  line-height: 1.3;
}

.user-role {
  font-size: 0.8rem;
  color: #64b5f6;
  font-weight: 500;
}

.sidebar.collapsed .user-details {
  opacity: 0;
}

.logout-btn {
  background: linear-gradient(135deg, #f56565, #e53e3e);
  color: white;
  border: none;
  padding: 0.75rem 1rem;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  font-size: 0.9rem;
  box-shadow: 0 4px 15px rgba(245, 101, 101, 0.3);
  width: 100%;
  margin-top: 1rem;
}

.logout-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(245, 101, 101, 0.4);
}

.sidebar.collapsed .logout-btn {
  padding: 0.75rem;
}

.logout-btn-text {
  opacity: 1;
  transition: opacity 0.3s ease;
}

.sidebar.collapsed .logout-btn-text {
  opacity: 0;
}

/* Main Content Area */
.main-content {
  flex: 1;
  margin-left: 280px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
}

.main-content.expanded {
  margin-left: 80px;
}

/* Top Bar */
.top-bar {
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding: 1rem 2rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
}

.sidebar-toggle {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #e2e8f0;
  padding: 0.75rem;
  border-radius: 12px;
  cursor: pointer;
  font-size: 1.1rem;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.sidebar-toggle:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.05);
}

.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #e2e8f0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.page-title i {
  color: #64b5f6;
  font-size: 1.3rem;
}

/* Content Frame */
.content-wrapper {
  flex: 1;
  padding: 2rem;
  display: flex;
  justify-content: center;
  align-items: stretch;
}

.content-frame {
  width: 100%;
  max-width: 1400px;
  background: rgba(30, 30, 50, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 
    0 25px 50px rgba(0, 0, 0, 0.5),
    0 0 0 1px rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.1);
  animation: slideUp 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  position: relative;
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

#contentFrame {
  width: 100%;
  height: calc(100vh - 160px);
  border: none;
  background: transparent;
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

/* Mobile Navigation Overlay */
.mobile-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(10px);
  z-index: 999;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
}

.mobile-overlay.active {
  opacity: 1;
  visibility: visible;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .sidebar {
    transform: translateX(-100%);
  }
  
  .sidebar.mobile-open {
    transform: translateX(0);
  }
  
  .main-content {
    margin-left: 0;
  }
  
  .main-content.expanded {
    margin-left: 0;
  }
}

@media (max-width: 768px) {
  .top-bar {
    padding: 1rem;
  }
  
  .page-title {
    font-size: 1.2rem;
  }
  
  .content-wrapper {
    padding: 1rem;
  }
  
  .content-frame {
    border-radius: 16px;
  }
  
  #contentFrame {
    height: calc(100vh - 140px);
  }
  
  .alert {
    right: 1rem;
    left: 1rem;
    min-width: auto;
    top: 80px;
  }
}

@media (max-width: 480px) {
  .sidebar-header {
    padding: 1.5rem 1rem;
  }
  
  .logo-title {
    font-size: 1.1rem;
  }
  
  .nav-item {
    padding: 0.75rem 1rem;
    margin: 0.25rem 0.75rem;
  }
  
  .user-profile {
    padding: 1rem;
  }
  
  .content-wrapper {
    padding: 0.5rem;
  }
  
  #contentFrame {
    height: calc(100vh - 120px);
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
.nav-item:focus-visible,
.logout-btn:focus-visible,
.sidebar-toggle:focus-visible {
  outline: 2px solid #64b5f6;
  outline-offset: 2px;
}

/* Animation for content loading */
.content-frame.loading::before {
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
  z-index: 1;
}

@keyframes spin {
  0% { transform: translate(-50%, -50%) rotate(0deg); }
  100% { transform: translate(-50%, -50%) rotate(360deg); }
}

/* Staggered animations */
.sidebar-header { animation: fadeIn 0.6s ease-out 0.1s both; }
.nav-section:nth-child(1) { animation: fadeIn 0.6s ease-out 0.3s both; }
.nav-section:nth-child(2) { animation: fadeIn 0.6s ease-out 0.4s both; }
.nav-section:nth-child(3) { animation: fadeIn 0.6s ease-out 0.5s both; }
.user-profile { animation: fadeIn 0.6s ease-out 0.6s both; }
.main-content { animation: fadeIn 0.6s ease-out 0.2s both; }

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
    </style>
</head>
<body>
    <!-- Mobile Overlay -->
    <div class="mobile-overlay" id="mobileOverlay" onclick="closeMobileSidebar()"></div>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <!-- Logo Section -->
        <div class="sidebar-header">
            <div class="logo-icon">
                <i class="fas fa-graduation-cap"></i>
            </div>
            <div class="logo-text">
                <div class="logo-title">Pahana Edu</div>
                <div class="logo-subtitle">Book Shop Admin</div>
            </div>
        </div>

        <!-- Navigation Menu -->
        <nav class="sidebar-nav">
            <!-- Main Section -->
            <div class="nav-section">
                <div class="nav-section-title">Main</div>
                <a href="<%=request.getContextPath()%>/jsp/customerForm.jsp" class="nav-item active" onclick="setActive(this)">
                    <div class="nav-item-icon">
                        <i class="fas fa-user-friends"></i>
                    </div>
                    <div class="nav-item-text">Customer Management</div>
                </a>
                <a href="<%=request.getContextPath()%>/jsp/itemForm.jsp" class="nav-item" onclick="setActive(this)">
                    <div class="nav-item-icon">
                        <i class="fas fa-boxes"></i>
                    </div>
                    <div class="nav-item-text">Item Management</div>
                </a>
                <a href="<%=request.getContextPath()%>/jsp/billing-history.jsp" class="nav-item" onclick="setActive(this)">
                    <div class="nav-item-icon">
                        <i class="fas fa-receipt"></i>
                    </div>
                    <div class="nav-item-text">Billing History</div>
                </a>
            </div>

            <!-- Analytics Section -->
            <div class="nav-section">
                <div class="nav-section-title">Analytics</div>
                <a href="<%=request.getContextPath()%>/jsp/reportMenu.jsp" class="nav-item" onclick="setActive(this)">
                    <div class="nav-item-icon">
                        <i class="fas fa-chart-pie"></i>
                    </div>
                    <div class="nav-item-text">Reports & Analytics</div>
                </a>
            </div>

            <!-- Support Section -->
            <div class="nav-section">
                <div class="nav-section-title">Support</div>
                <a href="<%=request.getContextPath()%>/jsp/help.jsp" class="nav-item" onclick="setActive(this)">
                    <div class="nav-item-icon">
                        <i class="fas fa-life-ring"></i>
                    </div>
                    <div class="nav-item-text">Help & Support</div>
                </a>
            </div>
        </nav>

        <!-- User Profile Section -->
        <div class="user-profile">
            <div class="user-info-card">
                <div class="user-avatar">
                    <%= loggedUser.getUsername().substring(0, 1).toUpperCase() %>
                </div>
                <div class="user-details">
                    <div class="user-name"><%= loggedUser.getUsername() %></div>
                    <div class="user-role">Administrator</div>
                </div>
            </div>
            <form action="<%=request.getContextPath()%>/logout" method="post">
                <button type="submit" class="logout-btn">
                    <i class="fas fa-power-off"></i>
                    <span class="logout-btn-text">Logout</span>
                </button>
            </form>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content" id="mainContent">
        <!-- Top Bar -->
        <div class="top-bar">
            <button class="sidebar-toggle" onclick="toggleSidebar()">
                <i class="fas fa-bars"></i>
            </button>
            <div class="page-title" id="pageTitle">
                <i class="fas fa-user-friends"></i>
                Customer Management
            </div>
            <div></div>
        </div>

        <!-- Content Wrapper -->
        <div class="content-wrapper">
            <div class="content-frame">
                <iframe id="contentFrame" src="<%=request.getContextPath()%>/jsp/customerForm.jsp"></iframe>
            </div>
        </div>
    </main>

    <script>
        // Navigation management
        const navItems = [
            { 
                href: '<%=request.getContextPath()%>/jsp/customerForm.jsp', 
                title: 'Customer Management', 
                icon: 'fas fa-user-friends' 
            },
            { 
                href: '<%=request.getContextPath()%>/jsp/itemForm.jsp', 
                title: 'Item Management', 
                icon: 'fas fa-boxes' 
            },
            { 
                href: '<%=request.getContextPath()%>/jsp/billing-history.jsp', 
                title: 'Billing History', 
                icon: 'fas fa-receipt' 
            },
            { 
                href: '<%=request.getContextPath()%>/jsp/reportMenu.jsp', 
                title: 'Reports & Analytics', 
                icon: 'fas fa-chart-pie' 
            },
            { 
                href: '<%=request.getContextPath()%>/jsp/help.jsp', 
                title: 'Help & Support', 
                icon: 'fas fa-life-ring' 
            }
        ];

        // Set active navigation item
        function setActive(element) {
            // Remove active class from all nav items
            document.querySelectorAll('.nav-item').forEach(item => {
                item.classList.remove('active');
            });
            
            // Add active class to clicked item
            element.classList.add('active');
            
            // Update page title
            const href = element.getAttribute('href');
            const navItem = navItems.find(item => item.href === href);
            if (navItem) {
                const pageTitle = document.getElementById('pageTitle');
                pageTitle.innerHTML = `<i class="${navItem.icon}"></i> ${navItem.title}`;
            }
            
            // Load content in iframe with loading state
            const contentFrame = document.getElementById('contentFrame');
            const contentFrameContainer = contentFrame.parentElement;
            contentFrameContainer.classList.add('loading');
            
            contentFrame.onload = () => {
                contentFrameContainer.classList.remove('loading');
            };
            
            contentFrame.src = href;
            
            // Close mobile sidebar if open
            closeMobileSidebar();
            
            // Prevent default link behavior
            return false;
        }

        // Sidebar toggle functionality
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');
            const mobileOverlay = document.getElementById('mobileOverlay');
            
            if (window.innerWidth <= 1024) {
                // Mobile behavior
                sidebar.classList.toggle('mobile-open');
                mobileOverlay.classList.toggle('active');
            } else {
                // Desktop behavior
                sidebar.classList.toggle('collapsed');
                mainContent.classList.toggle('expanded');
            }
        }

        // Close mobile sidebar
        function closeMobileSidebar() {
            const sidebar = document.getElementById('sidebar');
            const mobileOverlay = document.getElementById('mobileOverlay');
            
            sidebar.classList.remove('mobile-open');
            mobileOverlay.classList.remove('active');
        }

        // Update navigation links to use setActive
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', function(e) {
                e.preventDefault();
                setActive(this);
            });
        });

        // Handle window resize
        window.addEventListener('resize', function() {
            if (window.innerWidth > 1024) {
                closeMobileSidebar();
            }
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

        // Initialize sidebar state based on screen size
        function initializeSidebar() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');
            
            if (window.innerWidth <= 1024) {
                sidebar.classList.remove('collapsed');
                mainContent.classList.remove('expanded');
            }
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            initializeSidebar();
        });

        // Handle window resize for responsive behavior
        window.addEventListener('resize', initializeSidebar);
    </script>

    <c:if test="${not empty sessionScope.flashSuccess}">
        <script>
            showAlert("${fn:escapeXml(sessionScope.flashSuccess)}", "success");
        </script>
        <c:remove var="flashSuccess" scope="session"/>
    </c:if>
</body>
</html>