import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';
import 'payment_screen.dart';

class ReviewScreen extends StatelessWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String? method;

  const ReviewScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    this.method,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // Calculation (Mock)
    double amountVal = double.tryParse(amount) ?? 0;
    double fee = (amountVal / 100).ceil() * 0.99;
    double total = amountVal + fee;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.reviewTransfer,
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color, fontSize: 20 * context.fontSizeFactor),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20 * context.fontSizeFactor, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 20),
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      DetailRow(label: l10n.youSend, value: "\$$amount"),
                      const SizedBox(height: 12),
                      DetailRow(label: l10n.paymentMethod, value: method ?? "Murtaax Wallet"),
                      const SizedBox(height: 12),
                      DetailRow(label: l10n.fee, value: "\$${fee.toStringAsFixed(2)}"),
                      const SizedBox(height: 12),
                      DetailRow(label: l10n.exchangeRate, value: "1 USD = 1 USD"),
                      const Divider(height: 32),
                      DetailRow(
                        label: l10n.receiverGets, 
                        value: "\$$amount",
                        isBold: true,
                        valueColor: AppColors.accentTeal,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FadeInUp(
                child: Column(
                  children: [
                    Text(
                      l10n.deliveryNotice,
                      style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56 * context.fontSizeFactor,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentMethodScreen(
                                amount: amount,
                                receiverName: receiverName,
                                receiverPhone: receiverPhone,
                                // total: total.toStringAsFixed(2), // PaymentMethodScreen uses amount to calculate fee
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.confirmAndPay,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
