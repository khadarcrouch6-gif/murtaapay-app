import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/app_state.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'mobile_deposit_screen.dart';
import 'bank_deposit_screen.dart';
import 'wallet_card_deposit_screen.dart';

class DepositScreen extends StatefulWidget {
  final bool isTab;
  const DepositScreen({super.key, this.isTab = false});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "card",
      "titleKey": "visaMastercard",
      "descKey": "visaMastercardDesc",
      "gradient": [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
      "faIcon": FontAwesomeIcons.creditCard,
    },
    {
      "id": "mobile",
      "titleKey": "mobileMoney",
      "descKey": "mobileMoneyDesc",
      "gradient": [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
      "icon": Icons.phone_android_rounded,
    },
    {
      "id": "bank",
      "titleKey": "bankTransfer",
      "descKey": "bankTransferDesc",
      "gradient": [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)],
      "icon": Icons.account_balance_rounded,
    },
  ];

  String _getMethodTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case "visaMastercard": return l10n.visaMastercard;
      case "bankTransfer": return l10n.bankTransfer;
      case "mobileMoney": return l10n.mobileMoney;
      default: return "";
    }
  }

  String _getMethodDesc(String key, AppLocalizations l10n) {
    switch (key) {
      case "visaMastercardDesc": return l10n.visaMastercardDesc;
      case "bankTransferDesc": return l10n.bankTransferDesc;
      case "mobileMoneyDesc": return l10n.mobileMoneyDesc;
      default: return "";
    }
  }

  void _navigateToMethod(String methodId) {
    final amountText = _amountController.text;
    final double amount = double.tryParse(amountText) ?? 0;
    if (amount <= 0) return;

    final state = Provider.of<AppState>(context, listen: false);

    switch (methodId) {
      case "card":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalletCardDepositScreen(
              amount: amount.toString(),
              currencyCode: state.currencyCode,
            ),
          ),
        );
        break;
      case "mobile":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MobileDepositScreen(amount: amount),
          ),
        );
        break;
      case "bank":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BankDepositScreen(amount: amount),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(l10n.addMoney, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20 * context.fontSizeFactor, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.horizontalPadding,
              context.horizontalPadding,
              context.horizontalPadding,
              120, // Clear navigation bar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Amount Card
                FadeInDown(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accentTeal, AppColors.accentTeal.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentTeal.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.enterAmountToDeposit, 
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500)
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Text("\$", style: TextStyle(color: AppColors.accentTeal, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                      style: TextStyle(color: Colors.white, fontSize: 34 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: -1),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "0.00",
                                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Quick amounts
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [50, 100, 200, 500].map((amt) => GestureDetector(
                                  onTap: () => setState(() => _amountController.text = amt.toString()),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _amountController.text == amt.toString() ? AppColors.accentTeal : Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: _amountController.text == amt.toString() ? AppColors.accentTeal : Colors.white.withValues(alpha: 0.05)),
                                    ),
                                    child: Text("\$$amt", style: TextStyle(color: Colors.white, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
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
                  child: Text(l10n.paymentMethod, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                ),
                const SizedBox(height: 16),
    
                ...List.generate(_methods.length, (index) {
                  final method = _methods[index];
                  final amountText = _amountController.text;
                  final double amount = double.tryParse(amountText) ?? 0;
                  final bool isEnabled = amount > 0;

                  return FadeInUp(
                    delay: Duration(milliseconds: index * 80),
                    child: Opacity(
                      opacity: isEnabled ? 1.0 : 0.5,
                      child: GestureDetector(
                        onTap: !isEnabled ? null : () => _navigateToMethod(method["id"]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(bottom: 16),
                          width: double.infinity,
                          padding: EdgeInsets.all(20 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.05),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56 * context.fontSizeFactor,
                                height: 56 * context.fontSizeFactor,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: (method["gradient"] as List<Color>).map((c) => c.withValues(alpha: 0.9)).toList(),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (method["gradient"] as List<Color>).first.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: AdaptiveIcon(
                                    method["faIcon"] ?? method["icon"],
                                    color: Colors.white,
                                    size: 26 * context.fontSizeFactor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getMethodTitle(method["titleKey"], l10n),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getMethodDesc(method["descKey"], l10n),
                                      style: TextStyle(color: AppColors.grey.withValues(alpha: 0.7), fontSize: 13 * context.fontSizeFactor),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey.withValues(alpha: 0.3), size: 16 * context.fontSizeFactor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
