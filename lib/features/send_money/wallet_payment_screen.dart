import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'payment_success_screen.dart';

class WalletPaymentScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;

  const WalletPaymentScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
  });

  @override
  State<WalletPaymentScreen> createState() => _WalletPaymentScreenState();
}

class _WalletPaymentScreenState extends State<WalletPaymentScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isProcessing = false;

  void _processWalletPayment() async {
    if (_pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your 4-digit security PIN")),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    // Professional processing delay
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            method: "Murtaax Wallet",
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text("${l10n.appTitle} Wallet", style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryDark),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.walletBalance, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                          const Text("\$2,450.00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark)),
                        ],
                      ),
                    ),
                    Text(l10n.active, style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            
            // Visual Card
            FadeInUp(
              child: Container(
                height: 160,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, Color(0xFF2C3E50)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${l10n.appTitle} Pay", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const Icon(Icons.wallet, color: Colors.white70),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.availableBalance, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        const Text("\$2,450.00", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(l10n.securityVerification, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(l10n.enterTransactionPin, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            // PIN Input
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Center(
                child: SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _pinController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 32, letterSpacing: 24, fontWeight: FontWeight.bold),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      hintText: "****",
                      hintStyle: const TextStyle(letterSpacing: 24, fontSize: 32),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentTeal, width: 2)),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Pay Button
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processWalletPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                            const SizedBox(width: 12),
                            Text(l10n.authorizing, style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        )
                      : Text(
                          l10n.confirmPaymentAmount("\$${widget.amount}"),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ),
            
            if (_isProcessing)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: FadeIn(
                    child: Text(
                      l10n.verifyingTransaction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancelAndChangeMethod, style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}

