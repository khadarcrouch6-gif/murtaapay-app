import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/success_screen.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import '../more/investments_screen.dart';
import '../more/savings_screen.dart';
import '../deposit/deposit_card_screen.dart';
import '../../core/widgets/card_receipt_view.dart';
import '../withdraw/withdraw_screen.dart';
import '../../l10n/app_localizations.dart';
import 'models/card_model.dart';
import 'widgets/elite_virtual_card.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;
  bool _showBack = false;
  bool _showNumber = false;
  bool _isSearching = false;
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  final List<VirtualCard> _cards = [
    VirtualCard(
      id: "1",
      cardNumber: "4580123456789012",
      cardHolder: "KHADAR RAYAALE",
      expiryDate: "12/28",
      cvv: "455",
      theme: CardThemeType.obsidian,
      network: CardNetwork.visa,
    ),
    VirtualCard(
      id: "2",
      cardNumber: "5241987654321098",
      cardHolder: "KHADAR RAYAALE",
      expiryDate: "05/30",
      cvv: "822",
      theme: CardThemeType.gold,
      network: CardNetwork.mastercard,
    ),
    VirtualCard(
      id: "3",
      cardNumber: "4000111122223333",
      cardHolder: "KHADAR RAYAALE",
      expiryDate: "08/29",
      cvv: "109",
      theme: CardThemeType.emerald,
      network: CardNetwork.visa,
    ),
     VirtualCard(
      id: "4",
      cardNumber: "4912776655443322",
      cardHolder: "KHADAR RAYAALE",
      expiryDate: "03/31",
      cvv: "331",
      theme: CardThemeType.midnight,
      network: CardNetwork.amex,
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
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: _cards[_currentIndex].cardNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.cardNumberCopied),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.accentTeal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final filteredTransactions = state.transactions.where((tx) {
      final matchesSearch = tx.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == "All" || tx.category == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ResponsiveBreakpoints.of(context).equals(TABLET)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu_rounded, color: theme.iconTheme.color),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.horizontalPadding, 16, context.horizontalPadding, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.myCards,
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
            Expanded(child: _buildCardsTab(context, state, theme, filteredTransactions)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsTab(BuildContext context, AppState state, ThemeData theme, List<dynamic> filteredTransactions) {
    final l10n = AppLocalizations.of(context)!;
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
                  onPressed: () => _showNewCardDialog(context, state),
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
                      Text(l10n.addNewCard, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // --- CAROUSEL ---
            if (_cards.isEmpty)
              Container(
                height: 230 * context.fontSizeFactor,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.credit_card_off_rounded, size: 48 * context.fontSizeFactor, color: Colors.grey.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(l10n.noActiveCards, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              Scrollbar(
                controller: _pageController,
                thumbVisibility: true,
                thickness: 3,
                radius: const Radius.circular(10),
                child: Container(
                  height: 245 * context.fontSizeFactor,
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                    ),
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
                ),
              ),
            
            const SizedBox(height: 16),
            if (_cards.isNotEmpty)
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
            if (_cards.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildQuickAction(context, state, "Deposit", l10n.deposit, Icons.add_circle_outline_rounded, AppColors.accentTeal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositCardScreen(amount: "0", currencyCode: "USD")))),
                                const SizedBox(width: 8),
                                _buildQuickAction(context, state, "Withdraw", l10n.withdraw, Icons.file_upload_outlined, Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen()))),
                                const SizedBox(width: 8),
                                _buildQuickAction(context, state, "Savings", l10n.savings, Icons.account_balance_outlined, Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()))),
                                const SizedBox(width: 8),
                                _buildQuickAction(context, state, "Invest", l10n.invest, Icons.auto_graph_rounded, Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentsScreen()))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildFinancialInsights(context, state, theme),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!_isSearching)
                          Text(l10n.transactions, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
                        else
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: l10n.searchTransactions,
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                              ),
                              style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                              onChanged: (value) => setState(() => _searchQuery = value),
                            ),
                          ),
                        IconButton(
                          onPressed: () => setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _searchQuery = "";
                            }
                          }),
                          icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(l10n.all, _selectedFilter == "All", (sel) => setState(() => _selectedFilter = "All")),
                          _buildFilterChip(l10n.shopping, _selectedFilter == "Shopping", (sel) => setState(() => _selectedFilter = "Shopping")),
                          _buildFilterChip(l10n.food, _selectedFilter == "Food", (sel) => setState(() => _selectedFilter = "Food")),
                          _buildFilterChip(l10n.subscriptions, _selectedFilter == "Subscriptions", (sel) => setState(() => _selectedFilter = "Subscriptions")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        return _buildTxItem(
                          context, 
                          state, 
                          tx.title, 
                          tx.date, 
                          tx.amount, 
                          tx.isNegative,
                          onTap: () => CardReceiptView.show(context, tx.toJson()),
                        );
                      },
                    ),
                    if (filteredTransactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(l10n.noTransactionsFound, style: TextStyle(color: AppColors.grey)),
                        ),
                      ),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          SizedBox(
            height: 150 * context.fontSizeFactor,
            child: Row(
              children: [
                Expanded(child: PieChart(PieChartData(sectionsSpace: 4, centerSpaceRadius: 30 * context.fontSizeFactor, sections: [PieChartSectionData(color: AppColors.accentTeal, value: 30, title: '30%', titleStyle: TextStyle(fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.white)), PieChartSectionData(color: Colors.orange, value: 20, title: '20%', titleStyle: TextStyle(fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.white)), PieChartSectionData(color: Colors.blue, value: 50, title: '50%', titleStyle: TextStyle(fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.white))]))),
                const SizedBox(width: 16),
                Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [_legendItem(context, l10n.food, AppColors.accentTeal), _legendItem(context, l10n.shopping, Colors.orange), _legendItem(context, l10n.billsLabel, Colors.blue)]),
              ],
            ),
          ),
          const Divider(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l10n.monthlyBudget, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)), Text(r"$850 / $1000", style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor))]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: 0.85, minHeight: 8, backgroundColor: Colors.black12, valueColor: AlwaysStoppedAnimation(Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _legendItem(BuildContext context, String label, Color color) => Row(children: [Container(width: 8 * context.fontSizeFactor, height: 8 * context.fontSizeFactor, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 12 * context.fontSizeFactor))]);

  Widget _buildQuickAction(BuildContext context, AppState state, String title, String translatedTitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90 * context.fontSizeFactor, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22 * context.fontSizeFactor)), 
            const SizedBox(height: 8), 
            Flexible(child: Text(translatedTitle, style: TextStyle(fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis))
          ],
        ),
      ),
    );
  }

  Widget _buildTxItem(BuildContext context, AppState state, String title, String date, String amt, bool neg, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: neg ? Colors.red.withValues(alpha: 0.1) : AppColors.accentTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(neg ? Icons.shopping_bag_outlined : Icons.add_circle_outline, color: neg ? Colors.red : AppColors.accentTeal, size: 20 * context.fontSizeFactor)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)), Text(date, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor))])),
            Text(amt, style: TextStyle(fontWeight: FontWeight.bold, color: neg ? null : AppColors.accentTeal, fontSize: 14 * context.fontSizeFactor)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool sel, ValueChanged<bool> onSelected) => Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(label), selected: sel, onSelected: onSelected, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), selectedColor: AppColors.accentTeal.withValues(alpha: 0.2), checkmarkColor: AppColors.accentTeal));

  void _showCardSettings(BuildContext context, AppState state) {
    final currentCard = _cards[_currentIndex];
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
<<<<<<< HEAD
    
    // First, verify Virtual Card PIN (1122)
    _showPinVerification(context, state, l10n, (isVerified) {
      if (isVerified) {
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
                colors: isDark 
                    ? [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]
                    : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
=======
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (stateCtx, setModalState) => GlassmorphicContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.82,
          borderRadius: 24,
          blur: 30,
          alignment: Alignment.topCenter,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [AppColors.primaryDark.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.85)]
                : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
          ),
          borderGradient: LinearGradient(
            colors: [
              (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.2), 
              (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.05)
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.cardSettings,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
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
                          ? l10n.frozen
                          : l10n.active,
                        style: TextStyle(color: currentCard.isFrozen ? Colors.orange : AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
>>>>>>> 3c1539c38d50365477a915f750f3576a122df531
              ),
              borderGradient: LinearGradient(
                colors: [
                  (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.2), 
                  (isDark ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.05)
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.cardSettings,
                          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
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
                              ? l10n.frozen
                              : l10n.active,
                            style: TextStyle(color: currentCard.isFrozen ? Colors.orange : AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
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
                          _buildSectionTitle(context, l10n.security, isDark),
                          _buildSettingsTile(
                            context: context,
                            isDark: isDark,
                            icon: Icons.ac_unit_rounded,
                            color: Colors.blue,
                            title: currentCard.isFrozen 
                              ? l10n.unfreezeCard
                              : l10n.freezeCard,
                            subtitle: l10n.temporarilyDisablePayments,
                            onTap: () {
                              setState(() {
                                _cards[_currentIndex] = currentCard.copyWith(isFrozen: !currentCard.isFrozen);
                              });
                              setModalState(() {});
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle(context, l10n.cardControls, isDark),
                          _buildSwitchTile(
                            context: context,
                            isDark: isDark,
                            icon: Icons.shopping_basket_outlined,
                            color: Colors.teal,
                            title: l10n.onlinePayments,
                            value: currentCard.allowOnline,
                            onChanged: (v) {
                              setState(() => _cards[_currentIndex] = currentCard.copyWith(allowOnline: v));
                              setModalState(() {});
                            },
                          ),
                          _buildSwitchTile(
                            context: context,
                            isDark: isDark,
                            icon: Icons.public_rounded,
                            color: Colors.orange,
                            title: l10n.internationalUsage,
                            value: currentCard.allowInternational,
                            onChanged: (v) {
                              setState(() => _cards[_currentIndex] = currentCard.copyWith(allowInternational: v));
                              setModalState(() {});
                            },
                          ),
                          _buildSwitchTile(
                            context: context,
                            isDark: isDark,
                            icon: Icons.contactless_rounded,
                            color: Colors.purple,
                            title: l10n.contactlessPayments,
                            value: currentCard.allowContactless,
                            onChanged: (v) {
                              setState(() => _cards[_currentIndex] = currentCard.copyWith(allowContactless: v));
                              setModalState(() {});
                            },
                          ),
                          const SizedBox(height: 32),
                          _buildSettingsTile(
                            context: context,
                            isDark: isDark,
                            icon: Icons.delete_forever_rounded,
                            color: Colors.redAccent,
                            title: l10n.terminateCard,
                            subtitle: l10n.permanentlyDeleteCard,
                            onTap: () => _showTerminateConfirmation(context, l10n),
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
    });
  }

  void _showPinVerification(BuildContext context, AppState state, AppLocalizations l10n, Function(bool) onResult) {
    final TextEditingController pinController = TextEditingController();
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.cardPin, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.translate("Fadlan geli PIN-ka kaadhka si aad u sii wadato.", "Please enter card PIN to continue."), style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor)),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onResult(false);
            },
            child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (state.verifyCardPin(pinController.text)) {
                Navigator.pop(context);
                onResult(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.translate("PIN-kaagu waa khalad.", "PIN-kaagu waa khalad.")), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTerminateConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(l10n.terminateCard, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
          content: Text(
            l10n.terminateCardConfirm,
            style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.cancel, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx); // Close dialog
                _processTransaction(context, l10n);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(l10n.terminateCard, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
            ),
          ],
        ),
      ),
    );
  }

  void _processTransaction(BuildContext context, AppLocalizations l10n) async {
    final theme = Theme.of(context);
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

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    
    if (!context.mounted) return;
    setState(() {
      _cards.removeAt(_currentIndex);
      if (_currentIndex >= _cards.length && _cards.isNotEmpty) {
        _currentIndex = _cards.length - 1;
      }
    });
    
    if (!context.mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Close settings bottom sheet
    }

    if (!context.mounted) return;
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          title: l10n.cardTerminated,
          message: l10n.cardTerminatedSuccess,
          subMessage: l10n.newBalance(currencyFormatter.format(AppState().balance)),
          buttonText: l10n.backToHome,
        ),
      ),
    );
  }

  Widget _walletSection(BuildContext context, AppState state, VirtualCard card) {
    if (kIsWeb) return const SizedBox.shrink();
    final bool isIOS = Platform.isIOS;
    final l10n = AppLocalizations.of(context)!;
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
            Text(isIOS ? l10n.addToAppleWallet : l10n.addToGooglePay, style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black45, fontSize: 10 * context.fontSizeFactor, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsTile({required BuildContext context, required IconData icon, required Color color, required String title, required String subtitle, VoidCallback? onTap, bool isLast = false, bool isDark = true}) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22 * context.fontSizeFactor)),
          title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 15 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 11 * context.fontSizeFactor)),
          trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black26, size: 24 * context.fontSizeFactor),
        ),
        if (!isLast) Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), indent: 64),
      ],
    );
  }

  Widget _buildSwitchTile({required BuildContext context, required IconData icon, required Color color, required String title, required bool value, required ValueChanged<bool> onChanged, bool isDark = true}) {
    return Column(
      children: [
        SwitchListTile(
          value: value,
          onChanged: onChanged,
          secondary: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22 * context.fontSizeFactor)),
          title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 15 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          activeTrackColor: AppColors.accentTeal,
        ),
        Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), indent: 64),
      ],
    );
  }

  void _showNewCardDialog(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => GlassmorphicContainer(
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
            Text(l10n.addNewCard, style: TextStyle(color: Colors.white, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: _buildSettingsTile(context: context, icon: Icons.add_card_rounded, color: AppColors.accentTeal, title: l10n.orderVirtualCard, subtitle: l10n.instantlyIssueNewCard, onTap: () => Navigator.pop(sheetCtx), isLast: true),
            ),
          ],
        ),
      ),
    );
  }
}
