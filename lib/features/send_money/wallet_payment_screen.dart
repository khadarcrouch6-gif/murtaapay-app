import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'review_screen.dart';

class WalletPaymentScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String payoutMethod;
  final String currencyCode;
  final String purpose;

  const WalletPaymentScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.currencyCode,
    required this.purpose,
  });

  @override
  State<WalletPaymentScreen> createState() => _WalletPaymentScreenState();
}

class _WalletPaymentScreenState extends State<WalletPaymentScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _processWalletPayment() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (_pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterSecurityPin)),
      );
      return;
    }

    if (!appState.verifyPin(_pinController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PIN-kaagu waa khalad. Fadlan isku day markale."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Standardized transaction loader
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
                    l10n.justAMoment, 
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
    
    // Professional processing delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            method: widget.payoutMethod,
            paymentMethod: "Murtaax Wallet",
            currencyCode: widget.currencyCode,
            purpose: widget.purpose,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * scale),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.securityVerification, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * scale, color: Colors.white)),
        centerTitle: true,
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
              padding: EdgeInsets.only(bottom: 20 * scale),
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 800,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
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
            SizedBox(height: 16 * scale),
            Center(
              child: MaxWidthBox(
                maxWidth: 800,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        child: Container(
                          padding: EdgeInsets.all(16 * scale),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16 * scale),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.walletBalance, style: TextStyle(color: AppColors.grey, fontSize: 12 * scale, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.balance), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * scale, color: theme.textTheme.bodyLarge?.color)),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8 * scale),
                              Text(l10n.active, style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 14 * scale)),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 32 * scale),
                      
                      // Visual Card
                      FadeInUp(
                        child: Container(
                          height: 160 * scale,
                          width: double.infinity,
                          padding: EdgeInsets.all(24 * scale),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: theme.brightness == Brightness.dark 
                                ? [AppColors.primaryDark, const Color(0xFF1A252F)]
                                : [AppColors.primaryDark, const Color(0xFF2C3E50)],
                            ),
                            borderRadius: BorderRadius.circular(24 * scale),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text("${l10n.appTitle} Pay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16 * scale), overflow: TextOverflow.ellipsis)),
                                  Icon(Icons.wallet, color: Colors.white70, size: 24 * scale),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.availableBalance, style: TextStyle(color: Colors.white54, fontSize: 10 * scale, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.balance), style: TextStyle(color: Colors.white, fontSize: 24 * scale, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 40 * scale),

                      Text(l10n.securityVerification, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale), overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8 * scale),
                      Text(l10n.enterTransactionPin, style: TextStyle(color: AppColors.grey, fontSize: 13 * scale, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      SizedBox(height: 24 * scale),

                      // PIN Input
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: Center(
                          child: SizedBox(
                            width: 240 * scale,
                            child: TextField(
                              controller: _pinController,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 32 * scale, letterSpacing: 24 * scale, fontWeight: FontWeight.bold),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              decoration: InputDecoration(
                                hintText: "****",
                                hintStyle: TextStyle(letterSpacing: 24 * scale, fontSize: 32 * scale),
                                filled: true,
                                fillColor: theme.dividerColor.withValues(alpha: 0.05),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * scale), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * scale), borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2)),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 48 * scale),

                      // Pay Button
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56 * scale,
                          child: ElevatedButton(
                            onPressed: _processWalletPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
                              elevation: 4,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.confirmPaymentAmount(NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.calculateTotal(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0))),
                                style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 40 * scale),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancelAndChangeMethod, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14 * scale)),
                        ),
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

  Widget _buildStepIndicator(BuildContext context, int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    Color activeColor = isHeader ? Colors.white : theme.colorScheme.secondary;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!);
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? theme.colorScheme.secondary : Colors.grey);

    return Column(
      children: [
        Container(
          width: 28 * scale, height: 28 * scale,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 4 * scale) : null
          ),
          child: Center(child: isCompleted && !isActive ? Icon(Icons.check, color: isHeader ? theme.colorScheme.secondary : Colors.white, size: 16 * scale) : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? theme.colorScheme.secondary : Colors.white) : Colors.white, fontSize: 12 * scale, fontWeight: FontWeight.w900))),
        ),
        SizedBox(height: 4 * scale),
        SizedBox(
          width: 50 * scale,
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 9 * scale, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildStepLine(BuildContext context, bool isCompleted, {bool isHeader = false}) { 
    final theme = Theme.of(context);
    Color color = isHeader 
      ? (isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.3)) 
      : (isCompleted ? theme.colorScheme.secondary : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!));
    return Expanded(child: Container(height: 3, margin: EdgeInsets.symmetric(horizontal: 6 * context.fontSizeFactor), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))));
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}

