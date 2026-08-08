import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/models/transaction.dart' as model;

import '../../core/widgets/transaction_item.dart';
import '../../core/widgets/receipt_view.dart';
import '../../core/utils/export_helper.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    final query = _searchController.text.toLowerCase();
    final filteredTransactions = state.transactions.where((tx) {
      if (tx.cardId != null) return false;
      bool matchesSearch = tx.title.toLowerCase().contains(query) || tx.type.toLowerCase().contains(query);
      bool matchesFilter = _selectedFilter == "All" || 
                         (_selectedFilter == "Sent" && tx.isNegative) || 
                         (_selectedFilter == "Received" && !tx.isNegative);
      return matchesSearch && matchesFilter;
    }).toList();
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ResponsiveBreakpoints.of(context).equals(TABLET)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu_rounded, color: theme.iconTheme.color),
              ),
            )
          : null,
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16 * context.fontSizeFactor),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: context.horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          state.translate("Transaction History", "Taariikhda Lacagaha", ar: "سجل المعاملات", de: "Transaktionsverlauf", et: "Tehingute ajalugu"),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24 * context.fontSizeFactor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showExportOptions(context, state, filteredTransactions),
                        icon: Icon(Icons.download_rounded, color: AppColors.secondary, size: 24 * context.fontSizeFactor),
                        tooltip: state.translate("Export", "Soo deji", ar: "تصدير", de: "Exportieren", et: "Eksport"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8 * context.fontSizeFactor),
                _buildSearchAndFilter(context, state, theme),
                Expanded(
                  child: filteredTransactions.isEmpty
                        ? _buildEmptyState(context, state)
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              context.horizontalPadding,
                              8 * context.fontSizeFactor,
                              context.horizontalPadding,
                              120 * context.fontSizeFactor
                            ),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = filteredTransactions[index];
                              return TransactionItem(
                                title: tx.title,
                                subtitle: tx.purpose ?? tx.type,
                                amount: tx.amount,
                                status: tx.status,
                                date: tx.date,
                                isSent: tx.isNegative,
                                onTap: () => _showTransactionDetails(context, state, theme, tx),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, AppState state, ThemeData theme) {
    return Padding(
      padding: EdgeInsetsDirectional.all(context.horizontalPadding),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => _runFilter(),
            style: TextStyle(fontSize: 16 * context.fontSizeFactor),
            decoration: InputDecoration(
              hintText: state.translate("Search transactions...", "Baadh dhaqdhaqaaqyada...", ar: "البحث عن المعاملات...", de: "Transaktionen suchen...", et: "Otsi tehinguid..."),
              prefixIcon: Icon(Icons.search, color: AppColors.grey, size: 24 * context.fontSizeFactor),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
            ),
          ),
          SizedBox(height: 16 * context.fontSizeFactor),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, state, "All", state.translate("All", "Dhammaan", ar: "الكل", de: "Alle", et: "Kõik")),
                SizedBox(width: 8 * context.fontSizeFactor),
                _buildFilterChip(context, state, "Sent", state.translate("Sent", "La Diray", ar: "تم الإرسال", de: "Gesendet", et: "Saadetud")),
                SizedBox(width: 8 * context.fontSizeFactor),
                _buildFilterChip(context, state, "Received", state.translate("Received", "La Helay", ar: "تم الاستلام", de: "Empfangen", et: "Vastuvõetud")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, AppState state, String value, String label) {
    bool isSelected = _selectedFilter == value;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () { setState(() => _selectedFilter = value); _runFilter(); },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20 * context.fontSizeFactor,
          vertical: 10 * context.fontSizeFactor,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : AppColors.grey.withOpacity(0.2),
            width: 1 * context.fontSizeFactor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 12 * context.fontSizeFactor,
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, AppState state, ThemeData theme, model.Transaction tx) {
    ReceiptView.show(context, {
      "title": tx.title,
      "amount": tx.amount,
      "date": tx.date,
      "status": tx.status,
      "isNegative": tx.isNegative,
      "transactionId": tx.id,
      "purpose": tx.purpose,
      "method": tx.method,
      "paymentMethod": tx.paymentMethod,
    });
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

  Widget _buildEmptyState(BuildContext context, AppState state) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80 * context.fontSizeFactor,
              color: AppColors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16 * context.fontSizeFactor),
            Text(
              state.translate("No transactions found", "Dhaqdhaqaaq lama hayo", ar: "لم يتم العثور على معاملات", de: "Keine Transaktionen gefunden", et: "Tehinguid ei leitud"),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16 * context.fontSizeFactor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
