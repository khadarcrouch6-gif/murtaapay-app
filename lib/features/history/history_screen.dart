import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
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

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  late AnimationController _shimmerController;
  
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
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _fakeLoad();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _fakeLoad() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
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
                  child: _isLoading 
                    ? _buildSkeletonLoader(context)
                    : _filteredTransactions.isEmpty 
                        ? _buildEmptyState(context, state)
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(context.horizontalPadding, 8, context.horizontalPadding, 120),
                            itemCount: _filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = _filteredTransactions[index];
                              return _buildHistoryItem(context, state, tx, theme);
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
          // FIXED: Wrapped in SingleChildScrollView to prevent overflow when Somali text is long
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

  Widget _buildHistoryItem(BuildContext context, AppState state, Transaction tx, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showTransactionDetails(context, state, tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              height: 48, width: 48,
              decoration: BoxDecoration(color: (tx.isSent ? Colors.red : AppColors.accentTeal).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(child: Icon(tx.isSent ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown, color: tx.isSent ? Colors.red : AppColors.accentTeal, size: 16)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.name, 
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis
                  ),
                  Text(
                    "${tx.type} • ${tx.date}", 
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tx.amount, 
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold, 
                    color: tx.isSent ? theme.textTheme.bodyLarge?.color : AppColors.accentTeal
                  ),
                  maxLines: 1,
                ),
                Text(
                  tx.status, 
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tx.status == "Success" ? AppColors.accentTeal : Colors.orange, 
                    fontWeight: FontWeight.bold
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      itemCount: 8,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            _shimmerBox(context, 48, 48, isCircle: true),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_shimmerBox(context, 120, 16), const SizedBox(height: 8), _shimmerBox(context, 80, 12)])),
            _shimmerBox(context, 60, 16),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(BuildContext context, double width, double height, {bool isCircle = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100]!;
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) => Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: baseColor,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(6),
          gradient: LinearGradient(colors: [baseColor, highlightColor, baseColor], stops: const [0.1, 0.5, 0.9], begin: Alignment(-1.0 + (_shimmerController.value * 2.0), 0.0), end: Alignment(1.0 + (_shimmerController.value * 2.0), 0.0)),
        ),
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
              _buildDetailRow(context, state.translate("Recipient/Sender", "Qofka/Dhinaca"), tx.name),
              _buildDetailRow(context, state.translate("Amount", "Lacagta"), tx.amount),
              _buildDetailRow(context, state.translate("Type", "Nooca"), tx.type),
              _buildDetailRow(context, state.translate("Date", "Taariikhda"), tx.date),
              _buildDetailRow(context, state.translate("Status", "Heerka"), state.translate(tx.status, tx.status)),
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.grey))),
          const SizedBox(width: 16),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      )
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState state) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 80, color: AppColors.grey.withValues(alpha: 0.5)), const SizedBox(height: 16), Text(state.translate("No transactions found", "Dhaqdhaqaaq lama hayo"), style: const TextStyle(color: AppColors.grey))]));
  }
}

