import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();
    final isDark = theme.brightness == Brightness.dark;

    return ZoomIn(
      duration: const Duration(milliseconds: 400),
      child: Center(
        child: Container(
          width: 340,
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
              // Top Section: Icon & Header
              _buildHeader(theme, state),
              
              // Dashed Divider
              _buildDashedDivider(theme),
              
              // Details Section
              _buildDetails(theme, state),
              
              const SizedBox(height: 32),
              
              // Bottom Action
              _buildActions(context, state),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppState state) {
    final isSuccess = transaction['status'] == 'Success';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isSuccess ? AppColors.accentTeal : Colors.orange).withValues(alpha: 0.1),
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
            state.translate("Transfer Successful", "Lacagtii waa ay dirtay", ar: "تم التحويل بنجاح", de: "Überweisung erfolgreich"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            transaction['amount'] ?? r"$0.00",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.accentTeal),
          ),
        ],
      ),
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

  Widget _buildDetails(ThemeData theme, AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildDetailRow(theme, state.translate("Receiver", "Qofka helay", ar: "المستلم", de: "Empfänger"), transaction['title'] ?? ""),
          _buildDetailRow(theme, state.translate("Transaction ID", "ID-ga Dhaqdhaqaaqa", ar: "رقم العملية", de: "Transaktions-ID"), "#MTX-98234-AX"),
          _buildDetailRow(theme, state.translate("Date", "Taariikhda", ar: "التاريخ", de: "Datum"), transaction['date'] ?? ""),
          _buildDetailRow(theme, state.translate("Payment Method", "Habka Lacag Bixinta", ar: "طريقة الدفع", de: "Zahlungsmethode"), "Wallet Balance"),
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
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(state.translate("Download PDF", "Soo deji PDF", ar: "تحميل PDF", de: "PDF herunterladen")),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              state.translate("Share Receipt", "La wadaag Risidkan", ar: "مشاركة الإيصال", de: "Quittung teilen"),
              style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
