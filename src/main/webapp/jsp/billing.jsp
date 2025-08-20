<%-- 
    Document   : billing
    Created on : Aug 11, 2025, 4:19:26 PM
    Author     : ugdin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ page import="models.User,dao.CustomerDAO,dao.ItemDAO,models.Customer,models.Item,java.util.List" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || (!"CASHIER".equals(u.getRole()) && !"ADMIN".equals(u.getRole()))) { response.sendRedirect("../login.jsp"); return; }

  CustomerDAO cdao = new CustomerDAO();
  ItemDAO idao = new ItemDAO();
  java.util.List<Customer> customers = cdao.getAllCustomers();
  java.util.List<Item> items = idao.getAllItems();

  String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Billing (Cashier)</title>
  <style>
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
  padding: 2rem;
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

/* Main Container */
.billing-container {
  max-width: 1400px;
  margin: 0 auto;
  background: rgba(30, 30, 50, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
  padding: 3rem;
  animation: slideUp 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94);
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

/* Page Header */
.invoice-header {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 3rem;
  padding-bottom: 2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  gap: 1.5rem;
}

.invoice-icon {
  background: linear-gradient(135deg, #64b5f6, #42a5f5);
  width: 60px;
  height: 60px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.8rem;
  color: white;
  box-shadow: 0 8px 20px rgba(100, 181, 246, 0.3);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

h2 {
  font-size: 2.5rem;
  font-weight: 700;
  color: #e2e8f0;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  margin: 0;
}

/* Form Styling */
#billForm {
  width: 100%;
}

#billForm > div {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 16px;
  padding: 2rem;
  margin-bottom: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.3s ease;
}

#billForm > div:hover {
  border-color: rgba(100, 181, 246, 0.3);
  box-shadow: 0 8px 25px rgba(100, 181, 246, 0.1);
}

/* Labels */
label {
  font-size: 0.95rem;
  font-weight: 600;
  color: #64b5f6;
  margin-bottom: 0.75rem;
  display: block;
}

/* Form Controls */
select, input[type="number"] {
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  padding: 1rem;
  color: #e2e8f0;
  font-size: 0.95rem;
  font-family: inherit;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
  width: 100%;
  margin-bottom: 1.5rem;
}

select:focus, input[type="number"]:focus {
  outline: none;
  border-color: #64b5f6;
  box-shadow: 0 0 0 3px rgba(100, 181, 246, 0.2);
  background: rgba(255, 255, 255, 0.12);
}

select option {
  background: #1a1a2e;
  color: #e2e8f0;
}

/* Section Headers */
h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #e2e8f0;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

h3::before {
  content: '🛒';
  color: #64b5f6;
  font-size: 1.3rem;
}

/* Add Item Button */
button[onclick="addLine()"] {
  background: linear-gradient(135deg, #48bb78, #38a169);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 12px;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  margin-bottom: 1.5rem;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(72, 187, 120, 0.3);
}

button[onclick="addLine()"]:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(72, 187, 120, 0.4);
}

button[onclick="addLine()"]::before {
  content: '+ ';
  font-weight: 700;
}

/* Table Styling */
table {
  width: 100%;
  border-collapse: collapse;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
  margin-bottom: 2rem;
}

