import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
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
  bool _isProcessing = false;
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
    switch (_cardType) {
      case "visa":
        return const AdaptiveIcon(FontAwesomeIcons.ccVisa, color: AppColors.primaryDark, size: 28);
      case "mastercard":
        return const AdaptiveIcon(FontAwesomeIcons.ccMastercard, color: AppColors.primaryDark, size: 28);
      case "amex":
        return const AdaptiveIcon(FontAwesomeIcons.ccAmex, color: AppColors.primaryDark, size: 28);
      case "discover":
        return const AdaptiveIcon(FontAwesomeIcons.ccDiscover, color: AppColors.primaryDark, size: 28);
      default:
        return const Icon(Icons.credit_card_rounded, color: AppColors.grey, size: 28);
    }
  }

  Widget _buildLiveCard() {
    final l10n = AppLocalizations.of(context)!;
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
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardGradient,
        ),
        borderRadius: BorderRadius.circular(16),
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
              const Icon(Icons.contactless_rounded, color: Colors.white70, size: 32),
              if (isVisa) 
                   const AdaptiveIcon(FontAwesomeIcons.ccVisa, color: Colors.white, size: 40)
              else if (isMastercard)
                   const AdaptiveIcon(FontAwesomeIcons.ccMastercard, color: Colors.amber, size: 40)
              else
                   const AdaptiveIcon(FontAwesomeIcons.creditCard, color: Colors.white, size: 32)
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayNum,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.cardHolder, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(
                    displayHolder,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.expires, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(
                    displayExpiry,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
    if (_cardNumberController.text.isEmpty ||
        _cardHolderController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillAllFields)),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isProcessing = false);
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
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
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 500,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_rounded, color: theme.colorScheme.secondary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.cardDetailsInfo(widget.amount),
                                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        FadeInUp(
                           child: _buildLiveCard(),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          l10n.cardNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: theme.brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card Number
                        FadeInUp(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cardNumber, 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _cardNumberController,
                                inputFormatters: [
                                  CardNumberFormatter(),
                                ],
                                decoration: InputDecoration(
                                  hintText: "1234 5678 9012 3456",
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: _getCardIcon(),
                                  ),
                                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                  prefixIcon: Icon(Icons.payment_rounded, color: theme.colorScheme.secondary),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
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

                        const SizedBox(height: 16),

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
                                  color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _cardHolderController,
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                                ],
                                decoration: InputDecoration(
                                  hintText: "John Doe",
                                  prefixIcon: Icon(Icons.person_outline_rounded, color: theme.colorScheme.secondary),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

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
                                        color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _expiryController,
                                      inputFormatters: [
                                        ExpiryDateFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: "MM/YY",
                                        prefixIcon: Icon(Icons.calendar_today_rounded, color: theme.colorScheme.secondary),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.cvv, 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _cvvController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: "123",
                                        prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.secondary),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
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

                        const SizedBox(height: 40),

                        // Action Button moved back to body
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_isProcessing || !isFormValid) ? null : _processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                              disabledForegroundColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.3) : Colors.white70,
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      l10n.confirmPaymentAmount(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0)),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                    ),
                                  ),
                          ),
                        ),
                        if (_isProcessing)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: FadeIn(
                              child: Center(
                                child: Text(
                                  l10n.secureProcessing,
                                  style: const TextStyle(color: AppColors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
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
