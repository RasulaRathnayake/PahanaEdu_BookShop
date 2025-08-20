/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package services;

import dao.UserDAO;
import models.User;
import org.junit.jupiter.api.*;
import org.mindrot.jbcrypt.BCrypt;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AuthServiceTest {

    AuthService auth;
    UserDAO userDAO; // mock we'll inject

    @BeforeEach
    void setUp() throws Exception {
        auth = new AuthService();            // uses real no-arg constructor
        userDAO = mock(UserDAO.class);

        // reflection-inject our mock into private field 'userDAO'
        var f = AuthService.class.getDeclaredField("userDAO");
        f.setAccessible(true);
        f.set(auth, userDAO);
    }

    @AfterEach
    void pass(TestInfo info) {
        System.out.println("[PASS] " + info.getDisplayName());
    }

    @Test
    @DisplayName("AS-01 valid username + password → returns User")
    void authenticate_success() throws Exception {
        String raw = "s3cret!";
        String hash = BCrypt.hashpw(raw, BCrypt.gensalt());

        User u = new User();
        u.setUserId(1);
        u.setUsername("admin");
        u.setPasswordHash(hash);
        u.setRole("ADMIN");

        when(userDAO.findByUsername("admin")).thenReturn(u);

        User result = auth.authenticate("admin", "s3cret!");
        assertNotNull(result);
        assertEquals("admin", result.getUsername());
        assertEquals("ADMIN", result.getRole());
    }

    @Test
    @DisplayName("AS-02 wrong password → returns null")
    void authenticate_wrongPassword() throws Exception {
        String hash = BCrypt.hashpw("correct", BCrypt.gensalt());
        User u = new User();
        u.setUsername("cashier");
        u.setPasswordHash(hash);
        u.setRole("CASHIER");
        when(userDAO.findByUsername("cashier")).thenReturn(u);

        User result = auth.authenticate("cashier", "incorrect");
        assertNull(result);
    }

    @Test
    @DisplayName("AS-03 unknown user → returns null")
    void authenticate_userNotFound() throws Exception {
        when(userDAO.findByUsername("ghost")).thenReturn(null);
        User result = auth.authenticate("ghost", "anything");
        assertNull(result);
    }
}

