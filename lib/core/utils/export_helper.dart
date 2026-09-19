import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';

class ExportHelper {
  static Future<void> exportToPdf(List<Transaction> transactions) async {
    final pdf = pw.Document();

    // Load logo if available
    pw.ImageProvider? logo;
    try {
      final logoData = await rootBundle.load('assets/images/app_logo.png');
      logo = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Fallback to text logo
    }

    final primaryColor = PdfColor.fromInt(AppColors.primaryDark.toARGB32());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null)
                  pw.Image(logo, height: 40)
                else
                  pw.Text('MURTAAX PAY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20, color: primaryColor)),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Transaction Report', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5, color: PdfColors.grey300),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Receiver/Title', 'Category', 'Amount', 'Status'],
              data: transactions.map((tx) => [
                tx.date,
                tx.title,
                tx.category,
                tx.amount,
                tx.status,
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellHeight: 35,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.center,
              },
              cellStyle: const pw.TextStyle(fontSize: 10),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            ),
            pw.SizedBox(height: 40),
            pw.Divider(thickness: 0.5, color: PdfColors.grey300),
            pw.Center(
              child: pw.Text('MurtaaxPay - Premium Fintech for Somali Diaspora', 
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName = "MurtaaxPay_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles([XFile(file.path)], text: 'My MurtaaxPay Transaction History Report');
  }

  static Future<void> exportToCsv(List<Transaction> transactions) async {
    String csvData = "Date,Title,Category,Type,Amount,Status,Purpose\n";
    
    for (var tx in transactions) {
      csvData += "${tx.date},\"${tx.title}\",${tx.category},${tx.type},${tx.amount},${tx.status},\"${tx.purpose ?? ''}\"\n";
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/MurtaaxPay_Transactions.csv");
    await file.writeAsString(csvData);
    
    await Share.shareXFiles([XFile(file.path)], text: 'My MurtaaxPay Transaction History');
  }
}
