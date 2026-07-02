import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../functions/format_number.dart';

class InvoicePdfService {
  static Future<void> generateAndPrintInvoice({
    required Map<String, dynamic> invoice,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double discount,
    required double netTotal,
    required double totalPaid,
    required double remaining,
  }) async {
    final pdf = pw.Document();

    // Load Arabic font
    final fontData =
        await rootBundle.load('assets/fonts/static/Cairo-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final fontBoldData =
        await rootBundle.load('assets/fonts/static/Cairo-Bold.ttf');
    final ttfBold = pw.Font.ttf(fontBoldData);

    // Primary Color (Maroon/Dark Red used in app)
    final primaryColor = PdfColor.fromHex('#800000');
    final secondaryColor = PdfColor.fromHex('#fcf5f5');
    final textColor = PdfColor.fromHex('#333333');
    final lightGray = PdfColor.fromHex('#f3f4f6');

    // Format date
    String dateStr = invoice["date"] ?? DateTime.now().toIso8601String();
    DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);

    pdf.addPage(
      pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttfBold,
          ),
          margin: const pw.EdgeInsets.all(0),
          build: (pw.Context context) {
            return [
              // Colored Top Banner
              pw.Container(
                height: 120,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                ),
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "فاتورة مبيعات",
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "INVOICE",
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor(
                                1, 1, 1, 0.2), // White with 20% opacity
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content Body
              pw.Padding(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Info Section (Customer & Invoice Details)
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Invoice Details
                        pw.Container(
                          width: 200,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("تفاصيل الفاتورة",
                                  style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      color: primaryColor)),
                              pw.SizedBox(height: 8),
                              _buildInfoRow(
                                  "رقم الفاتورة:",
                                  "#${invoice["numper"] ?? invoice["id"]}",
                                  ttf,
                                  ttfBold,
                                  textColor),
                              _buildInfoRow("تاريخ الإصدار:", formattedDate,
                                  ttf, ttfBold, textColor),
                            ],
                          ),
                        ),

                        // Customer Details
                        pw.Container(
                          width: 200,
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            color: secondaryColor,
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(8)),
                            border: pw.Border.all(
                                color: const PdfColor(0.5, 0, 0, 0.2)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("فاتورة إلى:",
                                  style: pw.TextStyle(
                                      fontSize: 12, color: primaryColor)),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                invoice["customer_name"] ?? 'عميل عام',
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                    color: textColor),
                              ),
                              pw.SizedBox(height: 4),
                              if (invoice["customer_phone"] != null &&
                                  invoice["customer_phone"]
                                      .toString()
                                      .isNotEmpty)
                                pw.Text(
                                  "الهاتف: ${invoice["customer_phone"]}",
                                  style: pw.TextStyle(
                                      fontSize: 12, color: PdfColors.grey700),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 40),

                    // Items Table
                    pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1.5),
                        3: const pw.FlexColumnWidth(1.5),
                      },
                      children: [
                        // Table Header
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: primaryColor,
                            borderRadius: const pw.BorderRadius.vertical(
                                top: pw.Radius.circular(8)),
                          ),
                          children: [
                            _buildTableHeaderCell("المنتج"),
                            _buildTableHeaderCell("الكمية"),
                            _buildTableHeaderCell("سعر الوحدة"),
                            _buildTableHeaderCell("المجموع"),
                          ],
                        ),
                        // Table Rows
                        ...items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final double qty = double.tryParse(
                                  item["quantity"]?.toString() ?? "1") ??
                              1.0;
                          final double price = double.tryParse(
                                  item["unit_price"]?.toString() ?? "0") ??
                              0.0;
                          final double total = qty * price;

                          final isEven = index % 2 == 0;

                          return pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: isEven ? PdfColors.white : lightGray,
                              border: pw.Border(
                                  bottom: pw.BorderSide(
                                      color: PdfColors.grey300, width: 0.5)),
                            ),
                            children: [
                              _buildTableCell(
                                  item["product_name"] ?? "منتج غير معروف",
                                  isRight: false),
                              _buildTableCell(qty % 1 == 0
                                  ? qty.toInt().toString()
                                  : qty.toString()),
                              _buildTableCell(
                                  "${formatAmount(price)} دج"),
                              _buildTableCell(
                                  "${formatAmount(total)} دج",
                                  isBold: true),
                            ],
                          );
                        }).toList(),
                      ],
                    ),

                    pw.SizedBox(height: 30),

                    // Summary Section
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left side notes (empty or thanks message)
                        pw.Expanded(
                          child: pw.Container(
                            padding:
                                const pw.EdgeInsets.only(top: 10, left: 20),
                            child: pw.Text(
                              "ملاحظة:\nشكراً لثقتكم بنا واختياركم لخدماتنا. نسعد دائماً بتلبيـة احتياجاتكم.",
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.grey600,
                                  lineSpacing: 2),
                            ),
                          ),
                        ),

                        // Right side totals
                        pw.Container(
                          width: 260,
                          padding: const pw.EdgeInsets.all(16),
                          decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(10)),
                              border: pw.Border.all(
                                  color: PdfColors.grey300, width: 1),
                              boxShadow: [
                                pw.BoxShadow(
                                    color: PdfColors.grey200,
                                    blurRadius: 10,
                                    offset: const PdfPoint(0, 5))
                              ]),
                          child: pw.Column(
                            children: [
                              _buildTotalRow(
                                  "المجموع الفرعي:", subtotal, ttf, textColor),
                              pw.SizedBox(height: 6),
                              _buildTotalRow(
                                  "الخصم:", discount, ttf, PdfColors.red600),
                              pw.SizedBox(height: 10),
                              pw.Divider(
                                  color: PdfColors.grey300, thickness: 1),
                              pw.SizedBox(height: 10),

                              // Net Total Highlight
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: pw.BoxDecoration(
                                  color: const PdfColor(0.5, 0, 0, 0.05),
                                  borderRadius: const pw.BorderRadius.all(
                                      pw.Radius.circular(6)),
                                ),
                                child: _buildTotalRow("الصافي المستحق:",
                                    netTotal, ttfBold, primaryColor,
                                    isBold: true, size: 16),
                              ),

                              pw.SizedBox(height: 14),
                              _buildTotalRow("إجمالي المدفوع:", totalPaid,
                                  ttfBold, PdfColors.green700,
                                  isBold: true),
                              pw.SizedBox(height: 6),
                              _buildTotalRow(
                                  "المبلغ المتبقي:",
                                  remaining,
                                  ttfBold,
                                  remaining > 0 ? PdfColors.red700 : textColor,
                                  isBold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.only(top: 10, bottom: 20),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(color: primaryColor, width: 2)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    "تم إنشاء هذه الفاتورة آلياً",
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            );
          }),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${invoice["numper"] ?? invoice["id"]}.pdf',
    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
            fontSize: 12),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text,
      {bool isRight = true, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 11,
          color: PdfColors.grey900,
        ),
        textAlign: isRight ? pw.TextAlign.center : pw.TextAlign.right,
      ),
    );
  }

  static pw.Widget _buildTotalRow(
      String label, double value, pw.Font font, PdfColor color,
      {bool isBold = false, double size = 12}) {
    String formattedValue = formatAmount(value);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: size,
            color: PdfColors.grey800,
          ),
        ),
        pw.Text(
          "$formattedValue دج",
          style: pw.TextStyle(
            font: font,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: size,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font,
      pw.Font fontBold, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
                font: font, fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
                font: fontBold,
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
                color: color),
          ),
        ],
      ),
    );
  }
}
