import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isProcessing = false;
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
      _showSuccess(context, l10n);
    }
  }

  void _showSuccess(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    _audioPlayer.play(AssetSource('sounds/success.mp3'));
    final theme = Theme.of(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: MaxWidthBox(
              maxWidth: 500,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      child: Container(
                        height: 110, width: 110,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: const Color(0xFF11998E).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 65),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(l10n.depositSuccessful, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                    const SizedBox(height: 12),
                    Text(
                      l10n.depositSuccessMessage(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0)),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grey, fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(l10n.backToHome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          screenTitle,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.accentTeal,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
              child: Column(
                children: [
                   Text(
                    l10n.amount,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
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
                        FadeInUp(
                           child: _buildLiveCard(),
                        ),
                        const SizedBox(height: 32),
                        _buildForm(l10n, theme),
                        const SizedBox(height: 40),
                        _buildButton(l10n, theme, isFormValid),
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

  Widget _buildForm(AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        _inputField(l10n.cardNumber, _cardNumberController, "1234 5678 9012 3456", Icons.payment_rounded, [CardNumberFormatter()], TextInputType.number, theme),
        const SizedBox(height: 16),
        _inputField(l10n.cardHolderName, _cardHolderController, "John Doe", Icons.person_outline_rounded, [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))], TextInputType.text, theme),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _inputField(l10n.expiryDate, _expiryController, "MM/YY", Icons.calendar_today_rounded, [ExpiryDateFormatter()], TextInputType.number, theme)),
            const SizedBox(width: 12),
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: theme.brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          inputFormatters: formatters,
          obscureText: obscure,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.accentTeal),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentTeal, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(AppLocalizations l10n, ThemeData theme, bool isFormValid) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isProcessing || !isFormValid) ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : Text(l10n.confirmDeposit, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
