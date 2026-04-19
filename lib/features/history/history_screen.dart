import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/models/transaction.dart' as model;

import '../../core/widgets/transaction_item.dart';
import '../../core/widgets/wallet_receipt_view.dart';
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
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
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
                const SizedBox(height: 8),
                _buildSearchAndFilter(context, state, theme),
                Expanded(
                  child: filteredTransactions.isEmpty
                        ? _buildEmptyState(context, state)
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(context.horizontalPadding, 8, context.horizontalPadding, 120),
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
      padding: EdgeInsets.all(context.horizontalPadding),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => _runFilter(),
            decoration: InputDecoration(
              hintText: state.translate("Search transactions...", "Baadh dhaqdhaqaaqyada...", ar: "البحث عن المعاملات...", de: "Transaktionen suchen...", et: "Otsi tehinguid..."),
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, state, "All", state.translate("All", "Dhammaan", ar: "الكل", de: "Alle", et: "Kõik")),
                const SizedBox(width: 8),
                _buildFilterChip(context, state, "Sent", state.translate("Sent", "La Diray", ar: "تم الإرسال", de: "Gesendet", et: "Saadetud")),
                const SizedBox(width: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : AppColors.grey.withValues(alpha: 0.2)),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, AppState state, ThemeData theme, model.Transaction tx) {
    WalletReceiptView.show(context, {
      "title": tx.title,
      "amount": tx.amount,
      "date": tx.date,
      "status": tx.status,
      "isNegative": tx.isNegative,
      "transactionId": tx.id,
      "purpose": tx.purpose,
    });
  }

  Widget _buildEmptyState(BuildContext context, AppState state) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 80, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), Text(state.translate("No transactions found", "Dhaqdhaqaaq lama hayo", ar: "لم يتم العثور على معاملات", de: "Keine Transaktionen gefunden", et: "Tehinguid ei leitud"), style: const TextStyle(color: AppColors.grey))]));
  }
}
