# 📚 Pahana Edu Bookshop Billing System

A web-based billing and customer management system for **Pahana Edu Bookshop**, built with **Java EE (Servlets & JSP), MySQL, and GlassFish**.  
It supports **Admin** and **Cashier** roles, secure authentication with hashed passwords, billing & invoice printing, email notifications, and report generation.

---

## ✨ Features

### 👤 User Authentication
- Two roles: **Admin** and **Cashier**
- Login with **hashed passwords** (BCrypt)
- Role-based dashboards (Admin / Cashier)
- Logout & session management

### 👥 Customer Management
- Add, edit, view customers (Admin & Cashier)
- Unique account number per customer
- Email notification on registration (Java Mail API)

### 📦 Item Management (Admin only)
- Add, update, delete items
- Manage item name, description, price, and stock
- Validation for negative values

### 🧾 Billing (Cashier only)
- Select customer & items
- Add multiple items with quantity
- Auto calculate total + tax
- Save bill in database
- Generate **printable PDF invoice**

### 📊 Reports (Admin only)
- Daily and monthly sales reports
- Customer consumption summaries
- Customer payment history
- Audit log reports
- Export as **CSV or PDF**
- Visual charts using JS library (Chart.js)

### ❓ Help Section
- Role-based help documentation for Admin and Cashier

---

## 🛠️ Tech Stack

- **Backend:** Java EE (Servlets, JSP, JDBC)
- **Database:** MySQL
- **Server:** GlassFish 7.0.x
- **Frontend:** JSP, HTML, CSS, JavaScript
- **Reports:** Chart.js, iText / Jasper for PDF export
- **Email:** Java Mail API (SMTP, Gmail with App Passwords)

---

## ⚙️ Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/RasulaRathnayake/PahanaEdu_BookShop.git
cd PahanaEdu_BookShop
