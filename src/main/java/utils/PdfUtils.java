/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

/**
 *
 * @author ugdin
 */
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.Font;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import jakarta.servlet.ServletOutputStream;

import models.Bills;
import models.BillItem;

import java.awt.Color; // import only Color; DO NOT wildcard import java.awt.*
import java.io.OutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

public class PdfUtils {

    private static final int MONEY_SCALE = 2;
    private static final RoundingMode RM = RoundingMode.HALF_UP;
    private static final DateTimeFormatter DATE_FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    public static void writeInvoice(OutputStream os,
                                    String shopName,
                                    String shopAddress,
                                    String customerName,
                                    Bills bill) throws Exception {
        Document doc = new Document(PageSize.A4, 36, 36, 36, 36);
        PdfWriter.getInstance(doc, os);
        doc.open();

        // Header
        Font h1 = new Font(Font.HELVETICA, 18, Font.BOLD, new Color(33, 33, 33));
        Paragraph title = new Paragraph(shopName + " - Invoice", h1);
        title.setAlignment(Element.ALIGN_CENTER);
        doc.add(title);

        Font meta = new Font(Font.HELVETICA, 10, Font.NORMAL);
        doc.add(new Paragraph(shopAddress, meta));
        doc.add(new Paragraph("Invoice No: " + bill.getBillId(), meta));
        doc.add(new Paragraph("Date: " + formatTimestamp(bill.getCreatedAt()), meta));
        doc.add(new Paragraph("Customer: " + customerName, meta));
        doc.add(new Paragraph(" "));

        // Items table
        PdfPTable table = new PdfPTable(new float[]{4f, 1.2f, 1.0f, 1.2f});
        table.setWidthPercentage(100);
        addHeader(table, "Item");
        addHeader(table, "Unit Price");
        addHeader(table, "Qty");
        addHeader(table, "Total");

        for (BillItem li : bill.getItems()) {
            addCell(table, li.getItemName());
            addCell(table, money(li.getUnitPrice()));
            addCell(table, String.valueOf(li.getQuantity()));
            addCell(table, money(li.getLineTotal()));
        }
        doc.add(table);

        doc.add(new Paragraph(" "));
        PdfPTable totals = new PdfPTable(new float[]{6.4f, 1.2f});
        totals.setWidthPercentage(50);
        totals.setHorizontalAlignment(Element.ALIGN_RIGHT);
        addKV(totals, "Subtotal", money(bill.getSubtotal()));
        addKV(totals, "Tax (" + percent(bill.getTaxRate()) + ")", money(bill.getTaxAmount()));
        addKV(totals, "Total", money(bill.getTotal()));
        doc.add(totals);

        doc.add(new Paragraph(" "));
        Paragraph thanks = new Paragraph("Thank you for your purchase!", meta);
        thanks.setAlignment(Element.ALIGN_CENTER);
        doc.add(thanks);

        doc.close();
    }

    private static void addHeader(PdfPTable t, String s) {
        PdfPCell c = new PdfPCell(new Phrase(s, new Font(Font.HELVETICA, 11, Font.BOLD)));
        c.setHorizontalAlignment(Element.ALIGN_LEFT);
        c.setBackgroundColor(new Color(240, 240, 240));
        t.addCell(c);
    }

    private static void addCell(PdfPTable t, String s) {
        PdfPCell c = new PdfPCell(new Phrase(s, new Font(Font.HELVETICA, 10)));
        c.setHorizontalAlignment(Element.ALIGN_LEFT);
        t.addCell(c);
    }

    private static void addKV(PdfPTable t, String k, String v) {
        PdfPCell ck = new PdfPCell(new Phrase(k, new Font(Font.HELVETICA, 10)));
        PdfPCell cv = new PdfPCell(new Phrase(v, new Font(Font.HELVETICA, 10, Font.BOLD)));
        ck.setBorder(Rectangle.NO_BORDER);
        cv.setBorder(Rectangle.NO_BORDER);
        ck.setHorizontalAlignment(Element.ALIGN_RIGHT);
        cv.setHorizontalAlignment(Element.ALIGN_RIGHT);
        t.addCell(ck);
        t.addCell(cv);
    }

    // FORMATTERS

    private static String money(BigDecimal v) {
        if (v == null) v = BigDecimal.ZERO;
        return String.format("Rs %.2f", v.setScale(MONEY_SCALE, RM));
    }

    private static String percent(BigDecimal v) {
        if (v == null) v = BigDecimal.ZERO;
        return v.setScale(2, RM).toPlainString() + "%";
    }

    private static String formatTimestamp(Timestamp ts) {
        if (ts == null) return "";
        return ts.toInstant().atZone(ZoneId.systemDefault()).format(DATE_FMT);
    }

    public static void writeSimpleTable(ServletOutputStream outputStream, String name, List<String> headers, List<Map<String, Object>> rows) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    public static void writeSimpleKeyValueReport(ServletOutputStream outputStream, String daily_Sales, Map<String, Object> m) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}