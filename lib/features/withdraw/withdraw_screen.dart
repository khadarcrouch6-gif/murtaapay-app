import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../l10n/app_localizations.dart';
import 'unified_bank_withdraw_screen.dart';
import 'unified_mobile_withdraw_screen.dart';

class WithdrawScreen extends StatefulWidget {
  final bool isTab;
  final String cardId;
  const WithdrawScreen({super.key, this.isTab = false, required this.cardId});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isCalculating = false;
  Timer? _calcTimer;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (_amountController.text.isEmpty) return;
    setState(() => _isCalculating = true);
    _calcTimer?.cancel();
    _calcTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isCalculating = false);
    });
  }

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "mobile",
      "title": "mobileMoney",
      "desc": "withdrawToMobileDesc",
      "gradient": [AppColors.accentTeal, Color(0xFF00695C)],
      "icon": Icons.phone_android_rounded,
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
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _calcTimer?.cancel();
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
                          final double amount = double.tryParse(_amountController.text) ?? 0;
                          if (method["id"] == "mobile") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UnifiedMobileWithdrawScreen(
                                  source: "Virtual Card",
                                  cardId: widget.cardId,
                                  initialAmount: amount,
                                ),
                              ),
                            );
                          } else if (method["id"] == "bank") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UnifiedBankWithdrawScreen(
                                  source: "Virtual Card",
                                  cardId: widget.cardId,
                                  initialAmount: amount,
                                ),
                              ),
                            );
                          }
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

  String _getMethodTitle(String id, AppLocalizations l10n) {
    switch (id) {
      case "mobile":
        return l10n.mobileMoney;
      case "bank":
        return l10n.bankTransfer;
      default:
        return "";
    }
  }

  String _getMethodDesc(String id, AppLocalizations l10n) {
    switch (id) {
      case "mobile":
        return l10n.mobileMoneyDesc;
      case "bank":
        return l10n.withdrawToBankDesc;
      default:
        return "";
    }
  }
}
