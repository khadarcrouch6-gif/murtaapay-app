import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'review_screen.dart';


class CreditCardScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String payoutMethod;
  final String currencyCode;
  final String initialCardType;

  const CreditCardScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.payoutMethod,
    required this.currencyCode,
    this.initialCardType = "unknown",
  });

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  late String _cardType;

  @override
  void initState() {
    super.initState();
    _cardType = widget.initialCardType;
    _cardNumberController.addListener(() {
      _getCardType(_cardNumberController.text);
      setState(() {});
    });
    _cardHolderController.addListener(() => setState(() {}));
    _expiryController.addListener(() => setState(() {}));
    _cvvController.addListener(() => setState(() {}));
  }

  void _getCardType(String number) {
    String cleanNumber = number.replaceAll(' ', '');
    String type = "unknown";
    
    if (cleanNumber.startsWith(RegExp(r'^4'))) {
      type = "visa";
    } else if (cleanNumber.startsWith(RegExp(r'^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[01]|2720)'))) {
      type = "mastercard";
    } else if (cleanNumber.startsWith(RegExp(r'^3[47]'))) {
      type = "amex";
    } else if (cleanNumber.startsWith(RegExp(r'^6(?:011|5)'))) {
      type = "discover";
    }

    if (_cardType != type) {
      setState(() {
        _cardType = type;
      });
    }
  }

  Widget _getCardIcon() {
    final scale = context.fontSizeFactor;
    switch (_cardType) {
      case "visa":
        return AdaptiveIcon(FontAwesomeIcons.ccVisa, color: AppColors.primaryDark, size: 28 * scale);
      case "mastercard":
        return AdaptiveIcon(FontAwesomeIcons.ccMastercard, color: AppColors.primaryDark, size: 28 * scale);
      case "amex":
        return AdaptiveIcon(FontAwesomeIcons.ccAmex, color: AppColors.primaryDark, size: 28 * scale);
      case "discover":
        return AdaptiveIcon(FontAwesomeIcons.ccDiscover, color: AppColors.primaryDark, size: 28 * scale);
      default:
        return Icon(Icons.credit_card_rounded, color: AppColors.grey, size: 28 * scale);
    }
  }

  Widget _buildLiveCard() {
    final l10n = AppLocalizations.of(context)!;
    final scale = context.fontSizeFactor;
    bool isVisa = _cardType == "visa";
    bool isMastercard = _cardType == "mastercard";
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    List<Color> cardGradient = isDark 
        ? [const Color(0xFF1E1E2C), const Color(0xFF33334C)]
        : [AppColors.primaryDark, const Color(0xFF1E4B7A)];
    
    if (isVisa) {
      cardGradient = [const Color(0xFF1A1F71), const Color(0xFF283593)];
    } else if (isMastercard) {
      cardGradient = isDark 
          ? [const Color(0xFF222222), const Color(0xFF3B3B3B)]
          : [const Color(0xFF424242), const Color(0xFF212121)];
    }

    String displayNum = _cardNumberController.text.isEmpty 
        ? "**** **** **** ****" 
        : _cardNumberController.text;
        
    String displayHolder = _cardHolderController.text.isEmpty 
        ? l10n.cardHolder 
        : _cardHolderController.text.toUpperCase();
        
    String displayExpiry = _expiryController.text.isEmpty 
        ? "MM/YY" 
        : _expiryController.text;

    return Container(
      height: 200 * scale,
      width: double.infinity,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardGradient,
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: cardGradient[0].withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.contactless_rounded, color: Colors.white70, size: 32 * scale),
              if (isVisa) 
                   AdaptiveIcon(FontAwesomeIcons.ccVisa, color: Colors.white, size: 40 * scale)
              else if (isMastercard)
                   AdaptiveIcon(FontAwesomeIcons.ccMastercard, color: Colors.amber, size: 40 * scale)
              else
                   AdaptiveIcon(FontAwesomeIcons.creditCard, color: Colors.white, size: 32 * scale)
            ],
          ),
          SizedBox(height: 16 * scale),
          Text(
            displayNum,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22 * scale,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.cardHolder, style: TextStyle(color: Colors.white54, fontSize: 10 * scale)),
                  Text(
                    displayHolder,
                    style: TextStyle(color: Colors.white, fontSize: 14 * scale, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.expires, style: TextStyle(color: Colors.white54, fontSize: 10 * scale)),
                  Text(
                    displayExpiry,
                    style: TextStyle(color: Colors.white, fontSize: 14 * scale, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_cardNumberController.text.isEmpty ||
        _cardHolderController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillAllFields)),
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
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            receiverPhone: widget.receiverPhone,
            method: widget.payoutMethod,
            paymentMethod: l10n.cardEndingIn(_cardNumberController.text.substring(_cardNumberController.text.length - 4)),
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
    final scale = context.fontSizeFactor;
    String title = l10n.cardInformation;
    if (widget.initialCardType == "visa") title = l10n.visaDetails;
    if (widget.initialCardType == "mastercard") title = l10n.mastercardDetails;

    bool isFormValid = _cardNumberController.text.isNotEmpty &&
                       _cardHolderController.text.isNotEmpty &&
                       _expiryController.text.isNotEmpty &&
                       _cvvController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * scale),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * scale, color: Colors.white),
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
                          child: Container(
                            padding: EdgeInsets.all(16 * scale),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: Text(
                                    l10n.cardDetailsInfo(widget.amount),
                                    style: TextStyle(fontSize: 12 * scale, color: AppColors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24 * scale),

                        FadeInUp(
                           child: _buildLiveCard(),
                        ),

                        SizedBox(height: 32 * scale),

                        Text(
                          l10n.cardNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16 * scale,
                            color: theme.brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16 * scale),

                        // Card Number
                        FadeInUp(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cardNumber, 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14 * scale,
                                  color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              TextField(
                                controller: _cardNumberController,
                                style: TextStyle(fontSize: 16 * scale),
                                inputFormatters: [
                                  CardNumberFormatter(),
                                ],
                                decoration: InputDecoration(
                                  hintText: "1234 5678 9012 3456",
                                  hintStyle: TextStyle(fontSize: 16 * scale),
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                                    child: _getCardIcon(),
                                  ),
                                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                  prefixIcon: Icon(Icons.payment_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * scale)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16 * scale),
                                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16 * scale),
                                    borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16 * scale),

                        // Card Holder Name
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cardHolderName, 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14 * scale,
                                  color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              TextField(
                                controller: _cardHolderController,
                                style: TextStyle(fontSize: 16 * scale),
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                                ],
                                decoration: InputDecoration(
                                  hintText: "John Doe",
                                  hintStyle: TextStyle(fontSize: 16 * scale),
                                  prefixIcon: Icon(Icons.person_outline_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * scale)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16 * scale),
                                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16 * scale),
                                    borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16 * scale),

                        // Expiry and CVV Row
                        FadeInUp(
                          delay: const Duration(milliseconds: 150),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.expiryDate, 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14 * scale,
                                        color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 8 * scale),
                                    TextField(
                                      controller: _expiryController,
                                      style: TextStyle(fontSize: 16 * scale),
                                      inputFormatters: [
                                        ExpiryDateFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: "MM/YY",
                                        hintStyle: TextStyle(fontSize: 16 * scale),
                                        prefixIcon: Icon(Icons.calendar_today_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * scale)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16 * scale),
                                          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16 * scale),
                                          borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: theme.colorScheme.surface,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.cvv, 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14 * scale,
                                        color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 8 * scale),
                                    TextField(
                                      controller: _cvvController,
                                      style: TextStyle(fontSize: 16 * scale),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: "123",
                                        hintStyle: TextStyle(fontSize: 16 * scale),
                                        prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.secondary, size: 24 * scale),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * scale)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16 * scale),
                                          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16 * scale),
                                          borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: theme.colorScheme.surface,
                                      ),
                                      keyboardType: TextInputType.number,
                                      obscureText: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40 * scale),

                        // Action Button moved back to body
                        SizedBox(
                          width: double.infinity,
                          height: 56 * scale,
                          child: ElevatedButton(
                            onPressed: (!isFormValid) ? null : _processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
                              elevation: 4,
                              shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                              disabledForegroundColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.3) : Colors.white70,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.confirmPaymentAmount(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0)),
                                style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24 * scale),
                      ],
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

  Widget _buildStepIndicator(BuildContext context, int step, String label, bool isActive, bool isCompleted, {bool isHeader = false}) {
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    Color activeColor = isHeader ? Colors.white : theme.colorScheme.secondary;
    Color inactiveColor = isHeader ? Colors.white.withValues(alpha: 0.3) : (theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!);
    Color textColor = isHeader ? (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6)) : (isActive ? theme.colorScheme.secondary : Colors.grey);

    return Column(
      children: [
        Container(
          width: 32 * scale, height: 32 * scale,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor, 
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 4 * scale) : null
          ),
          child: Center(child: isCompleted && !isActive ? Icon(Icons.check, color: isHeader ? theme.colorScheme.secondary : Colors.white, size: 18 * scale) : Text("$step", style: TextStyle(color: isHeader ? (isActive || isCompleted ? theme.colorScheme.secondary : Colors.white) : Colors.white, fontSize: 14 * scale, fontWeight: FontWeight.w900))),
        ),
        SizedBox(height: 4 * scale),
        Text(label, style: TextStyle(fontSize: 12 * scale, fontWeight: isActive ? FontWeight.w900 : FontWeight.bold, color: textColor)),
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
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }
    
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i + 1) % 4 == 0 && i + 1 != digitsOnly.length) {
        buffer.write(' ');
      }
    }
    
    String formattedString = buffer.toString();
    return TextEditingValue(
      text: formattedString,
      selection: TextSelection.collapsed(offset: formattedString.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }
    
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if (i == 1 && i + 1 != digitsOnly.length) {
        buffer.write('/');
      }
    }
    
    String formattedString = buffer.toString();
    return TextEditingValue(
      text: formattedString,
      selection: TextSelection.collapsed(offset: formattedString.length),
    );
  }
}

