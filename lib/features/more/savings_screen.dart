import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/success_screen.dart';

class SavingsScreen extends StatefulWidget {
  final bool isTab;
  const SavingsScreen({super.key, this.isTab = false});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final List<Map<String, dynamic>> _goals = [
    {
      "title": "Hajj Fund",
      "soTitle": "Sanduuqa Xajka",
      "arTitle": "صندوق الحج",
      "deTitle": "Hajj-Fonds",
      "saved": 1200.0,
      "target": 5000.0,
      "deadline": "Dec 2025",
      "icon": Icons.mosque_rounded,
      "color": AppColors.accentTeal,
      "delay": 100,
      "isPaused": false,
    },
    {
      "title": "New Car",
      "soTitle": "Gaadhi Cusub",
      "arTitle": "سيارة جديدة",
      "deTitle": "Neues Auto",
      "saved": 4500.0,
      "target": 15000.0,
      "deadline": "Jun 2026",
      "icon": Icons.directions_car_rounded,
      "color": const Color(0xFF6366F1),
      "delay": 200,
      "isPaused": false,
    },
    {
      "title": "Emergency Fund",
      "soTitle": "Sanduuqa Degdegga",
      "arTitle": "صندوق الطوارئ",
      "deTitle": "Notfallfonds",
      "saved": 850.0,
      "target": 2000.0,
      "deadline": "Ongoing",
      "icon": Icons.health_and_safety_rounded,
      "color": const Color(0xFFF43F5E),
      "delay": 300,
      "isPaused": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) => Scaffold(
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
            maxWidth: 800,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: MaxWidthBox(
                      maxWidth: 500,
                      child: _buildTotalSavings(context, l10n),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.activeGoals, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor, letterSpacing: -0.5)),
                      TextButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            Text(l10n.seeAll, style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.accentTeal),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) => _buildSavingsGoalCard(context: context, l10n: l10n, index: index, goal: _goals[index]),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.recentSavingsActivity, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18 * context.fontSizeFactor, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  _buildRecentActivity(context, l10n),
                  const SizedBox(height: 100),
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
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, elevation: 8, shadowColor: AppColors.accentTeal.withValues(alpha: 0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle_outline_rounded, size: 24),
                              const SizedBox(width: 12),
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
      ),
    );
  }

  Widget _buildTotalSavings(BuildContext context, AppLocalizations l10n) {
    final state = AppState();
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.accentTeal, Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
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
                    Text("${l10n.cardBalanceLabel}${NumberFormat.simpleCurrency(name: 'USD').format(state.cardBalance)}", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text("2.5%", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.savingsBalance), style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildBalanceAction(context, l10n.deposit, Icons.add_rounded, Colors.white, AppColors.accentTeal, onTap: () => _showDepositMethodDialog(context, l10n))),
                const SizedBox(width: 12),
                Expanded(child: _buildBalanceAction(context, l10n.withdraw, Icons.arrow_outward_rounded, Colors.white.withValues(alpha: 0.15), Colors.white, onTap: () => _showWithdrawMethodDialog(context, l10n))),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 14 * context.fontSizeFactor)),
          ],
        ),
      ),
    );
  }

  void _showWithdrawMethodDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.chooseWithdrawalMethod, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMethodTile(context, l10n.sendToWallet, l10n.payFromSavingBalance, Icons.account_balance_wallet_rounded, AppColors.accentTeal, () {
              Navigator.pop(context);
              _showWalletWithdrawDialog(this.context, l10n);
            }),
            const SizedBox(height: 12),
            _buildMethodTile(context, l10n.sendToCard, l10n.withdrawToVirtualCard, Icons.credit_card_rounded, const Color(0xFF1A1F71), () {
              Navigator.pop(context);
              _showCardWithdrawDialog(this.context, l10n);
            }),
          ],
        ),
      ),
    );
  }

  void _showWalletWithdrawDialog(BuildContext context, AppLocalizations l10n) {
    final state = AppState();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.accentTeal, Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32)),
                      const SizedBox(height: 16),
                      Text(l10n.savingsBalanceLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      FittedBox(fit: BoxFit.scaleDown, child: ListenableBuilder(listenable: state, builder: (context, _) => Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.savingsBalance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      const SizedBox(height: 16),
                      _dialogInputField(context, l10n.walletPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () async {
                  if (state.verifyPin(pinController.text)) {
                    final double amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > state.savingsBalance) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red));
                      return;
                    }
                    Navigator.pop(context);
                    await _processWithdrawal(this.context, l10n, amountController.text, toCard: false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate("PIN-kaagu waa khalad.", "PIN-kaagu waa khalad.")), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardWithdrawDialog(BuildContext context, AppLocalizations l10n) {
    final state = AppState();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1F71), Color(0xFF000000)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const FaIcon(FontAwesomeIcons.ccVisa, color: Colors.white, size: 32)),
                      const SizedBox(height: 16),
                      Text(l10n.savingsBalanceLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      FittedBox(fit: BoxFit.scaleDown, child: ListenableBuilder(listenable: state, builder: (context, _) => Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.savingsBalance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      const SizedBox(height: 16),
                      _dialogInputField(context, l10n.cardPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () async {
                  if (state.verifyCardPin(pinController.text)) {
                    final double amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > state.savingsBalance) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red));
                      return;
                    }
                    Navigator.pop(context);
                    await _processWithdrawal(this.context, l10n, amountController.text, toCard: true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate("PIN-ka kaarkaagu waa khalad.", "PIN-ka kaarkaagu waa khalad.")), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1F71), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processWithdrawal(BuildContext context, AppLocalizations l10n, String amountStr, {bool toCard = false}) async {
    final theme = Theme.of(context);
    final state = AppState();
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
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(alignment: Alignment.center, children: [SizedBox(width: 65 * context.fontSizeFactor, height: 65 * context.fontSizeFactor, child: const CircularProgressIndicator(color: AppColors.accentTeal, strokeWidth: 3)), Icon(Icons.bolt_rounded, color: AppColors.accentTeal, size: 32 * context.fontSizeFactor)]),
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
      await state.withdrawFromSavings(amount, toCard: toCard);
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

  void _showDepositMethodDialog(BuildContext context, AppLocalizations l10n) {
    final state = AppState();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.selectPaymentMethod, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMethodTile(context, l10n.sendFromWallet, l10n.payFromWalletBalance, Icons.account_balance_wallet_rounded, AppColors.accentTeal, () {
              Navigator.pop(context);
              _showWalletDepositDialog(this.context, state, l10n);
            }),
            const SizedBox(height: 12),
            _buildMethodTile(context, l10n.sendFromCard, l10n.payFromVirtualCard, Icons.credit_card_rounded, const Color(0xFF1A1F71), () {
              Navigator.pop(context);
              _showCardDepositDialog(this.context, state, l10n);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _showWalletDepositDialog(BuildContext context, AppState state, AppLocalizations l10n) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.accentTeal, Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32)),
                      const SizedBox(height: 16),
                      Text(l10n.availableBalance, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      FittedBox(fit: BoxFit.scaleDown, child: ListenableBuilder(listenable: state, builder: (context, _) => Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      const SizedBox(height: 16),
                      _dialogInputField(context, l10n.walletPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () async {
                  if (state.verifyPin(pinController.text)) {
                    final double amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > state.balance) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red));
                      return;
                    }
                    Navigator.pop(context);
                    await _processDeposit(this.context, l10n, amountController.text, fromCard: false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate("PIN-kaagu waa khalad.", "PIN-kaagu waa khalad.")), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDepositDialog(BuildContext context, AppState state, AppLocalizations l10n) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1F71), Color(0xFF000000)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const FaIcon(FontAwesomeIcons.ccVisa, color: Colors.white, size: 32)),
                      const SizedBox(height: 16),
                      Text(l10n.virtualCardBalance, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      FittedBox(fit: BoxFit.scaleDown, child: ListenableBuilder(listenable: state, builder: (context, _) => Text(NumberFormat.simpleCurrency(name: state.currencyCode).format(state.cardBalance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      const SizedBox(height: 16),
                      _dialogInputField(context, l10n.cardPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () async {
                  if (state.verifyCardPin(pinController.text)) {
                    final double amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > state.cardBalance) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: Colors.red));
                      return;
                    }
                    Navigator.pop(context);
                    await _processDeposit(this.context, l10n, amountController.text, fromCard: true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate("PIN-ka kaarkaagu waa khalad.", "PIN-ka kaarkaagu waa khalad.")), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1F71), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processDeposit(BuildContext context, AppLocalizations l10n, String amountStr, {bool fromCard = false}) async {
    final theme = Theme.of(context);
    final state = AppState();
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
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(alignment: Alignment.center, children: [SizedBox(width: 65 * context.fontSizeFactor, height: 65 * context.fontSizeFactor, child: const CircularProgressIndicator(color: AppColors.accentTeal, strokeWidth: 3)), Icon(Icons.bolt_rounded, color: AppColors.accentTeal, size: 32 * context.fontSizeFactor)]),
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
      await state.transferToSavings(amount, fromCard: fromCard);
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentTeal, width: 2)),
      ),
    );
  }

  Widget _buildSavingsGoalCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required int index,
    required Map<String, dynamic> goal,
  }) {
    final theme = Theme.of(context);
    double progress = (goal['saved'] / goal['target']).clamp(0.0, 1.0);
    bool isPaused = goal['isPaused'] ?? false;

    return FadeInUp(
      delay: Duration(milliseconds: goal['delay']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: goal['color'].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Icon(goal['icon'], color: goal['color'], size: 28)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(goal['title'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.2)),
                            if (isPaused)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(l10n.paused.toUpperCase(), style: TextStyle(color: AppColors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("${l10n.targetWithColon}${NumberFormat.simpleCurrency(name: 'USD').format(goal['target'])} • ${goal['deadline']}", style: TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  _buildGoalOptions(context, l10n, index, goal),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(NumberFormat.simpleCurrency(name: 'USD').format(goal['saved']), style: TextStyle(color: goal['color'], fontWeight: FontWeight.w900, fontSize: 18)),
                      Text("${(progress * 100).toInt()}%", style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10))),
                      AnimatedContainer(duration: const Duration(seconds: 1), curve: Curves.easeOutCubic, height: 10, width: MediaQuery.of(context).size.width * 0.7 * progress, decoration: BoxDecoration(gradient: LinearGradient(colors: [goal['color'], goal['color'].withValues(alpha: 0.7)]), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: goal['color'].withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))])),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isPaused ? null : () => _showAddFundsDialog(context, l10n, index),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: goal['color'].withValues(alpha: 0.2)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 12)),
                          child: Text(l10n.addFunds, style: TextStyle(color: goal['color'], fontWeight: FontWeight.w700)),
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

  Widget _buildGoalOptions(BuildContext context, AppLocalizations l10n, int index, Map<String, dynamic> goal) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: AppColors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (value) {
        if (value == 'edit') _showEditGoalDialog(context, l10n, index, goal);
        if (value == 'pause') setState(() => _goals[index]['isPaused'] = !(_goals[index]['isPaused'] ?? false));
        if (value == 'delete') _showDeleteConfirmDialog(context, l10n, index);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit_rounded, size: 20), const SizedBox(width: 12), Text(l10n.edit)])),
        PopupMenuItem(value: 'pause', child: Row(children: [Icon(goal['isPaused'] == true ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 20), const SizedBox(width: 12), Text(goal['isPaused'] == true ? l10n.resume : l10n.pause)])),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red), const SizedBox(width: 12), Text(l10n.delete, style: const TextStyle(color: Colors.red))])),
      ],
    );
  }

  void _showAddFundsDialog(BuildContext context, AppLocalizations l10n, int index) {
    final state = AppState();
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.addFunds, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: _dialogInputField(context, l10n.amountToAdd, Icons.add_circle_outline_rounded, amountController, isNumber: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0 && amount <= state.balance) {
                setState(() {
                  _goals[index]['saved'] += amount;
                });
                state.transferToSavings(amount, goalName: _goals[index]['title']);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fundsAddedSuccess), backgroundColor: AppColors.accentTeal, behavior: SnackBarBehavior.floating));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AppLocalizations l10n, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.deleteGoal),
        content: Text(l10n.deleteGoalConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey))),
          TextButton(
            onPressed: () {
              setState(() => _goals.removeAt(index));
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, AppLocalizations l10n) {
    final state = AppState();
    final savingsTxs = state.transactions.where((tx) => tx.category == "Savings").toList();

    if (savingsTxs.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Icon(Icons.history_rounded, size: 64, color: AppColors.grey.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(l10n.noActivityYet, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return Column(
      children: savingsTxs
          .take(5)
          .map((tx) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05))),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (tx.isNegative ? Colors.orange : AppColors.accentTeal).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(tx.isNegative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: tx.isNegative ? Colors.orange : AppColors.accentTeal, size: 18)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(tx.date, style: TextStyle(color: AppColors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(tx.amount, style: TextStyle(fontWeight: FontWeight.w900, color: tx.isNegative ? Colors.orange : AppColors.accentTeal, fontSize: 15)),
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

    final List<IconData> goalIcons = [Icons.star_rounded, Icons.flight_rounded, Icons.home_rounded, Icons.directions_car_rounded, Icons.school_rounded, Icons.shopping_bag_rounded, Icons.favorite_rounded, Icons.mosque_rounded];
    final List<Color> goalColors = [AppColors.accentTeal, const Color(0xFF6366F1), const Color(0xFFF43F5E), const Color(0xFFF59E0B), const Color(0xFF10B981), const Color(0xFF8B5CF6), const Color(0xFFEC4899), const Color(0xFF0EA5E9)];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(l10n.createNewGoal, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogInputField(context, l10n.goalName, Icons.edit_rounded, titleController),
                  const SizedBox(height: 16),
                  _dialogInputField(context, l10n.targetAmount, Icons.attach_money_rounded, amountController, isNumber: true),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  Text(l10n.selectIcon, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
                  const SizedBox(height: 12),
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
                            decoration: BoxDecoration(color: isSelected ? selectedColor : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? selectedColor : Theme.of(context).dividerColor.withValues(alpha: 0.1))),
                            child: Icon(goalIcons[index], color: isSelected ? Colors.white : AppColors.grey, size: 26 * context.fontSizeFactor),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.selectColor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
                  const SizedBox(height: 12),
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
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  _processCreateGoal(context, l10n, titleController.text, amountController.text, deadlineController.text, selectedIcon, selectedColor);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processCreateGoal(BuildContext context, AppLocalizations l10n, String title, String amount, String deadline, IconData icon, Color color) async {
    final theme = Theme.of(context);
    final state = AppState();

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
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(alignment: Alignment.center, children: [SizedBox(width: 65 * context.fontSizeFactor, height: 65 * context.fontSizeFactor, child: const CircularProgressIndicator(color: AppColors.accentTeal, strokeWidth: 3)), Icon(Icons.auto_awesome_rounded, color: AppColors.accentTeal, size: 32 * context.fontSizeFactor)]),
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

    setState(() {
      _goals.add({"title": title, "saved": 0.0, "target": double.tryParse(amount) ?? 0.0, "deadline": deadline.isNotEmpty ? deadline : "Ongoing", "icon": icon, "color": color, "delay": 0, "isPaused": false});
    });

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

  void _showEditGoalDialog(BuildContext context, AppLocalizations l10n, int index, Map<String, dynamic> goal) {
    final TextEditingController titleController = TextEditingController(text: goal['title']);
    final TextEditingController amountController = TextEditingController(text: goal['target'].toString());
    final TextEditingController deadlineController = TextEditingController(text: goal['deadline']);
    IconData selectedIcon = goal['icon'];
    Color selectedColor = goal['color'];

    final List<IconData> goalIcons = [Icons.star_rounded, Icons.flight_rounded, Icons.home_rounded, Icons.directions_car_rounded, Icons.school_rounded, Icons.shopping_bag_rounded, Icons.favorite_rounded, Icons.mosque_rounded];
    final List<Color> goalColors = [AppColors.accentTeal, const Color(0xFF6366F1), const Color(0xFFF43F5E), const Color(0xFFF59E0B), const Color(0xFF10B981), const Color(0xFF8B5CF6), const Color(0xFFEC4899), const Color(0xFF0EA5E9)];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(l10n.editGoal, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogInputField(context, l10n.goalName, Icons.edit_rounded, titleController),
                  const SizedBox(height: 16),
                  _dialogInputField(context, l10n.targetAmount, Icons.attach_money_rounded, amountController, isNumber: true),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  Text(l10n.selectIcon, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
                  const SizedBox(height: 12),
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
                            decoration: BoxDecoration(color: isSelected ? selectedColor : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? selectedColor : Theme.of(context).dividerColor.withValues(alpha: 0.1))),
                            child: Icon(goalIcons[index], color: isSelected ? Colors.white : AppColors.grey, size: 26 * context.fontSizeFactor),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.selectColor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: AppColors.grey)),
                  const SizedBox(height: 12),
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
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  setState(() {
                    _goals[index]['title'] = titleController.text;
                    _goals[index]['target'] = double.tryParse(amountController.text) ?? goal['target'];
                    _goals[index]['deadline'] = deadlineController.text;
                    _goals[index]['icon'] = selectedIcon;
                    _goals[index]['color'] = selectedColor;
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
