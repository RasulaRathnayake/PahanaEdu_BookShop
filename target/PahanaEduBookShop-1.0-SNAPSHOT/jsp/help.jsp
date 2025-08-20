<%-- 
    Document   : help
    Created on : Aug 14, 2025, 11:37:38 AM
    Author     : ugdin
--%>

<%@ page import="models.User" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userRole = loggedUser.getRole();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help - Pahana Edu Book Shop</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
/* Help Page Styles - Matching the main theme */

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
    line-height: 1.6;
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

/* Help Container */
.help-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem 1rem;
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

/* Help Header */
.help-header {
    text-align: center;
    margin-bottom: 3rem;
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

.help-header h1 {
    font-size: 2.8rem;
    font-weight: 700;
    background: linear-gradient(135deg, #64b5f6, #42a5f5, #a855f7);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    flex-wrap: wrap;
}

.help-header h1 i {
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

.role-badge {
    display: inline-block;
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 25px;
    font-size: 0.9rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1px;
    box-shadow: 0 4px 15px rgba(100, 181, 246, 0.3);
    animation: slideIn 0.8s ease-out 0.5s both;
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: translateX(-20px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

.help-header p {
    color: #94a3b8;
    font-size: 1.2rem;
    font-weight: 500;
    margin-top: 1rem;
}

/* Search Box - Make it optional */
.search-container {
    position: relative;
    max-width: 500px;
    margin: 0 auto 2rem auto;
    animation: slideUp 0.8s ease-out 0.2s both;
}

.search-container i {
    position: absolute;
    left: 1.25rem;
    top: 50%;
    transform: translateY(-50%);
    color: #64b5f6;
    font-size: 1.1rem;
}

#searchInput {
    width: 100%;
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border: 2px solid rgba(100, 181, 246, 0.2);
    border-radius: 50px;
    padding: 1.25rem 1.25rem 1.25rem 3.5rem;
    color: #e2e8f0;
    font-family: 'Poppins', sans-serif;
    font-size: 1.1rem;
    transition: all 0.3s ease;
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
}

#searchInput:focus {
    outline: none;
    border-color: #64b5f6;
    box-shadow: 0 0 0 4px rgba(100, 181, 246, 0.15), 0 8px 25px rgba(0, 0, 0, 0.3);
    background: rgba(0, 0, 0, 0.6);
}

#searchInput::placeholder {
    color: #64748b;
}

/* If no search container exists, adjust help-content margin */
.help-content:not(.help-container .search-container ~ .help-content) {
    margin-top: 0;
}

/* Help Content */
.help-content {
    animation: slideUp 0.8s ease-out 0.4s both;
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

/* Help Sections */
.help-sections {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
}

.help-section {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    overflow: hidden;
    transition: all 0.3s ease;
    border-left: 5px solid #64b5f6;
}

.help-section:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.4);
    border-left-color: #42a5f5;
}

.help-section h2 {
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.1), rgba(66, 165, 245, 0.05));
    padding: 1.5rem 2rem;
    margin: 0;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 1rem;
    font-size: 1.3rem;
    font-weight: 600;
    color: #64b5f6;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    transition: all 0.3s ease;
    user-select: none;
}

.help-section h2:hover {
    background: linear-gradient(135deg, rgba(100, 181, 246, 0.15), rgba(66, 165, 245, 0.08));
    color: #42a5f5;
}

.toggle-icon {
    transition: transform 0.3s ease;
    font-size: 0.9rem !important;
}

.toggle-icon.rotated {
    transform: rotate(90deg);
}

.help-section h2 i:not(.toggle-icon) {
    color: #64b5f6;
    font-size: 1.2rem;
}

/* Section Content */
.section-content {
    padding: 2rem;
    max-height: 0;
    overflow: hidden;
    transition: all 0.4s ease;
    opacity: 0;
}

.section-content:not(.collapsed) {
    max-height: none;
    opacity: 1;
    padding: 2rem;
}

