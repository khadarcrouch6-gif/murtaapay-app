import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/receipt_view.dart';
import 'models/card_model.dart';

class CardStatementScreen extends StatefulWidget {
  final VirtualCard card;

  const CardStatementScreen({super.key, required this.card});

  @override
  State<CardStatementScreen> createState() => _CardStatementScreenState();
}

class _CardStatementScreenState extends State<CardStatementScreen> {
  String _selectedPeriod = "This Month";
  
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardTransactions = state.transactions.where((tx) => tx.cardId == widget.card.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(state.translate("Bayaanka Kaadhka", "Card Statement")),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.translate("Statement-ka waa la soo dejinayaa...", "Downloading statement...")),
                  backgroundColor: AppColors.accentTeal,
                ),
              );
            },
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: MaxWidthBox(
          maxWidth: 800,
          child: Column(
            children: [
              _buildCardSummary(context, state, isDark),
              _buildFilters(state, context),
              Expanded(
                child: cardTransactions.isEmpty
                    ? _buildEmptyState(state, context)
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 8),
                        itemCount: cardTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = cardTransactions[index];
                          return _buildStatementItem(context, state, tx);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSummary(BuildContext context, AppState state, bool isDark) {
    final currencyFormatter = NumberFormat.simpleCurrency(name: state.currencyCode);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16 * context.fontSizeFactor),
      padding: EdgeInsets.all(24 * context.fontSizeFactor),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [AppColors.primaryDark, const Color(0xFF1E293B)]
              : [AppColors.primaryDark, AppColors.primaryDark.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.card.cardHolder.toUpperCase(),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              Text(
                widget.card.network == CardNetwork.visa ? "VISA" : "MASTERCARD",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 14 * context.fontSizeFactor),
              ),
            ],
          ),
          SizedBox(height: 8 * context.fontSizeFactor),
          Text(
            "•••• •••• •••• ${widget.card.cardNumber.substring(widget.card.cardNumber.length - 4)}",
            style: TextStyle(color: Colors.white, fontSize: 18 * context.fontSizeFactor, letterSpacing: 2, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 24 * context.fontSizeFactor),
          Text(
            state.translate("Baaqiga Hadda", "Current Balance"),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12 * context.fontSizeFactor),
          ),
          Text(
            currencyFormatter.format(widget.card.balance),
            style: TextStyle(color: Colors.white, fontSize: 28 * context.fontSizeFactor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AppState state, BuildContext context) {
    final periods = ["This Month", "Last Month", "Last 3 Months", "Custom"];
    return SizedBox(
      height: 50 * context.fontSizeFactor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: EdgeInsets.only(right: 8 * context.fontSizeFactor),
            child: ChoiceChip(
              label: Text(state.translate(period, period)), // Simplification for mock
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedPeriod = period);
              },
              selectedColor: AppColors.accentTeal.withValues(alpha: 0.2),
              checkmarkColor: AppColors.accentTeal,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accentTeal : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13 * context.fontSizeFactor,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatementItem(BuildContext context, AppState state, dynamic tx) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => ReceiptView.show(context, tx.toJson()),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: (tx.isNegative ? Colors.red : AppColors.accentTeal).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tx.isNegative ? Icons.shopping_bag_outlined : Icons.add_circle_outline,
                color: tx.isNegative ? Colors.red : AppColors.accentTeal,
                size: 20 * context.fontSizeFactor,
              ),
            ),
            SizedBox(width: 16 * context.fontSizeFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor),
                  ),
                  Text(
                    tx.date,
                    style: TextStyle(color: Colors.grey, fontSize: 12 * context.fontSizeFactor),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tx.amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15 * context.fontSizeFactor,
                    color: tx.isNegative ? null : AppColors.accentTeal,
                  ),
                ),
                Text(
                  tx.status,
                  style: TextStyle(
                    fontSize: 10 * context.fontSizeFactor,
                    fontWeight: FontWeight.bold,
                    color: tx.status == "Success" ? AppColors.accentTeal : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppState state, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            state.translate("Ma jiraan wax dhaqdhaqaaq ah.", "No transactions found."),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