table th {
  background: linear-gradient(135deg, rgba(100, 181, 246, 0.2), rgba(66, 165, 245, 0.15));
  color: #64b5f6;
  padding: 1.25rem;
  text-align: left;
  font-weight: 600;
  font-size: 0.95rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

table td {
  padding: 1.25rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  vertical-align: middle;
}

table tr:hover {
  background: rgba(100, 181, 246, 0.05);
}

/* Table Form Controls */
table select,
table input {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  padding: 0.75rem;
  color: #e2e8f0;
  font-size: 0.9rem;
  width: 100%;
  margin: 0;
}

table select:focus,
table input:focus {
  border-color: #64b5f6;
  box-shadow: 0 0 0 2px rgba(100, 181, 246, 0.2);
}

/* Remove Button */
button[type="button"]:not([onclick="addLine()"]):not([onclick="submitBill()"]) {
  background: linear-gradient(135deg, #f56565, #e53e3e);
  color: white;
  border: none;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  font-size: 0.85rem;
  transition: all 0.3s ease;
}

button[type="button"]:not([onclick="addLine()"]):not([onclick="submitBill()"]):hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 15px rgba(245, 101, 101, 0.4);
}

/* Totals Section */
#billForm > div:last-of-type {
  background: rgba(0, 0, 0, 0.3);
  border-radius: 16px;
  padding: 2rem;
  margin-top: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  justify-content: space-around;
  align-items: center;
  flex-wrap: wrap;
  gap: 1.5rem;
  font-size: 1.2rem;
  font-weight: 600;
}

#billForm > div:last-of-type span {
  color: #64b5f6;
  font-weight: 700;
  font-size: 1.3rem;
}

#grand_total {
  color: #64b5f6 !important;
  font-size: 1.8rem !important;
  text-shadow: 0 2px 10px rgba(100, 181, 246, 0.3);
}

/* Submit Button */
button[onclick="submitBill()"] {
  background: linear-gradient(135deg, #64b5f6, #42a5f5);
  color: white;
  border: none;
  padding: 1.25rem 3rem;
  border-radius: 16px;
  font-weight: 600;
  font-size: 1.1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 8px 25px rgba(100, 181, 246, 0.3);
  display: block;
  margin: 2rem auto 0;
}

button[onclick="submitBill()"]:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 35px rgba(100, 181, 246, 0.4);
}

button[onclick="submitBill()"]::before {
  content: '💾 ';
  margin-right: 0.5rem;
}

/* Stock Warning Styling */
tr[style*="rgba(220,53,69,0.08)"] {
  background: rgba(245, 101, 101, 0.1) !important;
  border: 1px solid rgba(245, 101, 101, 0.3) !important;
}

tr[style*="rgba(220,53,69,0.08)"] td {
  border-color: rgba(245, 101, 101, 0.2);
}

