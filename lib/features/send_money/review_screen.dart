import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/success_screen.dart';

class ReviewScreen extends StatelessWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String method;
  final String paymentMethod;
  final String currencyCode;

  const ReviewScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.method,
    required this.paymentMethod,
    required this.currencyCode,
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
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24), 
          onPressed: () {
            // Go back two steps to PaymentScreen and clear the intermediate form state
            int count = 0;
            Navigator.popUntil(context, (route) => count++ == 2);
          },
        ),
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
                color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildStepIndicator(context, 1, l10n.stepAmount, false, true, isHeader: true),
                        _buildStepLine(context, true, isHeader: true),
                        _buildStepIndicator(context, 2, l10n.stepReceiver, false, true, isHeader: true),
                        _buildStepLine(context, true, isHeader: true),
                        _buildStepIndicator(context, 3, l10n.stepPayment, false, true, isHeader: true),
                        _buildStepLine(context, true, isHeader: true),
                        _buildStepIndicator(context, 4, l10n.stepReview, true, false, isHeader: true),
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
                              _buildReviewRow(context, l10n.youSend, NumberFormat.simpleCurrency(name: currencyCode).format(amountVal), isBold: true),
                              const Divider(height: 24),
                              _buildReviewRow(context, l10n.receiver, receiverName),
                              const SizedBox(height: 12),
                              _buildReviewRow(
                                context,
                                method.contains("Bank")
                                    ? l10n.accountNumber
                                    : (method == "Murtaax Wallet"
                                        ? l10n.walletId
                                        : (method.contains("Visa") || method.contains("MasterCard") ? l10n.cardNumber : l10n.phoneNumber)),
                                receiverPhone,
                              ),
                              const SizedBox(height: 12),
                              _buildReviewRow(context, l10n.payoutVia, method),
                              const SizedBox(height: 12),
                              _buildReviewRow(context, l10n.paidUsing, paymentMethod),
                              const SizedBox(height: 12),
                              _buildReviewRow(context, l10n.transactionFee, NumberFormat.simpleCurrency(name: currencyCode).format(fee)),
                              const Divider(height: 24),
                              _buildReviewRow(context, l10n.totalToPay, NumberFormat.simpleCurrency(name: currencyCode).format(total), isTotal: true),
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
                                color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.colorScheme.errorContainer.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, color: theme.colorScheme.error, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      l10n.deliveryNotice,
                                      style: TextStyle(color: theme.colorScheme.error, fontSize: 12, fontWeight: FontWeight.bold),
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
                                  foregroundColor: theme.colorScheme.error,
                                  side: BorderSide(color: theme.colorScheme.error, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(
                                  l10n.cancel,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                                  _processTransaction(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: theme.colorScheme.onSecondary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                  shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                ),
                                child: Text(
                                  "${l10n.confirmAndPay} (${NumberFormat.simpleCurrency(name: currencyCode).format(total)})",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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

  void _processTransaction(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: ZoomIn(
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 220 * context.fontSizeFactor,
              padding: EdgeInsets.all(32 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 65 * context.fontSizeFactor,
                        height: 65 * context.fontSizeFactor,
                        child: const CircularProgressIndicator(
                          color: AppColors.accentTeal,
                          strokeWidth: 3,
                        ),
                      ),
                      Icon(
                        Icons.bolt_rounded,
                        color: AppColors.accentTeal,
                        size: 32 * context.fontSizeFactor,
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  Text(
                    "Processing...", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18 * context.fontSizeFactor,
                      color: theme.textTheme.bodyLarge?.color,
                      decoration: TextDecoration.none,
                    )
                  ),
                  SizedBox(height: 8 * context.fontSizeFactor),
                  Text(
                    l10n.moneyOnWay, 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13 * context.fontSizeFactor,
                      color: AppColors.grey,
                      decoration: TextDecoration.none,
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    _showSuccess(context);
  }

  void _showSuccess(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.transferSuccessful,
          message: l10n.moneyOnWay,
          buttonText: l10n.backToHome,
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    final theme = Theme.of(context);
    Color activeColor = isHeader ? Colors.white : theme.colorScheme.secondary;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : theme.dividerColor.withValues(alpha: 0.1);
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? theme.colorScheme.secondary : theme.textTheme.bodySmall?.color ?? Colors.grey);

    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 4) : null
          ),
          child: Center(child: isCompleted && !isActive ? Icon(Icons.check, color: isHeader ? theme.colorScheme.secondary : Colors.white, size: 18) : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? theme.colorScheme.secondary : Colors.white) : Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildStepLine(BuildContext context, bool isCompleted, {bool isHeader = false}) { 
    final theme = Theme.of(context);
    Color color = isHeader 
      ? (isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.3)) 
      : (isCompleted ? theme.colorScheme.secondary : theme.dividerColor.withValues(alpha: 0.1));
    return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)))); 
  }

  Widget _buildReviewRow(BuildContext context, String label, String value, {bool isBold = false, bool isTotal = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label, 
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color, 
              fontSize: 15, 
              fontWeight: FontWeight.w900
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isTotal ? theme.colorScheme.secondary : theme.textTheme.bodyLarge?.color,
                fontSize: isTotal ? 24 : (isBold ? 18 : 16), 
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
