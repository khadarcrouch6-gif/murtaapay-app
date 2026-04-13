import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/adaptive_icon.dart';
import 'dart:ui';
import '../../core/responsive_utils.dart';
import '../../core/widgets/success_screen.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class WalletCardDepositScreen extends StatefulWidget {
  final String amount;
  final String currencyCode;

  const WalletCardDepositScreen({
    super.key,
    required this.amount,
    required this.currencyCode,
  });

  @override
  State<WalletCardDepositScreen> createState() => _WalletCardDepositScreenState();
}

class _WalletCardDepositScreenState extends State<WalletCardDepositScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  // final AudioPlayer _audioPlayer = AudioPlayer();
  // final bool _isProcessing = false;
  String _cardType = "unknown";

  @override
  void initState() {
    super.initState();
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
    }

    if (_cardType != type) {
      setState(() {
        _cardType = type;
      });
    }
  }

  Widget _buildLiveCard() {
    final l10n = AppLocalizations.of(context)!;
    bool isVisa = _cardType == "visa";
    bool isMastercard = _cardType == "mastercard";
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    List<Color> cardGradient = isDark 
        ? [const Color(0xFF1E1E2C), const Color(0xFF33334C)]
        : [AppColors.accentTeal, const Color(0xFF00796B)];
    
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
      height: 200 * context.fontSizeFactor,
      width: double.infinity,
      padding: EdgeInsets.all(24 * context.fontSizeFactor),
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
              Icon(Icons.contactless_rounded, color: Colors.white70, size: 32 * context.fontSizeFactor),
              if (isVisa) 
                   AdaptiveIcon(FontAwesomeIcons.ccVisa, color: Colors.white, size: 40 * context.fontSizeFactor)
              else if (isMastercard)
                   AdaptiveIcon(FontAwesomeIcons.ccMastercard, color: Colors.amber, size: 40 * context.fontSizeFactor)
              else
                   AdaptiveIcon(FontAwesomeIcons.creditCard, color: Colors.white, size: 32 * context.fontSizeFactor)
            ],
          ),
          SizedBox(height: 16 * context.fontSizeFactor),
          Text(
            displayNum,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22 * context.fontSizeFactor,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16 * context.fontSizeFactor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.cardHolder, style: TextStyle(color: Colors.white54, fontSize: 10 * context.fontSizeFactor)),
                  Text(
                    displayHolder,
                    style: TextStyle(color: Colors.white, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.expires, style: TextStyle(color: Colors.white54, fontSize: 10 * context.fontSizeFactor)),
                  Text(
                    displayExpiry,
                    style: TextStyle(color: Colors.white, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold),
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

    _processTransaction(context, l10n);
  }

  void _processTransaction(BuildContext context, AppLocalizations l10n) async {
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
                    l10n.processing, 
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
    if (!context.mounted) return;
    _showSuccess(context, l10n);
  }

  void _showSuccess(BuildContext context, AppLocalizations l10n) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.cardTopUpSuccessful,
          message: l10n.cardTopUpSuccessMessage(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0)),
          buttonText: l10n.backToHome,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    String screenTitle = l10n.addMoney;

    bool isFormValid = _cardNumberController.text.isNotEmpty &&
                       _cardHolderController.text.isNotEmpty &&
                       _expiryController.text.isNotEmpty &&
                       _cvvController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.accentTeal,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24 * context.fontSizeFactor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          screenTitle,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * context.fontSizeFactor, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.accentTeal,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  padding: EdgeInsets.only(bottom: 20 * context.fontSizeFactor, left: 24 * context.fontSizeFactor, right: 24 * context.fontSizeFactor),
                  child: Column(
                    children: [
                       Text(
                        l10n.amount,
                        style: TextStyle(color: Colors.white70, fontSize: 14 * context.fontSizeFactor),
                      ),
                      SizedBox(height: 4 * context.fontSizeFactor),
                      Text(
                        NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0),
                        style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                           child: _buildLiveCard(),
                        ),
                        SizedBox(height: 32 * context.fontSizeFactor),
                        _buildForm(l10n, theme),
                        SizedBox(height: 40 * context.fontSizeFactor),
                        _buildButton(l10n, theme, isFormValid),
                        SizedBox(height: 24 * context.fontSizeFactor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        _inputField(l10n.cardNumber, _cardNumberController, "1234 5678 9012 3456", Icons.payment_rounded, [CardNumberFormatter()], TextInputType.number, theme),
        SizedBox(height: 16 * context.fontSizeFactor),
        _inputField(l10n.cardHolderName, _cardHolderController, "John Doe", Icons.person_outline_rounded, [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))], TextInputType.text, theme),
        SizedBox(height: 16 * context.fontSizeFactor),
        Row(
          children: [
            Expanded(child: _inputField(l10n.expiryDate, _expiryController, "MM/YY", Icons.calendar_today_rounded, [ExpiryDateFormatter()], TextInputType.number, theme)),
            SizedBox(width: 12 * context.fontSizeFactor),
            Expanded(child: _inputField(l10n.cvv, _cvvController, "123", Icons.lock_outline_rounded, [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)], TextInputType.number, theme, obscure: true)),
          ],
        ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController controller, String hint, IconData icon, List<TextInputFormatter> formatters, TextInputType type, ThemeData theme, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary, fontSize: 14 * context.fontSizeFactor)),
        SizedBox(height: 8 * context.fontSizeFactor),
        TextField(
          controller: controller,
          inputFormatters: formatters,
          obscureText: obscure,
          keyboardType: type,
          style: TextStyle(fontSize: 16 * context.fontSizeFactor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
            prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentTeal, width: 2)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 14 * context.fontSizeFactor),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(AppLocalizations l10n, ThemeData theme, bool isFormValid) {
    return SizedBox(
      width: double.infinity,
      height: 56 * context.fontSizeFactor,
      child: ElevatedButton(
        onPressed: isFormValid ? _processPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(l10n.confirmTopUp, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
      ),
    );
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
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 16) digitsOnly = digitsOnly.substring(0, 16);
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i + 1) % 4 == 0 && i + 1 != digitsOnly.length) buffer.write(' ');
    }
    String formattedString = buffer.toString();
    return TextEditingValue(text: formattedString, selection: TextSelection.collapsed(offset: formattedString.length));
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 4) digitsOnly = digitsOnly.substring(0, 4);
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if (i == 1 && i + 1 != digitsOnly.length) buffer.write('/');
    }
    String formattedString = buffer.toString();
    return TextEditingValue(text: formattedString, selection: TextSelection.collapsed(offset: formattedString.length));
  }
}
