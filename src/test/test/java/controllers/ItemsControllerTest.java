/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import dao.ItemDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Item;
import org.junit.jupiter.api.*;
import org.mockito.MockedConstruction;

import java.util.concurrent.atomic.AtomicReference;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests for itemsController#doPost
 */
class ItemsControllerTest {

    HttpServletRequest request;
    HttpServletResponse response;
    HttpSession session;

    @BeforeEach
    void setUp() {
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);

        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn(""); // adjust to "/app" if you deploy under a context
    }

    @AfterEach
    void printPass(TestInfo info) {
        System.out.println("[PASS] " + info.getDisplayName());
    }

    @Test
    @DisplayName("IT-01 add: success → validates inputs, calls insertItem, sets flash, redirects ?msg=success")
    void add_success() throws Exception {
        when(request.getParameter("action")).thenReturn("add");
        when(request.getParameter("name")).thenReturn("Maths Book");
        when(request.getParameter("description")).thenReturn("A/L");
        when(request.getParameter("price")).thenReturn("950.00");
        when(request.getParameter("stock_quantity")).thenReturn("10");

        try (MockedConstruction<ItemDAO> mocked = org.mockito.Mockito.mockConstruction(
                ItemDAO.class,
                (mock, context) -> when(mock.insertItem(any(Item.class))).thenReturn(true)
        )) {
            itemsController c = new itemsController();
            c.doPost(request, response);

            ItemDAO mockDao = mocked.constructed().get(0);
            verify(mockDao).insertItem(argThat(it ->
                    "Maths Book".equals(it.getItemName())
                            && "A/L".equals(it.getDescription())
                            && "950.00".equals(it.getPrice())
                            && "10".equals(it.getStockQuantity())
            ));
            verify(session).setAttribute(eq("flashSuccess"), contains("add successfully"));
            verify(response).sendRedirect("/jsp/itemForm.jsp?msg=success");
        }
    }

    @Test
    @DisplayName("IT-02 edit: success → parses id, calls updateItem, sets flash, redirects ?msg=success")
    void edit_success() throws Exception {
        when(request.getParameter("action")).thenReturn("edit");
        when(request.getParameter("item_id")).thenReturn("5");
        when(request.getParameter("name")).thenReturn("Blue Pen");
        when(request.getParameter("description")).thenReturn("Fine tip");
        when(request.getParameter("price")).thenReturn("45.00");
        when(request.getParameter("stock_quantity")).thenReturn("100");

        try (MockedConstruction<ItemDAO> mocked = org.mockito.Mockito.mockConstruction(
                ItemDAO.class,
                (mock, context) -> when(mock.updateItem(any(Item.class))).thenReturn(true)
        )) {
            itemsController c = new itemsController();
            c.doPost(request, response);

            ItemDAO mockDao = mocked.constructed().get(0);
            verify(mockDao).updateItem(argThat(it ->
                    it.getItemId() == 5
                            && "Blue Pen".equals(it.getItemName())
                            && "Fine tip".equals(it.getDescription())
                            && "45.00".equals(it.getPrice())
                            && "100".equals(it.getStockQuantity())
            ));
            verify(session).setAttribute(eq("flashSuccess"), contains("edit successfully"));
            verify(response).sendRedirect("/jsp/itemForm.jsp?msg=success");
        }
    }

    @Test
    @DisplayName("IT-03 delete: success → calls deleteItem, sets flash, redirects ?msg=success")
    void delete_success() throws Exception {
        when(request.getParameter("action")).thenReturn("delete");
        when(request.getParameter("item_id")).thenReturn("7");

        try (MockedConstruction<ItemDAO> mocked = org.mockito.Mockito.mockConstruction(
                ItemDAO.class,
                (mock, context) -> when(mock.deleteItem("7")).thenReturn(true)
        )) {
            itemsController c = new itemsController();
            c.doPost(request, response);

            ItemDAO mockDao = mocked.constructed().get(0);
            verify(mockDao).deleteItem("7");
            verify(session).setAttribute(eq("flashSuccess"), contains("delete successfully"));
            verify(response).sendRedirect("/jsp/itemForm.jsp?msg=success");
        }
    }

    @Test
    @DisplayName("IT-04 missing action → lastError set, redirects ?msg=error")
    void missingAction_redirectsError() throws Exception {
        when(request.getParameter("action")).thenReturn(null);

        try (MockedConstruction<ItemDAO> mocked = org.mockito.Mockito.mockConstruction(ItemDAO.class)) {
            itemsController c = new itemsController();
            c.doPost(request, response);

            // controller records the exception in session
            verify(session).setAttribute(eq("lastError"), contains("IllegalArgumentException: Missing action"));
            verify(response).sendRedirect("/jsp/itemForm.jsp?msg=error");
            // DAO should not be used
            ItemDAO mockDao = mocked.constructed().get(0);
            verifyNoInteractions(mockDao);
        }
    }

    @Test
    @DisplayName("IT-05 add: validation failure (bad price) → lastError set, redirects ?msg=error, no DAO call")
    void add_badPrice_redirectsError() throws Exception {
        when(request.getParameter("action")).thenReturn("add");
        when(request.getParameter("name")).thenReturn("Ruler");
        when(request.getParameter("description")).thenReturn("30cm");
        when(request.getParameter("price")).thenReturn("abc"); // invalid BigDecimal
        when(request.getParameter("stock_quantity")).thenReturn("3");

        try (MockedConstruction<ItemDAO> mocked = org.mockito.Mockito.mockConstruction(ItemDAO.class)) {
            itemsController c = new itemsController();
            c.doPost(request, response);

            verify(session).setAttribute(eq("lastError"), contains("NumberFormatException"));
            verify(response).sendRedirect("/jsp/itemForm.jsp?msg=error");
            ItemDAO mockDao = mocked.constructed().get(0);
            verifyNoInteractions(mockDao);
        }
    }

    @Test
    @DisplayName("IT-06 add: required fields missing → error and no DAO call")
    void add_missingFields_redirectsError() throws Exception {
        when(request.getParameter("action")).thenReturn("add");
        // omit name/price/stock etc. to trigger 'Required fields missing'
        when(request.getParameter("description")).thenReturn("Something");

        try (MockedConstruction<ItemDAO> mocked = org.mockito.Mockito.mockConstruction(ItemDAO.class)) {
            itemsController c = new itemsController();
            c.doPost(request, response);

            verify(session).setAttribute(eq("lastError"), contains("Required fields missing"));
            verify(response).sendRedirect("/jsp/itemForm.jsp?msg=error");
            ItemDAO mockDao = mocked.constructed().get(0);
            verifyNoInteractions(mockDao);
        }
    }
}

