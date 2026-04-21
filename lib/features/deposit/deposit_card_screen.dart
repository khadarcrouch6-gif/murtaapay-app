import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';

import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/widgets/detail_row.dart';
import 'dart:ui' as ui;
import '../../core/responsive_utils.dart';
import '../../core/widgets/success_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/transaction.dart' as model;
import 'wallet_card_deposit_screen.dart';
import '../../core/widgets/adaptive_icon.dart';

class DepositCardScreen extends StatefulWidget {
  final String amount;
  final String currencyCode;
  final String initialCardType;
  final String cardId;

  const DepositCardScreen({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.initialCardType = "unknown",
    required this.cardId,
  });

  @override
  State<DepositCardScreen> createState() => _DepositCardScreenState();
}

class _DepositCardScreenState extends State<DepositCardScreen> {
  final TextEditingController _amountController = TextEditingController();
  final double _cardBalance = 850.50; // Mock card balance
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  String _selectedBank = "IBS Bank";

  final List<Map<String, String>> _banks = [
    {"name": "IBS Bank", "image": "assets/images/bank.png"},
    {"name": "Premier Bank", "image": "assets/images/bank.png"},
    {"name": "Salaam Bank", "image": "assets/images/bank.png"},
    {"name": "Amal Bank", "image": "assets/images/bank.png"},
    {"name": "Dahabshil Bank", "image": "assets/images/bank.png"},
    {"name": "MyBank", "image": "assets/images/bank.png"},
    {"name": "Amana Bank", "image": "assets/images/bank.png"},
  ];

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
    _bankNameController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "wallet",
      "title": "topUpFromWallet",
      "icon": Icons.account_balance_wallet_rounded,
      "color": AppColors.accentTeal,
    },
    {
      "id": "bank",
      "title": "bankTransfer",
      "icon": Icons.account_balance_rounded,
      "color": Colors.blue,
    },
    {
      "id": "card",
      "title": "visaMastercard",
      "icon": FontAwesomeIcons.ccVisa,
      "color": const Color(0xFF1A1F71),
    },
  ];

  String _getMethodTitle(String id, AppLocalizations l10n) {
    switch (id) {
      case "wallet":
        return l10n.topUpFromWallet;
      case "bank":
        return l10n.bankTransfer;
      case "card":
        return l10n.visaMastercard;
      default:
        return "";
    }
  }

  void _showSuccess(BuildContext context, AppLocalizations l10n) {
    final state = Provider.of<AppState>(context, listen: false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.cardTopUpSuccessful,
          message: l10n.cardTopUpSuccessMessage(NumberFormat.simpleCurrency(name: widget.currencyCode).format(double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0)),
          subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.cardBalance)),
          buttonText: l10n.backToHome,
          onPressed: () {
            state.setNavIndex(3);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  void _processTransaction(BuildContext context, AppLocalizations l10n, {bool isWalletDeduction = false}) async {
    final theme = Theme.of(context);
    final localContext = context;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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

    if (!localContext.mounted) return;

    if (isWalletDeduction) {
      final appState = Provider.of<AppState>(localContext, listen: false);
      appState.deductBalance(amount);
      appState.addCardBalance(widget.cardId, amount);
      
      appState.addTransaction(model.Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Card Top-up",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: appState.currencyCode).format(amount)}",
        isNegative: true,
        category: "All",
        status: "Success",
        type: "payment",
        cardId: widget.cardId,
      ));
    } else {
       final appState = Provider.of<AppState>(localContext, listen: false);
       appState.addCardBalance(widget.cardId, amount);
       appState.addTransaction(model.Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Card Top-up",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "+${NumberFormat.simpleCurrency(name: appState.currencyCode).format(amount)}",
        isNegative: false,
        category: "All",
        status: "Success",
        type: "deposit",
        method: "Bank",
        cardId: widget.cardId,
      ));
    }

    Navigator.of(localContext, rootNavigator: true).pop();
    _showSuccess(localContext, l10n);
  }

  void _showWalletPinDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    _pinController.clear();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
              SizedBox(width: 12 * context.fontSizeFactor),
              Text(l10n.topUpFromWallet, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.enterWalletPinMessage,
                style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20 * context.fontSizeFactor),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                style: TextStyle(
                  fontSize: 24 * context.fontSizeFactor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: AppColors.accentTeal.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "••••",
                  hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.3), letterSpacing: 8),
                ),
                onChanged: (value) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey))),
            ElevatedButton(
              onPressed: _pinController.text.length < 4
                  ? null
                  : () {
                      final localContext = this.context;
                      Navigator.pop(context);
                      _processTransaction(localContext, l10n, isWalletDeduction: true);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showBankTransferDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    _accountNumberController.clear();
    _accountNameController.clear();
    _bankNameController.clear();
    _selectedBank = _banks[0]["name"]!; // Reset to first bank

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          title: Row(
            children: [
              Icon(Icons.account_balance_rounded, color: Colors.blue, size: 24 * context.fontSizeFactor),
              SizedBox(width: 12 * context.fontSizeFactor),
              Text(l10n.bankTransfer, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.selectBank, style: TextStyle(fontSize: 13 * context.fontSizeFactor, color: AppColors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  _buildBankDropdown(theme, l10n, setDialogState),

                  if (_selectedBank == "Add Bank") ...[
                    SizedBox(height: 16 * context.fontSizeFactor),
                    _dialogInputField(context, l10n.bankName, Icons.account_balance_rounded, _bankNameController, onChanged: (_) => setDialogState(() {})),
                  ],

                  SizedBox(height: 20 * context.fontSizeFactor),
                  _dialogInputField(context, l10n.accountNumber, Icons.numbers_rounded, _accountNumberController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  _dialogInputField(context, l10n.accountName, Icons.person_rounded, _accountNameController, onChanged: (_) => setDialogState(() {})),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey))),
            ElevatedButton(
              onPressed: (_accountNumberController.text.isEmpty || _accountNameController.text.isEmpty || (_selectedBank == "Add Bank" && _bankNameController.text.isEmpty))
                  ? null
                  : () {
                      final localContext = this.context;
                      Navigator.pop(dialogContext);
                      _processTransaction(localContext, l10n);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(l10n.submit, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDropdown(ThemeData theme, AppLocalizations l10n, StateSetter setDialogState) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedBank,
        dropdownColor: theme.colorScheme.surface,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_balance_rounded, color: Colors.blue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue),
        items: [
          ..._banks.map((bank) => DropdownMenuItem(
            value: bank["name"],
            child: Text(bank["name"]!),
          )),
          DropdownMenuItem(
            value: "Add Bank",
            child: Text(l10n.addBank),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setDialogState(() => _selectedBank = value);
          }
        },
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
    final state = AppState();

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
          child: ListView(
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
                        l10n.currentCardBalance,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11 * context.fontSizeFactor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 4 * context.fontSizeFactor),
                      ListenableBuilder(
                        listenable: state,
                        builder: (context, _) {
                          final card = state.cards.firstWhere((c) => c.id == widget.cardId, orElse: () => state.cards.first);
                          return Text(
                            NumberFormat.simpleCurrency(name: state.currencyCode).format(card.balance),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28 * context.fontSizeFactor,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24 * context.fontSizeFactor),
                      Text(
                        l10n.enterAmountToTopUp,
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
                            Text(r"$", style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 32 * context.fontSizeFactor),
                child: Column(
                  children: List.generate(_methods.length, (index) {
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
                                        _getMethodTitle(method["id"], l10n),
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17 * context.fontSizeFactor),
                                      ),
                                      SizedBox(height: 4 * context.fontSizeFactor),
                                      Text(
                                        l10n.topUpInstantlyVia(method["id"] == "wallet" ? "Wallet" : method["id"] == "bank" ? "Bank" : "Card"),
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
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
