import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/success_screen.dart';
import '../navigation/main_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/transaction.dart' as model;

class WithdrawScreen extends StatefulWidget {
  final bool isTab;
  final String cardId;
  const WithdrawScreen({super.key, this.isTab = false, required this.cardId});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _field1Controller = TextEditingController();
  final TextEditingController _field2Controller = TextEditingController();
  final TextEditingController _customBankController = TextEditingController();
  String? _selectedBank;
  bool _isCustomBank = false;
  final double _cardBalance = 850.50; // Mock card balance
  String? _selectedPurpose;

  List<String> _getPurposes(AppLocalizations l10n) => [
    l10n.familySupport,
    l10n.educationTuition,
    l10n.medicalExpenses,
    l10n.businessTransaction,
    l10n.propertyRent,
    l10n.gift,
    l10n.other,
  ];

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "wallet",
      "title": "withdrawToWallet",
      "desc": "withdrawToWalletDesc",
      "gradient": [AppColors.accentTeal, Color(0xFF00695C)],
      "icon": Icons.account_balance_wallet_rounded,
    },
    {
      "id": "bank",
      "title": "bankTransfer",
      "desc": "withdrawToBankDesc",
      "gradient": [Colors.blue, Color(0xFF1565C0)],
      "icon": Icons.account_balance_rounded,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _field1Controller.dispose();
    _field2Controller.dispose();
    _customBankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.isTab ? null : AppBar(
        title: Text(l10n.withdrawMoney, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                FadeInDown(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
                          boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, 10 * context.fontSizeFactor))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                      Text(
                        l10n.virtualCardBalance.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11 * context.fontSizeFactor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                            SizedBox(height: 8 * context.fontSizeFactor),
                      ListenableBuilder(
                        listenable: state,
                        builder: (context, _) {
                          final card = state.cards.firstWhere((c) => c.id == widget.cardId, orElse: () => state.cards.first);
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(card.balance), style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                            SizedBox(height: 20 * context.fontSizeFactor),
                            // Amount Input
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14 * context.fontSizeFactor),
                              ),
                              child: Row(
                                children: [
                                  Text(r"$", style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8 * context.fontSizeFactor),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                      style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold),
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
                            SizedBox(height: 8 * context.fontSizeFactor),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4 * context.fontSizeFactor),
                              child: Text(
                                l10n.withdrawalLimitRange(
                                  NumberFormat.simpleCurrency(name: state.currencyCode, decimalDigits: 2).format(10.00),
                                  NumberFormat.simpleCurrency(name: state.currencyCode, decimalDigits: 2).format(2500.00),
                                ),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12 * context.fontSizeFactor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 12 * context.fontSizeFactor),
                            // Quick amounts
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [50, 100, 200, 500].map((amt) => GestureDetector(
                                  onTap: () => setState(() => _amountController.text = amt.toString()),
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8 * context.fontSizeFactor),
                                    padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor, vertical: 6 * context.fontSizeFactor),
                                    decoration: BoxDecoration(
                                      color: _amountController.text == amt.toString() ? AppColors.primaryDark : Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                                    ),
                                    child: Text("\$$amt", style: TextStyle(color: Colors.white, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
                                  ),
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32 * context.fontSizeFactor),
                FadeInUp(
                  child: Text(l10n.withdrawalMethod, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 16 * context.fontSizeFactor),
                ...List.generate(_methods.length, (index) {
                  final method = _methods[index];
                  final card = state.cards.firstWhere((c) => c.id == widget.cardId, orElse: () => state.cards.first);
                  final isAmountValid = (double.tryParse(_amountController.text) ?? 0) > 0 && 
                                       (double.tryParse(_amountController.text) ?? 0) <= card.balance;
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 80),
                    child: Opacity(
                      opacity: isAmountValid ? 1.0 : 0.6,
                      child: GestureDetector(
                        onTap: isAmountValid ? () {
                          if (method["id"] == "wallet") _showWalletWithdrawDialog(context, l10n);
                          if (method["id"] == "bank") _showBankWithdrawDialog(context, l10n);
                        } : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.only(bottom: 14 * context.fontSizeFactor),
                          padding: EdgeInsets.all(18 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 12 * context.fontSizeFactor,
                                offset: Offset(0, 4 * context.fontSizeFactor),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50 * context.fontSizeFactor, height: 50 * context.fontSizeFactor,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: (method["gradient"] as List<Color>),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14 * context.fontSizeFactor),
                                ),
                                child: Center(
                                  child: AdaptiveIcon(
                                    method["icon"],
                                    color: Colors.white,
                                    size: 24 * context.fontSizeFactor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16 * context.fontSizeFactor),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_getMethodTitle(method["id"], l10n), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                                    Text(_getMethodDesc(method["id"], l10n), style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor)),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, size: 16 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.4)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
    
                SizedBox(height: 120 * context.fontSizeFactor),
              ],
            ),
          ),

        ),
      ),
    );
  }

  void _showWalletWithdrawDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28 * context.fontSizeFactor)),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Header
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
                      child: Icon(Icons.credit_card_rounded, color: Colors.white, size: 32 * context.fontSizeFactor),
                    ),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    Text(
                      l10n.virtualCardBalance.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11 * context.fontSizeFactor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 4 * context.fontSizeFactor),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ListenableBuilder(
                        listenable: state,
                        builder: (context, _) {
                          final card = state.cards.firstWhere((c) => c.id == widget.cardId, orElse: () => state.cards.first);
                          return Text(
                            NumberFormat.simpleCurrency(name: state.currencyCode).format(card.balance),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32 * context.fontSizeFactor,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        },
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
                        borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.amount,
                                  style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500, fontSize: 14 * context.fontSizeFactor),
                                ),
                              ),
                              Text(
                                NumberFormat.simpleCurrency(name: state.currencyCode).format(double.tryParse(_amountController.text) ?? 0),
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16 * context.fontSizeFactor,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.fee,
                                  style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500, fontSize: 14 * context.fontSizeFactor),
                                ),
                              ),
                              Text(
                                NumberFormat.simpleCurrency(name: state.currencyCode).format(state.calculateFeeForSource(double.tryParse(_amountController.text) ?? 0, "Virtual Card", payoutMethod: "Murtaax Wallet")),
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16 * context.fontSizeFactor,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.totalToPay,
                                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                                ),
                              ),
                              Text(
                                NumberFormat.simpleCurrency(name: state.currencyCode).format(state.calculateTotalForSource(double.tryParse(_amountController.text) ?? 0, "Virtual Card", payoutMethod: "Murtaax Wallet")),
                                style: TextStyle(
                                  color: AppColors.accentTeal,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18 * context.fontSizeFactor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: FittedBox(child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8 * context.fontSizeFactor, bottom: 8 * context.fontSizeFactor),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showPinDialog(context, l10n, state, type: "wallet");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                  disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.2),
                ),
                child: FittedBox(child: Text(l10n.confirm, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
              ),
            ),
          ],
        ),
      ),
    );

  }

  void _showPinDialog(BuildContext context, AppLocalizations l10n, AppState state, {required String type}) {
    final TextEditingController pinController = TextEditingController();
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28 * context.fontSizeFactor)),
          title: Column(
            children: [
              Icon(Icons.lock_outline_rounded, color: type == "wallet" ? AppColors.accentTeal : Colors.blue, size: 40 * context.fontSizeFactor),
              SizedBox(height: 16 * context.fontSizeFactor),
              Text(l10n.enterVirtualCardPin, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.enterSecurityPin,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
              ),
              SizedBox(height: 24 * context.fontSizeFactor),
              SizedBox(
                width: 200 * context.fontSizeFactor,
                child: TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 32 * context.fontSizeFactor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 20 * context.fontSizeFactor,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  onChanged: (_) => setDialogState(() {}),
                  decoration: InputDecoration(
                    counterText: "",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: (type == "wallet" ? AppColors.accentTeal : Colors.blue).withValues(alpha: 0.2), width: 2 * context.fontSizeFactor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: type == "wallet" ? AppColors.accentTeal : Colors.blue, width: 3 * context.fontSizeFactor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: FittedBox(child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8 * context.fontSizeFactor, bottom: 8 * context.fontSizeFactor),
              child: ElevatedButton(
                onPressed: pinController.text.length < 4
                    ? null
                    : () {
                        if (state.verifyCardPin(pinController.text, cardId: widget.cardId)) {
                          final localContext = this.context;
                          Navigator.pop(context);
                          _processTransaction(localContext, l10n, state, type: type);
                        } else {
                          HapticFeedback.vibrate();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.invalidPin),
                              backgroundColor: Colors.red,
                            ),
                          );
                          pinController.clear();
                          setDialogState(() {});
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: type == "wallet" ? AppColors.accentTeal : Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                ),
                child: FittedBox(child: Text(l10n.confirm, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
              ),
            ),
          ],
        ),
      ),
    );

  }

  void _showBankWithdrawDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context, listen: false);
    _selectedBank = null;
    _isCustomBank = false;
    _customBankController.clear();
    _field1Controller.clear(); // Account Number
    _field2Controller.clear(); // Account Name

    final List<String> banks = ["IBS Bank", "Premier Bank", "Salaam Bank", "Amal Bank", "Dahabshil Bank", "Other (Custom)"];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24 * context.fontSizeFactor)),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32 * context.fontSizeFactor, horizontal: 24 * context.fontSizeFactor),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Color(0xFF1565C0)],
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
                      child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 32 * context.fontSizeFactor),
                    ),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.virtualCardBalance.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11 * context.fontSizeFactor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 4 * context.fontSizeFactor),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ListenableBuilder(
                        listenable: state,
                        builder: (context, _) {
                          final card = state.cards.firstWhere((c) => c.id == widget.cardId, orElse: () => state.cards.first);
                          return Text(
                            NumberFormat.simpleCurrency(name: state.currencyCode).format(card.balance),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32 * context.fontSizeFactor,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        },
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
                        borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.amount,
                                  style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500, fontSize: 14 * context.fontSizeFactor),
                                ),
                              ),
                              Text(
                                NumberFormat.simpleCurrency(name: state.currencyCode).format(double.tryParse(_amountController.text) ?? 0),
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16 * context.fontSizeFactor,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.fee,
                                  style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500, fontSize: 14 * context.fontSizeFactor),
                                ),
                              ),
                              Text(
                                NumberFormat.simpleCurrency(name: state.currencyCode).format(state.calculateFeeForSource(double.tryParse(_amountController.text) ?? 0, "Virtual Card", payoutMethod: "Bank Transfer")),
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16 * context.fontSizeFactor,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.totalToPay,
                                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                                ),
                              ),
                              Text(
                                NumberFormat.simpleCurrency(name: state.currencyCode).format(state.calculateTotalForSource(double.tryParse(_amountController.text) ?? 0, "Virtual Card", payoutMethod: "Bank Transfer")),
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18 * context.fontSizeFactor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24 * context.fontSizeFactor),
                    DropdownButtonFormField<String>(
                      dropdownColor: theme.colorScheme.surface,
                      decoration: InputDecoration(
                        labelText: l10n.selectBank,
                        labelStyle: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                      ),
                      items: banks.map((bank) => DropdownMenuItem(value: bank, child: Text(bank, style: TextStyle(fontSize: 15 * context.fontSizeFactor, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)))).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          _selectedBank = val;
                          _isCustomBank = val == "Other (Custom)";
                        });
                      },
                    ),
                    if (_isCustomBank) ...[
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _withdrawInputField(context, "Bank Name", Icons.business_rounded, _customBankController, onChanged: (_) => setDialogState(() {})),
                    ],
                    SizedBox(height: 16 * context.fontSizeFactor),
                    _withdrawInputField(context, l10n.accountNumber, Icons.numbers, _field1Controller, isNumber: true, onChanged: (_) => setDialogState(() {})),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    _withdrawInputField(context, l10n.accountName, Icons.person, _field2Controller, onChanged: (_) => setDialogState(() {})),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    _buildPurposeDropdown(theme, l10n, setDialogState),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    Container(
                      padding: EdgeInsets.all(12 * context.fontSizeFactor),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded, color: Colors.orange, size: 18 * context.fontSizeFactor),
                          SizedBox(width: 8 * context.fontSizeFactor),
                          Expanded(
                            child: Text(
                              state.translate(
                                "Bank withdrawals are processed within 24 hours.",
                                "Lacag bixinta bangiga waxaa lagu farsameeyaa 24 saac gudahood."
                              ),
                              style: TextStyle(
                                fontSize: 12 * context.fontSizeFactor,
                                color: Colors.orange[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: FittedBox(child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8 * context.fontSizeFactor, bottom: 8 * context.fontSizeFactor),
              child: ElevatedButton(
                onPressed: (_selectedBank == null || (_isCustomBank && _customBankController.text.isEmpty) || _field1Controller.text.isEmpty || _field2Controller.text.isEmpty)
                    ? null
                    : () {
                        Navigator.pop(context);
                        _showPinDialog(context, l10n, state, type: "bank");
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                  disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.2),
                ),
                child: FittedBox(child: Text(l10n.submit, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
              ),
            ),
          ],
        ),
      ),
    );

  }

  void _processTransaction(BuildContext context, AppLocalizations l10n, AppState state, {required String type}) async {
    final theme = Theme.of(context);
    final amountVal = double.tryParse(_amountController.text) ?? 0;
    
    // We are withdrawing FROM the Virtual Card.
    final double fee = state.calculateFeeForSource(
      amountVal, 
      "Virtual Card", 
      payoutMethod: type == "bank" ? "Bank Transfer" : "Murtaax Wallet"
    );
    final double totalDeduction = amountVal + fee;

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

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (type == "wallet") {
      // Card -> Wallet: Decrease Card Balance, Increase Wallet Balance
      state.deductCardBalance(widget.cardId, totalDeduction);
      state.addBalance(amountVal);
      
      final now = DateTime.now();
      final dateStr = DateFormat('MMM dd').format(now);
      final formattedAmount = NumberFormat.simpleCurrency(name: state.currencyCode).format(amountVal);
      final formattedFee = NumberFormat.simpleCurrency(name: state.currencyCode).format(fee);
      final formattedTotal = NumberFormat.simpleCurrency(name: state.currencyCode).format(totalDeduction);

      // 1. Negative entry for Card history (Red)
      state.addTransaction(model.Transaction(
        id: "${now.millisecondsSinceEpoch}-out",
        title: "Wallet Withdrawal",
        date: dateStr,
        amount: "-$formattedTotal",
        numericAmount: totalDeduction,
        fee: fee,
        isNegative: true,
        category: "Withdraw",
        status: "Success",
        type: "withdraw",
        method: "Virtual Card",
        purpose: "Transfer",
        cardId: widget.cardId,
      ));

      // 2. Positive entry for Wallet history (Green)
      state.addTransaction(model.Transaction(
        id: "${now.millisecondsSinceEpoch}-in",
        title: "Card Topup",
        date: dateStr,
        amount: "+$formattedAmount",
        numericAmount: amountVal,
        isNegative: false,
        category: "Transfer",
        status: "Success",
        type: "deposit",
        method: "Virtual Card",
        purpose: "Transfer",
        cardId: null, // Shown in main wallet history
      ));
    } else if (type == "bank") {
      // Card -> Bank: Decrease Card Balance, No change to Wallet Balance
      state.deductCardBalance(widget.cardId, totalDeduction);
      final String receiverName = _field2Controller.text.isNotEmpty ? _field2Controller.text : "Bank Transfer";
      
      state.addTransaction(model.Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "$receiverName",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(totalDeduction)}",
        numericAmount: totalDeduction,
        fee: fee,
        isNegative: true,
        category: "Withdraw",
        status: "Success",
        type: "withdraw",
        method: "Virtual Card",
        purpose: _selectedPurpose ?? "Bank Transfer",
        cardId: widget.cardId,
      ));
    }

    _showSuccess(context, l10n, state);
  }

  void _showSuccess(BuildContext context, AppLocalizations l10n, AppState state) {
    final card = state.cards.firstWhere((c) => c.id == widget.cardId, orElse: () => state.cards.first);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.withdrawalRequested,
          message: l10n.withdrawalSuccessMessage(NumberFormat.simpleCurrency(name: state.currencyCode).format(double.tryParse(_amountController.text) ?? 0)),
          subMessage: l10n.newBalance(NumberFormat.simpleCurrency(name: state.currencyCode).format(card.balance)),
          buttonText: l10n.backToHome,
          onPressed: () {
            state.setNavIndex(0); // Return to Home
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
              (route) => false,
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  String _getMethodTitle(String id, AppLocalizations l10n) {
    switch (id) {
      case "wallet":
        return l10n.withdrawToWallet;
      case "bank":
        return l10n.bankTransfer;
      default:
        return "";
    }
  }

  String _getMethodDesc(String id, AppLocalizations l10n) {
    switch (id) {
      case "wallet":
        return l10n.withdrawToWalletDesc;
      case "bank":
        return l10n.withdrawToBankDesc;
      default:
        return "";
    }
  }

  Widget _withdrawInputField(BuildContext context, String label, IconData icon, TextEditingController controller, {bool isNumber = false, bool isObscure = false, int? maxLength, Function(String)? onChanged}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isObscure,
      maxLength: maxLength,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        labelStyle: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: AppColors.grey, size: 20 * context.fontSizeFactor),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.black12, width: 2)),
      ),
    );
  }

  Widget _buildPurposeDropdown(ThemeData theme, AppLocalizations l10n, StateSetter setDialogState) {
    final purposes = _getPurposes(l10n);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedPurpose ?? purposes.first,
        dropdownColor: theme.colorScheme.surface,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600, fontSize: 15 * context.fontSizeFactor),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.info_outline_rounded, color: AppColors.grey, size: 20 * context.fontSizeFactor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor, horizontal: 16 * context.fontSizeFactor),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey, size: 24 * context.fontSizeFactor),
        items: purposes.map((p) => DropdownMenuItem(
          value: p,
          child: Text(p),
        )).toList(),
        onChanged: (value) {
          if (value != null) {
            setDialogState(() {
              _selectedPurpose = value;
            });
          }
        },
      ),
    );
  }
}
