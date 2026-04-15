import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/shimmer_loading.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/widgets/transaction_item.dart';
import '../send_money/send_amount_screen.dart';
import 'package:intl/intl.dart';
import '../history/history_screen.dart';
import '../cards/cards_screen.dart';
import '../bills/pay_bills_screen.dart';
import '../chat/chat_screen.dart';
import '../more/sadaqah_screen.dart';
import '../more/exchange_rates_screen.dart';

import '../deposit/deposit_screen.dart';
import '../notifications/notifications_screen.dart';
import '../analytics/analytics_screen.dart';
import '../hagbad/hagbad_screen.dart';
import '../../core/widgets/receipt_view.dart';
import '../withdraw/withdraw_screen.dart';
import '../scan/qr_scanner_screen.dart';

enum ChartType { bar, pie, line }

class QuickContact {
  final String name;
  final String avatar;
  final bool isOnline;
  QuickContact({required this.name, required this.avatar, this.isOnline = false});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isBalanceVisible = false;
  bool _isLoading = true;
  int _nameIndex = 0;
  int _charIndex = 0;
  String _displayedName = "";
  Timer? _timer;
  final List<String> _names = ["Khadar", "Abdi", "Warsame"];
  
  ChartType _selectedChartType = ChartType.bar;
  final List<double> _spendingData = [45, 80, 55, 95, 70, 40, 65];
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  final List<QuickContact> _quickContacts = [
    QuickContact(name: "Abdi", avatar: "https://i.pravatar.cc/150?u=abdi", isOnline: true),
    QuickContact(name: "Warsame", avatar: "https://i.pravatar.cc/150?u=warsame", isOnline: true),
    QuickContact(name: "Leyla", avatar: "https://i.pravatar.cc/150?u=leyla", isOnline: false),
    QuickContact(name: "Sahra", avatar: "https://i.pravatar.cc/150?u=sahra", isOnline: true),
    QuickContact(name: "Farah", avatar: "https://i.pravatar.cc/150?u=farah", isOnline: false),
    QuickContact(name: "Hassan", avatar: "https://i.pravatar.cc/150?u=hassan", isOnline: true),
  ];

  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _startNameAnimation();
    
