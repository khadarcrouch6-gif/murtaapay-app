import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../l10n/app_localizations.dart';
import 'credit_card_screen.dart';
import 'stripe_screen.dart';
import 'wallet_payment_screen.dart';
import 'payment_success_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String? initialMethod;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    this.initialMethod,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedPaymentMethod = "";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMethod != null) {
      if (widget.initialMethod == "Murtaax Wallet") _selectedPaymentMethod = "wallet";
      if (widget.initialMethod!.contains("Visa")) _selectedPaymentMethod = "visa";
      if (widget.initialMethod!.contains("Mastercard")) _selectedPaymentMethod = "mastercard";
      if (widget.initialMethod == "Stripe") _selectedPaymentMethod = "stripe";
      if (widget.initialMethod == "EVC Plus") _selectedPaymentMethod = "evc";
      if (widget.initialMethod == "ZAAD Service") _selectedPaymentMethod = "zaad";
      if (widget.initialMethod == "e-Dahab") _selectedPaymentMethod = "edahab";
    }
  }

    void _handleFinalPayment() async {
    if (_selectedPaymentMethod == "wallet") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WalletPaymentScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
          ),
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == "visa" || _selectedPaymentMethod == "mastercard") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreditCardScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            initialCardType: _selectedPaymentMethod,
          ),
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == "stripe") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StripeScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
          ),
        ),
      );
      return;
    }

    // Default processing for others (EVC, ZAAD, edahab, Bank)
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      String methodName = "";
      switch (_selectedPaymentMethod) {
        case "evc": methodName = "EVC Plus"; break;
        case "zaad": methodName = "ZAAD Service"; break;
        case "edahab": methodName = "e-Dahab"; break;
        case "bank": methodName = "Bank Transfer"; break;
        default: methodName = _selectedPaymentMethod.toUpperCase();
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            method: methodName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double sendAmount = double.tryParse(widget.amount) ?? 0;
    double fee = (_selectedPaymentMethod == "visa" || _selectedPaymentMethod == "mastercard" || _selectedPaymentMethod == "stripe") ? sendAmount * 0.019 : 0;
    double totalToPay = sendAmount + fee;
    double receivedAmount = sendAmount * 1.08;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.choosePaymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.finalSummary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildSummaryRow(l10n.amount, "${widget.amount} USD"),
                    _buildSummaryRow(l10n.fee, "${fee.toStringAsFixed(2)} USD", isTeal: fee == 0),
                    _buildSummaryRow(l10n.totalToPay, "${totalToPay.toStringAsFixed(2)} USD", isBold: true),
                    const Divider(height: 24),
                    _buildSummaryRow(l10n.receiverGets, "\$${receivedAmount.toStringAsFixed(2)}", isTeal: true, isBold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text(l10n.selectPaymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),

            _buildPaymentMethodCard(
              title: "${l10n.appTitle} Wallet",
              subtitle: l10n.instantPaymentFromWallet,
              imagePath: "assets/images/walletlogo.png",
              methodId: "wallet",
              isSelected: _selectedPaymentMethod == "wallet",
              onTap: () => setState(() => _selectedPaymentMethod = "wallet"),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              title: "EVC Plus",
              subtitle: l10n.payViaHormuud,
              imagePath: "assets/images/evc.png",
              methodId: "evc",
              isSelected: _selectedPaymentMethod == "evc",
              onTap: () => setState(() => _selectedPaymentMethod = "evc"),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              title: "ZAAD Service",
              subtitle: l10n.payViaTelesom,
              imagePath: "assets/images/zaad.png",
              methodId: "zaad",
              isSelected: _selectedPaymentMethod == "zaad",
              onTap: () => setState(() => _selectedPaymentMethod = "zaad"),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              title: "e-Dahab",
              subtitle: l10n.payViaSomtel,
              imagePath: "assets/images/edahab.png",
              methodId: "edahab",
              isSelected: _selectedPaymentMethod == "edahab",
              onTap: () => setState(() => _selectedPaymentMethod = "edahab"),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              title: l10n.bankTransfer,
              subtitle: l10n.localBankTransfer,
              imagePath: "assets/images/bank.png",
              methodId: "bank",
              isSelected: _selectedPaymentMethod == "bank",
              onTap: () => setState(() => _selectedPaymentMethod = "bank"),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            
            Text(l10n.internationalMethods, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            
            _buildPaymentMethodCard(
              title: "Visa / Mastercard",
              subtitle: l10n.payWithInternationalCard,
              icon: FontAwesomeIcons.creditCard,
              methodId: "visa",
              isSelected: _selectedPaymentMethod == "visa" || _selectedPaymentMethod == "mastercard",
              onTap: () => setState(() => _selectedPaymentMethod = "visa"),
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedPaymentMethod.isEmpty || _isProcessing) ? null : _handleFinalPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isProcessing 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.payNow, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTeal = false, bool isBold = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isTeal ? AppColors.accentTeal : theme.textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String title, 
    required String subtitle, 
    dynamic icon, 
    String? imagePath,
    required String methodId, 
    required bool isSelected, 
    required VoidCallback onTap
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.05) : theme.colorScheme.surface,
          border: Border.all(color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.1), width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : theme.dividerColor.withValues(alpha: 0.05), 
                borderRadius: BorderRadius.circular(14)
              ),
              child: imagePath != null 
                ? Image.asset(imagePath, fit: BoxFit.contain)
                : AdaptiveIcon(icon ?? Icons.payment_rounded, color: isSelected ? AppColors.accentTeal : AppColors.primaryDark, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.accentTeal),
          ],
        ),
      ),
    );
  }
}
