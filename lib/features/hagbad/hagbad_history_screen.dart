import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../core/models/hagbad_model.dart';
import '../../core/widgets/transaction_item.dart';
import '../../core/utils/export_helper.dart';
import '../../core/models/transaction.dart' as model;

class HagbadHistoryScreen extends StatelessWidget {
  final String groupId;

  const HagbadHistoryScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final group = state.hagbadGroups.firstWhere((g) => g.id == groupId);
    final transactions = state.transactions.where((tx) => tx.category == "Hagbad" && tx.referenceId == groupId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("History: ${group.name}"),
        actions: [
          if (transactions.isNotEmpty)
            IconButton(
              onPressed: () => _showExportOptions(context, state, transactions),
              icon: const Icon(Icons.download_rounded),
            ),
        ],
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text("No payout history yet"),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isEvent = tx.status == "Info" && tx.type == "event";
                
                return TransactionItem(
                  title: tx.title,
                  subtitle: isEvent ? "Group Event" : tx.type,
                  amount: tx.amount,
                  status: tx.status,
                  date: tx.date,
                  isSent: isEvent ? null : tx.isNegative,
                  icon: isEvent ? Icons.info_outline : null,
                );
              },
            ),
    );
  }

  void _showExportOptions(BuildContext context, AppState state, List<model.Transaction> transactions) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.translate("Export History", "Soo deji Taariikhda", ar: "تصدير السجل", de: "Verlauf exportieren", et: "Ekspordi ajalugu"),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("PDF Document"),
              onTap: () {
                Navigator.pop(context);
                ExportHelper.exportToPdf(transactions);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text("CSV Spreadsheet"),
              onTap: () {
                Navigator.pop(context);
                ExportHelper.exportToCsv(transactions);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
