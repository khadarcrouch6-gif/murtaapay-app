import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:math';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../more/investments_screen.dart';
import '../more/gift_cards_screen.dart';
import '../more/savings_screen.dart';
import '../deposit/deposit_screen.dart';
import '../withdraw/withdraw_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> with SingleTickerProviderStateMixin {
  bool _isFrozen = false;
  bool _showBack = false;
  bool _showNumber = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
      if (_showBack) _showNumber = false; 
    });
  }

  void _toggleShowNumber() {
    setState(() {
      _showNumber = !_showNumber;
    });
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42 * context.fontSizeFactor,
                    height: 42 * context.fontSizeFactor,
                    child: IconButton(
                      onPressed: () => _showCardSettings(context, state),
                      padding: EdgeInsets.zero,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.settings_outlined, color: theme.colorScheme.primary, size: 22 * context.fontSizeFactor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: theme.colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
              tabs: [
                Tab(text: state.translate("Cards", "Kaadhadhka")),
                Tab(text: state.translate("Invest", "Maal-gashi")),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCardsTab(context, state, theme),
                  const InvestmentsScreen(isTab: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsTab(BuildContext context, AppState state, ThemeData theme) {
    return Center(
      child: MaxWidthBox(
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
                        Flexible(
                          child: Text(
                            state.translate("Add New Card", "Ku dar Kaadh Cusub", ar: "إضافة بطاقة جديدة", de: "Neue Karte hinzufügen"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
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
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(value * pi / 180),
                          child: value <= 90
                              ? _buildCardFront(context, state)
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildCardBack(context, state),
                                ),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildQuickActionItem(
                        context,
                        state.translate("Deposit", "Dhigasho", ar: "إيداع", de: "Einzahlung"),
                        Icons.account_balance_wallet_rounded,
                        AppColors.accentTeal, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DepositScreen()));
                    }),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                        context,
                        state.translate("Withdraw", "La bixid", ar: "سحب", de: "Abheben"),
                        Icons.payments_rounded,
                        Colors.orange, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const WithdrawScreen()));
                    }),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                        context,
                        state.translate("Savings", "Kaydka", ar: "المدخرات", de: "Ersparnisse"),
                        Icons.savings_rounded,
                        Colors.blue, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsScreen()));
                    }),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                        context,
                        state.translate("Gift Cards", "Kaadhadhka Hadiyada", ar: "بطاقات الهدايا", de: "Geschenkkarten"),
                        Icons.redeem_rounded,
                        Colors.purple, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const GiftCardsScreen()));
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(state.translate("Card Transactions", "Dhaqdhaqaaqa Kaadhka", ar: "معاملات البطاقة", de: "Kartentransaktionen"),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
              const SizedBox(height: 16),
              _buildTransactionItem(context, state, "Netflix Subscription", "Oct 24", r"-$15.99", true, "Subscription"),
              _buildTransactionItem(context, state, "Amazon.com", "Oct 22", r"-$124.50", true, "Shopping"),
              _buildTransactionItem(context, state, "Card Topup", "Oct 20", r"+$500.00", false, "Transfer"),
              _buildTransactionItem(context, state, "Apple Store", "Oct 18", r"-$2.99", true, "Entertainment"),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    return GlassmorphicContainer(
      width: double.infinity,
      height: 200 * context.fontSizeFactor,
      borderRadius: 24,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _isFrozen ? Colors.grey.shade800 : AppColors.primaryDark.withValues(alpha: 0.9),
          _isFrozen ? Colors.grey.shade600 : AppColors.accentTeal.withValues(alpha: 0.6),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.2)],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32),
                    Text("VISA", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _showNumber ? "4580 1234 5678 9012" : "**** **** **** 4580",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white, 
                            letterSpacing: 2, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 18 * context.fontSizeFactor
                          ),
                        ),
                      ),
                    ),
                    IconButton(onPressed: _toggleShowNumber, icon: Icon(_showNumber ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70, size: 20 * context.fontSizeFactor)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "KHADAR RAYAALE", 
                        style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, letterSpacing: 1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("12/26", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          if (_isFrozen) Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)), child: Text("FROZEN", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, AppState state) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 200 * context.fontSizeFactor,
      borderRadius: 24,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _isFrozen ? Colors.grey.shade800 : AppColors.primaryDark.withValues(alpha: 0.9),
          _isFrozen ? Colors.grey.shade600 : AppColors.accentTeal.withValues(alpha: 0.6),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.2)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 44, width: double.infinity, color: Colors.black.withValues(alpha: 0.8)),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    height: 34, 
                    width: 80 * context.fontSizeFactor, 
                    constraints: BoxConstraints(maxWidth: 100 * context.fontSizeFactor),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), 
                    alignment: Alignment.centerRight, 
                    padding: const EdgeInsets.only(right: 8), 
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("455", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14 * context.fontSizeFactor))
                    )
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "CVV", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: 14 * context.fontSizeFactor
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100 * context.fontSizeFactor,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24 * context.fontSizeFactor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12 * context.fontSizeFactor,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleMedium?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showCardSettings(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(
                state.translate("Card Settings", "Dejinta Kaadhka",
                    ar: "إعدادات البطاقة", de: "Karteneinstellungen"),
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            _buildSettingTile(
                context,
                state.translate("Change Card PIN", "Beddel PIN-ka Kaadhka",
                    ar: "تغيير الرمز السري للبطاقة", de: "Karten-PIN ändern"),
                Icons.lock_outline_rounded,
                () {}),
            _buildSettingTile(context, _isFrozen ? "Unfreeze Card" : "Freeze Card",
                Icons.ac_unit_rounded, () {
              setState(() => _isFrozen = !_isFrozen);
              Navigator.pop(context);
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56 * context.fontSizeFactor,
              child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(state.translate("Close", "Xidh", ar: "إغلاق", de: "Schließen"))),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(state.translate("Add New Card", "Ku dar Kaadh Cusub", ar: "إضافة بطاقة جديدة", de: "Neue Karte hinzufügen"), style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            _buildSettingTile(context, "Order Virtual Card", Icons.add_card_rounded, () {}),
            _buildSettingTile(context, "Link Physical Card", Icons.link_rounded, () {}),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pop(context), 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400]),
              child: const Text("Cancel")),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: theme.colorScheme.primary, size: 20)),
      title: Text(
        title, 
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
      onTap: onTap,
    );
  }

  Widget _buildTransactionItem(BuildContext context, AppState state, String title, String date, String amount, bool isNegative, String category) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showTransactionDetail(context, state, title, date, amount, isNegative, category),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isNegative ? Colors.red.withValues(alpha: 0.1) : AppColors.accentTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(isNegative ? Icons.shopping_bag_outlined : Icons.add_circle_outline, color: isNegative ? Colors.red : AppColors.accentTeal, size: 20 * context.fontSizeFactor)),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(
                    title, 
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ), 
                  Text(
                    date, 
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)
                  )
                ]
              )
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: Text(
                amount, 
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16 * context.fontSizeFactor, 
                  color: isNegative ? theme.textTheme.bodyLarge?.color : AppColors.accentTeal
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, AppState state, String title, String date, String amount, bool isNegative, String category) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 32),
            _buildDetailRow("Amount", amount),
            _buildDetailRow("Date", date),
            _buildDetailRow("Category", category),
            _buildDetailRow("Status", "Success"),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: () => Navigator.pop(context), 
              child: const Text("Close")),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label, 
              style: const TextStyle(color: AppColors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value, 
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

