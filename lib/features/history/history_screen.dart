import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/transaction_item.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Transaction {
  final String name;
  final String type;
  final String amount;
  final String date;
  final String status;
  final bool isSent;

  Transaction({
    required this.name,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
    required this.isSent,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();
  
  final List<Transaction> _allTransactions = [
    Transaction(name: "Mohamed Ali", type: "EVC Plus", amount: r"-$250.00", date: "Oct 24, 2023", status: "Success", isSent: true),
    Transaction(name: "Ahmed Hersi", type: "ZAAD", amount: r"-$100.00", date: "Oct 24, 2023", status: "Pending", isSent: true),
    Transaction(name: "Wallet Topup", type: "Bank Transfer", amount: r"+$1,000.00", date: "Oct 23, 2023", status: "Success", isSent: false),
    Transaction(name: "Sahra Jama", type: "eDahab", amount: r"-$50.00", date: "Oct 22, 2023", status: "Success", isSent: true),
    Transaction(name: "Abdi Rahman", type: "EVC Plus", amount: r"+$300.00", date: "Oct 21, 2023", status: "Success", isSent: false),
    Transaction(name: "Somtel Bill", type: "Internet", amount: r"-$25.00", date: "Oct 20, 2023", status: "Success", isSent: true),
    Transaction(name: "Netflix", type: "Subscription", amount: r"-$15.99", date: "Oct 19, 2023", status: "Success", isSent: true),
    Transaction(name: "Salad Iid", type: "ZAAD", amount: r"+$150.00", date: "Oct 18, 2023", status: "Success", isSent: false),
    Transaction(name: "BECO", type: "Electricity", amount: r"-$42.50", date: "Oct 17, 2023", status: "Success", isSent: true),
    Transaction(name: "Hassan Nur", type: "Bank Transfer", amount: r"+$2,000.00", date: "Oct 16, 2023", status: "Success", isSent: false),
    Transaction(name: "Amazon", type: "Shopping", amount: r"-$124.50", date: "Oct 15, 2023", status: "Success", isSent: true),
    Transaction(name: "IBS Bank", type: "Savings", amount: r"+$500.00", date: "Oct 14, 2023", status: "Success", isSent: false),
  ];

  List<Transaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = _allTransactions;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTransactions = _allTransactions.where((tx) {
        bool matchesSearch = tx.name.toLowerCase().contains(query) || tx.type.toLowerCase().contains(query);
        bool matchesFilter = _selectedFilter == "All" || 
                           (_selectedFilter == "Sent" && tx.isSent) || 
                           (_selectedFilter == "Received" && !tx.isSent);
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    state.translate("Transaction History", "Taariikhda Lacagaha"),
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
                  child: _filteredTransactions.isEmpty
                        ? _buildEmptyState(context, state)
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(context.horizontalPadding, 8, context.horizontalPadding, 120),
                            itemCount: _filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = _filteredTransactions[index];
                              return TransactionItem(
                                name: tx.name,
                                type: tx.type,
                                amount: tx.amount,
                                status: tx.status,
                                date: tx.date,
                                isSent: tx.isSent,
                                onTap: () => _showTransactionDetails(context, state, tx),
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
              hintText: state.translate("Search transactions...", "Baadh dhaqdhaqaaqyada..."),
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
                _buildFilterChip(context, state, "All", state.translate("All", "Dhammaan")),
                const SizedBox(width: 8),
                _buildFilterChip(context, state, "Sent", state.translate("Sent", "La Diray")),
                const SizedBox(width: 8),
                _buildFilterChip(context, state, "Received", state.translate("Received", "La Helay")),
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

  void _showTransactionDetails(BuildContext context, AppState state, Transaction tx) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        padding: EdgeInsets.fromLTRB(32, 24, 32, 32 + MediaQuery.of(context).padding.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(state.translate("Transaction Details", "Faahfaahinta"), style: theme.textTheme.titleLarge),
              const SizedBox(height: 32),
              DetailRow(label: state.translate("Recipient/Sender", "Qofka/Dhinaca"), value: tx.name),
              DetailRow(label: state.translate("Amount", "Lacagta"), value: tx.amount, valueColor: tx.isSent ? null : AppColors.accentTeal),
              DetailRow(label: state.translate("Type", "Nooca"), value: tx.type),
              DetailRow(label: state.translate("Date", "Taariikhda"), value: tx.date),
              DetailRow(label: state.translate("Status", "Heerka"), value: state.translate(tx.status, tx.status), valueColor: tx.status == "Success" ? AppColors.accentTeal : Colors.orange),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context), 
                  child: Text(state.translate("Close", "Xidh")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState state) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 80, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), Text(state.translate("No transactions found", "Dhaqdhaqaaq lama hayo"), style: const TextStyle(color: AppColors.grey))]));
  }
}
