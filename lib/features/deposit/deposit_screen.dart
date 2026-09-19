import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/app_state.dart';
import '../../core/widgets/adaptive_icon.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
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
  String? _selectedMethodId;

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
    final amountText = _amountController.text.replaceAll(',', '.');
    final double amount = double.tryParse(amountText) ?? 0;
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterValidAmount),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final state = Provider.of<AppState>(context, listen: false);

    switch (methodId) {
      case "card":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalletCardDepositScreen(
              amount: amount,
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
    final amountText = _amountController.text.replaceAll(',', '.');
    final double amountValue = double.tryParse(amountText) ?? 0;
    final bool isAmountEntered = amountValue > 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.addMoney, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color)),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8 * context.fontSizeFactor),
            decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16 * context.fontSizeFactor, color: theme.iconTheme.color),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Amount Card
                FadeInDown(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(32 * context.fontSizeFactor),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.3),
                          blurRadius: 25 * context.fontSizeFactor,
                          offset: Offset(0, 12 * context.fontSizeFactor),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.enterAmountToDeposit, 
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.bold)
                        ),
                        SizedBox(height: 16 * context.fontSizeFactor),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Text("\$", style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.w900)),
                              SizedBox(width: 16 * context.fontSizeFactor),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}'))],
                                  style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: -1),
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
                        SizedBox(height: 20 * context.fontSizeFactor),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [50, 100, 200, 500].map((amt) => GestureDetector(
                              onTap: () {
                                setState(() => _amountController.text = amt.toString());
                                HapticFeedback.lightImpact();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(right: 10 * context.fontSizeFactor),
                                padding: EdgeInsets.symmetric(horizontal: 18 * context.fontSizeFactor, vertical: 10 * context.fontSizeFactor),
                                decoration: BoxDecoration(
                                  color: _amountController.text == amt.toString() ? Colors.white : Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14 * context.fontSizeFactor),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Text("\$$amt", style: TextStyle(color: _amountController.text == amt.toString() ? AppColors.primaryDark : Colors.white, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w900)),
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32 * context.fontSizeFactor),
                FadeInUp(
                  child: Text(l10n.paymentMethod, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.w900, color: theme.textTheme.titleLarge?.color)),
                ),
                SizedBox(height: 16 * context.fontSizeFactor),
    
                ...List.generate(_methods.length, (index) {
                  final method = _methods[index];
                  final isSelected = _selectedMethodId == method["id"];

                  return FadeInUp(
                    delay: Duration(milliseconds: index * 80),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedMethodId = method["id"]);
                        HapticFeedback.selectionClick();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: EdgeInsets.only(bottom: 16 * context.fontSizeFactor),
                        width: double.infinity,
                        padding: EdgeInsets.all(20 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
                          border: Border.all(
                            color: isSelected ? AppColors.accentTeal : theme.dividerColor.withValues(alpha: 0.05),
                            width: 2,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppColors.accentTeal.withValues(alpha: 0.1),
                              blurRadius: 15 * context.fontSizeFactor,
                              offset: Offset(0, 8 * context.fontSizeFactor),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
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
                                borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                              ),
                              child: Center(
                                child: AdaptiveIcon(
                                  method["faIcon"] ?? method["icon"],
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
                                  Text(
                                    _getMethodTitle(method["titleKey"], l10n),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
                                  ),
                                  SizedBox(height: 2 * context.fontSizeFactor),
                                  Text(
                                    _getMethodDesc(method["descKey"], l10n),
                                    style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor)
                            else
                              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey.withValues(alpha: 0.3), size: 16 * context.fontSizeFactor),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 120 * context.fontSizeFactor), // Space for bottom button
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 12 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: MaxWidthBox(
            maxWidth: 800,
            child: ElevatedButton(
              onPressed: (isAmountEntered && _selectedMethodId != null) 
                  ? () => _navigateToMethod(_selectedMethodId!) 
                  : null,
              style: context.elevatedButtonStyle(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.continueLabel),
            ),
          ),
        ),
      ),
    );
  }
}
