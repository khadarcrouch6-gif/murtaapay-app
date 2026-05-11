import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class ExportHelper {
  static Future<void> exportToPdf(List<Transaction> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('MurtaaxPay Transaction History', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Title', 'Category', 'Amount', 'Status'],
              data: transactions.map((tx) => [
                tx.date,
                tx.title,
                tx.category,
                tx.amount,
                tx.status,
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/MurtaaxPay_Transactions.pdf");
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles([XFile(file.path)], text: 'My MurtaaxPay Transaction History');
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
