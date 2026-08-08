import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
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
        title: Text(
          "History: ${group.name}",
          style: TextStyle(fontSize: 20 * context.fontSizeFactor),
        ),
        actions: [
          if (transactions.isNotEmpty)
            IconButton(
              onPressed: () => _showExportOptions(context, state, transactions),
              icon: Icon(Icons.download_rounded, size: 24 * context.fontSizeFactor),
            ),
        ],
      ),
      body: transactions.isEmpty
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64 * context.fontSizeFactor,
                      color: AppColors.grey.withOpacity(0.5),
                    ),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    Text(
                      "No payout history yet",
                      style: TextStyle(fontSize: 16 * context.fontSizeFactor),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16 * context.fontSizeFactor),
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 24 * context.fontSizeFactor,
          left: 16 * context.fontSizeFactor,
          right: 16 * context.fontSizeFactor,
          bottom: (24 + MediaQuery.of(context).padding.bottom) * context.fontSizeFactor,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * context.fontSizeFactor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40 * context.fontSizeFactor,
              height: 4 * context.fontSizeFactor,
              margin: EdgeInsets.only(bottom: 20 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2 * context.fontSizeFactor),
              ),
            ),
            Text(
              state.translate("Export History", "Soo deji Taariikhda", ar: "تصدير السجل", de: "Verlauf exportieren", et: "Ekspordi ajalugu"),
              style: TextStyle(
                fontSize: 18 * context.fontSizeFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20 * context.fontSizeFactor),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red, size: 24 * context.fontSizeFactor),
              title: Text(
                "PDF Document",
                style: TextStyle(fontSize: 16 * context.fontSizeFactor),
              ),
              onTap: () {
                Navigator.pop(context);
                ExportHelper.exportToPdf(transactions);
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.green, size: 24 * context.fontSizeFactor),
              title: Text(
                "CSV Spreadsheet",
                style: TextStyle(fontSize: 16 * context.fontSizeFactor),
              ),
              onTap: () {
                Navigator.pop(context);
                ExportHelper.exportToCsv(transactions);
              },
            ),
            SizedBox(height: 16 * context.fontSizeFactor),
          ],
        ),
      ),
    );
  }
}
