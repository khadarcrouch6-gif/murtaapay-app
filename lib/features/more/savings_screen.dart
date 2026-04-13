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

  double _totalSavingsBalance = 6550.00;

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
                      Text(l10n.activeGoals, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      TextButton(
                        onPressed: () {},
                        child: Text(l10n.seeAll, style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_goals.length, (index) {
                    final goal = _goals[index];
                    return _buildSavingsGoalCard(
                      context: context,
                      l10n: l10n,
                      index: index,
                      goal: goal,
                    );
                  }),
                  const SizedBox(height: 100), // Spacing for the fixed button
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(context.horizontalPadding, 0, context.horizontalPadding, 20),
            child: FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: MaxWidthBox(
                      maxWidth: 400,
                      child: SizedBox(
                        width: double.infinity,
                        height: 60 * context.fontSizeFactor,
                        child: ElevatedButton.icon(
                          onPressed: () => _showCreateGoalDialog(context, l10n),
                          icon: Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24 * context.fontSizeFactor),
                          label: Text(l10n.createNewGoal, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            elevation: 4,
                            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      ),
    );
  }

  Widget _buildTotalSavings(BuildContext context, AppLocalizations l10n) {
    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 25, offset: const Offset(0, 15)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalSavings, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: Colors.greenAccent, size: 14 * context.fontSizeFactor),
                      const SizedBox(width: 6),
                      Text("2.5%", style: TextStyle(color: Colors.white, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(NumberFormat.simpleCurrency(name: 'USD').format(_totalSavingsBalance), style: TextStyle(color: Colors.white, fontSize: 42 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceAction(
                    context, 
                    l10n.deposit, 
                    Icons.add_rounded, 
                    Colors.white, 
                    AppColors.primaryDark,
                    onTap: () => _showDepositMethodDialog(context, l10n),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBalanceAction(
                    context, 
                    l10n.withdraw, 
                    Icons.remove_rounded, 
                    Colors.white.withValues(alpha: 0.15), 
                    Colors.white,
                    onTap: () => _showWithdrawMethodDialog(context, l10n),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceAction(BuildContext context, String label, IconData icon, Color bgColor, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52 * context.fontSizeFactor,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20 * context.fontSizeFactor),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor)),
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
            _buildMethodTile(
              context,
              l10n.sendToWallet,
              l10n.payFromSavingBalance,
              Icons.account_balance_wallet_rounded,
              AppColors.accentTeal,
              () {
                Navigator.pop(context);
                _showWalletWithdrawDialog(this.context, l10n);
              },
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              context,
              l10n.sendToCard,
              l10n.withdrawToVirtualCard,
              Icons.account_balance_rounded,
              Colors.blue,
              () {
                Navigator.pop(context);
                _showBankWithdrawDialog(this.context, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletWithdrawDialog(BuildContext context, AppLocalizations l10n) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    final double savingsBalance = _totalSavingsBalance;

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
                  padding: EdgeInsets.symmetric(vertical: 32 * context.fontSizeFactor, horizontal: 24 * context.fontSizeFactor),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.accentTeal, Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Column(
                    children: [
                      Container(padding: EdgeInsets.all(12 * context.fontSizeFactor), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32 * context.fontSizeFactor)),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      Text(l10n.savingsBalanceLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      SizedBox(height: 4 * context.fontSizeFactor),
                      FittedBox(fit: BoxFit.scaleDown, child: Text(NumberFormat.simpleCurrency(name: 'USD').format(savingsBalance), style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.w900))),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24 * context.fontSizeFactor),
                  child: Column(
                    children: [
                      _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _dialogInputField(context, l10n.walletPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () {
                  Navigator.pop(context);
                  _processWithdraw(this.context, l10n, amountController.text);
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

  void _showBankWithdrawDialog(BuildContext context, AppLocalizations l10n) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController pinController = TextEditingController();
    final double savingsBalance = _totalSavingsBalance;

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
                  padding: EdgeInsets.symmetric(vertical: 32 * context.fontSizeFactor, horizontal: 24 * context.fontSizeFactor),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.blue, Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Column(
                    children: [
                      Container(padding: EdgeInsets.all(12 * context.fontSizeFactor), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 32 * context.fontSizeFactor)),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      Text(l10n.savingsBalanceLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      SizedBox(height: 4 * context.fontSizeFactor),
                      FittedBox(fit: BoxFit.scaleDown, child: Text(NumberFormat.simpleCurrency(name: 'USD').format(savingsBalance), style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.w900))),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24 * context.fontSizeFactor),
                  child: Column(
                    children: [
                      _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _dialogInputField(context, l10n.cardPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () {
                  Navigator.pop(context);
                  _processWithdraw(this.context, l10n, amountController.text);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processWithdraw(BuildContext context, AppLocalizations l10n, String amount) async {
    final theme = Theme.of(context);
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
                  SizedBox(height: 8 * context.fontSizeFactor),
                  Text(l10n.justAMoment, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13 * context.fontSizeFactor, color: AppColors.grey, decoration: ui.TextDecoration.none)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!context.mounted) return;

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          title: l10n.withdrawalSuccessful,
          message: l10n.withdrawalSuccessMessage(NumberFormat.simpleCurrency(name: 'USD').format(double.tryParse(amount) ?? 0)),
          buttonText: l10n.backToHome,
        ),
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController deadlineController = TextEditingController();
    IconData selectedIcon = Icons.stars_rounded;
    Color selectedColor = AppColors.accentTeal;

    final List<IconData> goalIcons = [
      Icons.mosque_rounded,
      Icons.directions_car_rounded,
      Icons.health_and_safety_rounded,
      Icons.home_rounded,
      Icons.flight_rounded,
      Icons.school_rounded,
      Icons.laptop_mac_rounded,
      Icons.shopping_bag_rounded,
      Icons.savings_rounded,
      Icons.celebration_rounded,
    ];

    final List<Color> goalColors = [
      AppColors.accentTeal,
      const Color(0xFF6366F1),
      const Color(0xFFF43F5E),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(l10n.createNewGoal, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.colorScheme.primary)),
          content: SizedBox(
            width: 400 * context.fontSizeFactor,
            child: SingleChildScrollView(
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
                    Icons.calendar_month_rounded, 
                    deadlineController,
                    readOnly: true,
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.accentTeal,
                                onPrimary: Colors.white,
                                onSurface: theme.colorScheme.primary,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(foregroundColor: AppColors.accentTeal),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        if (!context.mounted) return;
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.accentTeal,
                                  onPrimary: Colors.white,
                                  onSurface: theme.colorScheme.primary,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(foregroundColor: AppColors.accentTeal),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedTime != null) {
                          final DateTime fullDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          setDialogState(() {
                            deadlineController.text = DateFormat('dd MMM yyyy, HH:mm').format(fullDateTime);
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
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? selectedColor : theme.dividerColor.withValues(alpha: 0.1)),
                              boxShadow: isSelected ? [BoxShadow(color: selectedColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                            ),
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
                            decoration: BoxDecoration(
                              color: goalColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: 3),
                              boxShadow: isSelected ? [BoxShadow(color: goalColors[index].withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))] : null,
                            ),
                            child: isSelected ? Icon(Icons.check, color: Colors.white, size: 24 * context.fontSizeFactor) : null,
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
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _processCreateGoal(this.context, l10n, titleController.text, amountController.text, deadlineController.text, selectedIcon, selectedColor);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor)),
              child: Text(l10n.create, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
            ),
          ],
        ),
      ),
    );
  }

  void _processCreateGoal(BuildContext context, AppLocalizations l10n, String title, String amount, String deadline, IconData icon, Color color) async {
    final theme = Theme.of(context);
    
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
      _goals.add({
        "title": title,
        "soTitle": title,
        "arTitle": title,
        "deTitle": title,
        "saved": 0.0,
        "target": double.tryParse(amount) ?? 0.0,
        "deadline": deadline.isNotEmpty ? deadline : "Ongoing",
        "icon": icon,
        "color": color,
        "delay": 0,
        "isPaused": false,
      });
    });

    Navigator.of(context, rootNavigator: true).pop();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          title: l10n.goalCreated,
          message: l10n.goalCreatedSuccess(title, NumberFormat.simpleCurrency(name: 'USD').format(double.tryParse(amount) ?? 0)),
          buttonText: l10n.backToSavings,
          onPressed: () {
            Navigator.of(context).pop(); // Pop SuccessScreen
          },
        ),
      ),
    );
  }

  void _showDepositMethodDialog(BuildContext context, AppLocalizations l10n) {
    final state = AppState();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.choosePaymentMethod, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMethodTile(
              context,
              l10n.sendFromWallet,
              l10n.payFromWalletBalance,
              Icons.account_balance_wallet_rounded,
              AppColors.accentTeal,
              () {
                Navigator.pop(context);
                _showWalletDepositDialog(this.context, state, l10n);
              },
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              context,
              l10n.sendFromCard,
              l10n.payFromVirtualCard,
              FontAwesomeIcons.ccVisa,
              const Color(0xFF1A1F71),
              () {
                Navigator.pop(context);
                _showCardDepositDialog(this.context, state, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(BuildContext context, String title, String subtitle, dynamic icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: icon is FaIconData
                ? FaIcon(icon, color: color, size: 20 * context.fontSizeFactor)
                : Icon(icon as IconData?, color: color, size: 20 * context.fontSizeFactor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                  Text(subtitle, style: TextStyle(color: AppColors.grey, fontSize: 11 * context.fontSizeFactor)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey.withValues(alpha: 0.3)),
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
                  padding: EdgeInsets.symmetric(vertical: 32 * context.fontSizeFactor, horizontal: 24 * context.fontSizeFactor),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.accentTeal, Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Column(
                    children: [
                      Container(padding: EdgeInsets.all(12 * context.fontSizeFactor), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32 * context.fontSizeFactor)),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      Text(l10n.walletBalance.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      SizedBox(height: 4 * context.fontSizeFactor),
                      FittedBox(fit: BoxFit.scaleDown, child: Text(NumberFormat.simpleCurrency(name: 'USD').format(state.balance), style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.w900))),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24 * context.fontSizeFactor),
                  child: Column(
                    children: [
                      _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _dialogInputField(context, l10n.walletPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () {
                  Navigator.pop(context);
                  _processDeposit(this.context, l10n, amountController.text);
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
    final double cardBalance = 850.50; // Current Virtual Card Balance

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
                  padding: EdgeInsets.symmetric(vertical: 32 * context.fontSizeFactor, horizontal: 24 * context.fontSizeFactor),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1F71), Color(0xFF000000)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Column(
                    children: [
                      Container(padding: EdgeInsets.all(12 * context.fontSizeFactor), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: FaIcon(FontAwesomeIcons.ccVisa, color: Colors.white, size: 32 * context.fontSizeFactor)),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      Text(l10n.virtualCardBalance.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      SizedBox(height: 4 * context.fontSizeFactor),
                      FittedBox(fit: BoxFit.scaleDown, child: Text(NumberFormat.simpleCurrency(name: 'USD').format(cardBalance), style: TextStyle(color: Colors.white, fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.w900))),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24 * context.fontSizeFactor),
                  child: Column(
                    children: [
                      _dialogInputField(context, l10n.amount, Icons.attach_money_rounded, amountController, isNumber: true, onChanged: (_) => setDialogState(() {})),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      _dialogInputField(context, l10n.cardPin, Icons.lock_rounded, pinController, isNumber: true, isObscure: true, maxLength: 4, onChanged: (_) => setDialogState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: (amountController.text.isEmpty || pinController.text.length < 4) ? null : () {
                  Navigator.pop(context);
                  _processDeposit(this.context, l10n, amountController.text);
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

  void _processDeposit(BuildContext context, AppLocalizations l10n, String amount) async {
    final theme = Theme.of(context);
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
                  SizedBox(height: 8 * context.fontSizeFactor),
                  Text(l10n.justAMoment, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13 * context.fontSizeFactor, color: AppColors.grey, decoration: ui.TextDecoration.none)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!context.mounted) return;

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          title: l10n.depositSuccessful,
          message: l10n.depositSuccessMessage(NumberFormat.simpleCurrency(name: 'USD').format(double.tryParse(amount) ?? 0)),
          buttonText: l10n.backToHome,
        ),
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
    final title = goal['title'];
    final double savedAmount = goal['saved'];
    final double targetAmount = goal['target'];
    final String deadline = goal['deadline'] ?? "Ongoing";
    final IconData icon = goal['icon'];
    final Color color = goal['color'];
    final int delay = goal['delay'] ?? 0;
    final bool isPaused = goal['isPaused'] ?? false;
    final bool isCompleted = savedAmount >= targetAmount;

    return FadeInRight(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: (isPaused ? Colors.grey : color).withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () => _showGoalOptionsSheet(context, l10n, index, goal),
            child: Opacity(
              opacity: isPaused ? 0.7 : 1.0,
              child: ColorFiltered(
                colorFilter: isPaused
                    ? const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ])
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (isCompleted ? AppColors.accentTeal : color).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check_circle_rounded : icon,
                              color: isCompleted ? AppColors.accentTeal : color,
                              size: 24 * context.fontSizeFactor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16 * context.fontSizeFactor,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    if (isPaused)
                                      _buildBadge(context, l10n.paused, Colors.grey),
                                    if (isCompleted)
                                      _buildBadge(context, l10n.completed, AppColors.accentTeal),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${l10n.targetWithColon}${NumberFormat.simpleCurrency(name: 'USD').format(targetAmount)} • $deadline",
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12 * context.fontSizeFactor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.more_vert_rounded, color: AppColors.grey.withValues(alpha: 0.5), size: 20 * context.fontSizeFactor),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                NumberFormat.simpleCurrency(name: 'USD').format(savedAmount),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15 * context.fontSizeFactor,
                                  color: isCompleted ? AppColors.accentTeal : theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                "${((savedAmount / targetAmount) * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14 * context.fontSizeFactor,
                                  color: isCompleted ? AppColors.accentTeal : AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (savedAmount / targetAmount).clamp(0.0, 1.0),
                              backgroundColor: (isCompleted ? AppColors.accentTeal : color).withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? AppColors.accentTeal : color),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10 * context.fontSizeFactor, 
          color: color, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
  void _showGoalOptionsSheet(BuildContext context, AppLocalizations l10n, int index, Map<String, dynamic> goal) {
    final theme = Theme.of(context);
    final bool isPaused = goal['isPaused'] ?? false;
    final bool isCompleted = (goal['saved'] ?? 0) >= (goal['target'] ?? 0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, -5)),
            ],
          ),
          padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (goal['color'] as Color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(goal['icon'] as IconData, color: goal['color'] as Color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal['title'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.colorScheme.primary),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: AppColors.grey, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (!isCompleted)
                    _buildSheetAction(
                      context,
                      l10n.addFunds,
                      Icons.add_circle_outline_rounded,
                      AppColors.accentTeal,
                      () {
                        Navigator.pop(context);
                        _showAddFundsDialog(context, l10n, index);
                      },
                    ),
                  _buildSheetAction(
                    context,
                    l10n.edit,
                    Icons.edit_rounded,
                    Colors.blue,
                    () {
                      Navigator.pop(context);
                      _showEditGoalDialogAt(context, l10n, index, goal);
                    },
                  ),
                  _buildSheetAction(
                    context,
                    isPaused 
                      ? l10n.resume
                      : l10n.pause,
                    isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    Colors.orange,
                    () {
                      Navigator.pop(context);
                      setState(() {
                        _goals[index]['isPaused'] = !isPaused;
                      });
                    },
                  ),
                  _buildSheetAction(
                    context,
                    l10n.delete,
                    Icons.delete_outline_rounded,
                    Colors.red,
                    () {
                      Navigator.pop(context);
                      _showDeleteConfirm(context, l10n, index);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56 * context.fontSizeFactor,
            height: 56 * context.fontSizeFactor,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 26 * context.fontSizeFactor),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 70 * context.fontSizeFactor,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11 * context.fontSizeFactor,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddFundsDialog(BuildContext context, AppLocalizations l10n, int index) {
    final theme = Theme.of(context);
    final TextEditingController amountController = TextEditingController();
    final goal = _goals[index];
    final color = goal['color'] as Color;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(l10n.addFunds, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.colorScheme.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.targetWithColon + NumberFormat.simpleCurrency(name: 'USD').format(goal['target']),
              style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
            ),
            const SizedBox(height: 16),
            _dialogInputField(context, l10n.amountToAdd, Icons.add_card_rounded, amountController, isNumber: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey))),
          ElevatedButton(
            onPressed: () {
              final double amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                setState(() {
                  _goals[index]['saved'] += amount;
                  _totalSavingsBalance += amount;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.fundsAddedSuccess),
                    backgroundColor: AppColors.accentTeal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirm(BuildContext context, AppLocalizations l10n, int index) {
    showDialog(
      context: context,
      builder: (context) => ZoomIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              Text(l10n.deleteGoal, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            l10n.deleteGoalConfirm,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold))
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _goals.removeAt(index);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                foregroundColor: Colors.white, 
                elevation: 0, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(l10n.delete, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGoalDialogAt(BuildContext context, AppLocalizations l10n, int index, Map<String, dynamic> goal) {
    final theme = Theme.of(context);
    final TextEditingController titleController = TextEditingController(text: goal['title']);
    final TextEditingController amountController = TextEditingController(text: goal['target'].toString());
    final TextEditingController deadlineController = TextEditingController(text: goal['deadline']);
    IconData selectedIcon = goal['icon'];
    Color selectedColor = goal['color'];

    final List<IconData> goalIcons = [
      Icons.mosque_rounded,
      Icons.directions_car_rounded,
      Icons.health_and_safety_rounded,
      Icons.home_rounded,
      Icons.flight_rounded,
      Icons.school_rounded,
      Icons.laptop_mac_rounded,
      Icons.shopping_bag_rounded,
      Icons.savings_rounded,
      Icons.celebration_rounded,
    ];

    final List<Color> goalColors = [
      AppColors.accentTeal,
      const Color(0xFF6366F1),
      const Color(0xFFF43F5E),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(l10n.editGoal, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.colorScheme.primary)),
          content: SizedBox(
            width: 400 * context.fontSizeFactor,
            child: SingleChildScrollView(
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
                    Icons.calendar_month_rounded, 
                    deadlineController,
                    readOnly: true,
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.accentTeal,
                                onPrimary: Colors.white,
                                onSurface: theme.colorScheme.primary,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(foregroundColor: AppColors.accentTeal),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        if (!context.mounted) return;
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.accentTeal,
                                  onPrimary: Colors.white,
                                  onSurface: theme.colorScheme.primary,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(foregroundColor: AppColors.accentTeal),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedTime != null) {
                          final DateTime fullDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          setDialogState(() {
                            deadlineController.text = DateFormat('dd MMM yyyy, HH:mm').format(fullDateTime);
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
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? selectedColor : theme.dividerColor.withValues(alpha: 0.1)),
                              boxShadow: isSelected ? [BoxShadow(color: selectedColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                            ),
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
                            decoration: BoxDecoration(
                              color: goalColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: 3),
                              boxShadow: isSelected ? [BoxShadow(color: goalColors[index].withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))] : null,
                            ),
                            child: isSelected ? Icon(Icons.check, color: Colors.white, size: 24 * context.fontSizeFactor) : null,
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
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
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
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor)),
              child: Text(l10n.save, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
            ),
          ],
        ),
      ),
    );
  }
}
