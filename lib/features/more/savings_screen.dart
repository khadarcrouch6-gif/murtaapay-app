import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/models/savings_goal.dart';
import '../cards/models/card_model.dart';

class SavingsScreen extends StatefulWidget {
  final bool isTab;
  const SavingsScreen({super.key, this.isTab = false});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: widget.isTab ? null : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.savingsAndGoals, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 20 * context.fontSizeFactor)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: MaxWidthBox(
            maxWidth: 1000,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: _buildTotalSavings(context, l10n),
                    ),
                  ),
                  SizedBox(height: 32 * context.fontSizeFactor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.activeGoals, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor, letterSpacing: -0.5)),
                      TextButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            Text(l10n.seeAll, style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                            Icon(Icons.chevron_right_rounded, size: 20 * context.fontSizeFactor, color: AppColors.accentTeal),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.savingsGoals.length,
                    itemBuilder: (context, index) => _buildSavingsGoalCard(
                      context: context, 
                      l10n: l10n, 
                      index: index, 
                      goal: state.savingsGoals[index],
                      languageCode: state.locale.languageCode,
                    ),
                  ),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  Text(l10n.recentSavingsActivity, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor, letterSpacing: -0.5)),
                  SizedBox(height: 16 * context.fontSizeFactor),
                  _buildRecentActivity(context, l10n),
                  SizedBox(height: 120 * context.fontSizeFactor),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
            child: FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56 * context.fontSizeFactor,
                        child: ElevatedButton(
                          onPressed: () => _showCreateGoalDialog(context, l10n),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, elevation: 8, shadowColor: AppColors.accentTeal.withValues(alpha: 0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline_rounded, size: 24 * context.fontSizeFactor),
                              SizedBox(width: 12 * context.fontSizeFactor),
                              Text(l10n.createNewGoal, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16 * context.fontSizeFactor, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTotalSavings(BuildContext context, AppLocalizations l10n) {
    final state = Provider.of<AppState>(context);
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: EdgeInsets.all(24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.accentTeal, Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(32 * context.fontSizeFactor),
          boxShadow: [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, 10 * context.fontSizeFactor))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalSavings, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ListenableBuilder(
                      listenable: state,
                      builder: (context, _) {
                        final currentCardBalance = state.cards.isNotEmpty 
                            ? state.cards[state.selectedCardIndex < state.cards.length ? state.selectedCardIndex : 0].balance 
                            : 0.0;
                        return Text(
                          "${l10n.cardBalanceLabel}${NumberFormat.simpleCurrency(name: 'USD').format(currentCardBalance)}",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                    SizedBox(height: 4 * context.fontSizeFactor),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
                      child: Row(
                      children: [
                        Icon(Icons.trending_up_rounded, color: Colors.white, size: 14 * context.fontSizeFactor),
                        SizedBox(width: 4 * context.fontSizeFactor),
                        Text("2.5%", style: TextStyle(color: Colors.white, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8 * context.fontSizeFactor),
            Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.savingsBalance), style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: -1)),
            SizedBox(height: 24 * context.fontSizeFactor),
            Row(
              children: [
                Expanded(child: _buildBalanceAction(context, l10n.deposit, Icons.add_rounded, Colors.white, AppColors.accentTeal, onTap: () => _showWalletDepositDialog(context, l10n))),
                SizedBox(width: 12 * context.fontSizeFactor),
                Expanded(child: _buildBalanceAction(context, l10n.withdraw, Icons.arrow_outward_rounded, Colors.white.withValues(alpha: 0.15), Colors.white, onTap: () => _showWalletWithdrawDialog(context, l10n))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceAction(BuildContext context, String label, IconData icon, Color bgColor, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14 * context.fontSizeFactor),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20 * context.fontSizeFactor),
            SizedBox(width: 8 * context.fontSizeFactor),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 14 * context.fontSizeFactor)),
          ],
        ),
      ),
    );
  }

  void _showWalletWithdrawDialog(BuildContext context, AppLocalizations l10n) {
    final state = Provider.of<AppState>(context, listen: false);
    final TextEditingController amountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    final screenContext = context;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Center(
          child: MaxWidthBox(
            maxWidth: 600,
            child: AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28 * context.fontSizeFactor)),
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
                          colors: [AppColors.accentTeal, Color(0xFF004D40)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32 * context.fontSizeFactor),
                          ),
                          SizedBox(height: 20 * context.fontSizeFactor),
                          Text(
                            l10n.savingsBalanceLabel, 
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8), 
                              fontSize: 12 * context.fontSizeFactor, 
                              fontWeight: FontWeight.w800, 
                              letterSpacing: 1.2
                            )
                          ),
                          SizedBox(height: 8 * context.fontSizeFactor),
                          FittedBox(
                            fit: BoxFit.scaleDown, 
                            child: ListenableBuilder(
                              listenable: state, 
                              builder: (context, _) => Text(
                                NumberFormat.simpleCurrency(name: state.currencyCode).format(state.savingsBalance), 
                                style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: -1)
                              )
                            )
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(24 * context.fontSizeFactor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate("Target Wallet", "Boorsada loo dirayo"),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * context.fontSizeFactor, letterSpacing: -0.3)
                          ),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          Container(
                            padding: EdgeInsets.all(16 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10 * context.fontSizeFactor),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTeal.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.person_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                                ),
                                SizedBox(width: 12 * context.fontSizeFactor),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(state.translate("Main Wallet", "Boorsada Weyn"), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * context.fontSizeFactor)),
                                      Text("ID: ${state.walletId}", style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTeal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10 * context.fontSizeFactor),
                                  ),
                                  child: Text(
                                    NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance),
                                    style: TextStyle(color: AppColors.accentTeal, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24 * context.fontSizeFactor),
                          _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          _dialogInputField(context, l10n.walletPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                        ],
                      ),
                    ),
                  ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
                Padding(
                  padding: EdgeInsets.only(right: 8 * context.fontSizeFactor, bottom: 8 * context.fontSizeFactor),
                  child: ElevatedButton(
                    onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () async {
                      if (state.verifyPin(pinController.text)) {
                        final double amount = double.tryParse(amountController.text) ?? 0.0;
                        if (amount > state.savingsBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red));
                          return;
                        }
                        Navigator.pop(context);
                        await _processWithdrawal(screenContext, l10n, amountController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate("PIN-kaagu waa khalad.", "PIN-kaagu waa khalad.")), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor))),
                    child: Text(l10n.confirm, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _processWithdrawal(BuildContext context, AppLocalizations l10n, String amountStr, {String? toCardId}) async {
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context, listen: false);
    final double amount = double.tryParse(amountStr) ?? 0;

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
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(32 * context.fontSizeFactor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, 10 * context.fontSizeFactor))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(alignment: Alignment.center, children: [SizedBox(width: 65 * context.fontSizeFactor, height: 65 * context.fontSizeFactor, child: CircularProgressIndicator(color: AppColors.accentTeal, strokeWidth: 3 * context.fontSizeFactor)), Icon(Icons.bolt_rounded, color: AppColors.accentTeal, size: 32 * context.fontSizeFactor)]),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  Text(l10n.processing, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color, decoration: ui.TextDecoration.none)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      await state.withdrawFromSavings(amount, toCardId: toCardId);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            title: l10n.withdrawalSuccessful,
            message: l10n.withdrawalSuccessFromSavings(NumberFormat.simpleCurrency(name: state.currencyCode).format(amount)),
            buttonText: l10n.backToSavings,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  void _showWalletDepositDialog(BuildContext context, AppLocalizations l10n) {
    final state = Provider.of<AppState>(context, listen: false);
    final TextEditingController amountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    final screenContext = context;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Center(
          child: MaxWidthBox(
            maxWidth: 600,
            child: AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28 * context.fontSizeFactor)),
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
                          colors: [AppColors.accentTeal, Color(0xFF004D40)], 
                          begin: Alignment.topLeft, 
                          end: Alignment.bottomRight
                        )
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16 * context.fontSizeFactor), 
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15), 
                              shape: BoxShape.circle
                            ), 
                            child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32 * context.fontSizeFactor)
                          ),
                          SizedBox(height: 20 * context.fontSizeFactor),
                          Text(
                            l10n.availableBalance, 
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8), 
                              fontSize: 12 * context.fontSizeFactor, 
                              fontWeight: FontWeight.w800, 
                              letterSpacing: 1.2
                            )
                          ),
                          SizedBox(height: 8 * context.fontSizeFactor),
                          FittedBox(
                            fit: BoxFit.scaleDown, 
                            child: ListenableBuilder(
                              listenable: state, 
                              builder: (context, _) => Text(
                                NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance), 
                                style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: -1)
                              )
                            )
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(24 * context.fontSizeFactor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate("Source Wallet", "Boorsada Isha"),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * context.fontSizeFactor, letterSpacing: -0.3)
                          ),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          Container(
                            padding: EdgeInsets.all(16 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10 * context.fontSizeFactor),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTeal.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.security_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                                ),
                                SizedBox(width: 12 * context.fontSizeFactor),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(state.translate("Main Balance", "Hadhaaga Weyn"), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14 * context.fontSizeFactor)),
                                      Text(state.translate("Verified Account", "Akoon La Xaqiijiyay"), style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                              ],
                            ),
                          ),
                          SizedBox(height: 24 * context.fontSizeFactor),
                          _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                          SizedBox(height: 16 * context.fontSizeFactor),
                          _dialogInputField(context, l10n.walletPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                        ],
                      ),
                    ),
                  ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
                Padding(
                  padding: EdgeInsets.only(right: 8 * context.fontSizeFactor, bottom: 8 * context.fontSizeFactor),
                  child: ElevatedButton(
                    onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () async {
                      if (state.verifyPin(pinController.text)) {
                        final double amount = double.tryParse(amountController.text) ?? 0.0;
                        if (amount > state.balance) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red));
                          return;
                        }
                        Navigator.pop(context);
                        await _processDeposit(screenContext, l10n, amountController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate("PIN-kaagu waa khalad.", "PIN-kaagu waa khalad.")), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor))),
                    child: Text(l10n.confirm, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processDeposit(BuildContext context, AppLocalizations l10n, String amountStr, {String? fromCardId, String? goalName, String? goalId}) async {
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context, listen: false);
    final double amount = double.tryParse(amountStr) ?? 0;

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
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(32 * context.fontSizeFactor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, 10 * context.fontSizeFactor))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(alignment: Alignment.center, children: [SizedBox(width: 65 * context.fontSizeFactor, height: 65 * context.fontSizeFactor, child: CircularProgressIndicator(color: AppColors.accentTeal, strokeWidth: 3 * context.fontSizeFactor)), Icon(Icons.bolt_rounded, color: AppColors.accentTeal, size: 32 * context.fontSizeFactor)]),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  Text(l10n.processing, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color, decoration: ui.TextDecoration.none)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      await state.transferToSavings(amount, fromCardId: fromCardId, goalName: goalName, goalId: goalId);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            title: l10n.depositSuccessful,
            message: l10n.depositSuccessMessage(NumberFormat.simpleCurrency(name: state.currencyCode).format(amount)),
            buttonText: l10n.backToSavings,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  Widget _dialogInputField(BuildContext context, String label, IconData icon, TextEditingController controller, {bool isNumber = false, bool isObscure = false, int? maxLength, Function(String)? onChanged, bool readOnly = false, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: isObscure,
      onChanged: onChanged,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        labelStyle: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor),
        prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor), borderSide: const BorderSide(color: AppColors.accentTeal, width: 2)),
      ),
    );
  }

  Widget _buildSavingsGoalCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required int index,
    required SavingsGoal goal,
    required String languageCode,
  }) {
    final theme = Theme.of(context);
    double progress = (goal.saved / goal.target).clamp(0.0, 1.0);
    bool isPaused = goal.isPaused;

    return FadeInUp(
      delay: Duration(milliseconds: goal.delay),
      child: Container(
        margin: EdgeInsets.only(bottom: 16 * context.fontSizeFactor),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24 * context.fontSizeFactor), border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10 * context.fontSizeFactor, offset: Offset(0, 4 * context.fontSizeFactor))]),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20 * context.fontSizeFactor),
              child: Row(
                children: [
                  Container(padding: EdgeInsets.all(12 * context.fontSizeFactor), decoration: BoxDecoration(color: goal.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)), child: Icon(goal.icon, color: goal.color, size: 28 * context.fontSizeFactor)),
                  SizedBox(width: 16 * context.fontSizeFactor),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(goal.getLocalizedTitle(languageCode), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17 * context.fontSizeFactor, letterSpacing: -0.2)),
                            if (isPaused)
                              Container(
                                margin: EdgeInsets.only(left: 8 * context.fontSizeFactor),
                                padding: EdgeInsets.symmetric(horizontal: 8 * context.fontSizeFactor, vertical: 2 * context.fontSizeFactor),
                                decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8 * context.fontSizeFactor)),
                                child: Text(l10n.paused.toUpperCase(), style: TextStyle(color: AppColors.grey, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        SizedBox(height: 4 * context.fontSizeFactor),
                        Text("${l10n.targetWithColon}${NumberFormat.simpleCurrency(name: 'USD').format(goal.target)} • ${goal.deadline}", style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  _buildGoalOptions(context, l10n, index, goal),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20 * context.fontSizeFactor, 0, 20 * context.fontSizeFactor, 20 * context.fontSizeFactor),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(NumberFormat.simpleCurrency(name: 'USD').format(goal.saved), style: TextStyle(color: goal.color, fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor)),
                      Text("${(progress * 100).toInt()}%", style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
                    ],
                  ),
                  SizedBox(height: 12 * context.fontSizeFactor),
                  Stack(
                    children: [
                      Container(height: 10 * context.fontSizeFactor, width: double.infinity, decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10 * context.fontSizeFactor))),
                      AnimatedContainer(duration: const Duration(seconds: 1), curve: Curves.easeOutCubic, height: 10 * context.fontSizeFactor, width: MediaQuery.of(context).size.width * 0.7 * progress, decoration: BoxDecoration(gradient: LinearGradient(colors: [goal.color, goal.color.withValues(alpha: 0.7)]), borderRadius: BorderRadius.circular(10 * context.fontSizeFactor), boxShadow: [BoxShadow(color: goal.color.withValues(alpha: 0.3), blurRadius: 6 * context.fontSizeFactor, offset: Offset(0, 2 * context.fontSizeFactor))])),
                    ],
                  ),
                  SizedBox(height: 20 * context.fontSizeFactor),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isPaused ? null : () => _showAddFundsDialog(context, l10n, index),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: goal.color.withValues(alpha: 0.2)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * context.fontSizeFactor)), padding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor)),
                          child: Text(l10n.addFunds, style: TextStyle(color: goal.color, fontWeight: FontWeight.w700, fontSize: 14 * context.fontSizeFactor)),
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
    );
  }

  Widget _buildGoalOptions(BuildContext context, AppLocalizations l10n, int index, SavingsGoal goal) {
    final state = Provider.of<AppState>(context, listen: false);
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: AppColors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
      onSelected: (value) {
        if (value == 'edit') _showEditGoalDialog(context, l10n, index, goal);
        if (value == 'pause') state.updateSavingsGoal(index, goal.copyWith(isPaused: !goal.isPaused));
        if (value == 'delete') _showDeleteConfirmDialog(context, l10n, index);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 20 * context.fontSizeFactor), SizedBox(width: 12 * context.fontSizeFactor), Text(l10n.edit, style: TextStyle(fontSize: 14 * context.fontSizeFactor))])),
        PopupMenuItem(value: 'pause', child: Row(children: [Icon(goal.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 20 * context.fontSizeFactor), SizedBox(width: 12 * context.fontSizeFactor), Text(goal.isPaused ? l10n.resume : l10n.pause, style: TextStyle(fontSize: 14 * context.fontSizeFactor))])),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 20 * context.fontSizeFactor, color: Colors.red), SizedBox(width: 12 * context.fontSizeFactor), Text(l10n.delete, style: TextStyle(color: Colors.red, fontSize: 14 * context.fontSizeFactor))])),
      ],
    );
  }

  void _showAddFundsDialog(BuildContext context, AppLocalizations l10n, int index) {
    final state = Provider.of<AppState>(context, listen: false);
    final TextEditingController amountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    final screenContext = context;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Center(
          child: MaxWidthBox(
            maxWidth: 500,
            child: AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28 * context.fontSizeFactor)),
              title: Text(l10n.addFunds, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, fontSize: 18 * context.fontSizeFactor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogInputField(context, l10n.amountToAdd, Icons.add_circle_outline_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState((){})),
                  SizedBox(height: 20 * context.fontSizeFactor),
                  Align(alignment: Alignment.centerLeft, child: Text(state.translate("Source", "Isha"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor, color: AppColors.grey))),
                  SizedBox(height: 12 * context.fontSizeFactor),
                  Container(
                    padding: EdgeInsets.all(16 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal,
                      borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                      boxShadow: [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.2), blurRadius: 10 * context.fontSizeFactor, offset: Offset(0, 4 * context.fontSizeFactor))],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24 * context.fontSizeFactor),
                        SizedBox(width: 12 * context.fontSizeFactor),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.translate("Wallet", "Boorsada"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14 * context.fontSizeFactor)),
                            Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance), style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20 * context.fontSizeFactor),
                  _dialogInputField(
                    context, 
                    l10n.walletPin, 
                    Icons.lock_rounded, 
                    pinController, 
                    isNumber: true, 
                    isObscure: true, 
                    maxLength: 4, 
                    onChanged: (_) => setDialogState(() {})
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
                Padding(
                  padding: EdgeInsets.only(right: 8 * context.fontSizeFactor, bottom: 8 * context.fontSizeFactor),
                  child: ElevatedButton(
                    onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () async {
                      final amount = double.tryParse(amountController.text) ?? 0;
                      final sourceBalance = state.balance;

                      // Verify PIN
                      bool pinValid = state.verifyPin(pinController.text);
                      
                      if (!pinValid) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(state.translate("PIN-kaagu waa khalad.", "PIN-kaagu waa khalad.")), 
                          backgroundColor: Colors.red
                        ));
                        return;
                      }

                      if (amount > 0 && amount <= sourceBalance) {
                        Navigator.pop(context);
                        final goal = state.savingsGoals[index];
                        await _processDeposit(screenContext, l10n, amountController.text, goalName: goal.title, goalId: goal.id);
                      } else if (amount > sourceBalance) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor))
                    ),
                    child: Text(l10n.confirm, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showDeleteConfirmDialog(BuildContext context, AppLocalizations l10n, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24 * context.fontSizeFactor)),
          title: Text(l10n.deleteGoal, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          content: Text(l10n.deleteGoalConfirm, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor))),
            TextButton(
              onPressed: () {
                Provider.of<AppState>(context, listen: false).removeSavingsGoal(index);
                Navigator.pop(context);
              },
              child: Text(l10n.delete, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
            ),
          ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, AppLocalizations l10n) {
    final state = Provider.of<AppState>(context);
    final savingsTxs = state.transactions.where((tx) => tx.category == "Savings").toList();

    if (savingsTxs.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 32 * context.fontSizeFactor),
            Icon(Icons.history_rounded, size: 64 * context.fontSizeFactor, color: AppColors.grey.withValues(alpha: 0.2)),
            SizedBox(height: 16 * context.fontSizeFactor),
            Text(l10n.noActivityYet, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500, fontSize: 14 * context.fontSizeFactor)),
          ],
        ),
      );
    }

    return Column(
      children: savingsTxs
          .take(5)
          .map((tx) => Container(
                margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
                padding: EdgeInsets.all(16 * context.fontSizeFactor),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20 * context.fontSizeFactor), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05))),
                child: Row(
                  children: [
                    Container(padding: EdgeInsets.all(10 * context.fontSizeFactor), decoration: BoxDecoration(color: (tx.isNegative ? Colors.orange : AppColors.accentTeal).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(tx.isNegative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: tx.isNegative ? Colors.orange : AppColors.accentTeal, size: 18 * context.fontSizeFactor)),
                    SizedBox(width: 16 * context.fontSizeFactor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                          Text(tx.date, style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor)),
                        ],
                      ),
                    ),
                    Text(tx.amount, style: TextStyle(fontWeight: FontWeight.w900, color: tx.isNegative ? Colors.orange : AppColors.accentTeal, fontSize: 15 * context.fontSizeFactor)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _showCreateGoalDialog(BuildContext context, AppLocalizations l10n) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController deadlineController = TextEditingController();
    IconData selectedIcon = Icons.star_rounded;
    Color selectedColor = AppColors.accentTeal;
    final screenContext = context;

    final List<IconData> goalIcons = [Icons.star_rounded, Icons.flight_rounded, Icons.home_rounded, Icons.directions_car_rounded, Icons.school_rounded, Icons.shopping_bag_rounded, Icons.favorite_rounded, Icons.mosque_rounded];
    final List<Color> goalColors = [AppColors.accentTeal, const Color(0xFF6366F1), const Color(0xFFF43F5E), const Color(0xFFF59E0B), const Color(0xFF10B981), const Color(0xFF8B5CF6), const Color(0xFFEC4899), const Color(0xFF0EA5E9)];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28 * context.fontSizeFactor)),
          title: Text(l10n.createNewGoal, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, fontSize: 18 * context.fontSizeFactor)),
          content: MaxWidthBox(
            maxWidth: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    _dialogInputField(context, l10n.goalName, Icons.edit_rounded, titleController),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    _dialogInputField(context, l10n.targetAmount, Icons.attach_money_rounded, amountController, isNumber: true),
                    SizedBox(height: 16 * context.fontSizeFactor),
                    _dialogInputField(
                      context,
                      l10n.deadline,
                      Icons.calendar_today_rounded,
                      deadlineController,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)));
                        if (date != null) {
                          if (!context.mounted) return;
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) {
                            final fullDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            setDialogState(() {
                              deadlineController.text = DateFormat('dd MMM yyyy').format(fullDateTime);
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 24 * context.fontSizeFactor),
                    Text(l10n.selectIcon, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
                    SizedBox(height: 12 * context.fontSizeFactor),
                    SizedBox(
                      height: 55 * context.fontSizeFactor,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: goalIcons.length,
                        itemBuilder: (context, index) {
                          bool isSelected = selectedIcon == goalIcons[index];
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedIcon = goalIcons[index]),
                            child: Container(
                              margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
                              width: 50 * context.fontSizeFactor,
                              decoration: BoxDecoration(color: isSelected ? selectedColor : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14 * context.fontSizeFactor), border: Border.all(color: isSelected ? selectedColor : Theme.of(context).dividerColor.withValues(alpha: 0.1))),
                              child: Icon(goalIcons[index], color: isSelected ? Colors.white : AppColors.grey, size: 26 * context.fontSizeFactor),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24 * context.fontSizeFactor),
                    Text(l10n.selectColor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
                    SizedBox(height: 12 * context.fontSizeFactor),
                    SizedBox(
                      height: 45 * context.fontSizeFactor,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: goalColors.length,
                        itemBuilder: (context, index) {
                          bool isSelected = selectedColor == goalColors[index];
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedColor = goalColors[index]),
                            child: Container(
                              margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
                              width: 45 * context.fontSizeFactor,
                              decoration: BoxDecoration(color: goalColors[index], shape: BoxShape.circle, border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 3)),
                              child: isSelected ? Icon(Icons.check, color: Colors.white, size: 24 * context.fontSizeFactor) : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _processCreateGoal(screenContext, l10n, titleController.text, amountController.text, deadlineController.text, selectedIcon, selectedColor);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor))),
              child: Text(l10n.create, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processCreateGoal(BuildContext context, AppLocalizations l10n, String title, String amount, String deadline, IconData icon, Color color) async {
    final theme = Theme.of(context);
    final state = Provider.of<AppState>(context, listen: false);

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
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(32 * context.fontSizeFactor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, 10 * context.fontSizeFactor))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(alignment: Alignment.center, children: [SizedBox(width: 65 * context.fontSizeFactor, height: 65 * context.fontSizeFactor, child: CircularProgressIndicator(color: AppColors.accentTeal, strokeWidth: 3 * context.fontSizeFactor)), Icon(Icons.auto_awesome_rounded, color: AppColors.accentTeal, size: 32 * context.fontSizeFactor)]),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  Text(l10n.processing, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color, decoration: ui.TextDecoration.none)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!context.mounted) return;

    state.addSavingsGoal(SavingsGoal(
      id: "G${DateTime.now().millisecondsSinceEpoch}",
      title: title, 
      saved: 0.0, 
      target: double.tryParse(amount) ?? 0.0, 
      deadline: deadline.isNotEmpty ? deadline : "Ongoing", 
      icon: icon, 
      color: color, 
      delay: 0, 
      isPaused: false
    ));

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          title: l10n.goalCreated,
          message: l10n.goalCreatedSuccess(title, NumberFormat.simpleCurrency(name: state.currencyCode).format(double.tryParse(amount) ?? 0)),
          buttonText: l10n.backToSavings,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, AppLocalizations l10n, int index, SavingsGoal goal) {
    final TextEditingController titleController = TextEditingController(text: goal.title);
    final TextEditingController amountController = TextEditingController(text: goal.target.toString());
    final TextEditingController deadlineController = TextEditingController(text: goal.deadline);
    IconData selectedIcon = goal.icon;
    Color selectedColor = goal.color;

    final List<IconData> goalIcons = [Icons.star_rounded, Icons.flight_rounded, Icons.home_rounded, Icons.directions_car_rounded, Icons.school_rounded, Icons.shopping_bag_rounded, Icons.favorite_rounded, Icons.mosque_rounded];
    final List<Color> goalColors = [AppColors.accentTeal, const Color(0xFF6366F1), const Color(0xFFF43F5E), const Color(0xFFF59E0B), const Color(0xFF10B981), const Color(0xFF8B5CF6), const Color(0xFFEC4899), const Color(0xFF0EA5E9)];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Center(
          child: MaxWidthBox(
            maxWidth: 450,
            child: AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28 * context.fontSizeFactor)),
              title: Text(l10n.editGoal, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, fontSize: 18 * context.fontSizeFactor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      _dialogInputField(context, l10n.goalName, Icons.edit_rounded, titleController),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _dialogInputField(context, l10n.targetAmount, Icons.attach_money_rounded, amountController, isNumber: true),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _dialogInputField(
                        context,
                        l10n.deadline,
                        Icons.calendar_today_rounded,
                        deadlineController,
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)));
                          if (date != null) {
                            if (!context.mounted) return;
                            setDialogState(() {
                              deadlineController.text = DateFormat('dd MMM yyyy').format(date);
                            });
                          }
                        },
                      ),
                      SizedBox(height: 24 * context.fontSizeFactor),
                      Text(l10n.selectIcon, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
                      SizedBox(height: 12 * context.fontSizeFactor),
                      SizedBox(
                        height: 55 * context.fontSizeFactor,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: goalIcons.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedIcon == goalIcons[index];
                            return GestureDetector(
                              onTap: () => setDialogState(() => selectedIcon = goalIcons[index]),
                              child: Container(
                                margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
                                width: 50 * context.fontSizeFactor,
                                decoration: BoxDecoration(color: isSelected ? selectedColor : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14 * context.fontSizeFactor), border: Border.all(color: isSelected ? selectedColor : Theme.of(context).dividerColor.withValues(alpha: 0.1))),
                                child: Icon(goalIcons[index], color: isSelected ? Colors.white : AppColors.grey, size: 26 * context.fontSizeFactor),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24 * context.fontSizeFactor),
                      Text(l10n.selectColor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
                      SizedBox(height: 12 * context.fontSizeFactor),
                      SizedBox(
                        height: 45 * context.fontSizeFactor,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: goalColors.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedColor == goalColors[index];
                            return GestureDetector(
                              onTap: () => setDialogState(() => selectedColor = goalColors[index]),
                              child: Container(
                                margin: EdgeInsets.only(right: 12 * context.fontSizeFactor),
                                width: 45 * context.fontSizeFactor,
                                decoration: BoxDecoration(color: goalColors[index], shape: BoxShape.circle, border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 3)),
                                child: isSelected ? Icon(Icons.check, color: Colors.white, size: 24 * context.fontSizeFactor) : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      Provider.of<AppState>(context, listen: false).updateSavingsGoal(
                        index, 
                        goal.copyWith(
                          title: titleController.text,
                          target: double.tryParse(amountController.text) ?? goal.target,
                          deadline: deadlineController.text,
                          icon: selectedIcon,
                          color: selectedColor,
                        )
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor))),
                  child: Text(l10n.save, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
