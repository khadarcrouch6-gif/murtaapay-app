import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/success_screen.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

class WithdrawScreen extends StatefulWidget {
  final bool isTab;
  const WithdrawScreen({super.key, this.isTab = false});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _field1Controller = TextEditingController();
  final TextEditingController _field2Controller = TextEditingController();
  final double _cardBalance = 850.50; // Mock card balance

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
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
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(NumberFormat.simpleCurrency(name: 'USD').format(_cardBalance), style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 20),
                            // Amount Input
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Text(r"$", style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
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
                            const SizedBox(height: 12),
                            // Quick amounts
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [50, 100, 200, 500].map((amt) => GestureDetector(
                                  onTap: () => setState(() => _amountController.text = amt.toString()),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _amountController.text == amt.toString() ? AppColors.primaryDark : Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
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
                const SizedBox(height: 32),
                FadeInUp(
                  child: Text(l10n.withdrawalMethod, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                ...List.generate(_methods.length, (index) {
                  final method = _methods[index];
                  final isAmountValid = (double.tryParse(_amountController.text) ?? 0) > 0 && 
                                       (double.tryParse(_amountController.text) ?? 0) <= _cardBalance;
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
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: EdgeInsets.all(18 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
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
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: AdaptiveIcon(
                                    method["icon"],
                                    color: Colors.white,
                                    size: 24 * context.fontSizeFactor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
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
    
                const SizedBox(height: 120),
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
    _field1Controller.clear(); // Using field1 as PIN controller

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
                        child: Text(
                          NumberFormat.simpleCurrency(name: 'USD').format(_cardBalance), // Mock card balance
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32 * context.fontSizeFactor,
                            fontWeight: FontWeight.w900,
                          ),
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
                          children: [
                            Expanded(
                              child: Text(
                                l10n.amount,
                                style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500, fontSize: 14 * context.fontSizeFactor),
                              ),
                            ),
                            Text(
                              NumberFormat.simpleCurrency(name: 'USD').format(double.tryParse(_amountController.text) ?? 0),
                              style: TextStyle(
                                color: AppColors.accentTeal,
                                fontWeight: FontWeight.w800,
                                fontSize: 18 * context.fontSizeFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * context.fontSizeFactor),
                      Text(
                        l10n.enterVirtualCardPin,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14 * context.fontSizeFactor,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20 * context.fontSizeFactor),
                      SizedBox(
                        width: 200 * context.fontSizeFactor,
                        child: TextField(
                          controller: _field1Controller,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32 * context.fontSizeFactor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 20,
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
                onPressed: _field1Controller.text.length < 4
                    ? null
                    : () {
                        Navigator.pop(context);
                        _processTransaction(this.context, l10n, state);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.2),
                ),
                child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    String? selectedBank;
    bool isCustomBank = false;
    final TextEditingController customBankController = TextEditingController();
    _field1Controller.clear(); // Account Number
    _field2Controller.clear(); // Account Name

    final List<String> banks = ["IBS Bank", "Premier Bank", "Salaam Bank", "Amal Bank", "Dahabshil Bank", "Other (Custom)"];

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
                        child: Text(
                          NumberFormat.simpleCurrency(name: 'USD').format(_cardBalance),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32 * context.fontSizeFactor,
                            fontWeight: FontWeight.w900,
                          ),
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
                          children: [
                            Expanded(
                              child: Text(
                                l10n.amount,
                                style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500, fontSize: 14 * context.fontSizeFactor),
                              ),
                            ),
                            Text(
                              NumberFormat.simpleCurrency(name: 'USD').format(double.tryParse(_amountController.text) ?? 0),
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w800,
                                fontSize: 18 * context.fontSizeFactor,
                              ),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                        ),
                        items: banks.map((bank) => DropdownMenuItem(value: bank, child: Text(bank, style: TextStyle(fontSize: 15 * context.fontSizeFactor, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)))).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedBank = val;
                            isCustomBank = val == "Other (Custom)";
                          });
                        },
                      ),
                      if (isCustomBank) ...[
                        SizedBox(height: 16 * context.fontSizeFactor),
                        _withdrawInputField(context, "Bank Name", Icons.business_rounded, customBankController, onChanged: (_) => setDialogState(() {})),
                      ],
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _withdrawInputField(context, l10n.accountNumber, Icons.numbers, _field1Controller, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _withdrawInputField(context, l10n.accountName, Icons.person, _field2Controller, onChanged: (_) => setDialogState(() {})),
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
                onPressed: (selectedBank == null || (isCustomBank && customBankController.text.isEmpty) || _field1Controller.text.isEmpty || _field2Controller.text.isEmpty)
                    ? null
                    : () {
                        Navigator.pop(context);
                        _processTransaction(this.context, l10n, state);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.2),
                ),
                child: Text(l10n.submit, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processTransaction(BuildContext context, AppLocalizations l10n, AppState state) async {
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
    _showSuccess(context, l10n, state);
  }

  void _showSuccess(BuildContext context, AppLocalizations l10n, AppState state) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.withdrawalRequested,
          message: l10n.withdrawalSuccessMessage(NumberFormat.simpleCurrency(name: 'USD').format(double.tryParse(_amountController.text) ?? 0)),
          buttonText: l10n.backToHome,
        ),
      ),
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

  Widget _withdrawInputField(BuildContext context, String label, IconData icon, TextEditingController controller, {bool isNumber = false, Function(String)? onChanged}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: AppColors.grey, size: 20 * context.fontSizeFactor),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.black12, width: 2)),
      ),
    );
  }
}
