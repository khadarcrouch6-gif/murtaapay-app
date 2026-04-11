import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/widgets/adaptive_icon.dart';
import 'dart:ui';
import '../../core/responsive_utils.dart';
import '../../core/widgets/success_screen.dart';
import '../cards/widgets/elite_virtual_card.dart';
import '../cards/models/card_model.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:murtaaxpay_app/features/deposit/wallet_card_deposit_screen.dart';

class DepositCardScreen extends StatefulWidget {
  final String amount;
  final String currencyCode;
  final String initialCardType;

  const DepositCardScreen({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.initialCardType = "unknown",
  });

  @override
  State<DepositCardScreen> createState() => _DepositCardScreenState();
}

class _DepositCardScreenState extends State<DepositCardScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amount == "0" ? "" : widget.amount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "wallet",
      "title": "TopUp from Wallet",
      "icon": Icons.account_balance_wallet_rounded,
      "color": AppColors.accentTeal,
    },
    {
      "id": "bank",
      "title": "Bank Transfer",
      "icon": Icons.account_balance_rounded,
      "color": Colors.blue,
    },
    {
      "id": "card",
      "title": "Visa / MasterCard",
      "icon": FontAwesomeIcons.ccVisa,
      "color": const Color(0xFF1A1F71),
    },
  ];

  void _showSuccess(BuildContext context, AppLocalizations l10n) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.depositSuccessful,
          message: l10n.depositSuccessMessage(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0)),
          buttonText: l10n.backToHome,
        ),
      ),
    );
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

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    _showSuccess(context, l10n);
  }

  void _showWalletPinDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context, listen: false);
    
    _pinController.clear();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Header Section with Gradient
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 32 * context.fontSizeFactor, horizontal: 24 * context.fontSizeFactor),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accentTeal, Color(0xFF00695C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32 * context.fontSizeFactor),
                      ),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      Text(
                        l10n.walletBalance.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11 * context.fontSizeFactor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 4 * context.fontSizeFactor),
                      Text(
                        NumberFormat.simpleCurrency(name: 'USD').format(state.balance),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32 * context.fontSizeFactor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.all(24 * context.fontSizeFactor),
                  child: Column(
                    children: [
                      // Amount Summary
                      Container(
                        padding: EdgeInsets.all(16 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.amount,
                              style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "\$${_amountController.text}",
                              style: TextStyle(
                                color: AppColors.accentTeal,
                                fontWeight: FontWeight.w800,
                                fontSize: 18 * context.fontSizeFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32 * context.fontSizeFactor),
                      Text(
                        l10n.enterWalletPinMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14 * context.fontSizeFactor,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20 * context.fontSizeFactor),
                      // PIN Field
                      SizedBox(
                        width: 220 * context.fontSizeFactor,
                        child: TextField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 32 * context.fontSizeFactor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 24,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          onChanged: (_) => setDialogState(() {}),
                          decoration: InputDecoration(
                            counterText: "",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.accentTeal.withValues(alpha: 0.2), width: 2),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.accentTeal, width: 3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: _pinController.text.length < 4
                    ? null
                    : () {
                        Navigator.pop(context);
                        _processTransaction(this.context, l10n);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.2),
                ),
                child: Text(l10n.confirm, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBankTransferDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    String? selectedBank;
    final List<String> banks = ["IBS Bank", "Premier Bank", "Salaam Bank", "Amal Bank", "Dahabshil Bank"];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.bankTransfer.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10 * context.fontSizeFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 8 * context.fontSizeFactor),
                      Text(
                        NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(_amountController.text) ?? 0),
                        style: TextStyle(
                          fontSize: 28 * context.fontSizeFactor,
                          fontWeight: FontWeight.w900,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24 * context.fontSizeFactor),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: l10n.selectBank,
                          labelStyle: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        items: banks.map((bank) => DropdownMenuItem(value: bank, child: Text(bank, style: TextStyle(fontSize: 15 * context.fontSizeFactor)))).toList(),
                        onChanged: (val) => setDialogState(() => selectedBank = val),
                      ),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _dialogInputField(context, l10n.accountNumber, Icons.numbers, _accountNumberController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _dialogInputField(context, l10n.accountName, Icons.person, _accountNameController, onChanged: (_) => setDialogState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
            ),
            ElevatedButton(
              onPressed: (selectedBank == null || _accountNumberController.text.isEmpty || _accountNameController.text.isEmpty)
                  ? null
                  : () {
                      Navigator.pop(context);
                      _processTransaction(this.context, l10n);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
                minimumSize: Size(120 * context.fontSizeFactor, 45 * context.fontSizeFactor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.submit, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogInputField(BuildContext context, String label, IconData icon, TextEditingController controller, {bool isNumber = false, bool isObscure = false, List<TextInputFormatter>? formatters, int? maxLength, Function(String)? onChanged}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: isObscure,
      onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: formatters,
      maxLength: maxLength,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor),
        prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
        filled: true,
        fillColor: theme.colorScheme.surface,
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 14 * context.fontSizeFactor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          l10n.virtualCardTopUp,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * context.fontSizeFactor, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: Column(
            children: [
              FadeInDown(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.accentTeal,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                  padding: EdgeInsets.only(bottom: 40 * context.fontSizeFactor, left: 24 * context.fontSizeFactor, right: 24 * context.fontSizeFactor),
                  child: Column(
                    children: [
                      Text(
                        l10n.enterAmountToDeposit,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 12 * context.fontSizeFactor),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("\$", style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                            SizedBox(width: 12 * context.fontSizeFactor),
                            IntrinsicWidth(
                              child: TextField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                style: TextStyle(color: Colors.white, fontSize: 40 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: -1),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "0.00",
                                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * context.fontSizeFactor),
                      // Quick amounts
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [10, 20, 50, 100].map((amt) => GestureDetector(
                            onTap: () => setState(() => _amountController.text = amt.toString()),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 10 * context.fontSizeFactor),
                              decoration: BoxDecoration(
                                color: _amountController.text == amt.toString() ? Colors.white : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                "\$$amt",
                                style: TextStyle(
                                  color: _amountController.text == amt.toString() ? AppColors.accentTeal : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14 * context.fontSizeFactor,
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 32 * context.fontSizeFactor),
                  itemCount: _methods.length,
                  itemBuilder: (context, index) {
                    final method = _methods[index];
                    final isAmountValid = (double.tryParse(_amountController.text) ?? 0) > 0;
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 100),
                      child: Opacity(
                        opacity: isAmountValid ? 1.0 : 0.6,
                        child: GestureDetector(
                          onTap: isAmountValid ? () {
                            if (method["id"] == "wallet") _showWalletPinDialog();
                            if (method["id"] == "bank") _showBankTransferDialog();
                            if (method["id"] == "card") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WalletCardDepositScreen(
                                    amount: _amountController.text,
                                    currencyCode: widget.currencyCode,
                                  ),
                                ),
                              );
                            }
                          } : null,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20 * context.fontSizeFactor),
                            padding: EdgeInsets.all(24 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))
                              ],
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16 * context.fontSizeFactor),
                                  decoration: BoxDecoration(
                                    color: method["color"].withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: AdaptiveIcon(method["icon"], color: method["color"], size: 28 * context.fontSizeFactor),
                                ),
                                SizedBox(width: 20 * context.fontSizeFactor),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method["title"],
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17 * context.fontSizeFactor),
                                      ),
                                      SizedBox(height: 4 * context.fontSizeFactor),
                                      Text(
                                        l10n.topUpInstantlyVia(method["id"]),
                                        style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 18 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.5)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