    // Simulate initial data loading
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _startNameAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted) {
        String targetName = _names[_nameIndex];
        if (_charIndex < targetName.length) {
          setState(() {
            _displayedName = targetName.substring(0, _charIndex + 1);
            _charIndex++;
          });
        } else {
          if (_charIndex >= targetName.length + 15) {
            setState(() {
              _nameIndex = (_nameIndex + 1) % _names.length;
              _charIndex = 0;
              _displayedName = "";
            });
          } else {
            _charIndex++;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            _buildFixedTopBar(context, state, l10n, theme),
            Expanded(
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 1200,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRemainingHeader(context, state, l10n, theme),
                        SizedBox(height: context.verticalPadding),
                        _buildQuickSend(context, state, l10n, theme),
                        SizedBox(height: context.verticalPadding),
                        _buildSpendingAnalysis(context, state, l10n, theme),
                        SizedBox(height: context.verticalPadding),
                        _buildQuickActions(context, state, l10n, theme),
                        SizedBox(height: context.verticalPadding),
                        _buildVirtualCardPromo(context, state, l10n, theme),
                        SizedBox(height: context.verticalPadding * 1.5),
                        _buildRecentTransactions(context, state, l10n, theme),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedTopBar(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme) {
    final bool isTablet = ResponsiveBreakpoints.of(context).equals(TABLET);

    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          final topPadding = MediaQuery.of(context).padding.top + 16;
          // Dynamically adjust padding to avoid overflow on narrow windows with sidebar
          final horizontalPadding = context.isDesktop ? 24.0 : context.horizontalPadding;
          
          return Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding, 
              topPadding, 
              horizontalPadding, 
              16
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark,
                  Color.lerp(AppColors.primaryDark, Colors.blue.shade900, _gradientController.value)!,
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!context.isMobile)
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                padding: const EdgeInsets.only(right: 12),
                constraints: const BoxConstraints(),
              ),
            Expanded(
              child: FadeInLeft(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryDark,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=rayaale'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.welcome,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13 * context.fontSizeFactor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _displayedName, 
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                fontSize: 20 * context.fontSizeFactor
                              ), 
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FadeInRight(
                  delay: const Duration(milliseconds: 400),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatScreen(
                            userId: 'support_bot',
                            userName: 'Murtaax Support',
                            userAvatar: 'assets/images/logo1.png',
                          ),
                        ),
                      );
                    },
                    icon: Stack(
                      children: [
                        const Icon(Icons.support_agent_rounded, color: Colors.white),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Pulse(
                            infinite: true,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryDark, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FadeInRight(
                  delay: const Duration(milliseconds: 500),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: Colors.white),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Pulse(
                            infinite: true,
                            duration: const Duration(seconds: 2),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingHeader(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme) {
    // Use narrower padding on desktop to accommodate the sidebar
    final horizontalPadding = context.isDesktop ? 24.0 : context.horizontalPadding;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 40),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient, 
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32), 
          bottomRight: Radius.circular(32)
        )
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Column(
            children: [
              const SizedBox(height: 16),
              NotchedWalletCard(
                size: Size(double.infinity, (isWide ? 160 : 180) * context.fontSizeFactor),
                action: Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 4),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScannerScreen()));
                    },
                    child: Container(
                      width: 130 * context.fontSizeFactor,
                      height: 52 * context.fontSizeFactor,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20 * context.fontSizeFactor),
                          const SizedBox(width: 8),
                          Text(
                            "Scan & Pay", 
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 13 * context.fontSizeFactor
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 20 : 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                        children: [
                          Expanded(
                            child: Text(
                              l10n.walletBalance, 
                              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold), 
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible), 
                            icon: Icon(_isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ]
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: ShimmerLoading(
                                  isLoading: _isLoading,
                                  child: Text(
                                    _isBalanceVisible ? NumberFormat.simpleCurrency(name: state.currencyCode).format(state.balance) : "******",
                                    style: theme.textTheme.displayMedium?.copyWith(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 32 * context.fontSizeFactor
                                    )
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${l10n.walletId}: 102234",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11 * context.fontSizeFactor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 140, maxWidth: isWide ? 400 : double.infinity),
                    child: _buildActionButton(context, l10n.send, FontAwesomeIcons.circleArrowRight, AppColors.accentGradient, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SendAmountScreen()))),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 140, maxWidth: isWide ? 400 : (MediaQuery.of(context).size.width - (context.horizontalPadding * 2) - 16) / 2),
                    child: _buildActionButton(context, l10n.add, FontAwesomeIcons.circlePlus, LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1)]), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DepositScreen()))),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 140, maxWidth: isWide ? 400 : (MediaQuery.of(context).size.width - (context.horizontalPadding * 2) - 16) / 2),
                    child: _buildActionButton(context, l10n.withdraw, FontAwesomeIcons.circleArrowUp, LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1)]), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WithdrawScreen()))),
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSpendingAnalysis(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsScreen())),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, 
            borderRadius: BorderRadius.circular(24), 
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))]
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 420;
              final isVerySmall = constraints.maxWidth < 280;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.spendingAnalysis, 
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: isSmall ? 15 : 18),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildChartTypeToggle(ChartType.bar, Icons.bar_chart_rounded, isSmall),
                            _buildChartTypeToggle(ChartType.line, Icons.show_chart_rounded, isSmall),
                            _buildChartTypeToggle(ChartType.pie, Icons.pie_chart_rounded, isSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (!isVerySmall) ...[
                    SizedBox(
                      height: constraints.maxWidth > 600 ? 250 : 180,
                      child: _buildSelectedChart(theme),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (isSmall) 
                    Column(
                      children: [
                        _buildStatItem(context, l10n.send, r"$4,250", Colors.blue, isList: true),
                        const SizedBox(height: 12),
                        _buildStatItem(context, l10n.bills, r"$1,120", Colors.orange, isList: true),
                        const SizedBox(height: 12),
                        _buildStatItem(context, l10n.sadaqah, r"$450", AppColors.accentTeal, isList: true),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(child: _buildStatItem(context, l10n.send, r"$4,250", Colors.blue)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatItem(context, l10n.bills, r"$1,120", Colors.orange)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatItem(context, l10n.sadaqah, r"$450", AppColors.accentTeal)),
                      ],
                    ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.getStarted, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 300 ? 2 : 4;
              return GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: crossAxisCount, 
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                mainAxisSpacing: 4, 
                crossAxisSpacing: 8,
                childAspectRatio: crossAxisCount == 2 ? 1.5 : 0.8,
                children: [
                  _buildFeatureItem(context, "Hagbad", Icons.group_work_rounded, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HagbadScreen()))),
                  _buildFeatureItem(context, l10n.bills, Icons.receipt_long_rounded, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PayBillsScreen()))),
                  _buildFeatureItem(context, l10n.sadaqah, Icons.volunteer_activism_rounded, AppColors.accentTeal, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SadaqahScreen()))),
                  _buildFeatureItem(context, l10n.exchange, Icons.currency_exchange_rounded, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExchangeRatesScreen()))),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualCardPromo(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: ZoomIn(
      child: Hero(
        tag: 'virtual_card',
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CardsScreen())),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text("PREMIUM", style: TextStyle(color: Colors.white70, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 12),
                      Text(l10n.virtualCard, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
                      const SizedBox(height: 4),
                      Text(l10n.virtualCardDesc, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12 * context.fontSizeFactor)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 16),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.recentTransactions, 
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())), 
                  child: Text(
                    l10n.seeAll,
                    style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                    overflow: TextOverflow.ellipsis,
                  )
                ),
              ),
            ],
          ),
          if (_isLoading) ...[
            TransactionItem.skeleton(context),
            TransactionItem.skeleton(context),
            TransactionItem.skeleton(context),
          ] else ...[
            TransactionItem(
              title: "Amazon.com", 
              subtitle: "Shopping", 
              amount: "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(124.50)}", 
              date: "Today, 2:45 PM", 
              status: "Success", 
              icon: FontAwesomeIcons.amazon,
              onTap: () => ReceiptView.show(context, {
                'title': 'Amazon.com',
                'amount': "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(124.50)}",
                'date': 'Today, 2:45 PM',
                'status': 'Success'
              }),
            ),
            TransactionItem(
              title: "Ahmed Warsame", 
              subtitle: "Transfer", 
              amount: "+${NumberFormat.simpleCurrency(name: state.currencyCode).format(2500.00)}", 
              date: "Yesterday, 10:20 AM", 
              status: "Success", 
              icon: FontAwesomeIcons.user,
              onTap: () => ReceiptView.show(context, {
                'title': 'Ahmed Warsame',
                'amount': "+${NumberFormat.simpleCurrency(name: state.currencyCode).format(2500.00)}",
                'date': 'Yesterday, 10:20 AM',
                'status': 'Success'
              }),
            ),
            TransactionItem(
              title: "Somnet Bill", 
              subtitle: "Utilities", 
              amount: "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(35.00)}", 
              date: "24 Oct, 4:15 PM", 
              status: "Pending", 
              icon: Icons.wifi_rounded,
              onTap: () => ReceiptView.show(context, {
                'title': 'Somnet Bill',
                'amount': "-${NumberFormat.simpleCurrency(name: state.currencyCode).format(35.00)}",
                'date': '24 Oct, 4:15 PM',
                'status': 'Pending'
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, dynamic icon, Gradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 56 * context.fontSizeFactor,
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          AdaptiveIcon(icon, color: Colors.white, size: 18 * context.fontSizeFactor),
          const SizedBox(width: 8),
          Flexible(child: Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor), overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String label, dynamic icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: AdaptiveIcon(icon, color: color, size: 24 * context.fontSizeFactor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(fontSize: 11 * context.fontSizeFactor, fontWeight: FontWeight.w500), 
            textAlign: TextAlign.center, 
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeToggle(ChartType type, dynamic icon, [bool isSmall = false]) {
    final isSelected = _selectedChartType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = type),
      child: Container(
        padding: EdgeInsets.all(isSmall ? 4 : 6),
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(color: isSelected ? AppColors.primaryDark.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: AdaptiveIcon(icon, size: isSmall ? 14 : 16, color: isSelected ? AppColors.primaryDark : Colors.grey),
      ),
    );
  }

  Widget _buildSelectedChart(ThemeData theme) {
    switch (_selectedChartType) {
      case ChartType.bar: return _buildBarChart(theme);
      case ChartType.line: return _buildLineChart(theme);
      case ChartType.pie: return _buildPieChart(theme);
    }
  }

  Widget _buildBarChart(ThemeData theme) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primaryDark,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${_days[group.x.toInt()]}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '\$${rod.toY.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(_days[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)))),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(_spendingData.length, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: _spendingData[i], gradient: AppColors.primaryGradient, width: 12, borderRadius: BorderRadius.circular(4))])),
      ),
    );
  }

  Widget _buildLineChart(ThemeData theme) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primaryDark,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '\$${spot.y.toStringAsFixed(2)}',
                  const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => value.toInt() < _days.length ? Text(_days[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)) : const SizedBox())),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(_spendingData.length, (i) => FlSpot(i.toDouble(), _spendingData[i])),
            isCurved: true,
            gradient: AppColors.primaryGradient,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primaryDark.withValues(alpha: 0.2), AppColors.primaryDark.withValues(alpha: 0)])),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme) {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(color: Colors.blue, value: 45, title: '45%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          PieChartSectionData(color: Colors.orange, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          PieChartSectionData(color: AppColors.accentTeal, value: 25, title: '25%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickSend(BuildContext context, AppState state, AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.quickSend,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  l10n.seeAll,
                  style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding - 8),
            itemCount: _quickContacts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // Return "Add New" button
                return FadeInRight(
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.translate("Search for a new contact", "Raadi xiriir cusub"))),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2), width: 2),
                            ),
                            child: const Icon(Icons.add_rounded, color: AppColors.accentTeal, size: 30),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.translate("New", "Cusub"),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final contact = _quickContacts[index - 1];
              return FadeInRight(
                duration: const Duration(milliseconds: 500),
                delay: Duration(milliseconds: 100 * index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SendAmountScreen(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(contact.avatar),
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ),
                            if (contact.isOnline)
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 2.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contact.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String amount, Color color, {bool isList = false}) {
    if (isList) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label, 
                    style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  )
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label, 
                style: const TextStyle(color: Colors.grey, fontSize: 10), 
                overflow: TextOverflow.ellipsis, 
                maxLines: 1
              )
            ),
          ],
        ),
        const SizedBox(height: 2),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

