import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/widgets/transaction_item.dart';
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
import '../notifications/notifications_screen.dart';

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
                      state.translate("Welcome back,", "Ku soo dhawaaw,", ar: "مرحباً بعودتك،", de: "Willkommen zurück,"), 
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
                      Text(state.translate("Wallet Balance", "Hadhaaga Wallet-ka", ar: "رصيد المحفظة", de: "Kontostand"), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14 * context.fontSizeFactor)),
                      IconButton(onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible), icon: Icon(_isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 20 * context.fontSizeFactor)),
                    ]),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(_isBalanceVisible ? r"$12,450.80" : "******", style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32 * context.fontSizeFactor)),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 32),
              Row(children: [
                Expanded(child: _buildActionButton(context, state.translate("Send", "Dir", ar: "إرسال", de: "Senden"), FontAwesomeIcons.paperPlane, AppColors.accentGradient, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SendAmountScreen())))),
                const SizedBox(width: 16),
                Expanded(child: _buildActionButton(context, state.translate("Add", "Ku dar", ar: "إضافة", de: "Hinzufügen"), FontAwesomeIcons.plus, LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1)]), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DepositScreen())))),
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
                Expanded(child: Text(state.translate("Spending Analysis", "Isticmaalka", ar: "تحليل الإنفاق", de: "Ausgabenanalyse"), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChartTypeToggle(ChartType.bar, Icons.bar_chart_rounded),
                    _buildChartTypeToggle(ChartType.line, Icons.show_chart_rounded),
                    _buildChartTypeToggle(ChartType.pie, Icons.pie_chart_rounded),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _buildSelectedChart(theme),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatItem(context, state.translate("Send", "Dir", ar: "إرسال", de: "Senden"), r"$4,250", Colors.blue)),
                Expanded(child: _buildStatItem(context, state.translate("Bills", "Biilasha", ar: "الفواتير", de: "Rechnungen"), r"$1,120", Colors.orange)),
                Expanded(child: _buildStatItem(context, state.translate("Sadaqah", "Sadaqada", ar: "الصدقة", de: "Sadaqah"), r"$450", AppColors.accentTeal)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppState state, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.translate("Get Started", "Bilow Hadda", ar: "ابدأ الآن", de: "Loslegen"), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 16, crossAxisSpacing: 16,
            children: [
              _buildFeatureItem(context, state.translate("Bills", "Biilasha", ar: "الفواتير", de: "Rechnungen"), Icons.receipt_long_rounded, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PayBillsScreen()))),
              _buildFeatureItem(context, state.translate("Sadaqah", "Sadaqada", ar: "الصدقة", de: "Sadaqah"), Icons.volunteer_activism_rounded, AppColors.accentTeal, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SadaqahScreen()))),
              _buildFeatureItem(context, state.translate("Exchange", "Sarifka", ar: "صرف", de: "Wechselkurs"), Icons.currency_exchange_rounded, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExchangeRatesScreen()))),
              _buildFeatureItem(context, state.translate("Vouchers", "Waatsharrada", ar: "قسائم", de: "Gutscheine"), Icons.confirmation_number_rounded, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VouchersScreen()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualCardPromo(BuildContext context, AppState state, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: ZoomIn(
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
                      Text(state.translate("Virtual Card", "Kaadhka Online-ka ah", ar: "بطاقة افتراضية", de: "Virtuelle Karte"), style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor)),
                      const SizedBox(height: 4),
                      Text(state.translate("Get your secure virtual card and shop globally.", "Hadda qaado kaadhkaaga online-ka ah si aad wax u iibsato.", ar: "احصل على بطاقتك الافتراضية الآمنة وتسوق عالمياً.", de: "Holen Sie sich Ihre sichere virtuelle Karte und kaufen Sie weltweit ein."), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12 * context.fontSizeFactor)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 16),
              ],
            ),
          ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  state.translate("Recent Transactions", "Dhaqdhaqaaqadii u dambeeyay", ar: "المعاملات الأخيرة", de: "Letzte Transaktionen"), 
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())), child: Text(state.translate("See All", "Dhammaan", ar: "عرض الكل", de: "Alle anzeigen"), style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
            ],
          ),
          const TransactionItem(title: "Amazon.com", subtitle: "Shopping", amount: r"-$124.50", date: "Today, 2:45 PM", status: "Success", icon: FontAwesomeIcons.amazon),
          const TransactionItem(title: "Ahmed Warsame", subtitle: "Transfer", amount: r"+$2,500.00", date: "Yesterday, 10:20 AM", status: "Success", icon: FontAwesomeIcons.userLarge),
          const TransactionItem(title: "Somnet Bill", subtitle: "Utilities", amount: r"-$35.00", date: "24 Oct, 4:15 PM", status: "Pending", icon: Icons.wifi_rounded),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, dynamic icon, Gradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56 * context.fontSizeFactor,
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          AdaptiveIcon(icon, color: Colors.white, size: 18 * context.fontSizeFactor),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor)),
        ]),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String label, dynamic icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: AdaptiveIcon(icon, color: color, size: 24 * context.fontSizeFactor),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(label, style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.w500), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeToggle(ChartType type, dynamic icon) {
    final isSelected = _selectedChartType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = type),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(color: isSelected ? AppColors.primaryDark.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: AdaptiveIcon(icon, size: 18, color: isSelected ? AppColors.primaryDark : Colors.grey),
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
        barTouchData: BarTouchData(enabled: true),
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

  Widget _buildStatItem(BuildContext context, String label, String amount, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
      ],
    );
  }
}
