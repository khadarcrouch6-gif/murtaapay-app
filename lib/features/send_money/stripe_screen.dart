import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../l10n/app_localizations.dart';
import 'payment_success_screen.dart';
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
  bool _isProcessing = false;

  void _processPayment() async {
    if (_emailController.text.isEmpty || _cardController.text.isEmpty || _expiryMmyyController.text.isEmpty || _cvcController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete the Stripe form")),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            method: "Stripe",
            currencyCode: widget.currencyCode,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const Color stripeColor = Color(0xFF635BFF);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdaptiveIcon(FontAwesomeIcons.stripe, color: Colors.white, size: 48),
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
            child: Center(
              child: MaxWidthBox(
                maxWidth: 500,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        child: Center(
                          child: Column(
                            children: [
                              const Text("Total Due", style: TextStyle(color: AppColors.grey, fontSize: 14)),
                              const SizedBox(height: 8),
                              Text(
                                NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0),
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                              ),
                              const SizedBox(height: 4),
                              Text("To ${widget.receiverName}", style: const TextStyle(color: AppColors.grey, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        child: Text("Contact", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.titleMedium?.color)),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(color: theme.hintColor),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: stripeColor, width: 2),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                         delay: const Duration(milliseconds: 150),
                         child: Text(l10n.paymentMethod, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.titleMedium?.color)),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
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
                                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                                decoration: InputDecoration(
                                  hintText: l10n.cardNumber,
                                  hintStyle: TextStyle(color: theme.hintColor),
                                  prefixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.grey),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                                      decoration: InputDecoration(
                                        hintText: "MM / YY",
                                        hintStyle: TextStyle(color: theme.hintColor),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, height: 48, color: theme.dividerColor.withValues(alpha: 0.1)),
                                  Expanded(
                                    child: TextField(
                                      controller: _cvcController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                                      decoration: InputDecoration(
                                        hintText: "CVC",
                                        hintStyle: TextStyle(color: theme.hintColor),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      const SizedBox(height: 32),
                      
                      // Pay Button
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: stripeColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: _isProcessing
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text("Processing...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : Text(
                                    "Pay ${NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0)}",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      if (_isProcessing)
                        Center(
                          child: FadeIn(
                            child: const Text(
                              "Processing via Stripe secure 3D secure...",
                              style: TextStyle(color: AppColors.grey, fontSize: 13, fontStyle: FontStyle.italic),
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
        ],
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
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor)),
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

  @override
  void dispose() {
    _emailController.dispose();
    _cardController.dispose();
    _expiryMmyyController.dispose();
    _cvcController.dispose();
    super.dispose();
  }
}

