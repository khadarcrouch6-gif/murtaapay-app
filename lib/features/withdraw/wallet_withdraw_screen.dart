import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/widgets/failure_screen.dart';
import '../navigation/main_navigation.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/pin_entry_dialog.dart';
import '../../core/models/transaction.dart' as model;
import 'package:responsive_framework/responsive_framework.dart';
import 'unified_bank_withdraw_screen.dart';
import 'unified_mobile_withdraw_screen.dart';

class WalletWithdrawScreen extends StatefulWidget {
  const WalletWithdrawScreen({super.key});

  @override
  State<WalletWithdrawScreen> createState() => _WalletWithdrawScreenState();
}

class _WalletWithdrawScreenState extends State<WalletWithdrawScreen> {
  String? _selectedMethodId;

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "mobile",
      "icon": Icons.phone_android_rounded,
      "gradient": [AppColors.accentTeal, Color(0xFF0D9488)],
    },
    {
      "id": "bank",
      "icon": Icons.account_balance_rounded,
      "gradient": [Color(0xFF6366F1), Color(0xFF4F46E5)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.withdrawMoney, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == ui.TextDirection.rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            color: theme.colorScheme.primary,
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
                // Main Wallet Balance Card
                FadeInDown(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: Column(
                        children: [
                          Container(
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
                                  l10n.walletBalance.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11 * context.fontSizeFactor,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 8 * context.fontSizeFactor),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance),
                                    style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.bold)
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          // Limits Info Box
                          Container(
                            padding: EdgeInsets.all(16 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: Column(
                              children: [
                                _buildLimitHeadroom(
                                  l10n.dailyLimit, 
                                  state.getDailyRemaining(), 
                                  state.dailyLimit,
                                  state.currencyCode,
                                  theme,
                                  context,
                                ),
                                SizedBox(height: 12 * context.fontSizeFactor),
                                _buildLimitHeadroom(
                                  l10n.monthlyLimit, 
                                  state.getMonthlyRemaining(), 
                                  state.monthlyLimit,
                                  state.currencyCode,
                                  theme,
                                  context,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                  final isSelected = _selectedMethodId == method["id"];

                  return FadeInUp(
                    delay: Duration(milliseconds: index * 80),
                    child: GestureDetector(
                      onTap: () {
                        if (method["id"] == "mobile") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UnifiedMobileWithdrawScreen(
                                source: "Wallet",
                              ),
                            ),
                          );
                        } else if (method["id"] == "bank") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UnifiedBankWithdrawScreen(
                                source: "Wallet",
                              ),
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.only(bottom: 14 * context.fontSizeFactor),
                        padding: EdgeInsets.all(18 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                          border: Border.all(
                            color: isSelected ? AppColors.accentTeal : Colors.transparent,
                            width: 2 * context.fontSizeFactor,
                          ),
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
                                  Text(
                                    _getMethodTitle(method["id"], l10n), 
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                                  ),
                                  Text(
                                    _getMethodDesc(method["id"], l10n), 
                                    style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor)
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Directionality.of(context) == ui.TextDirection.rtl ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
                              size: 16 * context.fontSizeFactor, 
                              color: AppColors.grey.withValues(alpha: 0.4)
                            ),
                          ],
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
      case "mobile": return l10n.mobileMoney;
      case "bank": return l10n.bankTransfer;
      default: return "";
    }
  }

  String _getMethodDesc(String id, AppLocalizations l10n) {
    switch (id) {
      case "mobile": return l10n.mobileMoneyDesc;
      case "bank": return l10n.localBankTransfer;
      default: return "";
    }
  }

  Widget _buildLimitHeadroom(String label, double remaining, double limit, String currency, ThemeData theme, BuildContext context) {
    final double percent = (remaining / limit).clamp(0.0, 1.0);
    final scale = context.fontSizeFactor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w600, color: AppColors.grey)),
            Text(
              "${NumberFormat.simpleCurrency(name: currency).format(remaining)} left",
              style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: percent < 0.2 ? Colors.orange : AppColors.accentTeal),
            ),
          ],
        ),
        SizedBox(height: 6 * scale),
        ClipRRect(
          borderRadius: BorderRadius.circular(4 * scale),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: AppColors.grey.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              percent < 0.2 ? Colors.orange : AppColors.accentTeal,
            ),
            minHeight: 4 * scale,
          ),
        ),
      ],
    );
  }
}
