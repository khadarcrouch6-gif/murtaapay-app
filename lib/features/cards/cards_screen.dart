import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../more/investments_screen.dart';
import '../more/savings_screen.dart';
import '../deposit/deposit_screen.dart';
import '../withdraw/withdraw_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool _isFrozen = false;
  bool _showBack = false;
  bool _showNumber = false;

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
      if (_showBack) _showNumber = false;
    });
  }

  void _toggleShowNumber() {
    setState(() => _showNumber = !_showNumber);
  }

  void _copyCardNumber(BuildContext context, AppState state) {
    Clipboard.setData(const ClipboardData(text: "4580123456789012"));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.translate("Card number copied!", "Lambarada waa la koobiyeeyay!", ar: "تم نسخ رقم البطاقة!", de: "Kartennummer kopiert!")),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.accentTeal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.horizontalPadding, 16, context.horizontalPadding, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.translate("My Cards", "Kaadhadhkayga", ar: "بطاقاتي", de: "Meine Karten"),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24 * context.fontSizeFactor,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showCardSettings(context, state),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.settings_outlined, color: theme.colorScheme.primary, size: 22 * context.fontSizeFactor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildCardsTab(context, state, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsTab(BuildContext context, AppState state, ThemeData theme) {
    return MaxWidthBox(
      maxWidth: 800,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: () => _showAddCardDialog(context, state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                    foregroundColor: AppColors.accentTeal,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.accentTeal, width: 1.5),
                    minimumSize: Size(double.infinity, 50 * context.fontSizeFactor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 20 * context.fontSizeFactor),
                      const SizedBox(width: 8),
                      Text(state.translate("Add New Card", "Ku dar Kaadh Cusub", ar: "إضافة بطاقة جديدة", de: "Neue Karte hinzufügen"), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: MaxWidthBox(
                maxWidth: 400,
                child: GestureDetector(
                  onTap: _flipCard,
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: _showBack ? 180 : 0),
                    builder: (context, double value, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(value * pi / 180),
                        child: value <= 90 ? _buildCardFront(context, state) : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi), child: _buildCardBack(context, state)),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickAction(context, state, "Deposit", state.translate("Deposit", "Dhigasho", ar: "إيداع", de: "Einzahlung"), Icons.add_circle_outline_rounded, AppColors.accentTeal, const DepositScreen()),
                  const SizedBox(width: 10),
                  _buildQuickAction(context, state, "Withdraw", state.translate("Withdraw", "Kala Bax", ar: "سحب", de: "Abheben"), Icons.file_upload_outlined, Colors.orange, const WithdrawScreen()),
                  const SizedBox(width: 10),
                  _buildQuickAction(context, state, "Savings", state.translate("Savings", "Kayd", ar: "مدخرات", de: "Ersparnisse"), Icons.account_balance_outlined, Colors.blue, const SavingsScreen()),
                  const SizedBox(width: 10),
                  _buildQuickAction(context, state, "Invest", state.translate("Invest", "Maalgashi", ar: "استثمار", de: "Investieren"), Icons.auto_graph_rounded, Colors.purple, const InvestmentsScreen()),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildFinancialInsights(context, state, theme),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(state.translate("Transactions", "Dhaqdhaqaaqa", ar: "المعاملات", de: "Transaktionen"), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("All", true),
                  _buildFilterChip("Shopping", false),
                  _buildFilterChip("Food", false),
                  _buildFilterChip("Subscriptions", false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTxItem(context, state, "Netflix", "Oct 24", r"-$15.99", true),
            _buildTxItem(context, state, "Amazon", "Oct 22", r"-$124.50", true),
            _buildTxItem(context, state, "Topup", "Oct 20", r"+$500.00", false),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(BuildContext context, AppState state) {
    return GlassmorphicContainer(
      width: double.infinity, height: 200 * context.fontSizeFactor, borderRadius: 24, blur: 20, alignment: Alignment.bottomCenter, border: 2,
      linearGradient: LinearGradient(colors: [_isFrozen ? Colors.grey.shade800 : AppColors.primaryDark.withValues(alpha: 0.9), _isFrozen ? Colors.grey.shade600 : AppColors.accentTeal.withValues(alpha: 0.6)]),
      borderGradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.2)]),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32), Text("VISA", style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 20))]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_showNumber ? "4580 1234 5678 9012" : "**** **** **** 4580", style: const TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 18)),
                Row(children: [IconButton(onPressed: () => _copyCardNumber(context, state), icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20)), IconButton(onPressed: _toggleShowNumber, icon: Icon(_showNumber ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70, size: 20))]),
              ],
            ),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("KHADAR RAYAALE", style: TextStyle(color: Colors.white, letterSpacing: 1)), Text("12/26", style: TextStyle(color: Colors.white))]),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, AppState state) {
    return GlassmorphicContainer(
      width: double.infinity, height: 200 * context.fontSizeFactor, borderRadius: 24, blur: 20, alignment: Alignment.center, border: 2,
      linearGradient: LinearGradient(colors: [_isFrozen ? Colors.grey.shade800 : AppColors.primaryDark.withValues(alpha: 0.9), _isFrozen ? Colors.grey.shade600 : AppColors.accentTeal.withValues(alpha: 0.6)]),
      borderGradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.2)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(height: 44, width: double.infinity, color: Colors.black87), const SizedBox(height: 24), Container(height: 34, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), alignment: Alignment.center, child: const Text("455", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))]),
    );
  }

  Widget _buildFinancialInsights(BuildContext context, AppState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(child: PieChart(PieChartData(sectionsSpace: 4, centerSpaceRadius: 30, sections: [PieChartSectionData(color: AppColors.accentTeal, value: 30, title: '30%'), PieChartSectionData(color: Colors.orange, value: 20, title: '20%'), PieChartSectionData(color: Colors.blue, value: 50, title: '50%')]))),
                const SizedBox(width: 16),
                Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [_legendItem(state.translate("Food", "Cunto", ar: "طعام", de: "Essen"), AppColors.accentTeal), _legendItem(state.translate("Shopping", "Adeegasho", ar: "تسوق", de: "Einkaufen"), Colors.orange), _legendItem(state.translate("Bills", "Biillasha", ar: "فواتير", de: "Rechnungen"), Colors.blue)]),
              ],
            ),
          ),
          const Divider(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(state.translate("Monthly Budget", "Miisaaniyadda Bisha", ar: "الميزانية الشهرية", de: "Monatliches Budget"), style: const TextStyle(fontWeight: FontWeight.bold)), Text(r"$850 / $1000", style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor))]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: 0.85, minHeight: 8, backgroundColor: Colors.black12, valueColor: AlwaysStoppedAnimation(Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) => Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 12))]);

  Widget _buildQuickAction(BuildContext context, AppState state, String title, String translatedTitle, IconData icon, Color color, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        width: 85 * context.fontSizeFactor, padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22)), const SizedBox(height: 8), Text(translatedTitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildTxItem(BuildContext context, AppState state, String title, String date, String amt, bool neg) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: neg ? Colors.red.withValues(alpha: 0.1) : AppColors.accentTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(neg ? Icons.shopping_bag_outlined : Icons.add_circle_outline, color: neg ? Colors.red : AppColors.accentTeal, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(date, style: const TextStyle(color: AppColors.grey, fontSize: 12))])),
          Text(amt, style: TextStyle(fontWeight: FontWeight.bold, color: neg ? null : AppColors.accentTeal)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool sel) => Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(label), selected: sel, onSelected: (_) {}, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  void _showCardSettings(BuildContext context, AppState state) {
    showModalBottomSheet(context: context, builder: (_) => Container(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.lock_outline), title: Text(state.translate("Change PIN", "Beddel PIN-ka", ar: "تغيير رمز PIN", de: "PIN ändern"))), ListTile(leading: const Icon(Icons.ac_unit), title: Text(_isFrozen ? state.translate("Unfreeze", "Ka qaad xanibaadda", ar: "إلغاء التجميد", de: "Entsperren") : state.translate("Freeze", "Xanib", ar: "تجميد", de: "Einfrieren")), onTap: () { setState(() => _isFrozen = !_isFrozen); Navigator.pop(context); })])));
  }

  void _showAddCardDialog(BuildContext context, AppState state) {
    showModalBottomSheet(context: context, builder: (_) => Container(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.add_card), title: Text(state.translate("Order Virtual Card", "Dalbo Kaadh Virtual ah", ar: "طلب بطاقة افتراضية", de: "Virtuelle Karte bestellen"))), ListTile(leading: const Icon(Icons.link), title: Text(state.translate("Link Physical Card", "Ku xidh Kaadh Jirka ah", ar: "ربط بطاقة فعلية", de: "Physische Karte verknüpfen")))])));
  }
}
