import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../l10n/app_localizations.dart';
import 'wallet_card_deposit_screen.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

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
                      l10n.depositSuccessMessage(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0)),
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

  void _showWalletPinDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(l10n.walletPin, style: const TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.enterWalletPinMessage, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 15),
                onChanged: (_) => setDialogState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  counterText: "",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey)),
            ),
            ElevatedButton(
              onPressed: _pinController.text.length < 4
                  ? null
                  : () {
                      Navigator.pop(context);
                      _showSuccess(context, l10n);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentTeal,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          title: Text(l10n.bankTransfer, style: const TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.selectBank,
                    labelStyle: const TextStyle(color: AppColors.grey),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  items: banks.map((bank) => DropdownMenuItem(value: bank, child: Text(bank))).toList(),
                  onChanged: (val) => setDialogState(() => selectedBank = val),
                ),
                const SizedBox(height: 16),
                _dialogInputField(context, l10n.accountNumber, Icons.numbers, _accountNumberController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                const SizedBox(height: 16),
                _dialogInputField(context, l10n.accountName, Icons.person, _accountNameController, onChanged: (_) => setDialogState(() {})),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey)),
            ),
            ElevatedButton(
              onPressed: (selectedBank == null || _accountNumberController.text.isEmpty || _accountNameController.text.isEmpty)
                  ? null
                  : () {
                      Navigator.pop(context);
                      _showSuccess(context, l10n);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.submit, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 20),
        filled: true,
        fillColor: theme.colorScheme.surface,
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.virtualCardTopUp,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FadeInDown(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.accentTeal,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
              child: Column(
                children: [
                  Text(
                    l10n.enterAmountToDeposit,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("\$", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1),
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
                  const SizedBox(height: 24),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _amountController.text == amt.toString() ? Colors.white : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "\$$amt",
                            style: TextStyle(
                              color: _amountController.text == amt.toString() ? AppColors.accentTeal : Colors.white,
                              fontWeight: FontWeight.bold,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(24),
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: method["color"].withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: AdaptiveIcon(method["icon"], color: method["color"], size: 28),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method["title"],
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.topUpInstantlyVia(method["id"]),
                                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.grey.withValues(alpha: 0.5)),
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
