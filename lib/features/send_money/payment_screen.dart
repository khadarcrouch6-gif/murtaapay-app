import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'review_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String payoutMethod;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = "Murtaax Wallet";

  final List<Map<String, dynamic>> _paymentMethods = [
    {"name": "Murtaax Wallet", "icon": Icons.account_balance_wallet_rounded, "desc": "Pay from your app balance"},
    {"name": "Visa / MasterCard", "icon": Icons.credit_card_rounded, "desc": "Pay using your card"},
    {"name": "Bank Transfer", "icon": Icons.account_balance_rounded, "desc": "Direct bank transfer"},
    {"name": "Mobile Money", "icon": Icons.phone_android_rounded, "desc": "EVC Plus, Sahal, ZAAD, e-Dahab"},
  ];

  void _handleContinue() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          amount: widget.amount,
          receiverName: widget.receiverName,
          receiverPhone: widget.receiverPhone,
          method: widget.payoutMethod,
          paymentMethod: _selectedPaymentMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : AppColors.accentTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment & Review",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER BACKGROUND (Step Indicator) ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? AppColors.primaryDark : AppColors.accentTeal,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        _buildStepIndicator(1, "Amount", false, true, isHeader: true),
                        _buildStepLine(true, isHeader: true),
                        _buildStepIndicator(2, "Receiver", false, true, isHeader: true),
                        _buildStepLine(true, isHeader: true),
                        _buildStepIndicator(3, "Payment", true, false, isHeader: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- RECEIVER SUMMARY CARD ---
                          FadeInDown(
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Transfer Amount", style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                                      Text("\$${widget.amount}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.accentTeal)),
                                    ],
                                  ),
                                  const Divider(height: 30),
                                  _buildSummaryRow("Recipient", widget.receiverName, Icons.person_outline),
                                  const SizedBox(height: 12),
                                  _buildSummaryRow(
                                    widget.payoutMethod.contains("Bank")
                                        ? "Account Number"
                                        : (widget.payoutMethod == "Murtaax Wallet"
                                            ? "Wallet ID"
                                            : (widget.payoutMethod.contains("Visa") || widget.payoutMethod.contains("MasterCard")
                                                ? "Card Number"
                                                : "Phone Number")),
                                    widget.receiverPhone,
                                    widget.payoutMethod.contains("Bank") ? Icons.account_balance_outlined : Icons.phone_android_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSummaryRow("Payout Via", widget.payoutMethod, Icons.speed_rounded),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          const Text(
                            "Select Payment Method",
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          
                          ..._paymentMethods.map((method) => FadeInLeft(
                            delay: Duration(milliseconds: _paymentMethods.indexOf(method) * 100),
                            child: _buildPaymentMethodTile(method, theme),
                          )),
                          
                          const SizedBox(height: 30),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: AppColors.accentTeal.withValues(alpha: 0.3),
                              ),
                              child: const Text(
                                "Review & Confirm",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method, ThemeData theme) {
    bool isSelected = _selectedPaymentMethod == method["name"];
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method["name"]),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.1), blurRadius: 10)] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.dividerColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(method["icon"], color: isSelected ? AppColors.accentTeal : AppColors.grey, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(method["name"], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      if (method["name"] == "Murtaax Wallet")
                        const Text("Bal: \$1,250.00", style: TextStyle(color: AppColors.accentTeal, fontSize: 12, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Text(method["desc"], style: const TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    Color activeColor = isHeader ? Colors.white : AppColors.accentTeal;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300]!;
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? AppColors.accentTeal : Colors.grey);

    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 4) : null
          ),
          child: Center(child: isCompleted && !isActive ? Icon(Icons.check, color: isHeader ? AppColors.accentTeal : Colors.white, size: 18) : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? AppColors.accentTeal : Colors.white) : Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted, {bool isHeader = false}) { 
    Color color = isHeader 
      ? (isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.3)) 
      : (isCompleted ? AppColors.accentTeal : Colors.grey[200]!);
    return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))));
  }
}
