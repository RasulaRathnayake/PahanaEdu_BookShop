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
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .help-container {
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .help-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }

        .help-header h1 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }

        .role-badge {
            background: rgba(255, 255, 255, 0.2);
            padding: 0.3rem 1rem;
            border-radius: 20px;
            font-size: 1rem;
            font-weight: 500;
        }

        .help-content {
            padding: 2rem;
        }

        .search-box {
            width: 100%;
            max-width: 500px;
            margin: 0 auto 2rem;
            position: relative;
        }

        .search-input {
            width: 100%;
            padding: 15px 50px 15px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 50px;
            font-size: 16px;
            outline: none;
            transition: all 0.3s ease;
        }

        .search-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .search-icon {
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
            font-size: 18px;
        }

        .help-sections {
            display: grid;
            gap: 2rem;
        }

        .help-section {
            background: white;
            border-radius: 15px;
            padding: 1.5rem;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            border-left: 5px solid #667eea;
            transition: all 0.3s ease;
        }

        .help-section:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
        }

        .help-section h2 {
            color: #333;
            margin-bottom: 1rem;
            font-size: 1.5rem;
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            user-select: none;
        }

        .help-section h2:hover {
            color: #667eea;
        }

        .section-content {
            margin-left: 2rem;
            line-height: 1.6;
            color: #555;
        }

        .section-content.collapsed {
            display: none;
        }

        .toggle-icon {
            transition: transform 0.3s ease;
        }

        .toggle-icon.rotated {
            transform: rotate(180deg);
        }

        .step-list {
            list-style: none;
            counter-reset: step-counter;
        }

        .step-list li {
            counter-increment: step-counter;
            margin-bottom: 1rem;
            padding-left: 3rem;
            position: relative;
        }

        .step-list li::before {
            content: counter(step-counter);
            position: absolute;
            left: 0;
            top: 0;
            background: #667eea;
            color: white;
            width: 25px;
            height: 25px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 12px;
        }

        .tip-box {
            background: #f8f9ff;
            border: 1px solid #e0e6ff;
            border-radius: 10px;
            padding: 1rem;
            margin: 1rem 0;
            border-left: 4px solid #667eea;
        }

        .tip-box .tip-title {
            font-weight: 600;
            color: #667eea;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 0.5rem;
        }

        .warning-box {
            background: #fff9e6;
            border: 1px solid #ffe066;
            border-radius: 10px;
            padding: 1rem;
            margin: 1rem 0;
            border-left: 4px solid #ffa500;
        }

        .warning-box .warning-title {
            font-weight: 600;
            color: #cc8400;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 0.5rem;
        }

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }

        .feature-card {
            background: #f8f9ff;
            border: 1px solid #e0e6ff;
            border-radius: 10px;
            padding: 1rem;
            text-align: center;
            transition: all 0.3s ease;
        }

        .feature-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .feature-card i {
            font-size: 2rem;
            color: #667eea;
            margin-bottom: 0.5rem;
        }

        .feature-card h4 {
            color: #333;
            margin-bottom: 0.5rem;
        }

        .keyboard-shortcut {
            background: #333;
            color: white;
            padding: 3px 8px;
            border-radius: 5px;
            font-size: 12px;
            font-weight: 500;
            margin: 0 3px;
        }

        .quick-actions {
            display: flex;
            gap: 1rem;
            margin-top: 1rem;
            flex-wrap: wrap;
        }

        .quick-action-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 25px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
        }

        .quick-action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
            color: white;
            text-decoration: none;
        }

        @media (max-width: 768px) {
            .help-container {
                margin: 10px;
            }

            .help-content {
                padding: 1rem;
            }

            .help-header h1 {
                font-size: 2rem;
                flex-direction: column;
                gap: 10px;
            }

            .section-content {
                margin-left: 1rem;
            }

            .quick-actions {
                justify-content: center;
            }
        }

        .hidden {
            display: none !important;
        }
    </style>
</head>
<body>
    <div class="help-container">
        <div class="help-header">
            <h1>
                <i class="fas fa-question-circle"></i>
                Help & User Guide
                <span class="role-badge"><%= userRole %> Guide</span>
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
