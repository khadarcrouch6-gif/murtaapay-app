import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/adaptive_icon.dart';
import 'payment_success_screen.dart';

class CreditCardScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String initialCardType;

  const CreditCardScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
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
    bool isVisa = _cardType == "visa";
    bool isMastercard = _cardType == "mastercard";
    
    List<Color> cardGradient = [
      const Color(0xFF1E1E2C),
      const Color(0xFF33334C),
    ];
    
    if (isVisa) {
      cardGradient = [const Color(0xFF1A1F71), const Color(0xFF283593)];
    } else if (isMastercard) {
      cardGradient = [const Color(0xFF222222), const Color(0xFF3B3B3B)];
    }

    String displayNum = _cardNumberController.text.isEmpty 
        ? "**** **** **** ****" 
        : _cardNumberController.text;
        
    String displayHolder = _cardHolderController.text.isEmpty 
        ? "CARD HOLDER" 
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
                  const Text("Card Holder", style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(
                    displayHolder,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Expires", style: TextStyle(color: Colors.white54, fontSize: 10)),
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
    if (_cardNumberController.text.isEmpty ||
        _cardHolderController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
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
            method: "Credit Card",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "Card Information";
    if (widget.initialCardType == "visa") title = "Visa Details";
    if (widget.initialCardType == "mastercard") title = "Mastercard Details";

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  color: AppColors.accentTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_rounded, color: AppColors.accentTeal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Enter your card details to complete the transfer of ${widget.amount} EUR",
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

            const Text(
              "Card Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Card Number
            FadeInUp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Card Number", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      prefixIcon: const Icon(Icons.payment_rounded, color: AppColors.accentTeal),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
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
                  const Text("Card Holder Name", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cardHolderController,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                    ],
                    decoration: InputDecoration(
                      hintText: "John Doe",
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.accentTeal),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
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
                        const Text("Expiry Date", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _expiryController,
                          inputFormatters: [
                            ExpiryDateFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: "MM/YY",
                            prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.accentTeal),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
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
                        const Text("CVV", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _cvvController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: InputDecoration(
                            hintText: "123",
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.accentTeal),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
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

            // Pay Button
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text("Processing payment...", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        )
                      : Text(
                          "Pay ${widget.amount} EUR",
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
                    child: const Text(
                      "Securely processing your payment...",
                      style: TextStyle(color: AppColors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

          ],
        ),
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

