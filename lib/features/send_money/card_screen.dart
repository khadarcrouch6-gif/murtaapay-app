import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'payment_screen.dart';
import '../../core/widgets/step_indicator.dart';
import '../../l10n/app_localizations.dart';


class CardScreen extends StatefulWidget {
  final String amount;
  final String method;
  final String currencyCode;
  final String senderSource;
  final String? cardId;

  const CardScreen({
    super.key,
    required this.amount,
    required this.method,
    required this.currencyCode,
    required this.senderSource,
    this.cardId,
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
            paymentMethod: widget.senderSource,
            cardId: widget.cardId,
            currencyCode: widget.currencyCode,
            purpose: AppLocalizations.of(context)!.familySupport, // Default purpose
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;

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
          widget.method,
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: 20 * context.fontSizeFactor, 
            color: Colors.white
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // --- HEADER BACKGROUND (Step Indicator) ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark ? AppColors.primaryDark : theme.colorScheme.secondary,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30 * context.fontSizeFactor), bottomRight: Radius.circular(30 * context.fontSizeFactor)),
                ),
                padding: EdgeInsets.only(bottom: 20 * context.fontSizeFactor),
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 500,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor),
                      child: Column(
                        children: [
                          // Source Display in Header
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16 * context.fontSizeFactor, 
                              vertical: 8 * context.fontSizeFactor
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.senderSource == "Main Wallet" 
                                    ? Icons.account_balance_wallet_outlined 
                                    : Icons.credit_card_outlined, 
                                  color: Colors.white70, 
                                  size: 16 * context.fontSizeFactor
                                ),
                                SizedBox(width: 8 * context.fontSizeFactor),
                                Text(
                                  "${widget.senderSource}: ${widget.currencyCode} ${widget.amount}",
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.w900, 
                                    fontSize: 14 * context.fontSizeFactor
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20 * context.fontSizeFactor),
                          Row(
                            children: [
                              StepIndicator(step: 1, label: l10n.stepAmount, isActive: false, isCompleted: true, isHeader: true),
                              StepLine(isCompleted: true, isHeader: true),
                              StepIndicator(step: 2, label: l10n.stepReceiver, isActive: true, isCompleted: false, isHeader: true),
                              StepLine(isCompleted: false, isHeader: true),
                              StepIndicator(step: 3, label: l10n.stepPayment, isActive: false, isCompleted: false, isHeader: true),
                              StepLine(isCompleted: false, isHeader: true),
                              StepIndicator(step: 4, label: l10n.stepReview, isActive: false, isCompleted: false, isHeader: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: Padding(
                        padding: EdgeInsets.all(20.0 * context.fontSizeFactor),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- CARD VISUAL ---

                              FadeInDown(
                                child: Container(
                                  height: 220 * context.fontSizeFactor,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: theme.brightness == Brightness.dark 
                                          ? [const Color(0xFF232526), const Color(0xFF414345)]
                                          : [AppColors.primaryDark, const Color(0xFF1E4B7A)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (theme.brightness == Brightness.dark ? Colors.black : AppColors.primaryDark).withValues(alpha: 0.2),
                                        blurRadius: 15 * context.fontSizeFactor,
                                        offset: Offset(0, 10 * context.fontSizeFactor),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(24 * context.fontSizeFactor),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            Icons.credit_card_rounded, 
                                            color: Colors.white, 
                                            size: 40 * context.fontSizeFactor
                                          ),
                                          Text(
                                            widget.method.contains("Visa") ? "VISA" : "MasterCard",
                                            style: TextStyle(
                                              color: Colors.white, 
                                              fontSize: 24 * context.fontSizeFactor, 
                                              fontWeight: FontWeight.w900, 
                                              fontStyle: FontStyle.italic
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _cardNumberController.text.isEmpty ? "XXXX XXXX XXXX XXXX" : _cardNumberController.text,
                                        style: TextStyle(
                                          color: Colors.white, 
                                          fontSize: 22 * context.fontSizeFactor, 
                                          fontWeight: FontWeight.bold, 
                                          letterSpacing: 2
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  l10n.cardHolder, 
                                                  style: TextStyle(
                                                    color: Colors.white70, 
                                                    fontSize: 10 * context.fontSizeFactor, 
                                                    fontWeight: FontWeight.bold
                                                  )
                                                ),
                                                Text(
                                                  _nameController.text.isEmpty ? l10n.yourName : _nameController.text.toUpperCase(),
                                                  style: TextStyle(
                                                    color: Colors.white, 
                                                    fontSize: 14 * context.fontSizeFactor, 
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 16 * context.fontSizeFactor),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.expires, 
                                                style: TextStyle(
                                                  color: Colors.white70, 
                                                  fontSize: 10 * context.fontSizeFactor, 
                                                  fontWeight: FontWeight.bold
                                                )
                                              ),
                                              Text(
                                                _expiryController.text.isEmpty ? "MM/YY" : _expiryController.text,
                                                style: TextStyle(
                                                  color: Colors.white, 
                                                  fontSize: 14 * context.fontSizeFactor, 
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 30 * context.fontSizeFactor),
                              
                              // --- FORM FIELDS ---
                              _buildTextField(
                                context: context,
                                label: l10n.cardHolderNameLabel,
                                controller: _nameController,
                                hint: l10n.johnDoe,
                                icon: Icons.person_outline_rounded,
                                onChanged: (v) => setState(() {}),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(25),
                                ],
                              ),
                              SizedBox(height: 16 * context.fontSizeFactor),
                              _buildTextField(
                                context: context,
                                label: l10n.cardNumber,
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
                              SizedBox(height: 16 * context.fontSizeFactor),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      context: context,
                                      label: l10n.expiryDate,
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
                                  SizedBox(width: 16 * context.fontSizeFactor),
                                  Expanded(
                                    flex: 1,
                                    child: _buildTextField(
                                      context: context,
                                      label: l10n.cvv,
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
                              
                              SizedBox(height: 40 * context.fontSizeFactor),
                              
                              SizedBox(
                                width: double.infinity,
                                height: 56 * context.fontSizeFactor,
                                child: ElevatedButton(
                                  onPressed: _handleContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.secondary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                                    elevation: 4,
                                  ),
                                  child: Text(
                                    l10n.continueLabel,
                                    style: TextStyle(
                                      fontSize: 18 * context.fontSizeFactor, 
                                      fontWeight: FontWeight.w900
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20 * context.fontSizeFactor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 14 * context.fontSizeFactor, 
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8 * context.fontSizeFactor),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16 * context.fontSizeFactor,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey[400],
              fontSize: 16 * context.fontSizeFactor,
            ),
            prefixIcon: Icon(
              icon, 
              color: theme.colorScheme.secondary,
              size: 24 * context.fontSizeFactor,
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
              borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 16 * context.fontSizeFactor,
              horizontal: 16 * context.fontSizeFactor,
            ),
          ),
          validator: (value) => value!.isEmpty ? l10n.requiredField : null,
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
