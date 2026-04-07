import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:io' show Platform;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../more/investments_screen.dart';
import '../more/savings_screen.dart';
import '../deposit/deposit_screen.dart';
import '../withdraw/withdraw_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'models/card_model.dart';
import 'widgets/elite_virtual_card.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;
  bool _showBack = false;
  bool _showNumber = false;

  final List<VirtualCard> _cards = [
    VirtualCard(
      id: "1",
      cardNumber: "4580123456789012",
      cardHolder: "KHADAR RAYAALE",
      expiryDate: "12/28",
      cvv: "455",
      theme: CardThemeType.obsidian,
    ),
    VirtualCard(
      id: "2",
      cardNumber: "5241987654321098",
      cardHolder: "KHADAR RAYAALE",
      expiryDate: "05/30",
      cvv: "822",
      theme: CardThemeType.gold,
    ),
    VirtualCard(
      id: "3",
      cardNumber: "4000111122223333",
      cardHolder: "KHADAR RAYAALE",
      expiryDate: "08/29",
      cvv: "109",
      theme: CardThemeType.emerald,
    ),
     VirtualCard(
      id: "4",
      cardNumber: "4912776655443322",
      cardHolder: "KHADAR RAYAALE",
      expiryDate: "03/31",
      cvv: "331",
      theme: CardThemeType.midnight,
    ),
  ];

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
    Clipboard.setData(ClipboardData(text: _cards[_currentIndex].cardNumber));
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
        padding: EdgeInsets.symmetric(vertical: context.verticalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                child: ElevatedButton(
                  onPressed: () => _showAddCardDialog(context, state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                    foregroundColor: AppColors.accentTeal,
                    elevation: 0,
                    side: const BorderSide(color: AppColors.accentTeal, width: 1.5),
                    minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
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
            const SizedBox(height: 24),
            
            // --- CAROUSEL ---
            SizedBox(
              height: 230 * context.fontSizeFactor,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
                onPageChanged: (index) => setState(() {
                  _currentIndex = index;
                  _showBack = false;
                  _showNumber = false;
                }),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                      }
                      return Center(
                        child: Transform.scale(
                          scale: Curves.easeOut.transform(value),
                          child: Opacity(
                            opacity: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: EliteVirtualCard(
                                card: _cards[index],
                                showNumber: _showNumber,
                                showBack: _showBack,
                                onFlip: _flipCard,
                                onToggleShowNumber: _toggleShowNumber,
                                onCopyNumber: () => _copyCardNumber(context, state),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _cards.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: AppColors.accentTeal,
                  dotColor: Colors.grey,
                  dotHeight: 6,
                  dotWidth: 6,
                  expansionFactor: 4,
                  spacing: 4,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
              child: Column(
                children: [
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
          ],
        ),
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
    final currentCard = _cards[_currentIndex];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GlassmorphicContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.82,
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
                        color: (currentCard.isFrozen ? Colors.orange : AppColors.accentTeal).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: (currentCard.isFrozen ? Colors.orange : AppColors.accentTeal).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        currentCard.isFrozen 
                          ? state.translate("Frozen", "Xaniban", ar: "مجمدة", de: "Eingefroren")
                          : state.translate("Active", "Shaqaynaya", ar: "نشطة", de: "Aktiv"),
                        style: TextStyle(color: currentCard.isFrozen ? Colors.orange : AppColors.accentTeal, fontSize: 12, fontWeight: FontWeight.bold),
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
                      _walletSection(context, state, currentCard),
                      const SizedBox(height: 24),
                      _buildSectionTitle(state.translate("Security", "Ammaanka", ar: "الأمان", de: "Sicherheit")),
                      _buildSettingsTile(
                        icon: Icons.ac_unit_rounded,
                        color: Colors.blue,
                        title: currentCard.isFrozen 
                          ? state.translate("Unfreeze Card", "Ka qaad Xanibaadda", ar: "إلغاء تجميد البطاقة", de: "Karte entsperren")
                          : state.translate("Freeze Card", "Xanib Kaadhka", ar: "تجمid البطاقة", de: "Karte sperren"),
                        subtitle: state.translate("Temporarily disable payments", "Hadda si kumeelgaar ah u xir", ar: "تعطيل المدفوعات مؤقتاً", de: "Zahlungen vorübergehend deaktivieren"),
                        onTap: () {
                          setState(() {
                            _cards[_currentIndex] = currentCard.copyWith(isFrozen: !currentCard.isFrozen);
                          });
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle(state.translate("Card Controls", "Maamulka Kaadhka", ar: "إدارة البطاقة", de: "Kartenverwaltung")),
                      _buildSwitchTile(
                        icon: Icons.shopping_basket_outlined,
                        color: Colors.teal,
                        title: state.translate("Online Payments", "Lacag-bixinta Online-ka", ar: "المدفوعات عبر الإنترنت", de: "Online-Zahlungen"),
                        value: currentCard.allowOnline,
                        onChanged: (v) {
                          setState(() => _cards[_currentIndex] = currentCard.copyWith(allowOnline: v));
                          setModalState(() {});
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.public_rounded,
                        color: Colors.orange,
                        title: state.translate("International Usage", "Isticmaalka Caalamiga ah", ar: "الاستخدام الدولي", de: "Internationale Nutzung"),
                        value: currentCard.allowInternational,
                        onChanged: (v) {
                          setState(() => _cards[_currentIndex] = currentCard.copyWith(allowInternational: v));
                          setModalState(() {});
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.contactless_rounded,
                        color: Colors.purple,
                        title: state.translate("Contactless Payments", "Lacag-bixinta Taabashada", ar: "مدفوعات بدون تلامس", de: "Kontaktloses Bezahlen"),
                        value: currentCard.allowContactless,
                        onChanged: (v) {
                          setState(() => _cards[_currentIndex] = currentCard.copyWith(allowContactless: v));
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(height: 32),
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

  Widget _walletSection(BuildContext context, AppState state, VirtualCard card) {
    final isIOS = Platform.isIOS;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.accentTeal, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isIOS ? Icons.apple : Icons.g_mobiledata_rounded, color: AppColors.accentTeal),
            const SizedBox(width: 12),
            Text(isIOS ? "Add to Apple Wallet" : "Add to Google Pay", style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
          ],
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

  Widget _buildSettingsTile({required IconData icon, required Color color, required String title, required String subtitle, VoidCallback? onTap, bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
          trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2)),
        ),
        if (!isLast) Divider(color: Colors.white.withValues(alpha: 0.05), indent: 64),
      ],
    );
  }

  Widget _buildSwitchTile({required IconData icon, required Color color, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Column(
      children: [
        SwitchListTile(
          value: value,
          onChanged: onChanged,
          secondary: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          activeColor: AppColors.accentTeal,
        ),
        Divider(color: Colors.white.withValues(alpha: 0.05), indent: 64),
      ],
    );
  }

  void _showAddCardDialog(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 320,
        borderRadius: 24,
        blur: 30,
        alignment: Alignment.topCenter,
        border: 2,
        linearGradient: LinearGradient(colors: [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]),
        borderGradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)]),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(state.translate("Add New Card", "Ku dar Kaadh Cusub", ar: "إضافة بطاقة جديدة", de: "Neue Karte hinzufügen"), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: _buildSettingsTile(icon: Icons.add_card_rounded, color: AppColors.accentTeal, title: "Order Virtual Card", subtitle: "Instantly issue a new digital card", onTap: () => Navigator.pop(context), isLast: true),
            ),
          ],
        ),
      ),
    );
  }
}
