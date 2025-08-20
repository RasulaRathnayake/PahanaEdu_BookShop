/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

import dao.ReportDAO;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.*;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import utils.PdfUtils;
import utils.Security;

import java.io.*;
import java.sql.Date;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ReportControllerTest {

    ReportController controller;
    ReportDAO dao;

    HttpServletRequest req;
    HttpServletResponse resp;

    StringWriter body;        // capture text/JSON/CSV
    PrintWriter writer;
    ByteArrayOutputStream pdfBytes;
    ServletOutputStream out;

    @BeforeEach
    void setUp() throws Exception {
        controller = new ReportController();

        // inject mock DAO (private final field) via reflection
        dao = mock(ReportDAO.class);
        var f = ReportController.class.getDeclaredField("dao");
        f.setAccessible(true);
        f.set(controller, dao);

        req  = mock(HttpServletRequest.class);
        resp = mock(HttpServletResponse.class);

        // writer for JSON/CSV
        body = new StringWriter();
        writer = new PrintWriter(body, true);
        when(resp.getWriter()).thenReturn(writer);

        // output stream for PDF
        pdfBytes = new ByteArrayOutputStream();
        out = new ServletOutputStream() {
            @Override public void write(int b) throws IOException { pdfBytes.write(b); }

            @Override
            public boolean isReady() {
                throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
            }

            @Override
            public void setWriteListener(WriteListener wl) {
                throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
            }
        };
        when(resp.getOutputStream()).thenReturn(out);
    }

    @AfterEach
    void printPass(TestInfo info) {
        System.out.println("[PASS] " + info.getDisplayName());
    }

    @Test
    @DisplayName("RC-01 /sales/daily JSON → 200 with expected JSON body")
    void salesDaily_json_success() throws Exception {
        when(req.getPathInfo()).thenReturn("/sales/daily");
        when(req.getParameter("format")).thenReturn(null); // defaults to json
        when(req.getParameter("date")).thenReturn("2025-08-01");

        Map<String,Object> m = new LinkedHashMap<>();
        m.put("date", Date.valueOf("2025-08-01"));
        m.put("bills", 7);
        m.put("subtotal", "2035.00");
        m.put("tax", "162.80");
        m.put("total", "2197.80");
        when(dao.salesDaily(Date.valueOf("2025-08-01"))).thenReturn(m);

        try (MockedStatic<Security> sec = mockStatic(Security.class)) {
            sec.when(() -> Security.isAdmin(req)).thenReturn(true);

            controller.doGet(req, resp);

            verify(resp).setContentType("application/json");
            String json = body.toString().trim();
            assertTrue(json.contains("\"bills\":7"));
            assertTrue(json.contains("\"total\":\"2197.80\""));
        }
    }

    @Test
    @DisplayName("RC-02 /sales/daily CSV → 200 with headers and one data line")
    void salesDaily_csv_success() throws Exception {
        when(req.getPathInfo()).thenReturn("/sales/daily");
        when(req.getParameter("format")).thenReturn("csv");
        when(req.getParameter("date")).thenReturn("2025-08-02");

        Map<String,Object> m = new LinkedHashMap<>();
        m.put("date", Date.valueOf("2025-08-02"));
        m.put("bills", 3);
        m.put("subtotal", "500.00");
        m.put("tax", "40.00");
        m.put("total", "540.00");
        when(dao.salesDaily(Date.valueOf("2025-08-02"))).thenReturn(m);

        try (MockedStatic<Security> sec = mockStatic(Security.class)) {
            sec.when(() -> Security.isAdmin(req)).thenReturn(true);

            controller.doGet(req, resp);

            verify(resp).setContentType("text/csv");
            ArgumentCaptor<String> cd = ArgumentCaptor.forClass(String.class);
            verify(resp).setHeader(eq("Content-Disposition"), cd.capture());
            assertTrue(cd.getValue().startsWith("attachment; filename=daily-sales.csv"));

            String csv = body.toString();
            assertTrue(csv.lines().findFirst().orElse("").equals("date,bills,subtotal,tax,total"));
            assertTrue(csv.contains("2025-08-02,3,500.00,40.00,540.00"));
        }
    }

    @Test
    @DisplayName("RC-03 /sales/daily PDF → calls PdfUtils.writeSimpleKeyValueReport with map")
    void salesDaily_pdf_callsPdfUtils() throws Exception {
        when(req.getPathInfo()).thenReturn("/sales/daily");
        when(req.getParameter("format")).thenReturn("pdf");
        when(req.getParameter("date")).thenReturn("2025-08-03");

        Map<String,Object> m = new LinkedHashMap<>();
        m.put("date", "2025-08-03"); m.put("bills", 2); m.put("total", "100.00");
        when(dao.salesDaily(Date.valueOf("2025-08-03"))).thenReturn(m);

        try (MockedStatic<Security> sec = mockStatic(Security.class);
             MockedStatic<PdfUtils> pdf = mockStatic(PdfUtils.class)) {
            sec.when(() -> Security.isAdmin(req)).thenReturn(true);

            controller.doGet(req, resp);

            verify(resp).setContentType("application/pdf");
            pdf.verify(() -> PdfUtils.writeSimpleKeyValueReport(any(), eq("Daily Sales"), eq(m)));
        }
    }

    @Test
    @DisplayName("RC-04 /sales/monthly PDF → writeSimpleTable called with expected headers")
    void salesMonthly_pdf_table() throws Exception {
        when(req.getPathInfo()).thenReturn("/sales/monthly");
        when(req.getParameter("format")).thenReturn("pdf");
        when(req.getParameter("year")).thenReturn("2025");
        when(req.getParameter("month")).thenReturn("8");

        List<Map<String,Object>> rows = List.of(
            Map.of("date", "2025-08-01", "bills", 2, "total", "540.00"),
            Map.of("date", "2025-08-02", "bills", 1, "total", "100.00")
        );
        when(dao.salesMonthly(2025, 8)).thenReturn(rows);

        try (MockedStatic<Security> sec = mockStatic(Security.class);
             MockedStatic<PdfUtils> pdf = mockStatic(PdfUtils.class)) {
            sec.when(() -> Security.isAdmin(req)).thenReturn(true);

            controller.doGet(req, resp);

            verify(resp).setContentType("application/pdf");
            pdf.verify(() -> PdfUtils.writeSimpleTable(
                any(), eq("monthly-sales"), eq(List.of("date","bills","total")), eq(rows)
            ));
        }
    }

    @Test
    @DisplayName("RC-05 missing auth (isAdmin=false) → 403")
    void authRequired_forbidden() throws Exception {
        when(req.getPathInfo()).thenReturn("/sales/daily");
        when(req.getParameter("date")).thenReturn("2025-08-01");

        try (MockedStatic<Security> sec = mockStatic(Security.class)) {
            sec.when(() -> Security.isAdmin(req)).thenReturn(false);

            controller.doGet(req, resp);

            verify(resp).sendError(403, "Admin only");
            verifyNoInteractions(dao);
        }
    }

    @Test
    @DisplayName("RC-06 invalid path → 404")
    void invalidPath_notFound() throws Exception {
        when(req.getPathInfo()).thenReturn("/nope");
        try (MockedStatic<Security> sec = mockStatic(Security.class)) {
            sec.when(() -> Security.isAdmin(req)).thenReturn(true);

            controller.doGet(req, resp);

            verify(resp).sendError(404, "Not found");
        }
    }

    @Test
    @DisplayName("RC-07 handler throws → 500 'Report error'")
    void handlerException_internalServerError() throws Exception {
        when(req.getPathInfo()).thenReturn("/sales/daily");
        when(req.getParameter("format")).thenReturn("json");
        when(req.getParameter("date")).thenReturn("2025-08-09");

        when(dao.salesDaily(Date.valueOf("2025-08-09"))).thenThrow(new RuntimeException("DB down"));

        try (MockedStatic<Security> sec = mockStatic(Security.class)) {
            sec.when(() -> Security.isAdmin(req)).thenReturn(true);

            controller.doGet(req, resp);

            verify(resp).sendError(500, "Report error");
        }
    }
}


