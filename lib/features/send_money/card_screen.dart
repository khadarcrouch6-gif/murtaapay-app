import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import 'payment_screen.dart';

class CardScreen extends StatefulWidget {
  final String amount;
  final String method;

  const CardScreen({
    super.key,
    required this.amount,
    required this.method,
  });

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            amount: widget.amount,
            receiverName: _nameController.text,
            receiverPhone: "**** **** **** ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}",
            payoutMethod: widget.method,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.primaryDark : AppColors.accentTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.method,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Center(
              child: MaxWidthBox(
                maxWidth: 500,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CARD VISUAL ---
                        FadeInDown(
                          child: Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF232526), Color(0xFF414345)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.credit_card_rounded, color: Colors.white, size: 40),
                                    Text(
                                      widget.method.contains("Visa") ? "VISA" : "MasterCard",
                                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, italic: true),
                                    ),
                                  ],
                                ),
                                Text(
                                  _cardNumberController.text.isEmpty ? "XXXX XXXX XXXX XXXX" : _cardNumberController.text,
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("CARD HOLDER", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                        Text(
                                          _nameController.text.isEmpty ? "YOUR NAME" : _nameController.text.toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("EXPIRES", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                        Text(
                                          _expiryController.text.isEmpty ? "MM/YY" : _expiryController.text,
                                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // --- FORM FIELDS ---
                        _buildTextField(
                          label: "Card Holder Name",
                          controller: _nameController,
                          hint: "John Doe",
                          icon: Icons.person_outline_rounded,
                          onChanged: (v) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: "Card Number",
                          controller: _cardNumberController,
                          hint: "XXXX XXXX XXXX XXXX",
                          icon: Icons.credit_card_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            _CardNumberFormatter(),
                          ],
                          onChanged: (v) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                label: "Expiry Date",
                                controller: _expiryController,
                                hint: "MM/YY",
                                icon: Icons.calendar_today_rounded,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  _ExpiryDateFormatter(),
                                ],
                                onChanged: (v) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: _buildTextField(
                                label: "CVV",
                                controller: _cvvController,
                                hint: "XXX",
                                icon: Icons.lock_outline_rounded,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _handleContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                            child: const Text(
                              "Proceed to Payment",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.grey),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.accentTeal),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
            ),
          ),
          validator: (value) => value!.isEmpty ? "Required" : null,
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(' ', '');
    String formatted = "";
    for (int i = 0; i < text.length; i++) {
      formatted += text[i];
      if ((i + 1) % 4 == 0 && i != text.length - 1) formatted += " ";
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll('/', '');
    String formatted = "";
    for (int i = 0; i < text.length; i++) {
      formatted += text[i];
      if (i == 1 && text.length > 2) formatted += "/";
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
