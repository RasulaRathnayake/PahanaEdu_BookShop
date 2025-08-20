/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.*;
import static org.mockito.Mockito.*;

/**
 * Tests for LogoutController#doPost
 */
class LogoutControllerTest {

    LogoutController controller;

    HttpServletRequest request;
    HttpServletResponse response;

    @BeforeEach
    void setUp() {
        controller = new LogoutController();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
    }

    @AfterEach
    void printPass(TestInfo info) {
        System.out.println("[PASS] " + info.getDisplayName());
    }

    @Test
    @DisplayName("LG-01 existing session: invalidates old, sets flash on new, redirects to /jsp/login.jsp")
    void logout_withExistingSession() throws Exception {
        // existing session present
        HttpSession oldSession = mock(HttpSession.class);
        when(request.getSession(false)).thenReturn(oldSession);

        // new session for flash
        HttpSession newSession = mock(HttpSession.class);
        when(request.getSession(true)).thenReturn(newSession);

        // context path (adjust if your app uses a non-empty context)
        when(request.getContextPath()).thenReturn("");

        controller.doPost(request, response);

        // old session invalidated
        verify(oldSession).invalidate();

        // flash set on the fresh session
        verify(newSession).setAttribute(eq("flashSuccess"), eq("You have logged out successfully"));

        // redirected to login page (respecting context path)
        verify(response).sendRedirect("/jsp/login.jsp");
    }

    @Test
    @DisplayName("LG-02 no existing session: creates new session for flash, redirects to contextPath + /jsp/login.jsp")
    void logout_withoutExistingSession() throws Exception {
        // no old session
        when(request.getSession(false)).thenReturn(null);

        // new session for flash
        HttpSession newSession = mock(HttpSession.class);
        when(request.getSession(true)).thenReturn(newSession);

        // simulate non-empty context path (e.g., deployed under /app)
        when(request.getContextPath()).thenReturn("/app");

        controller.doPost(request, response);

        // no invalidate called
        // (old session is null, so nothing to verify here)

        // flash set
        verify(newSession).setAttribute(eq("flashSuccess"), eq("You have logged out successfully"));

        // redirected using context path
        verify(response).sendRedirect("/app/jsp/login.jsp");
    }
}

