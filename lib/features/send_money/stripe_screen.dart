import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/step_indicator.dart';
import '../../core/widgets/success_screen.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../l10n/app_localizations.dart';
import 'credit_card_screen.dart';

class StripeScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String currencyCode;

  const StripeScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.currencyCode,
  });

  @override
  State<StripeScreen> createState() => _StripeScreenState();
}

class _StripeScreenState extends State<StripeScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryMmyyController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();

  void _processPayment() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    if (_emailController.text.isEmpty || _cardController.text.isEmpty || _expiryMmyyController.text.isEmpty || _cvcController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete the Stripe form")),
      );
      return;
    }

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

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: l10n.transferSuccessful,
            message: l10n.transferSentMessage(
              NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0),
              widget.receiverName,
            ),
            buttonText: l10n.backToHome,
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scale = context.fontSizeFactor;
    const Color stripeColor = Color(0xFF635BFF);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * scale),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdaptiveIcon(FontAwesomeIcons.stripe, color: Colors.white, size: 48 * scale),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- HEADER BACKGROUND (Step Indicator) ---
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
          
          Expanded(
            child: Center(
              child: MaxWidthBox(
                maxWidth: 800,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.0 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        child: Center(
                          child: Column(
                            children: [
                              Text("Total Due", style: TextStyle(color: AppColors.grey, fontSize: 14 * scale)),
                              SizedBox(height: 8 * scale),
                              Text(
                                NumberFormat.simpleCurrency(name: widget.currencyCode).format(Provider.of<AppState>(context, listen: false).calculateTotalForSource(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0, "Stripe")),
                                style: TextStyle(fontSize: 32 * scale, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                              ),
                              SizedBox(height: 4 * scale),
                              Text("To ${widget.receiverName}", style: TextStyle(color: AppColors.grey, fontSize: 14 * scale)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32 * scale),
                      FadeInUp(
                        child: Text("Contact", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale, color: theme.textTheme.titleMedium?.color)),
                      ),
                      SizedBox(height: 12 * scale),
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16 * scale),
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(color: theme.hintColor, fontSize: 16 * scale),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12 * scale),
                              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12 * scale),
                              borderSide: const BorderSide(color: stripeColor, width: 2),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      FadeInUp(
                         delay: const Duration(milliseconds: 150),
                         child: Text(l10n.paymentMethod, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale, color: theme.textTheme.titleMedium?.color)),
                      ),
                      SizedBox(height: 12 * scale),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                            color: theme.colorScheme.surface,
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _cardController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  CardNumberFormatter(),
                                ],
                                style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16 * scale),
                                decoration: InputDecoration(
                                  hintText: l10n.cardNumber,
                                  hintStyle: TextStyle(color: theme.hintColor, fontSize: 16 * scale),
                                  prefixIcon: Icon(Icons.credit_card_rounded, color: AppColors.grey, size: 24 * scale),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                                  border: InputBorder.none,
                                ),
                              ),
                              Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _expiryMmyyController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        ExpiryDateFormatter(),
                                      ],
                                      style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16 * scale),
                                      decoration: InputDecoration(
                                        hintText: "MM / YY",
                                        hintStyle: TextStyle(color: theme.hintColor, fontSize: 16 * scale),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, height: 48 * scale, color: theme.dividerColor.withValues(alpha: 0.1)),
                                  Expanded(
                                    child: TextField(
                                      controller: _cvcController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16 * scale),
                                      decoration: InputDecoration(
                                        hintText: "CVC",
                                        hintStyle: TextStyle(color: theme.hintColor, fontSize: 16 * scale),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                                        border: InputBorder.none,
                                      ),
                                      obscureText: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32 * scale),
                      
                      // Pay Button
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: stripeColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              padding: EdgeInsets.symmetric(vertical: 16 * scale),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                              elevation: 0,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Pay ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(Provider.of<AppState>(context, listen: false).calculateTotalForSource(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0, "Stripe"))}",
                                style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24 * scale),
                      Center(
                        child: FadeIn(
                          child: Text(
                            "Processing via Stripe secure 3D secure...",
                            style: TextStyle(color: AppColors.grey, fontSize: 13 * scale, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cardController.dispose();
    _expiryMmyyController.dispose();
    _cvcController.dispose();
    super.dispose();
  }
}

