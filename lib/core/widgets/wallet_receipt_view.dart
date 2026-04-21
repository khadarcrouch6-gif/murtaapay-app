import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../app_colors.dart';
import '../../l10n/app_localizations.dart';

class WalletReceiptView extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const WalletReceiptView({super.key, required this.transaction});

  static void show(BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WalletReceiptView(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
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
                _buildDetails(theme, l10n),
                const SizedBox(height: 32),
                _buildActions(context, l10n),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final isSuccess = transaction['status'] == 'Success' || transaction['status'] == 'Completed';
    final isNegative = transaction['isNegative'] ?? false;
    final amountColor = isNegative ? Colors.red : AppColors.accentTeal;

    return Stack(
      children: [
        Positioned(
          right: 16,
          top: 16,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: Colors.grey.withOpacity(0.5)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isSuccess ? AppColors.accentTeal : Colors.orange).withOpacity(0.1),
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
                l10n.walletTransaction,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                transaction['amount']?.toString() ?? "0.00",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: amountColor),
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
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildDetailRow(theme, l10n.sourceReceiver, transaction['title'] ?? ""),
          _buildDetailRow(theme, l10n.transactionId, transaction['transactionId'] ?? "#MTX-WALL-12345"),
          _buildDetailRow(theme, l10n.date, transaction['date'] ?? ""),
          _buildDetailRow(theme, l10n.paymentMethod, l10n.walletBalance),
          if (transaction['purpose'] != null && transaction['purpose'].toString().isNotEmpty)
            _buildDetailRow(theme, l10n.purpose, transaction['purpose']),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(l10n.downloadPdf),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.shareReceipt,
              style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
