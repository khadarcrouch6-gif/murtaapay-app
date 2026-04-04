import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AppPdfHelper {
  static Future<void> generateTransactionReceipt({
    required String title,
    required String amount,
    required String date,
    required String category,
    required String reference,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Header
              pw.Container(
                color: const PdfColor(0.1, 0.7, 0.7), // Teal color
                padding: const pw.EdgeInsets.all(30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "MURTAAX PAY",
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "International Money Transfer Service",
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Main Content
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Receipt Title
                    pw.Center(
                      child: pw.Text(
                        "TRANSACTION RECEIPT",
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),

                    pw.SizedBox(height: 20),

                    // Reference and Date Section
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      padding: const pw.EdgeInsets.all(15),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                "Transaction ID",
                                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                reference,
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                "Date & Time",
                                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                date,
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 25),

                    // Transaction Details Section
                    pw.Text(
                      "TRANSACTION DETAILS",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor(0.1, 0.7, 0.7),
                      ),
                    ),

                    pw.SizedBox(height: 12),

                    _buildPdfDetailRow("Recipient Name", title),
                    pw.SizedBox(height: 8),
                    _buildPdfDetailRow("Transfer Type", category),
                    pw.SizedBox(height: 8),
                    _buildPdfDetailRow("Status", "Completed"),

                    pw.SizedBox(height: 25),

                    // Amount Section
                    pw.Container(
                      color: const PdfColor(0.95, 0.98, 0.98),
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Amount Transferred",
                                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                              ),
                              pw.Text(
                                amount,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: const PdfColor(0.1, 0.7, 0.7),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 12),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 12),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Fees",
                                style: pw.TextStyle(fontSize: 11),
                              ),
                              pw.Text(
                                "Free",
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: const PdfColor(0.2, 0.6, 0.2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 30),

                    // Footer Message
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
                        ),
                      ),
                      padding: const pw.EdgeInsets.only(top: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            "Thank you for choosing MurtaaxPay!",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontStyle: pw.FontStyle.italic,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            "Your transaction has been securely processed.",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 30),

                    // Company Info Footer
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            "MurtaaxPay © 2024",
                            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                          ),
                          pw.Text(
                            "Secure International Money Transfer",
                            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
