import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/step_indicator.dart';
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
  final String? sourceOfFunds;
  final String? swiftCode;
  final String? address;
  final String? city;
  final String? country;

  const WalletPaymentScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.currencyCode,
    required this.purpose,
    this.sourceOfFunds,
    this.swiftCode,
    this.address,
    this.city,
    this.country,
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
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterSecurityPin)),
      );
      return;
    }

    if (!appState.verifyPin(_pinController.text)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PIN-kaagu waa khalad. Fadlan isku day markale."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final amountVal = double.tryParse(widget.amount.replaceAll(',', '')) ?? 0;
    final total = appState.calculateTotal(amountVal, payoutMethod: widget.payoutMethod);
    
    if (appState.balance < total) {
      final needed = total - appState.balance;
      if (appState.savingsBalance >= needed) {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(appState.translate("Insufficient Funds", "Haraagaagu kuma filna")),
            content: Text(appState.translate(
              "Your main wallet is missing \$${needed.toStringAsFixed(2)}. Would you like to auto-top up from your Savings Account to complete this transaction?",
              "Wallet-kaaga weyn waxaa ka dhiman \$${needed.toStringAsFixed(2)}. Ma rabtaa in laga soo qaado Savings-ka si loo dhamaystiro xawaaladdan?"
            )),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
                child: Text(appState.translate("Yes, Top-up", "Haa, ka soo qaad")),
              ),
            ],
          ),
        );

        if (confirm == true) {
          try {
            await appState.autoTopUpMainFromSavings(needed);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
            );
            return;
          }
        } else {
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appState.translate("Insufficient total balance", "Haraagaagu guud ahaan kuma filna")),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    HapticFeedback.mediumImpact();
    // Standardized transaction loader
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
            sourceOfFunds: widget.sourceOfFunds,
            swiftCode: widget.swiftCode,
            address: widget.address,
            city: widget.city,
            country: widget.country,
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
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30 * scale), bottomRight: Radius.circular(30 * scale)),
              ),
              padding: EdgeInsets.only(bottom: 20 * scale),
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 800,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    child: Row(
                      children: [
                        StepIndicator(step: 1, label: l10n.stepAmount, isActive: false, isCompleted: true, isHeader: true),
                        StepLine(isCompleted: true, isHeader: true),
                        StepIndicator(step: 2, label: l10n.stepReceiver, isActive: false, isCompleted: true, isHeader: true),
                        StepLine(isCompleted: true, isHeader: true),
                        StepIndicator(step: 3, label: l10n.stepPayment, isActive: true, isCompleted: false, isHeader: true),
                        StepLine(isCompleted: false, isHeader: true),
                        StepIndicator(step: 4, label: l10n.stepReview, isActive: false, isCompleted: false, isHeader: true),
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
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10 * scale)],
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

                      SizedBox(height: 16 * scale),
                      // Daily Limit Progress Bar
                      FadeInDown(
                        delay: const Duration(milliseconds: 100),
                        child: Container(
                          padding: EdgeInsets.all(16 * scale),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16 * scale),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    appState.translate("Daily Limit", "Xadka Maalinta"),
                                    style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: AppColors.grey),
                                  ),
                                  Text(
                                    "${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.getDailySpent())} / ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.dailyLimit)}",
                                    style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w900, color: theme.colorScheme.secondary),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10 * scale),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10 * scale),
                                child: LinearProgressIndicator(
                                  value: (appState.getDailySpent() / appState.dailyLimit).clamp(0.0, 1.0),
                                  backgroundColor: theme.dividerColor.withValues(alpha: 0.05),
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                                  minHeight: 8 * scale,
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              Text(
                                "${appState.translate("Remaining", "Hambada")}: ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.getDailyRemaining())}",
                                style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.bold, color: AppColors.grey),
                              ),
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
                        child: Column(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 240 * scale,
                                child: TextField(
                                  controller: _pinController,
                                  obscureText: true,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    if (val.isNotEmpty) HapticFeedback.selectionClick();
                                  },
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
                            const SizedBox(height: 24),
                            // Digital Signature / Security Mark
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_user_rounded, color: theme.colorScheme.secondary.withValues(alpha: 0.5), size: 16 * scale),
                                SizedBox(width: 8 * scale),
                                Text(
                                  "SECURE DIGITAL SIGNATURE ACTIVE",
                                  style: TextStyle(
                                    fontSize: 10 * scale,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                                    letterSpacing: 1.2 * scale
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                                l10n.confirmPaymentAmount(NumberFormat.simpleCurrency(name: widget.currencyCode).format(appState.calculateTotal(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0, payoutMethod: widget.payoutMethod))),
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

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}

