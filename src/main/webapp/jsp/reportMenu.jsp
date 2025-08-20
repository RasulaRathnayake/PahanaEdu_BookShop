<%-- 
    Document   : reportMenu
    Created on : Aug 13, 2025, 10:03:21 PM
    Author     : ugdin
--%>
<%-- admin/reports/reportMenu.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%@ page import="models.User" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }
  String base = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports Dashboard - Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
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
            color: #e2e8f0;
            overflow-x: hidden;
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

        /* Container */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
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

        /* Header */
        .header {
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

        .header h1 {
            font-size: 3rem;
            font-weight: 700;
            background: linear-gradient(135deg, #64b5f6, #42a5f5, #a855f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
            text-shadow: 0 0 50px rgba(100, 181, 246, 0.3);
        }

        .header .subtitle {
            font-size: 1.2rem;
            color: #94a3b8;
            font-weight: 400;
        }

        /* Tree Container */
        .tree-container {
            width: 100%;
            max-width: 800px;
            background: rgba(30, 30, 50, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 2.5rem;
            box-shadow: 
                0 25px 50px rgba(0, 0, 0, 0.5),
                0 0 0 1px rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.1);
            animation: slideUp 1s cubic-bezier(0.25, 0.46, 0.45, 0.94) 0.3s both;
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

        /* Tree Structure */
        .tree {
            list-style: none;
        }

        .tree ul {
            list-style: none;
            margin-left: 2rem;
            margin-top: 1rem;
            padding-left: 1.5rem;
            border-left: 2px solid rgba(100, 181, 246, 0.2);
            position: relative;
        }

        .tree ul::before {
            content: '';
            position: absolute;
            left: -2px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: linear-gradient(180deg, rgba(100, 181, 246, 0.4), rgba(100, 181, 246, 0.1));
        }

        .tree li {
            margin-bottom: 1rem;
            position: relative;
        }

        .tree li::before {
            content: '';
            position: absolute;
            left: -1.7rem;
            top: 50%;
            width: 12px;
            height: 2px;
            background: rgba(100, 181, 246, 0.3);
            transform: translateY(-50%);
        }

        /* Tree Nodes */
        .tree-node {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem 1.5rem;
            border-radius: 16px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            text-decoration: none;
            color: inherit;
            border: 1px solid transparent;
            background: rgba(0, 0, 0, 0.2);
        }

        .tree-node::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(100, 181, 246, 0.15), transparent);
            transition: left 0.5s;
        }

        .tree-node:hover::before {
            left: 100%;
        }

        /* Category Nodes */
        .category-node {
            background: linear-gradient(135deg, rgba(100, 181, 246, 0.15), rgba(66, 165, 245, 0.1));
            border-color: rgba(100, 181, 246, 0.3);
            cursor: default;
            margin-bottom: 0.5rem;
        }

        .category-node .tree-node-text {
            font-weight: 600;
            font-size: 1.1rem;
            color: #64b5f6;
        }

        /* Link Nodes */
        a.tree-node {
            cursor: pointer;
        }

        a.tree-node:hover {
            background: rgba(100, 181, 246, 0.12);
            border-color: rgba(100, 181, 246, 0.4);
            transform: translateX(8px);
            box-shadow: 0 8px 25px rgba(100, 181, 246, 0.2);
        }

        a.tree-node:active {
            transform: translateX(8px) scale(0.98);
        }

        /* Tree Node Elements */
        .tree-node-icon {
            font-size: 1.5rem;
            min-width: 2rem;
            text-align: center;
            filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3));
        }

        .category-node .tree-node-icon {
            background: linear-gradient(135deg, #64b5f6, #42a5f5);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 1.8rem;
        }

        .tree-node-text {
            flex: 1;
            font-weight: 500;
            color: #e2e8f0;
            font-size: 1rem;
        }

        a.tree-node .tree-node-text {
            transition: color 0.3s ease;
        }

        a.tree-node:hover .tree-node-text {
            color: #64b5f6;
        }

        .tree-node-arrow {
            font-size: 1.2rem;
            color: #64b5f6;
            opacity: 0;
            transform: translateX(-10px);
            transition: all 0.3s ease;
        }

        a.tree-node:hover .tree-node-arrow {
            opacity: 1;
            transform: translateX(0);
        }

        /* Staggered animations for tree items */
        .tree > li:nth-child(1) { animation: fadeInUp 0.6s ease-out 0.5s both; }
        .tree > li:nth-child(2) { animation: fadeInUp 0.6s ease-out 0.7s both; }
        .tree ul li:nth-child(1) { animation: fadeInUp 0.6s ease-out 0.9s both; }
        .tree ul li:nth-child(2) { animation: fadeInUp 0.6s ease-out 1.1s both; }
        .tree ul li:nth-child(3) { animation: fadeInUp 0.6s ease-out 1.3s both; }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }

            .header h1 {
                font-size: 2.5rem;
            }

            .header .subtitle {
                font-size: 1rem;
            }

            .tree-container {
                padding: 2rem;
            }

            .tree ul {
                margin-left: 1rem;
                padding-left: 1rem;
            }

            .tree-node {
                padding: 0.875rem 1rem;
            }

            .tree-node-icon {
                font-size: 1.3rem;
            }

            .tree-node-text {
                font-size: 0.95rem;
            }
        }

        @media (max-width: 480px) {
            .header h1 {
                font-size: 2rem;
            }

            .tree-container {
                padding: 1.5rem;
            }

            .tree-node {
                padding: 0.75rem;
            }

            .tree-node-text {
                font-size: 0.9rem;
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
        a.tree-node:focus-visible {
            outline: 2px solid #64b5f6;
            outline-offset: 2px;
        }

        /* Loading animation for dynamic content */
        .tree-container.loading::before {
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
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-chart-line"></i> Reports Dashboard</h1>
            <p class="subtitle">Access comprehensive reports and analytics</p>
        </div>
        
        <div class="tree-container">
            <ul class="tree">
                <li>
                    <div class="tree-node category-node">
                        <span class="tree-node-icon"><i class="fas fa-chart-bar"></i></span>
                        <span class="tree-node-text">Sales Reports</span>
                    </div>
                    <ul>
                        <li>
                            <a href="<%=base%>/jsp/sales-daily.jsp" class="tree-node">
                                <span class="tree-node-icon"><i class="fas fa-calendar-day"></i></span>
                                <span class="tree-node-text">Daily Sales Report</span>
                                <span class="tree-node-arrow"><i class="fas fa-arrow-right"></i></span>
                            </a>
                        </li>
                        <li>
                            <a href="<%=base%>/jsp/sales-monthly.jsp" class="tree-node">
                                <span class="tree-node-icon"><i class="fas fa-calendar-alt"></i></span>
                                <span class="tree-node-text">Monthly Sales Report</span>
                                <span class="tree-node-arrow"><i class="fas fa-arrow-right"></i></span>
                            </a>
                        </li>
                    </ul>
                </li>
                <li>
                    <div class="tree-node category-node">
                        <span class="tree-node-icon"><i class="fas fa-users"></i></span>
                        <span class="tree-node-text">Customer Reports</span>
                    </div>
                    <ul>
                        <li>
                            <a href="<%=base%>/jsp/customer-consumption.jsp" class="tree-node">
                                <span class="tree-node-icon"><i class="fas fa-bolt"></i></span>
                                <span class="tree-node-text">Customer Consumption Report</span>
                                <span class="tree-node-arrow"><i class="fas fa-arrow-right"></i></span>
                            </a>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>

    <script>
        // Add smooth scrolling and enhanced interactions
        document.addEventListener('DOMContentLoaded', function() {
            // Add click ripple effect to tree nodes
            const treeNodes = document.querySelectorAll('a.tree-node');
            
            treeNodes.forEach(node => {
                node.addEventListener('click', function(e) {
                    // Create ripple effect
                    const ripple = document.createElement('span');
                    const rect = this.getBoundingClientRect();
                    const size = Math.max(rect.width, rect.height);
                    const x = e.clientX - rect.left - size / 2;
                    const y = e.clientY - rect.top - size / 2;
                    
                    ripple.style.cssText = `
                        position: absolute;
                        width: ${size}px;
                        height: ${size}px;
                        left: ${x}px;
                        top: ${y}px;
                        background: rgba(100, 181, 246, 0.3);
                        border-radius: 50%;
                        transform: scale(0);
                        animation: ripple 0.6s ease-out;
                        pointer-events: none;
                    `;
                    
                    this.appendChild(ripple);
                    
                    setTimeout(() => {
                        ripple.remove();
                    }, 600);
                });
            });

            // Add CSS for ripple animation
            const style = document.createElement('style');
            style.textContent = `
                @keyframes ripple {
                    0% { transform: scale(0); opacity: 1; }
                    100% { transform: scale(2); opacity: 0; }
                }
                
                .tree-node {
                    position: relative;
                    overflow: hidden;
                }
            `;
            document.head.appendChild(style);

            // Add keyboard navigation
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Tab') {
                    document.body.classList.add('keyboard-nav');
                }
            });

            document.addEventListener('mousedown', function() {
                document.body.classList.remove('keyboard-nav');
            });
        });
    </script>
</body>
</html>