class NotchedWalletCard extends StatelessWidget {
  final Widget child;
  final Widget action;
  final Size size;
  
  const NotchedWalletCard({super.key, required this.child, required this.action, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: size,
          painter: WalletCardPainter(),
          child: ClipPath(
            clipper: WalletCardClipper(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.transparent,
                child: child,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: action,
        ),
      ],
    );
  }
}

class WalletCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _getCardPath(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WalletCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _getCardPath(size);
    
    // Fill
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
    
    // Border
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.2)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

Path _getCardPath(Size size) {
  double notchWidth = 140.0;
  double notchHeight = 60.0;
  double radius = 24.0;
  
  Path path = Path();
  path.moveTo(radius, 0);
  path.lineTo(size.width - radius, 0);
  path.quadraticBezierTo(size.width, 0, size.width, radius);
  
  // Down to notch
  path.lineTo(size.width, size.height - notchHeight - radius);
  path.quadraticBezierTo(size.width, size.height - notchHeight, size.width - radius, size.height - notchHeight);
  
  // Across notch
  path.lineTo(size.width - notchWidth + (radius * 0.8), size.height - notchHeight);
  path.quadraticBezierTo(size.width - notchWidth, size.height - notchHeight, size.width - notchWidth, size.height - notchHeight + (radius * 0.8));
  
  // Down to bottom
  path.lineTo(size.width - notchWidth, size.height - radius);
  path.quadraticBezierTo(size.width - notchWidth, size.height, size.width - notchWidth - radius, size.height);
  
  // Bottom across
  path.lineTo(radius, size.height);
  path.quadraticBezierTo(0, size.height, 0, size.height - radius);
  
  // Left side up
  path.lineTo(0, radius);
  path.quadraticBezierTo(0, 0, radius, 0);
  
  path.close();
  return path;
}
