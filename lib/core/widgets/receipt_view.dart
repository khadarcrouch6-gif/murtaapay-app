import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import '../app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

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
    // Using context safely before async gap
    final state = Provider.of<AppState>(context, listen: false);
    final purposeLabel = state.translate("Purpose", "Ujeedada");
    
    final isNegative = transaction['isNegative'] ??
        (transaction['type'] == 'withdraw' || transaction['type'] == 'payment');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('MurtaaxPay Receipt',
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(transaction['date'] ?? '',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        isNegative
                            ? l10n.transactionSuccessful
                            : l10n.topUpSuccessful,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        transaction['amount']?.toString() ?? "0.00",
                        style: pw.TextStyle(
                            fontSize: 36, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Divider(),
                _pdfRow(l10n.receiverSource, transaction['title'] ?? ""),
                if (transaction['purpose'] != null)
                  _pdfRow(purposeLabel, transaction['purpose'].toString()),
                _pdfRow(l10n.transactionId, "#MTX-98234-AX"),
                _pdfRow(l10n.date, transaction['date'] ?? ""),
                _pdfRow(l10n.paymentMethod, transaction['method'] ?? "Wallet"),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Thank you for using MurtaaxPay!',
                  style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic, color: PdfColors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                top: 40,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, theme, l10n),
                  _buildDashedDivider(theme),
                  _buildDetails(context, theme, l10n),
                  const SizedBox(height: 32),
                  _buildActions(context, l10n),
                  const SizedBox(height: 24),
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
        Positioned(
          right: 16,
          top: 16,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded,
                color: Colors.grey.withValues(alpha: 0.5)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isSuccess ? AppColors.accentTeal : Colors.orange)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.pending_rounded,
                  color: isSuccess ? AppColors.accentTeal : Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                transaction['amount']?.toString() ?? "0.00",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: amountColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(
          15,
          (index) => Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: Colors.grey.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final isNegative = transaction['isNegative'] ??
        (transaction['type'] == 'withdraw' || transaction['type'] == 'payment');
    final state = Provider.of<AppState>(context, listen: false);

    String methodTitle = transaction['method'] ??
        (isNegative ? l10n.virtualCard : l10n.walletBalance);
    if (transaction['type'] == 'deposit') {
      methodTitle = "TopUP from ${transaction['method'] ?? l10n.murtaaxWallet}";
    } else if (transaction['type'] == 'withdraw') {
      methodTitle = l10n.bankTransfer;
    } else if (isNegative) {
      methodTitle = "Payment method ${l10n.virtualCard}";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildDetailRow(theme, l10n.receiverSource, transaction['title'] ?? ""),
          if (transaction['purpose'] != null)
            _buildDetailRow(theme, state.translate("Purpose", "Ujeedada"), transaction['purpose'].toString()),
          _buildDetailRow(theme, l10n.transactionId, "#MTX-98234-AX"),
          _buildDetailRow(theme, l10n.date, transaction['date'] ?? ""),
          _buildDetailRow(theme, l10n.paymentMethod, methodTitle),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.right,
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(l10n.downloadPdf),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              try {
                final pdfData = await _generatePdf(context, l10n);
                await Share.shareXFiles(
                  [
                    XFile.fromData(
                      pdfData,
                      name: 'Receipt.pdf',
                      mimeType: 'application/pdf',
                    )
                  ],
                  text: 'My MurtaaxPay Transaction Receipt',
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
              style: const TextStyle(
                  color: AppColors.primaryDark, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
