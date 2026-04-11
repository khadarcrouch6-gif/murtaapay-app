import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/success_screen.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PayBillsScreen extends StatefulWidget {
  const PayBillsScreen({super.key});

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final List<Map<String, dynamic>> _categories = [
    {"title": "Electricity", "l10nKey": "electricity", "icon": Icons.lightbulb_outline_rounded, "color": Colors.orange},
    {"title": "Water", "l10nKey": "water", "icon": Icons.water_drop_outlined, "color": Colors.blue},
    {"title": "Internet", "l10nKey": "internet", "icon": Icons.wifi_rounded, "color": Colors.purple},
    {"title": "TV Cable", "l10nKey": "tvCable", "icon": Icons.tv_rounded, "color": Colors.red},
    {"title": "Education", "l10nKey": "education", "icon": Icons.school_outlined, "color": Colors.green},
    {"title": "Gov Services", "l10nKey": "govServices", "icon": Icons.account_balance_rounded, "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          l10n.payBills, 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color)
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20 * context.fontSizeFactor, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 900,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.horizontalPadding,
              context.horizontalPadding,
              context.horizontalPadding,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Text(
                    l10n.selectCategory, 
                    style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.responsiveValue(mobile: 2, tablet: 3, desktop: 4),
                    mainAxisSpacing: 16 * context.fontSizeFactor,
                    crossAxisSpacing: 16 * context.fontSizeFactor,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 50),
                      child: _buildBillCategory(
                        context,
                        _categories[index]["title"],
                        _categories[index]["l10nKey"],
                        _categories[index]["icon"],
                        _categories[index]["color"],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  child: Text(
                    l10n.recentBills, 
                    style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentBill(context, "Somtel Internet", "Oct 20, 2023", "\$25.00", "Internet", "internet", "ACC-992831"),
                _buildRecentBill(context, "BECO Electricity", "Oct 15, 2023", "\$42.50", "Electricity", "electricity", "ACC-110293"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillCategory(BuildContext context, String title, String l10nKey, IconData icon, Color color) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    String translatedTitle = _getTranslatedCategory(l10n, l10nKey);
    return GestureDetector(
      onTap: () => _showPayDialog(context, title, l10nKey, icon, color),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.02), 
              blurRadius: 20, 
              offset: const Offset(0, 8)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12 * context.fontSizeFactor),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28 * context.fontSizeFactor),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                translatedTitle, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(BuildContext context, String category, String l10nKey, IconData icon, Color color) {
    TextEditingController idController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final translatedCategory = _getTranslatedCategory(l10n, l10nKey);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(32 * context.fontSizeFactor),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10 * context.fontSizeFactor),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 24 * context.fontSizeFactor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        translatedCategory, 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: idController,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16 * context.fontSizeFactor),
                  decoration: InputDecoration(
                    labelText: "$translatedCategory ID / ${l10n.accountNumber}",
                    labelStyle: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    prefixIcon: Icon(Icons.tag, color: AppColors.grey, size: 20 * context.fontSizeFactor),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16 * context.fontSizeFactor),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.amountToPay,
                    labelStyle: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    prefixIcon: Icon(Icons.attach_money, color: AppColors.grey, size: 20 * context.fontSizeFactor),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56 * context.fontSizeFactor,
                  child: ElevatedButton(
                    onPressed: () {
                      if (idController.text.isNotEmpty && amountController.text.isNotEmpty) {
                        Navigator.pop(context);
                        _processTransaction(this.context, l10nKey, amountController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.confirmPayment, 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processTransaction(BuildContext context, String l10nKey, String amount) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
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
    
    _showSuccess(context, l10nKey, amount);
  }

  void _showSuccess(BuildContext context, String l10nKey, String amount) {
    final l10n = AppLocalizations.of(context)!;
    final translatedCategory = _getTranslatedCategory(l10n, l10nKey);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: l10n.paymentSuccessful,
          message: l10n.paymentSuccessMessage("$amount", translatedCategory),
          buttonText: l10n.backToBills,
        ),
      ),
    );
  }

  Widget _buildRecentBill(BuildContext context, String title, String date, String amount, String category, String l10nKey, String id) {
    final theme = Theme.of(context);
    return FadeInUp(
      child: GestureDetector(
        onTap: () => _showBillDetail(context, title, date, amount, category, l10nKey, id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.1 : 0.02), 
                blurRadius: 15, 
                offset: const Offset(0, 6)
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10 * context.fontSizeFactor),
                decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, shape: BoxShape.circle),
                child: Icon(Icons.receipt_long_rounded, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)),
                    Text(date, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
                  ],
                ),
              ),
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)),
            ],
          ),
        ),
      ),
    );
  }

  void _showBillDetail(BuildContext context, String title, String date, String amount, String category, String l10nKey, String id) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.fromLTRB(32 * context.fontSizeFactor, 20 * context.fontSizeFactor, 32 * context.fontSizeFactor, 32 * context.fontSizeFactor),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Text(
                  l10n.billDetails, 
                  style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)
                ),
                const SizedBox(height: 24),
                DetailRow(label: l10n.serviceProvider, value: title),
                DetailRow(label: l10n.category, value: _getTranslatedCategory(l10n, l10nKey)),
                DetailRow(label: l10n.accountId, value: id),
                DetailRow(label: l10n.amountPaid, value: amount),
                DetailRow(label: l10n.paymentDate, value: date),
                DetailRow(label: l10n.status, value: l10n.completed, valueColor: AppColors.accentTeal),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56 * context.fontSizeFactor,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.downloadReceipt, 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.close, 
                    style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTranslatedCategory(AppLocalizations l10n, String l10nKey) {
    switch (l10nKey) {
      case "electricity": return l10n.electricity;
      case "water": return l10n.water;
      case "internet": return l10n.internet;
      case "tvCable": return l10n.tvCable;
      case "education": return l10n.education;
      case "govServices": return l10n.govServices;
      default: return l10nKey;
    }
  }
}
