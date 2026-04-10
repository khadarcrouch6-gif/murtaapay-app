import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';

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
    final state = AppState();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(state.translate("Zakat Calculator", "Xisaabiyaha Sakada", ar: "حاسبة الزكاة", de: "Zakat-Rechner"), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(state.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Center(
          child: MaxWidthBox(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        Text(state.translate("Total Zakat to Pay", "Wadarta Sakada laga rabo", ar: "إجمالي الزكاة المستحقة", de: "Gesamtbetrag der Zakat"), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                        const SizedBox(height: 8),
                        Text("\$${_totalZakat.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.translate("Enter Your Assets", "Geli Hantidaada", ar: "أدخل أصولك", de: "Geben Sie Ihr Vermögen ein"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _buildInputField(state.translate("Cash & Savings", "Lacagta & Kaydka", ar: "النقد والمدخرات", de: "Bargeld & Ersparnisse"), _cashController, Icons.account_balance_wallet_rounded, isDark),
                      const SizedBox(height: 16),
                      _buildInputField(state.translate("Gold Value", "Qiimaha Dahabka", ar: "قيمة الذهب", de: "Goldwert"), _goldController, Icons.auto_awesome_rounded, isDark),
                      const SizedBox(height: 16),
                      _buildInputField(state.translate("Silver Value", "Qiimaha Qalinka", ar: "قيمة الفضة", de: "Silberwert"), _silverController, Icons.brightness_high_rounded, isDark),
                      const SizedBox(height: 16),
                      _buildInputField(state.translate("Other Investments", "Maalgelin Kale", ar: "استثمارات أخرى", de: "Andere Investitionen"), _investmentsController, Icons.trending_up_rounded, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentTeal.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.accentTeal),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            state.translate(
                              "Zakatable amount is calculated as 2.5% of your total wealth if it exceeds the Nisab threshold.",
                              "Cadadka Sakada waxaa loo xisaabinayaa 2.5% hantidaada haddii ay gaadho heerka nisaabka.",
                              ar: "يتم حساب مبلغ الزكاة بنسبة 2.5٪ من إجمالي ثروتك إذا تجاوزت حد النصاب.",
                              de: "Der zakatfähige Betrag wird mit 2,5 % Ihres Gesamtvermögens berechnet, wenn es die Nisab-Schwelle überschreitet.",
                            ),
                            style: const TextStyle(fontSize: 13, color: AppColors.accentTeal, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _totalZakat > 0 ? () {
                      // Implementation for donating from calculator
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Proceeding to donate \$${_totalZakat.toStringAsFixed(2)}")));
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                    child: Text(state.translate("Donate Your Zakat", "Bixi Sakadaada", ar: "تبرع بزكاتك", de: "Zakat spenden"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.accentTeal),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            hintText: "0.00",
          ),
        ),
      ],
    );
  }
}
