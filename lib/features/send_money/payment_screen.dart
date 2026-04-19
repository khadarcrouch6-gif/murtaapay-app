import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/responsive_utils.dart';
import 'package:intl/intl.dart';
import 'review_screen.dart';
import 'wallet_payment_screen.dart';
import 'credit_card_screen.dart';
import 'sender_bank_screen.dart';
import 'mobile_money_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String payoutMethod;
  final String currencyCode;
  final String purpose;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.currencyCode,
    required this.purpose,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = "Murtaax Wallet";

  void _handleContinue(AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    final appState = Provider.of<AppState>(context, listen: false);
    final amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
    final totalCost = appState.calculateTotal(amountVal);

    if (_selectedPaymentMethod == "Murtaax Wallet" && !appState.hasSufficientBalance(amountVal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.translate("Insufficient balance in your Murtaax Wallet", "Haraagaagu kuguma filna Murtaax Wallet")),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == "Murtaax Wallet") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalletPaymentScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            payoutMethod: widget.payoutMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
          ),
        ),
      );
    } else if (_selectedPaymentMethod == "Visa / MasterCard") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreditCardScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            payoutMethod: widget.payoutMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
          ),
        ),
      );
    } else if (_selectedPaymentMethod == "Bank Transfer") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SenderBankScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            payoutMethod: widget.payoutMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
          ),
        ),
      );
    } else if (_selectedPaymentMethod == "Mobile Money") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileMoneyScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            payoutMethod: widget.payoutMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
          ),
        ),
      );
    } else {
      String displayMethod = _selectedPaymentMethod;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            method: widget.payoutMethod,
            paymentMethod: displayMethod,
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context);

    final List<Map<String, dynamic>> paymentMethods = [
      {"id": "Murtaax Wallet", "name": l10n.murtaaxWallet, "icon": Icons.account_balance_wallet_rounded, "desc": l10n.murtaaxWalletDesc},
      {"id": "Visa / MasterCard", "name": l10n.visaMastercard, "icon": Icons.credit_card_rounded, "desc": l10n.visaMastercardDesc},
      {"id": "Bank Transfer", "name": l10n.bankTransfer, "icon": Icons.account_balance_rounded, "desc": l10n.bankTransferDesc},
      {"id": "Mobile Money", "name": l10n.mobileMoney, "icon": Icons.phone_android_rounded, "desc": l10n.mobileMoneyDesc},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.choosePaymentMethod,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
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
                        _buildStepIndicator(context, 3, l10n.stepPayment, true, false, isHeader: true),
                        _buildStepLine(context, false, isHeader: true),
                        _buildStepIndicator(context, 4, l10n.stepReview, false, false, isHeader: true),
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
                                      Text(l10n.amount, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                                      Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: theme.colorScheme.secondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(l10n.transactionFee, style: const TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                                      Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.calculateFee(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0)), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.grey)),
                                    ],
                                  ),
                                  const Divider(height: 30),
                                  _buildSummaryRow(l10n.receiver, widget.receiverName, Icons.person_outline),
                                  const SizedBox(height: 12),
                                  _buildSummaryRow(
                                    widget.payoutMethod.contains("Bank")
                                        ? l10n.accountNumber
                                        : (widget.payoutMethod == "Murtaax Wallet"
                                            ? l10n.walletId
                                            : (widget.payoutMethod.contains("Visa") || widget.payoutMethod.contains("MasterCard")
                                                ? l10n.cardNumber
                                                : l10n.phoneNumber)),
                                    widget.receiverPhone,
                                    widget.payoutMethod.contains("Bank") ? Icons.account_balance_outlined : Icons.phone_android_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSummaryRow(l10n.payoutVia, widget.payoutMethod, Icons.speed_rounded),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          Text(
                            l10n.selectPaymentMethod,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          
                          ...paymentMethods.map((method) => FadeInLeft(
                            delay: Duration(milliseconds: paymentMethods.indexOf(method) * 100),
                            child: _buildPaymentMethodTile(method, theme, l10n),
                          )),
                          
                          const SizedBox(height: 30),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _handleContinue(l10n),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              ),
                              child: Text(
                                l10n.continueToReview,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
    final fontSizeFactor = context.fontSizeFactor;
    return Row(
      children: [
        Icon(icon, size: (18 * fontSizeFactor).toDouble(), color: AppColors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label, 
            style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: (14 * fontSizeFactor).toDouble()),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: (14 * fontSizeFactor).toDouble()),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method, ThemeData theme, AppLocalizations l10n) {
    bool isSelected = _selectedPaymentMethod == method["id"];
    final appState = Provider.of<AppState>(context, listen: false);
    
    final amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
    final hasEnough = appState.hasSufficientBalance(amountVal);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method["id"]),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
              ? (method["id"] == "Murtaax Wallet" && !hasEnough ? Colors.red : theme.colorScheme.secondary) 
              : theme.dividerColor.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: isSelected ? [BoxShadow(color: (method["id"] == "Murtaax Wallet" && !hasEnough ? Colors.red : theme.colorScheme.secondary).withValues(alpha: 0.1), blurRadius: 10)] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected 
                  ? (method["id"] == "Murtaax Wallet" && !hasEnough ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.secondary.withValues(alpha: 0.1)) 
                  : theme.dividerColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(method["icon"], color: isSelected ? (method["id"] == "Murtaax Wallet" && !hasEnough ? Colors.red : theme.colorScheme.secondary) : AppColors.grey, size: 24),
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
                      if (method["id"] == "Murtaax Wallet")
                        Text(
                          "Bal: ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.balance)}", 
                          style: TextStyle(
                            color: hasEnough ? theme.colorScheme.secondary : Colors.red, 
                            fontSize: 12, 
                            fontWeight: FontWeight.w900
                          )
                        ),
                    ],
                  ),
                  Text(method["desc"], style: const TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                  if (method["id"] == "Murtaax Wallet" && !hasEnough)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        appState.translate("Insufficient balance", "Haraagaagu kuguma filna"),
                        style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                method["id"] == "Murtaax Wallet" && !hasEnough ? Icons.error_outline_rounded : Icons.check_circle_rounded, 
                color: method["id"] == "Murtaax Wallet" && !hasEnough ? Colors.red : theme.colorScheme.secondary, 
                size: 24
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    final theme = Theme.of(context);
    Color activeColor = isHeader ? Colors.white : theme.colorScheme.secondary;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!);
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? theme.colorScheme.secondary : Colors.grey);

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
      : (isCompleted ? theme.colorScheme.secondary : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!));
    return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))));
  }
}
