import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../app_colors.dart';
import '../responsive_utils.dart';
import '../../l10n/app_localizations.dart';

class ReceiptView extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const ReceiptView({super.key, required this.transaction});

  static void show(BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiptView(transaction: transaction),
    );
  }

  Future<Uint8List> _generatePdf(BuildContext context, AppLocalizations l10n) async {
    final pdf = pw.Document();
    
    // Load Logo
    pw.ImageProvider? logo;
    try {
      final logoData = await rootBundle.load('assets/images/logo.png');
      logo = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      debugPrint("Could not load logo for PDF: $e");
    }

    final isNegative = transaction['isNegative'] ??
        (transaction['type'] == 'withdraw' || transaction['type'] == 'payment');
    
    final primaryColor = PdfColor.fromInt(AppColors.primaryDark.toARGB32());
    final tealColor = PdfColor.fromInt(AppColors.accentTeal.toARGB32());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Branding
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logo != null)
                    pw.Image(logo, height: 50)
                  else
                    pw.Text('MURTAAX PAY',
                        style: pw.TextStyle(
                            fontSize: 24, 
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('RECEIPT', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.Text(transaction['transactionId'] ?? transaction['id'] ?? "#MTX-98234-AX",
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.SizedBox(height: 30),
              
              // Summary Section
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          isNegative
                              ? l10n.transactionSuccessful
                              : l10n.topUpSuccessful,
                          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          transaction['amount']?.toString() ?? "0.00",
                          style: pw.TextStyle(
                              fontSize: 28, 
                              fontWeight: pw.FontWeight.bold,
                              color: isNegative ? PdfColors.red : tealColor),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: tealColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                      ),
                      child: pw.Text(
                        'SUCCESSFUL',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 40),
              
              // Transaction Details
              pw.Text('TRANSACTION DETAILS', 
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1.2)),
              pw.SizedBox(height: 16),
              _pdfRow(l10n.date, transaction['date'] ?? ""),
              pw.Divider(thickness: 0.5, color: PdfColors.grey200),
              _pdfRow(l10n.receiverSource, transaction['title'] ?? ""),
              pw.Divider(thickness: 0.5, color: PdfColors.grey200),
              if (transaction['purpose'] != null && transaction['purpose'].toString().isNotEmpty) ...[
                _pdfRow(l10n.purpose, transaction['purpose'].toString()),
                pw.Divider(thickness: 0.5, color: PdfColors.grey200),
              ],
              _pdfRow(l10n.payoutVia, transaction['method'] ?? l10n.murtaaxWallet),
              pw.Divider(thickness: 0.5, color: PdfColors.grey200),
              _pdfRow(l10n.paidUsing, transaction['paymentMethod'] ?? l10n.walletBalance),
              pw.Divider(thickness: 0.5, color: PdfColors.grey200),
              _pdfRow(l10n.transactionId, transaction['transactionId'] ?? transaction['id'] ?? "#MTX-98234-AX"),
              
              pw.Spacer(),
              
              // Branding Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 20),
                child: pw.Column(
                  children: [
                    pw.Text('MurtaaxPay - Trusted Somali Partner', 
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: primaryColor)),
                    pw.SizedBox(height: 4),
                    pw.Text('This is a computer-generated receipt. No signature is required.', 
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('www.murtaaxpay.com', style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue)),
                        pw.SizedBox(width: 20),
                        pw.Text('support@murtaaxpay.com', style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return ZoomIn(
      duration: const Duration(milliseconds: 400),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: 40 * context.fontSizeFactor,
          ),
          child: MaxWidthBox(
            maxWidth: 340,
            child: Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(32 * context.fontSizeFactor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30 * context.fontSizeFactor,
                    offset: Offset(0, 15 * context.fontSizeFactor),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, theme, l10n),
                  _buildDashedDivider(theme, context),
                  _buildDetails(context, theme, l10n),
                  SizedBox(height: 32 * context.fontSizeFactor),
                  _buildActions(context, l10n),
                  SizedBox(height: 24 * context.fontSizeFactor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final isSuccess = transaction['status'] == 'Success' ||
        transaction['status'] == 'Completed';
    final isNegative = transaction['isNegative'] ??
        (transaction['type'] == 'withdraw' || transaction['type'] == 'payment');
    final amountColor = isNegative ? Colors.red : AppColors.accentTeal;

    String title = l10n.transactionSuccessful;
    if (transaction['type'] == 'deposit' || !isNegative) {
      title = l10n.topUpSuccessful;
    } else if (transaction['type'] == 'withdraw') {
      title = l10n.withdrawalSuccessful;
    }

    return Stack(
      children: [
        PositionedDirectional(
          end: 16 * context.fontSizeFactor,
          top: 16 * context.fontSizeFactor,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: Colors.grey.withValues(alpha: 0.5),
              size: 24 * context.fontSizeFactor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            24 * context.fontSizeFactor,
            40 * context.fontSizeFactor,
            24 * context.fontSizeFactor,
            24 * context.fontSizeFactor,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16 * context.fontSizeFactor),
                decoration: BoxDecoration(
                  color: (isSuccess ? AppColors.accentTeal : Colors.orange)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.pending_rounded,
                  color: isSuccess ? AppColors.accentTeal : Colors.orange,
                  size: 40 * context.fontSizeFactor,
                ),
              ),
              SizedBox(height: 16 * context.fontSizeFactor),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18 * context.fontSizeFactor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * context.fontSizeFactor),
              FittedBox(
                child: Text(
                  transaction['amount']?.toString() ?? "0.00",
                  style: TextStyle(
                      fontSize: 32 * context.fontSizeFactor,
                      fontWeight: FontWeight.w900,
                      color: amountColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider(ThemeData theme, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor),
      child: Row(
        children: List.generate(
          15,
          (index) => Expanded(
            child: Container(
              height: 1 * context.fontSizeFactor,
              margin: EdgeInsets.symmetric(horizontal: 2 * context.fontSizeFactor),
              color: Colors.grey.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * context.fontSizeFactor,
        vertical: 16 * context.fontSizeFactor,
      ),
      child: Column(
        children: [
          _buildDetailRow(context, theme, l10n.receiverSource, transaction['title'] ?? ""),
          if (transaction['purpose'] != null && transaction['purpose'].toString().isNotEmpty)
            _buildDetailRow(context, theme, l10n.purpose, transaction['purpose'].toString()),
          _buildDetailRow(context, theme, l10n.transactionId, transaction['transactionId'] ?? transaction['id'] ?? "#MTX-98234-AX"),
          _buildDetailRow(context, theme, l10n.date, transaction['date'] ?? ""),
          _buildDetailRow(context, theme, l10n.payoutVia, transaction['method'] ?? l10n.murtaaxWallet),
          _buildDetailRow(context, theme, l10n.paidUsing, transaction['paymentMethod'] ?? l10n.walletBalance),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * context.fontSizeFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13 * context.fontSizeFactor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8 * context.fontSizeFactor),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13 * context.fontSizeFactor,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final pdfData = await _generatePdf(context, l10n);
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => pdfData,
                  name: 'MurtaaxPay_Receipt_${transaction['title']}.pdf',
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error generating PDF: $e')),
                  );
                }
              }
            },
            icon: Icon(Icons.download_rounded, size: 18 * context.fontSizeFactor),
            label: Text(
              l10n.downloadPdf,
              style: TextStyle(fontSize: 14 * context.fontSizeFactor),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50 * context.fontSizeFactor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
              elevation: 0,
            ),
          ),
          SizedBox(height: 12 * context.fontSizeFactor),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 50 * context.fontSizeFactor),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
            ),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * context.fontSizeFactor),
            ),
          ),
          SizedBox(height: 12 * context.fontSizeFactor),
          TextButton(
            onPressed: () async {
              try {
                final pdfData = await _generatePdf(context, l10n);
                  await Share.shareXFiles(
                  [
                    XFile.fromData(
                      pdfData,
                      name: 'MurtaaxPay_Receipt.pdf',
                      mimeType: 'application/pdf',
                    )
                  ],
                  text: 'Here is my transaction receipt from MurtaaxPay.',
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error sharing receipt: $e')),
                  );
                }
              }
            },
            child: Text(
              l10n.shareReceipt,
              style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * context.fontSizeFactor),
            ),
          ),
        ],
      ),
    );
  }
}
