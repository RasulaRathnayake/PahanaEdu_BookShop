package controllers;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import models.User;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.DisplayName;
import org.mockito.ArgumentCaptor;
import services.AuthService;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AuthControllerTest {

    private AuthService authService;
    private AuthController controller;

    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;

    // Auto-print a pass line after each successful test
    @AfterEach
    void afterEach(TestInfo info) {
        System.out.println("[PASS] " + info.getDisplayName());
    }

    @BeforeEach
    void setUp() throws Exception {
        authService = mock(AuthService.class);

        // ===== CHOOSE ONE SETUP =====
        // A) If you added a public AuthController(AuthService) constructor (recommended)
        controller = new AuthController(authService);

        // B) If you did NOT change the servlet, comment A) and uncomment this:
        /*
        controller = new AuthController(); // no-arg
        var f = AuthController.class.getDeclaredField("authService");
        f.setAccessible(true);
        f.set(controller, authService);
        */

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);

        when(request.getSession()).thenReturn(session);
        when(request.getRequestDispatcher("jsp/login.jsp")).thenReturn(dispatcher);
    }

    @Test
    @DisplayName("UT-01 Admin login → session+cookie and redirect to admin dashboard")
    void adminLogin_redirectsToAdmin_setsSessionAndCookie() throws Exception {
        when(request.getParameter("username")).thenReturn("admin");
        when(request.getParameter("password")).thenReturn("pass");

        User u = new User();
        u.setUsername("admin");
        u.setRole("ADMIN");
        when(authService.authenticate("admin", "pass")).thenReturn(u);

        controller.doPost(request, response);

        // session & flash
        verify(session).setAttribute("user", u);
        verify(session).setAttribute(eq("flashSuccess"), contains("Admin"));

        // cookie
        ArgumentCaptor<Cookie> cookieCap = ArgumentCaptor.forClass(Cookie.class);
        verify(response).addCookie(cookieCap.capture());
        Cookie c = cookieCap.getValue();
        assertEquals("username", c.getName());
        assertEquals("admin", c.getValue());
        assertEquals(3600, c.getMaxAge());

        // redirect (no forward)
        verify(response).sendRedirect("jsp/adminDashboard.jsp");
        verify(dispatcher, never()).forward(request, response);
    }

    @Test
    @DisplayName("UT-02 Cashier login → session and redirect to cashier dashboard")
    void cashierLogin_redirectsToCashier() throws Exception {
        when(request.getParameter("username")).thenReturn("cashier");
        when(request.getParameter("password")).thenReturn("123");

        User u = new User();
        u.setUsername("cashier");
        u.setRole("CASHIER");
        when(authService.authenticate("cashier", "123")).thenReturn(u);

        controller.doPost(request, response);

        verify(session).setAttribute("user", u);
        verify(session).setAttribute(eq("flashSuccess"), contains("Cashier"));
        verify(response).sendRedirect("jsp/cashierDashboard.jsp");
        verify(dispatcher, never()).forward(request, response);
    }

    @Test
    @DisplayName("UT-03 Invalid credentials → forward to login with error")
    void invalidCredentials_forwardsToLoginWithError() throws Exception {
        when(request.getParameter("username")).thenReturn("x");
        when(request.getParameter("password")).thenReturn("y");
        when(authService.authenticate("x", "y")).thenReturn(null);

        controller.doPost(request, response);

        verify(request).setAttribute("error", "Invalid credentials");
        verify(dispatcher).forward(request, response);
        verify(response, never()).sendRedirect(anyString());
    }

    @Test
    @DisplayName("UT-04 Auth exception → forward to login with 'Server error'")
    void exceptionPath_forwardsServerError() throws Exception {
        when(request.getParameter("username")).thenReturn("a");
        when(request.getParameter("password")).thenReturn("b");
        when(authService.authenticate("a", "b")).thenThrow(new RuntimeException("DB down"));

        controller.doPost(request, response);

        verify(request).setAttribute("error", "Server error");
        verify(dispatcher).forward(request, response);
        verify(response, never()).sendRedirect(anyString());
    }
}