.section-content.collapsed {
    max-height: 0;
    padding: 0 2rem;
    opacity: 0;
}

.section-content > p {
    color: #cbd5e1;
    font-size: 1.05rem;
    margin-bottom: 1.5rem;
    line-height: 1.7;
}

.section-content h3 {
    color: #64b5f6;
    font-size: 1.2rem;
    font-weight: 600;
    margin: 2rem 0 1rem 0;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.section-content h3::before {
    content: '';
    width: 4px;
    height: 20px;
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    border-radius: 2px;
}

/* Lists */
.step-list {
    list-style: none;
    counter-reset: step-counter;
    margin: 1.5rem 0;
}

.step-list li {
    counter-increment: step-counter;
    padding: 1rem 0 1rem 3rem;
    position: relative;
    color: #e2e8f0;
    border-left: 2px solid rgba(100, 181, 246, 0.2);
    margin-left: 1rem;
}

.step-list li::before {
    content: counter(step-counter);
    position: absolute;
    left: -1.5rem;
    top: 0.8rem;
    width: 2rem;
    height: 2rem;
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 0.9rem;
    box-shadow: 0 4px 12px rgba(100, 181, 246, 0.3);
}

.step-list li strong {
    color: #64b5f6;
    font-weight: 600;
}

/* Regular lists */
.section-content ul {
    margin: 1.5rem 0;
    padding-left: 0;
    list-style: none;
}

.section-content ul li {
    padding: 0.75rem 0;
    padding-left: 2rem;
    position: relative;
    color: #e2e8f0;
    border-left: 2px solid rgba(100, 181, 246, 0.1);
    margin-left: 1rem;
    transition: all 0.3s ease;
}

.section-content ul li::before {
    content: '';
    position: absolute;
    left: -0.5rem;
    top: 1.2rem;
    width: 8px;
    height: 8px;
    background: linear-gradient(135deg, #64b5f6, #42a5f5);
    border-radius: 50%;
    box-shadow: 0 2px 8px rgba(100, 181, 246, 0.3);
}

.section-content ul li:hover {
    border-left-color: rgba(100, 181, 246, 0.3);
    transform: translateX(4px);
}

.section-content ul li strong {
    color: #64b5f6;
    font-weight: 600;
}

/* Info Boxes */
.tip-box, .warning-box {
    margin: 2rem 0;
    padding: 1.5rem;
    border-radius: 12px;
    border-left: 4px solid;
    position: relative;
    backdrop-filter: blur(10px);
}

.tip-box {
    background: rgba(16, 185, 129, 0.1);
    border-left-color: #10b981;
    box-shadow: 0 4px 20px rgba(16, 185, 129, 0.1);
}

.warning-box {
    background: rgba(245, 158, 11, 0.1);
    border-left-color: #f59e0b;
    box-shadow: 0 4px 20px rgba(245, 158, 11, 0.1);
}

.tip-title, .warning-title {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    font-weight: 600;
    font-size: 1.1rem;
    margin-bottom: 1rem;
    color: #e2e8f0;
}

.tip-title i {
    color: #10b981;
    font-size: 1.2rem;
}

.warning-title i {
    color: #f59e0b;
    font-size: 1.2rem;
}

.tip-box p, .warning-box p {
    color: #cbd5e1;
    line-height: 1.6;
    margin: 0;
}

/* Navigation Links */
.help-nav {
    background: rgba(30, 30, 50, 0.95);
    backdrop-filter: blur(20px);
    border-radius: 12px;
    padding: 1.5rem;
    margin-bottom: 2rem;
    border: 1px solid rgba(255, 255, 255, 0.1);
    text-align: center;
}

.help-nav a {
    color: #64b5f6;
    text-decoration: none;
    font-weight: 600;
    padding: 0.75rem 1.5rem;
    margin: 0 0.5rem;
    border-radius: 8px;
    background: rgba(100, 181, 246, 0.1);
    border: 1px solid rgba(100, 181, 246, 0.2);
    transition: all 0.3s ease;
    display: inline-block;
}

.help-nav a:hover {
    background: rgba(100, 181, 246, 0.2);
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(100, 181, 246, 0.2);
}

/* Responsive Design */
@media (max-width: 768px) {
    .help-container {
        padding: 1rem 0.5rem;
    }

    .help-header h1 {
        font-size: 2.2rem;
        flex-direction: column;
        gap: 0.5rem;
    }

    .role-badge {
        font-size: 0.8rem;
        padding: 0.4rem 0.8rem;
    }

    .help-section h2 {
        font-size: 1.1rem;
        padding: 1.25rem 1.5rem;
        flex-wrap: wrap;
    }

    .section-content {
        padding: 1.5rem;
    }

    .section-content:not(.collapsed) {
        padding: 1.5rem;
    }

    .step-list li {
        padding-left: 2.5rem;
    }

    .step-list li::before {
        left: -1.25rem;
        width: 1.5rem;
        height: 1.5rem;
        font-size: 0.8rem;
    }

    .section-content ul li {
        padding-left: 1.5rem;
    }

    #searchInput {
        font-size: 1rem;
        padding: 1rem 1rem 1rem 3rem;
    }

    .search-container i {
        left: 1rem;
    }
}

@media (max-width: 480px) {
    .help-header h1 {
        font-size: 1.8rem;
    }

    .help-section h2 {
        font-size: 1rem;
        padding: 1rem;
        gap: 0.75rem;
    }

    .section-content {
        padding: 1rem;
    }

    .section-content:not(.collapsed) {
        padding: 1rem;
    }

    .tip-box, .warning-box {
        padding: 1rem;
    }
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
    
    .help-section {
        background: white !important;
        border: 1px solid #ccc !important;
        box-shadow: none !important;
    }
    
    .help-section h2 {
        background: #f5f5f5 !important;
        color: #333 !important;
    }
    
    .section-content {
        max-height: none !important;
        opacity: 1 !important;
        padding: 1rem !important;
    }
    
    .search-container {
        display: none !important;
    }
    
    .tip-box, .warning-box {
        background: #f9f9f9 !important;
        border-left-color: #666 !important;
    }
}

/* Focus styles for accessibility */
*:focus-visible {
    outline: 2px solid #64b5f6;
    outline-offset: 2px;
    border-radius: 4px;
}

/* Custom scrollbar */
::-webkit-scrollbar {
    width: 8px;
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
    </style>
</head>
<body>
    <div class="help-container">
        <div class="help-header">
            <h1>
                <i class="fas fa-question-circle"></i>
                Help & User Guide
<!--                <span class="role-badge"><%= userRole %> Guide</span>-->
            </h1>
            <p>Welcome to the Pahana Edu Book Shop system help center</p>
        </div>

        <div class="help-content">
            

            <div class="help-sections" id="helpSections">
                <% if ("ADMIN".equals(userRole)) { %>
                    <!-- ADMIN HELP SECTIONS -->
                    
                    <div class="help-section" data-keywords="getting started admin dashboard overview">
                        <h2 onclick="toggleSection(this)">
                            <i class="fas fa-play toggle-icon"></i>
                            <i class="fas fa-rocket"></i>
                            Getting Started
                        </h2>
                        <div class="section-content">
                            <p>Welcome to the Admin Dashboard! This comprehensive guide will help you navigate and use all the system features effectively.</p>
                            
                            
                        </div>
                    </div>

                    <div class="help-section" data-keywords="invoice billing create bill payment">
                        <h2 onclick="toggleSection(this)">
                            <i class="fas fa-play toggle-icon"></i>
                            <i class="fas fa-file-invoice"></i>
                            Invoice Management
                        </h2>
                        <div class="section-content">
                            <p>Learn how to create, manage, and process customer invoices efficiently.</p>
                            
                            <h3>Creating a New Invoice:</h3>
                            <ol class="step-list">
                                <li>Navigate to <strong>Invoice Management</strong> from the main menu</li>
                                <li>Select or add a customer from the dropdown</li>
                                <li>Add items by searching and selecting from the inventory</li>
                                <li>Adjust quantities as needed</li>
                                <li>Apply any tax if applicable</li>
                                <li>Review the total and click <strong>"Save & Print"</strong></li>
                            </ol>

                            <h3>Invoice Features:</h3>
                            <ul>
                                <li><strong>Auto-calculation:</strong> Tax and totals are calculated automatically</li>
                                <li><strong>Print functionality:</strong> Generate printable receipts</li>
                            </ul>

                        </div>
                    </div>

                    <div class="help-section" data-keywords="customer management add edit delete client">
                        <h2 onclick="toggleSection(this)">
                            <i class="fas fa-play toggle-icon"></i>
                            <i class="fas fa-users"></i>
                            Customer Management
                        </h2>
                        <div class="section-content">
                            <p>Manage your customer database effectively with these comprehensive tools.</p>
                            
                            <h3>Adding a New Customer:</h3>
                            <ol class="step-list">
                                <li>Go to <strong>Customer Management</strong> section</li>
                                <li>Fill in required information (Name, Contact, Address etc.)</li>
                                <li>Save the customer</li>
                            </ol>

                            <h3>Customer Features:</h3>
                            <ul>
                                <li><strong>Search & Filter:</strong> Quickly find customers by name, phone, or email</li>
                               
                            </ul>

                            <div class="tip-box">
                                <div class="tip-title">
                                    <i class="fas fa-lightbulb"></i>
                                    Best Practice
                                </div>
                                <p>Always verify customer contact information during their visit. Updated information helps with follow-ups and promotional communications.</p>
                            </div>
                        </div>
                    </div>

                    <div class="help-section" data-keywords="inventory item management stock product add edit">
                        <h2 onclick="toggleSection(this)">
                            <i class="fas fa-play toggle-icon"></i>
                            <i class="fas fa-box"></i>
                            Item Management
                        </h2>
                        <div class="section-content">
                            <p>Efficiently manage your inventory with comprehensive item management tools.</p>
                            
                            <h3>Adding New Items:</h3>
                            <ol class="step-list">
                                <li>Navigate to <strong>Item Management</strong></li>
                                <li>Enter item details (Name, Description)</li>
                                <li>Set pricing information ( Price)</li>
                                <li>Add stock quantity and minimum stock levels</li>
                                <li>Save the item</li>
                            </ol>

                            <h3>Inventory Features:</h3>
                            <ul>
                                <li><strong>Stock Tracking:</strong> Real-time inventory levels</li>
                                <li><strong>Low Stock Alerts:</strong> Automatic notifications when items run low</li>
                            </ul>

                            <div class="warning-box">
                                <div class="warning-title">
                                    <i class="fas fa-exclamation-triangle"></i>
                                    Stock Management
                                </div>
                                <p>Regularly update stock levels and set appropriate minimum stock alerts to avoid stockouts. Consider seasonal demand when setting reorder points.</p>
                            </div>
                        </div>
                    </div>

                    <div class="help-section" data-keywords="reports analytics sales billing history">
                        <h2 onclick="toggleSection(this)">
                            <i class="fas fa-play toggle-icon"></i>
                            <i class="fas fa-chart-line"></i>
                            Reports & Analytics
                        </h2>
                        <div class="section-content">
                            <p>Access comprehensive reports and analytics to make informed business decisions.</p>
                            
                            <h3>Available Reports:</h3>
                            <ul>
                                <li><strong>Sales Reports:</strong> Daily, monthly sales summaries</li>
                                <li><strong>Customer Reports:</strong> Purchase patterns and customer analytics</l>
                            </ul>

                            <h3>Generating Reports:</h3>
                            <ol class="step-list">
                                <li>Go to <strong>Reports</strong> section</li>
                                <li>Select report type from the menu</li>
                                <li>Choose date range and filters</li>
                                <li>Click <strong>"Load"</strong></li>
 
                            </ol>

                            <div class="tip-box">
                                <div class="tip-title">
                                    <i class="fas fa-lightbulb"></i>
                                    Analytics Tip
                                </div>
                                <p>Review sales reports weekly to identify trends, popular items, and peak sales periods. Use this data to optimize inventory and staff scheduling.</p>
                            </div>
                        </div>
                    </div>

                <% } else if ("CASHIER".equals(userRole)) { %>
                    <!-- CASHIER HELP SECTIONS -->
                    
                    <div class="help-section" data-keywords="getting started cashier pos point of sale">
                        <h2 onclick="toggleSection(this)">
                            <i class="fas fa-play toggle-icon"></i>
                            <i class="fas fa-rocket"></i>
                            Getting Started - Cashier Guide
                        </h2>
                       <div class="help-section" data-keywords="customer management add edit delete client">
                        <h2 onclick="toggleSection(this)">
                            <i class="fas fa-play toggle-icon"></i>
                            <i class="fas fa-users"></i>
                            Customer Management
                        </h2>
                        <div class="section-content">
                            <p>Manage your customer database effectively with these comprehensive tools.</p>
                            
                            <h3>Adding a New Customer:</h3>
                            <ol class="step-list">
                                <li>Go to <strong>Customer Management</strong> section</li>
                                <li>Fill in required information (Name, Contact, Address etc.)</li>
                                <li>Save the customer</li>
                            </ol>

                            <h3>Customer Features:</h3>
                            <ul>
                                <li><strong>Search & Filter:</strong> Quickly find customers by name, phone, or email</li>
                               
                            </ul>

                            <div class="tip-box">
                                <div class="tip-title">
                                    <i class="fas fa-lightbulb"></i>
                                    Best Practice
                                </div>
                                <p>Always verify customer contact information during their visit. Updated information helps with follow-ups and promotional communications.</p>
                            </div>
                        </div>
                    </div>
                    </div>

                <% } %>

  

            
            </div>
        </div>
    </div>

    <script>
        // Toggle section expansion
        function toggleSection(header) {
            const content = header.nextElementSibling;
            const icon = header.querySelector('.toggle-icon');
            
            content.classList.toggle('collapsed');
            icon.classList.toggle('rotated');
        }

        // Search functionality
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            const sections = document.querySelectorAll('.help-section');
            
            sections.forEach(section => {
                const keywords = section.dataset.keywords || '';
                const content = section.textContent.toLowerCase();
                
                if (searchTerm === '' || keywords.includes(searchTerm) || content.includes(searchTerm)) {
                    section.style.display = 'block';
                    // Highlight matching sections
                    if (searchTerm !== '' && (keywords.includes(searchTerm) || content.includes(searchTerm))) {
                        section.style.background = '#f0f8ff';
                        section.style.borderLeft = '5px solid #007bff';
                    } else {
                        section.style.background = 'white';
                        section.style.borderLeft = '5px solid #667eea';
                    }
                } else {
                    section.style.display = 'none';
                }
            });
        });

        // Auto-expand first section
        document.addEventListener('DOMContentLoaded', function() {
            const firstSection = document.querySelector('.help-section');
            if (firstSection) {
                const firstHeader = firstSection.querySelector('h2');
                // Don't auto-expand, let users choose what to open
                // toggleSection(firstHeader);
            }
        });

        // Smooth scrolling for internal links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Print functionality
        function printHelp() {
            window.print();
        }

        // Keyboard shortcut for help search
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey && e.key === '/') {
                e.preventDefault();
                document.getElementById('searchInput').focus();
            }
        });
    </script>
</body>
</html>
