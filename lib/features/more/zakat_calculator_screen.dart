import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _investmentsController = TextEditingController();
  double _totalZakat = 0.0;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_calculateZakat);
    _goldController.addListener(_calculateZakat);
    _silverController.addListener(_calculateZakat);
    _investmentsController.addListener(_calculateZakat);
  }

  void _calculateZakat() {
    double cash = double.tryParse(_cashController.text) ?? 0.0;
    double gold = double.tryParse(_goldController.text) ?? 0.0;
    double silver = double.tryParse(_silverController.text) ?? 0.0;
    double investments = double.tryParse(_investmentsController.text) ?? 0.0;

    double totalAssets = cash + gold + silver + investments;
    setState(() {
      _totalZakat = totalAssets * 0.025; // 2.5% rule
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _investmentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);

    final scale = context.fontSizeFactor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.zakatCalculator, 
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 20 * scale)
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(state.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.colorScheme.primary, size: 24 * scale),
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
                FadeInDown(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(32 * scale),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(32 * scale),
                          boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 20 * scale, offset: Offset(0, 10 * scale))],
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.totalZakatToPay, 
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16 * scale)
                            ),
                            SizedBox(height: 8 * scale),
                            Text("\$${_totalZakat.toStringAsFixed(2)}", style: TextStyle(color: Colors.white, fontSize: 42 * scale, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40 * scale),
                FadeInUp(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.enterYourAssets, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold)),
                          SizedBox(height: 24 * scale),
                          _buildInputField(l10n.cashAndSavings, _cashController, Icons.account_balance_wallet_rounded, isDark, scale),
                          SizedBox(height: 16 * scale),
                          _buildInputField(l10n.goldValue, _goldController, Icons.auto_awesome_rounded, isDark, scale),
                          SizedBox(height: 16 * scale),
                          _buildInputField(l10n.silverValue, _silverController, Icons.brightness_high_rounded, isDark, scale),
                          SizedBox(height: 16 * scale),
                          _buildInputField(l10n.otherInvestments, _investmentsController, Icons.trending_up_rounded, isDark, scale),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40 * scale),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Container(
                        padding: EdgeInsets.all(20 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.accentTeal, size: 24 * scale),
                            SizedBox(width: 16 * scale),
                            Expanded(
                              child: Text(
                                l10n.zakatInfo,
                                style: TextStyle(fontSize: 13 * scale, color: AppColors.accentTeal, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 60 * scale),
                Center(
                  child: MaxWidthBox(
                    maxWidth: 600,
                    child: SizedBox(
                      width: double.infinity,
                      height: 60 * scale,
                      child: ElevatedButton(
                        onPressed: _totalZakat > 0 ? () {
                          // Implementation for donating from calculator
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.proceedingToDonate("\$${_totalZakat.toStringAsFixed(2)}"))));
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * scale)),
                          elevation: 4,
                        ),
                        child: Text(l10n.donateYourZakat, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * scale)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40 * scale),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, bool isDark, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold, color: Colors.grey)),
        SizedBox(height: 8 * scale),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 20 * scale),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16 * scale), borderSide: BorderSide.none),
            hintText: "0.00",
            contentPadding: EdgeInsets.symmetric(vertical: 16 * scale, horizontal: 16 * scale),
          ),
        ),
      ],
    );
  }

}