/* Alert Styles */
.alert {
  position: fixed;
  top: 2rem;
  right: 2rem;
  padding: 1rem 1.5rem;
  border-radius: 12px;
  color: white;
  font-weight: 600;
  z-index: 1000;
  min-width: 300px;
  backdrop-filter: blur(20px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
  animation: slideInRight 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

@keyframes slideInRight {
  from {
    transform: translateX(120%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.alert.success {
  background: linear-gradient(135deg, #48bb78, #38a169);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.alert.error {
  background: linear-gradient(135deg, #f56565, #e53e3e);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

/* Responsive Design */
@media (max-width: 1024px) {
  body {
    padding: 1rem;
  }
  
  .billing-container {
    padding: 2rem;
  }
}

@media (max-width: 768px) {
  body {
    padding: 0.5rem;
  }
  
  .billing-container {
    padding: 1.5rem;
  }
  
  h2 {
    font-size: 2rem;
  }
  
  h2::before {
    width: 50px;
    height: 50px;
    font-size: 1.5rem;
  }
  
  table {
    font-size: 0.85rem;
  }
  
  table th, 
  table td {
    padding: 0.75rem;
  }
  
  #billForm > div:last-of-type {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }
}

@media (max-width: 480px) {
  .billing-container {
    padding: 1rem;
  }
  
  h2 {
    font-size: 1.5rem;
  }
  
  table {
    font-size: 0.8rem;
  }
  
  table th,
  table td {
    padding: 0.5rem;
  }
  
  button[onclick="submitBill()"] {
    padding: 1rem 2rem;
    font-size: 1rem;
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
select:focus-visible,
input:focus-visible,
button:focus-visible {
  outline: 2px solid #64b5f6;
  outline-offset: 2px;
}
</style>

<script>
  // --- utils ---
  function currency(n) {
    const x = Number.parseFloat(n || 0);
    return Number.isFinite(x) ? x.toFixed(2) : "0.00";
  }
  function getUnitPrice(selectEl) {
    const opt = selectEl?.options?.[selectEl.selectedIndex] || null;
    const raw = opt?.getAttribute?.('data-price') ?? opt?.dataset?.price ?? "0";
    const num = parseFloat(raw);
    return Number.isFinite(num) ? num : 0;
  }
  function getStock(selectEl) {
    const opt = selectEl?.options?.[selectEl.selectedIndex] || null;
    const raw = opt?.getAttribute?.('data-stock') ?? opt?.dataset?.stock ?? "0";
    const num = parseInt(raw, 10);
    return Number.isFinite(num) ? num : 0;
  }

  // --- totals + stock highlighting ---
  function recalc() {
    let subtotal = 0;
    document.querySelectorAll('#lines tr').forEach(tr => {
      const sel = tr.querySelector('select[name="item_id"]');
      const qtyEl = tr.querySelector('input[name="quantity"]');
      if (!sel || !qtyEl) return;

      const unit  = getUnitPrice(sel);
      const qty   = parseInt(qtyEl.value || "0", 10) || 0;
      const stock = getStock(sel);
      const line  = unit * qty;

      tr.querySelector('.unit').textContent      = currency(unit);
      tr.querySelector('.lineTotal').textContent = currency(line);
      subtotal += line;

      // highlight shortage
      if (qty > stock) {
        tr.style.background = 'rgba(220,53,69,0.08)'; // light red
        qtyEl.title = `Only ${stock} in stock`;
      } else {
        tr.style.background = '';
        qtyEl.title = '';
      }
    });

    const taxRate = parseFloat(document.getElementById('tax_rate')?.value || "0") || 0;
    const taxAmt  = subtotal * (taxRate / 100);
    const total   = subtotal + taxAmt;

    document.getElementById('subtotal').textContent     = currency(subtotal);
    document.getElementById('tax_amt').textContent      = currency(taxAmt);
    document.getElementById('grand_total').textContent  = currency(total);
  }

  // --- add a row ---
  function addLine() {
    const itemsEl = document.getElementById('itemsJson');
    if (!itemsEl) { alert('Item list not found'); return; }

    let items = [];
    try { items = JSON.parse(itemsEl.value) || []; } catch { items = []; }

    const tbody = document.getElementById('lines');
    const tr = document.createElement('tr');

    // Item select
    const tdItem = document.createElement('td');
    const sel = document.createElement('select');
    sel.name = 'item_id';
    sel.required = true;

    const ph = document.createElement('option');
    ph.value = ''; ph.text = '-- choose --'; ph.disabled = true; ph.selected = true;
    ph.setAttribute('data-price','0'); ph.setAttribute('data-stock','0');
    sel.appendChild(ph);

//    items.forEach(it => {
//      const o = document.createElement('option');
//      o.value = it.itemId;
//      o.text  = `${it.itemName} (Rs ${it.price}, stock ${it.stock})`;
//      o.setAttribute('data-price', it.price);
//      o.setAttribute('data-stock', it.stock);
//      sel.appendChild(o);
//    });
//    sel.addEventListener('change', recalc);
//    tdItem.appendChild(sel);
    items.forEach(it => {
        const o = document.createElement('option');
        o.value = it.itemId;
        o.text = it.itemName + ' (Rs ' + it.price + ') ${it.stock}';
        o.setAttribute('data-price', it.price);
        o.setAttribute('data-stock', it.stock);
        sel.appendChild(o);
      });
      sel.onchange = recalc;
      tdItem.appendChild(sel);

    // Qty
    const tdQty = document.createElement('td');
    const qty = document.createElement('input');
    qty.type = 'number'; qty.name = 'quantity'; qty.min = '1'; qty.value = '1';
    qty.addEventListener('input', recalc);
    tdQty.appendChild(qty);

    // Unit + Line
    const tdUnit = document.createElement('td'); tdUnit.className = 'unit';      tdUnit.textContent = '0.00';
    const tdLine = document.createElement('td'); tdLine.className = 'lineTotal'; tdLine.textContent = '0.00';

    // Remove
    const tdAct = document.createElement('td');
    const rm = document.createElement('button'); rm.type='button'; rm.textContent='Remove';
    rm.addEventListener('click', () => { tr.remove(); recalc(); });
    tdAct.appendChild(rm);

    tr.appendChild(tdItem);
    tr.appendChild(tdQty);
    tr.appendChild(tdUnit);
    tr.appendChild(tdLine);
    tr.appendChild(tdAct);

    tbody.appendChild(tr);
    recalc();
  }

  // --- validate + submit ---
  function submitBill() {
    const form  = document.getElementById('billForm');
    const tbody = document.getElementById('lines');

    if (!tbody || tbody.children.length === 0) {
      alert('Please add at least one item');
      return;
    }

    let validCount = 0;
    const shortages = [];
    [...tbody.children].forEach(tr => {
      const sel   = tr.querySelector('select[name="item_id"]');
      const qtyEl = tr.querySelector('input[name="quantity"]');

      const itemTxt = sel?.options?.[sel.selectedIndex]?.text || 'Unknown';
      const qty     = parseInt(qtyEl?.value || "0", 10);
      const stock   = getStock(sel);

      if (sel?.value && qty > 0) {
        validCount++;
        if (qty > stock) shortages.push(`${itemTxt}: need ${qty}, in stock ${stock}`);
      }
    });

    if (validCount === 0) {
      alert('Please select items and set valid quantities');
      return;
    }
    if (shortages.length) {
      alert("Insufficient stock:\n\n" + shortages.join("\n"));
      return;
    }

    form.submit(); // server will also re-check & deduct stock in a transaction
  }
</script>

</head>
<body>


<% if ("success".equals(msg)) { %><script>alert("✔ Bill saved!");</script><% } %>

<form id="billForm" action="<%=request.getContextPath()%>/billing" method="post" target="_blank">
  <div>
    <label>Customer</label>
    <select name="customer_id" required>
      <option value="">-- choose --</option>
      <% for (Customer c : customers) { %>
        <option value="<%= c.getCustomerId() %>"><%= c.getAccountNumber() %> - <%= c.getFirstName()+" "+c.getLastName() %></option>
      <% } %>
    </select>
  </div>

  <div>
    <label>Tax Rate (%)</label>
    <input id="tax_rate" name="tax_rate" type="number" min="0" step="0.01" value="0" oninput="recalc()" />
  </div>

<input type="hidden" id="itemsJson" value='[
<% for (int i=0;i<items.size();i++){ 
     Item it = items.get(i); 
     String safeName = it.getItemName() == null ? "" : it.getItemName().replace("\"","\\\"");
     String price = it.getPrice() == null ? "0" : it.getPrice();
     String stock = it.getStockQuantity() == null ? "0" : it.getStockQuantity();
%>
  {"itemId": <%=it.getItemId()%>, "itemName": "<%=safeName%>", "price": "<%=price%>", "stock": "<%=stock%>"}<%= (i<items.size()-1) ? "," : "" %>
<% } %>
]' />

  <h3>Items</h3>
  <button type="button" onclick="addLine()">+ Add Item</button>

  <table border="1" cellpadding="5" cellspacing="0">
    <thead>
      <tr>
        <th>Item</th>
        <th>Qty</th>
        <th>Unit</th>
        <th>Line Total</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody id="lines"></tbody>
  </table>

  <div>
    Subtotal: Rs <span id="subtotal">0.00</span> |
    Tax: Rs <span id="tax_amt">0.00</span> |
    Grand Total: Rs <span id="grand_total">0.00</span>
  </div>

  <div>
    <button type="button" onclick="submitBill()">Save & Print</button>
  </div>
</form>

</body>
</html>
   