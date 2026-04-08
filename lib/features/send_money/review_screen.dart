import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../navigation/main_navigation.dart';

class ReviewScreen extends StatelessWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String method;
  final String paymentMethod;

  const ReviewScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.method,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    double amountVal = double.tryParse(amount.replaceAll(',', '')) ?? 0;
    double fee = amountVal * 0.0099;
    double total = amountVal + fee;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : AppColors.accentTeal,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24), onPressed: () => Navigator.pop(context)),
        title: Text(l10n.reviewTransfer, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white, letterSpacing: -0.5)),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER BACKGROUND ---
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
                        _buildStepIndicator(3, "Payment", false, true, isHeader: true),
                        _buildStepLine(true, isHeader: true),
                        _buildStepIndicator(4, "Review", true, false, isHeader: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: MaxWidthBox(
                maxWidth: 500,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      FadeInDown(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildReviewRow(context, l10n.youSend, "\$ $amount", isBold: true),
                              const Divider(height: 24),
                              _buildReviewRow(context, l10n.receiver, receiverName),
                              const SizedBox(height: 12),
                              _buildReviewRow(
                                context,
                                method.contains("Bank")
                                    ? "Account Number"
                                    : (method == "Murtaax Wallet"
                                        ? "Wallet ID"
                                        : (method.contains("Visa") || method.contains("MasterCard") ? "Card Number" : "Phone Number")),
                                receiverPhone,
                              ),
                              const SizedBox(height: 12),
                              _buildReviewRow(context, "Payout Via", method),
                              const SizedBox(height: 12),
                              _buildReviewRow(context, "Paid Using", paymentMethod),
                              const SizedBox(height: 12),
                              _buildReviewRow(context, l10n.transactionFee, "\$ ${fee.toStringAsFixed(2)}"),
                              const Divider(height: 24),
                              _buildReviewRow(context, l10n.totalToPay, "\$ ${total.toStringAsFixed(2)}", isTotal: true),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      FadeInUp(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      l10n.deliveryNotice,
                                      style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  _showSuccessDialog(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentTeal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                  shadowColor: AppColors.accentTeal.withValues(alpha: 0.3),
                                ),
                                child: Text(
                                  l10n.confirmAndPay,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    final transactionId = "TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Transfer Successful!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 10),
            const Text("Your money is on its way.", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            
            // Transaction ID Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Ref ID: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text(transactionId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: transactionId));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID Copied"), duration: Duration(seconds: 1)));
                    },
                    child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.accentTeal),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // Share Receipt Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Share logic here
                },
                icon: const Icon(Icons.share_rounded, size: 20),
                label: const Text("Share Receipt", style: TextStyle(fontWeight: FontWeight.w900)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentTeal,
                  side: const BorderSide(color: AppColors.accentTeal, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainNavigation()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Back to Home", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
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

  Widget _buildReviewRow(BuildContext context, String label, String value, {bool isBold = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.grey, fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isTotal ? AppColors.accentTeal : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
              fontSize: isTotal ? 24 : (isBold ? 18 : 16), 
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}
