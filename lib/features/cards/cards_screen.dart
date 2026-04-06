import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:io' show Platform;
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
                child: Column(
                  children: [
                    GestureDetector(
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
                    const SizedBox(height: 16),
                    _buildWalletButtons(context, state),
                  ],
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
    return Container(
      width: double.infinity,
      height: 200 * context.fontSizeFactor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryDark.withValues(alpha: 0.8), AppColors.accentTeal.withValues(alpha: 0.6)],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Chip and Murtaax Pay Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 45,
                      height: 35,
                      child: CustomPaint(painter: RealisticCardChipPainter()),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/walletlogo.png", 
                          width: 18, 
                          height: 18, 
                          color: Colors.white,
                          errorBuilder: (c, e, s) => const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Murtaax Pay", 
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 14, 
                            letterSpacing: -0.5
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                // Middle Row: Card Number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _showNumber ? "4580 1234 5678 9012" : "**** **** **** 4580",
                          style: const TextStyle(
                            color: Colors.white,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'monospace', // Card-like font
                            shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        IconButton(onPressed: () => _copyCardNumber(context, state), icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 18)),
                        IconButton(onPressed: _toggleShowNumber, icon: Icon(_showNumber ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70, size: 18)),
                      ],
                    ),
                  ],
                ),
                // Bottom Row: Name and Expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.translate("Card Holder", "Milkiilaha", ar: "صاحب البطاقة", de: "Karteninhaber").toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, letterSpacing: 1)),
                        const Text("KHADAR RAYAALE", style: TextStyle(color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(state.translate("Expires", "Dhicitaanka", ar: "تنتهي في", de: "Ablauf").toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, letterSpacing: 1)),
                        const Text("12/26", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Frosted Ice Overlay (Frozen State)
          if (_isFrozen)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: const Icon(Icons.lock_rounded, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              state.translate("FROZEN", "XANIBAN", ar: "مجمدة", de: "GESPERRT"),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, AppState state) {
    return Container(
      width: double.infinity,
      height: 200 * context.fontSizeFactor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: _isFrozen ? [Colors.grey.shade800, Colors.grey.shade900] : [AppColors.primaryDark, AppColors.primaryDark.withValues(alpha: 0.9)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Container(height: 45, width: double.infinity, color: Colors.black),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 140,
                  height: 35,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(4)),
                  child: const Center(child: Text("•••• •••• •••• ••••", style: TextStyle(color: Colors.grey, letterSpacing: 2))),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 35,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  alignment: Alignment.center,
                  child: const Text("455", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Customer Service: +123 456 789\nMurtaaxPay Virtual Card is issued by MurtaaxPay Bank.",
              style: TextStyle(color: Colors.white24, fontSize: 8),
            ),
          ),
        ],
      ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GlassmorphicContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.7,
          borderRadius: 24,
          blur: 30,
          alignment: Alignment.topCenter,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)],
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              // Header & Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.translate("Card Settings", "Meelaha Kaadhka", ar: "إعدادات البطاقة", de: "Karteneinstellungen"),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (_isFrozen ? Colors.orange : AppColors.accentTeal).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: (_isFrozen ? Colors.orange : AppColors.accentTeal).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isFrozen ? Icons.lock_clock_rounded : Icons.check_circle_rounded,
                            size: 14,
                            color: _isFrozen ? Colors.orange : AppColors.accentTeal,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isFrozen 
                              ? state.translate("Frozen", "Xaniban", ar: "مجمدة", de: "Eingefroren")
                              : state.translate("Active", "Shaqaynaya", ar: "نشطة", de: "Aktiv"),
                            style: TextStyle(
                              color: _isFrozen ? Colors.orange : AppColors.accentTeal,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(state.translate("Security", "Ammaanka", ar: "الأمان", de: "Sicherheit")),
                      _buildSettingsTile(
                        icon: Icons.ac_unit_rounded,
                        color: Colors.blue,
                        title: _isFrozen 
                          ? state.translate("Unfreeze Card", "Ka qaad Xanibaadda", ar: "إلغاء تجميد البطاقة", de: "Karte entsperren")
                          : state.translate("Freeze Card", "Xanib Kaadhka", ar: "تجمid البطاقة", de: "Karte sperren"),
                        subtitle: state.translate("Temporarily disable payments", "Hadda si kumeelgaar ah u xir", ar: "تعطيل المدفوعات مؤقتاً", de: "Zahlungen vorübergehend deaktivieren"),
                        onTap: () {
                          setState(() => _isFrozen = !_isFrozen);
                          setModalState(() {});
                          Navigator.pop(context);
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        color: Colors.orange,
                        title: state.translate("Change PIN", "Beddel PIN-ka", ar: "تغيير رمز PIN", de: "PIN ändern"),
                        subtitle: state.translate("Update your card security code", "Beddel lambarka qarsoodiga ah", ar: "تحديث رمز الأمان الخاص بك", de: "Aktualisieren Sie Ihren Sicherheitscode"),
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle(state.translate("Card Management", "Maamulka Kaadhka", ar: "إدارة البطاقة", de: "Kartenverwaltung")),
                      _buildSettingsTile(
                        icon: Icons.speed_rounded,
                        color: Colors.teal,
                        title: state.translate("Spending Limits", "Xadka Kharashka", ar: "حدود الإنفاق", de: "Ausgabenlimits"),
                        subtitle: state.translate("Set daily or monthly limits", "Hubi inta aad bixin karto", ar: "تعيين الحدود اليومية أو الشهرية", de: "Tägliche oder monatliche Limits festlegen"),
                        onTap: () {
                          Navigator.pop(context); // Close settings
                          _showSpendingLimitsDialog(context, state);
                        },
                      ),
                      _buildSettingsTile(
                        icon: Icons.contactless_rounded,
                        color: Colors.purple,
                        title: state.translate("Contactless Payments", "Lacag-bixinta Taabashada", ar: "مدفوعات بدون تلامس", de: "Kontaktloses Bezahlen"),
                        subtitle: state.translate("Enable/Disable tap to pay", "Oggolow bixinta bilaa taabashada", ar: "تمكين/تعطيل النقر للدفع", de: "Kontaktloses Bezahlen aktivieren/deaktivieren"),
                        trailing: Switch(
                          value: true,
                          onChanged: (v) {},
                          activeColor: AppColors.accentTeal,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle(state.translate("Danger Zone", "Qaybta Khatarta", ar: "منطقة الخطر", de: "Gefahrenzone")),
                      _buildSettingsTile(
                        icon: Icons.delete_forever_rounded,
                        color: Colors.redAccent,
                        title: state.translate("Terminate Card", "Tirtir Kaadhka", ar: "إلغاء البطاقة", de: "Karte kündigen"),
                        subtitle: state.translate("Permanently delete this virtual card", "Si rasmi ah u tirtir kaadhkan", ar: "حذف هذه البطاقة الافتراضية بشكل دائم", de: "Diese virtuelle Karte dauerhaft löschen"),
                        onTap: () {},
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWalletButtons(BuildContext context, AppState state) {
    final isIOS = Platform.isIOS;
    return Center(
      child: MaxWidthBox(
        maxWidth: 300,
        child: isIOS 
          ? _walletButton(
              "Apple Wallet",
              Icons.apple,
              Colors.black,
              () => _showWalletConfirm(context, state, "Apple Wallet"),
            )
          : _walletButton(
              "Google Pay",
              Icons.g_mobiledata_rounded,
              Colors.blue.shade900,
              () => _showWalletConfirm(context, state, "Google Pay"),
            ),
      ),
    );
  }

  Widget _walletButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label == "Apple Wallet" ? "Add to Apple Wallet" : "Add to Google Pay",
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletConfirm(BuildContext context, AppState state, String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.translate("Connecting to $platform...", "Hadda waxaan ku xireynaa $platform...", ar: "جاري الاتصال بـ $platform...", de: "Verbindung zu $platform wird hergestellt...")),
        backgroundColor: AppColors.accentTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
          trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2)),
        ),
        if (!isLast) Divider(color: Colors.white.withValues(alpha: 0.05), indent: 64, endIndent: 12),
      ],
    );
  }

  void _showAddCardDialog(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 320 * context.fontSizeFactor,
        borderRadius: 24,
        blur: 30,
        alignment: Alignment.topCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(
              state.translate("Add New Card", "Ku dar Kaadh Cusub", ar: "إضافة بطاقة جديدة", de: "Neue Karte hinzufügen"),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.add_card_rounded,
                    color: AppColors.accentTeal,
                    title: state.translate("Order Virtual Card", "Dalbo Kaadh Virtual ah", ar: "طلب بطاقة افتراضية", de: "Virtuelle Karte bestellen"),
                    subtitle: state.translate("Instantly issue a new digital card", "Hadda hel kaadhkaaga online-ka ah", ar: "إصدار بطاقة رقمية جديدة على الفور", de: "Sofort eine neue digitale Karte ausstellen"),
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildSettingsTile(
                    icon: Icons.link_rounded,
                    color: Colors.blue,
                    title: state.translate("Link Physical Card", "Ku xidh Kaadh Jirka ah", ar: "ربط بطاقة فعلية", de: "Physische Karte verknüpfen"),
                    subtitle: state.translate("Connect your plastic MurtaaxPay card", "Ku xidho kaadhkaaga caadiga ah", ar: "ربط بطاقتك البلاستيكية من MurtaaxPay", de: "Verknüpfen Sie Ihre physische MurtaaxPay-Karte"),
                    onTap: () => Navigator.pop(context),
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpendingLimitsDialog(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 480 * context.fontSizeFactor,
        borderRadius: 24,
        blur: 30,
        alignment: Alignment.topCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(
              state.translate("Spending Limits", "Xadka Kharashka", ar: "حدود الإنفاق", de: "Ausgabenlimits"),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _limitItem(context, state, "Daily Limit", r"$500 / $1000", 0.5, Colors.teal),
                    const SizedBox(height: 32),
                    _limitItem(context, state, "Monthly Limit", r"$3,200 / $5,000", 0.64, Colors.blue),
                    const SizedBox(height: 32),
                    _limitItem(context, state, "Online Shopping", r"$1,200 / $2,000", 0.6, Colors.orange),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        state.translate("Save Changes", "Keydi Isbedellada", ar: "حفظ التغييرات", de: "Änderungen speichern"),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _limitItem(BuildContext context, AppState state, String title, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(value, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class RealisticCardChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.yellow.shade200, Colors.yellow.shade700, Colors.yellow.shade900],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(6));
    canvas.drawRRect(rrect, paint);

    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw chip lines for realism
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), linePaint);
    canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.65, size.height), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width * 0.3, size.height * 0.33), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.66), Offset(size.width * 0.3, size.height * 0.66), linePaint);
    canvas.drawLine(Offset(size.width * 0.65, size.height * 0.5), Offset(size.width, size.height * 0.5), linePaint);
    
    // Middle vertical cut
    canvas.drawRRect(RRect.fromLTRBR(size.width * 0.35, size.height * 0.2, size.width * 0.6, size.height * 0.8, const Radius.circular(2)), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
