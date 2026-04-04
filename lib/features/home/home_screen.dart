import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../send_money/send_amount_screen.dart';
import '../history/history_screen.dart';
import '../cards/cards_screen.dart';
import '../bills/pay_bills_screen.dart';
import '../withdraw/withdraw_screen.dart';
import '../chat/chat_screen.dart';
import '../more/sadaqah_screen.dart';
import '../more/savings_screen.dart';
import '../more/exchange_rates_screen.dart';
import '../more/vouchers_screen.dart';
import '../deposit/deposit_screen.dart';
import '../auth/kyc_screen.dart';

enum ChartType { bar, pie, line }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isBalanceVisible = false;
  int _nameIndex = 0;
  int _charIndex = 0;
  String _displayedName = "";
  Timer? _timer;
  final List<String> _names = ["Khadar", "Abdi", "Warsame"];
  
  bool _isLoading = true;

  ChartType _selectedChartType = ChartType.bar;
  final List<double> _spendingData = [45, 80, 55, 95, 70, 40, 65];
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _startNameAnimation();
    _fakeLoad();
  }

  void _fakeLoad() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            _buildFixedTopBar(context, state, theme),
            Expanded(
              child: Center(
                child: MaxWidthBox(
                  maxWidth: 1200,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRemainingHeader(context, state, theme),
                        SizedBox(height: context.verticalPadding),
                        _buildSpendingAnalysis(context, state, theme),
                        SizedBox(height: context.verticalPadding),
                        _buildQuickActions(context, state, theme),
                        SizedBox(height: context.verticalPadding),
                        _buildVirtualCardPromo(context, state, theme),
                        SizedBox(height: context.verticalPadding * 1.5),
                        _buildRecentTransactions(context, state, theme),
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

  Widget _buildFixedTopBar(BuildContext context, AppState state, ThemeData theme) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              context.horizontalPadding, 
              MediaQuery.of(context).padding.top + 16, 
              context.horizontalPadding, 
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
            Expanded(
              child: FadeInLeft(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(
                      state.translate("Welcome back,", "Ku soo dhawaaw,"), 
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13 * context.fontSizeFactor)
                    ),
                    Text(
                      _displayedName, 
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 20 * context.fontSizeFactor
                      ), 
                      overflow: TextOverflow.ellipsis
                    ),
                  ]
                ),
              ),
            ),
            Row(
              children: [
                FadeInRight(
                  delay: const Duration(milliseconds: 400),
                  child: IconButton(
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
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingHeader(BuildContext context, AppState state, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(context.horizontalPadding, 0, context.horizontalPadding, 40),
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
              GlassmorphicContainer(
                width: double.infinity, 
                height: (isWide ? 120 : 160) * context.fontSizeFactor, 
                borderRadius: 24, blur: 20, alignment: Alignment.center, border: 2,
                linearGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)]),
                borderGradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.2)]),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(state.translate("Wallet Balance", "Hadhaaga Wallet-ka"), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14 * context.fontSizeFactor)),
                      IconButton(onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible), icon: Icon(_isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 20 * context.fontSizeFactor)),
                    ]),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(_isBalanceVisible ? "\$12,450.80" : "******", style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32 * context.fontSizeFactor)),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 32),
              Row(children: [
                Expanded(child: _buildActionButton(context, state.translate("Send", "Dir"), FontAwesomeIcons.paperPlane, AppColors.accentGradient, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SendAmountScreen())))),
                const SizedBox(width: 16),
                Expanded(child: _buildActionButton(context, state.translate("Add", "Ku dar"), FontAwesomeIcons.plus, LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1)]), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DepositScreen())))),
              ]),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSpendingAnalysis(BuildContext context, AppState state, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))]),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(state.translate("Spending Analysis", "Falanqaynta Isticmaalka"), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                _buildChartTypeToggle(),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildSelectedChart(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(ChartType.bar, Icons.bar_chart_rounded),
          _buildToggleItem(ChartType.pie, Icons.pie_chart_rounded),
          _buildToggleItem(ChartType.line, Icons.show_chart_rounded),
        ],
      ),
    );
  }

  Widget _buildToggleItem(ChartType type, IconData icon) {
    bool isSelected = _selectedChartType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isSelected ? AppColors.primaryDark : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.grey),
      ),
    );
  }

  Widget _buildSelectedChart(ThemeData theme) {
    switch (_selectedChartType) {
      case ChartType.pie: return _buildPieChart(theme);
      case ChartType.line: return _buildLineChart(theme);
      default: return _buildBarChart(theme);
    }
  }

  Widget _buildBarChart(ThemeData theme) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primaryDark,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem("\$${rod.toY.toInt()}", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) => Padding(padding: const EdgeInsets.only(top: 8), child: Text(_days[v.toInt()], style: TextStyle(color: AppColors.grey, fontSize: 10))))),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _spendingData.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value, gradient: AppColors.accentGradient, width: 16, borderRadius: BorderRadius.circular(4))])).toList(),
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme) {
    return PieChart(
      PieChartData(
        sectionsSpace: 4, centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(value: 40, title: 'Bills', color: AppColors.primaryDark, radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 30, title: 'Food', color: AppColors.accentTeal, radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 20, title: 'Shop', color: Colors.orange, radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 10, title: 'Other', color: AppColors.grey, radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildLineChart(ThemeData theme) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) => Text(_days[v.toInt()], style: const TextStyle(color: AppColors.grey, fontSize: 10)))),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _spendingData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true, gradient: AppColors.accentGradient, barWidth: 4, isStrokeCapRound: true, dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.accentTeal.withValues(alpha: 0.3), AppColors.accentTeal.withValues(alpha: 0.0)])),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, Gradient gradient, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56 * context.fontSizeFactor, 
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              FaIcon(icon, color: Colors.white, size: 16 * context.fontSizeFactor), 
              const SizedBox(width: 8), 
              Flexible(
                child: Text(
                  title, 
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * context.fontSizeFactor
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppState state, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double spacing = 16.0;
          final int crossAxisCount = constraints.maxWidth > 600 ? 5 : 4;
          // Ensure width is never negative
          final double availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
          final double itemWidth = (availableWidth / crossAxisCount).clamp(60.0, 120.0);

          return Wrap(
            spacing: spacing,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickActionItem(
                  context,
                  state.translate("Bills", "Biilasha"),
                  FontAwesomeIcons.receipt,
                  itemWidth,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PayBillsScreen()))),
              _buildQuickActionItem(
                  context,
                  state.translate("Sadaqah", "Sadaqada"),
                  FontAwesomeIcons.heart,
                  itemWidth,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SadaqahScreen()))),
              _buildQuickActionItem(
                  context,
                  state.translate("Exchange", "Sarifka"),
                  FontAwesomeIcons.moneyBillTransfer,
                  itemWidth,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExchangeRatesScreen()))),
              _buildQuickActionItem(
                  context,
                  state.translate("Vouchers", "Waatsharrada"),
                  FontAwesomeIcons.ticket,
                  itemWidth,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => VouchersScreen()))),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, String title, IconData icon, double width, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
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

  Widget _buildVirtualCardPromo(BuildContext context, AppState state, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 180,
        borderRadius: 24,
        blur: 15,
        alignment: Alignment.center,
        border: 1.5,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F2027).withValues(alpha: 0.9),
            const Color(0xFF203A43).withValues(alpha: 0.8),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.credit_card_rounded, size: 150, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.stars_rounded, color: AppColors.accentTeal, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        state.translate("Virtual Card", "Kaadhka Online-ka ah"),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.translate("Get your secure virtual card and shop globally.", "Hadda qaado kaadhkaaga oo meel kasta ka adeegso."),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => state.setNavIndex(3),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(state.translate("Get Started", "Bilow Hadda"), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, AppState state, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding), 
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  state.translate("Recent Transactions", "Dhaqdhaqaaqii Ugu Dambeeyay"), 
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                )
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())), 
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text(
                  state.translate("See All", "Dhammaan"), 
                  style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold),
                )
              ),
            ]
          ),
          _buildTransactionItem(context, state, "Mohamed Ali", "EVC Plus", "-\$250.00", "Success"),
          _buildTransactionItem(context, state, "Ahmed Hersi", "ZAAD", "-\$100.00", "Pending"),
        ]
      )
    );
  }

  Widget _buildTransactionItem(BuildContext context, AppState state, String name, String type, String amount, String status) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12), 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            height: 48, 
            width: 48, 
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.05), shape: BoxShape.circle), 
            child: Center(child: Text(name[0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)))
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  name, 
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                ), 
                Text(
                  type, 
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                )
              ]
            )
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, 
              children: [
                Text(
                  amount, 
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold, 
                    color: amount.startsWith('+') ? AppColors.accentTeal : null
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                ),
                Text(
                  status == "Success" ? state.translate("Success", "Guul") : state.translate("Pending", "Sugayn"), 
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: status == "Success" ? AppColors.accentTeal : Colors.orange, 
                    fontWeight: FontWeight.bold
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                ),
              ]
            ),
          ),
        ]
      ),
    );
  }


}

