/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package tests;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBTestRunner {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/pahanaedubookshop";
        String user = "bookshop_user";
        String password = "bookshop_pass";

        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            if (conn != null) {
                System.out.println("✅ Database connection successful!");
            } else {
                System.out.println("❌ Failed to connect to database.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

