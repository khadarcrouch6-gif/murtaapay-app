import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/adaptive_icon.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  int _touchedIndex = -1;
  String _selectedPeriod = 'Monthly'; // Weekly, Monthly, Yearly

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(state.translate("Analytics", "Taxliilka", ar: "التحليلات", de: "Analysen")),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded),
                onPressed: () => _showPeriodSelector(context, state),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(milliseconds: 500));
              setState(() => _isLoading = false);
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(context.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalSpendingCard(theme, state),
                  const SizedBox(height: 24),
                  _buildCategoryDistribution(theme, state),
                  const SizedBox(height: 24),
                  _buildTrendChart(theme, state),
                  const SizedBox(height: 24),
                  _buildTopCategoriesList(theme, state),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPeriodSelector(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.translate("Select Period", "Xulo Muddada"),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              _periodItem(context, 'Weekly', state.translate("Weekly", "Todobaadle")),
              _periodItem(context, 'Monthly', state.translate("Monthly", "Bille")),
              _periodItem(context, 'Yearly', state.translate("Yearly", "Sanadle")),
            ],
          ),
        );
      },
    );
  }

  Widget _periodItem(BuildContext context, String value, String label) {
    return ListTile(
      title: Text(label),
      trailing: _selectedPeriod == value ? const Icon(Icons.check_circle, color: AppColors.accentTeal) : null,
      onTap: () {
        setState(() => _selectedPeriod = value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildTotalSpendingCard(ThemeData theme, AppState state) {
    final now = DateTime.now();
    final double spending = state.transactions
        .where((tx) {
          if (!tx.isNegative) return false;
          if (_selectedPeriod == 'Monthly') return tx.timestamp.month == now.month && tx.timestamp.year == now.year;
          if (_selectedPeriod == 'Weekly') return now.difference(tx.timestamp).inDays < 7;
          if (_selectedPeriod == 'Yearly') return tx.timestamp.year == now.year;
          return true;
        })
        .fold(0.0, (sum, tx) => sum + tx.numericAmount);

    final periodLabel = _selectedPeriod == 'Monthly' 
        ? state.translate("this Month", "bishaan") 
        : (_selectedPeriod == 'Weekly' ? state.translate("this Week", "todobaadkan") : state.translate("this Year", "sanadkan"));

    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${state.translate("Total Spent", "Wixii baxay")} $periodLabel",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
            const SizedBox(height: 8),
            ShimmerLoading(
              isLoading: _isLoading,
              child: Text(
                NumberFormat.simpleCurrency(name: state.currencyCode).format(spending),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.analytics_outlined, color: AppColors.accentTeal, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    state.translate("Insights ready", "Taxliilka waa diyaar"),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution(ThemeData theme, AppState state) {
    final now = DateTime.now();
    final Map<String, double> categorySpending = {};
    for (var tx in state.transactions.where((t) => t.isNegative)) {
      if (_selectedPeriod == 'Monthly' && (tx.timestamp.month != now.month || tx.timestamp.year != now.year)) continue;
      if (_selectedPeriod == 'Weekly' && now.difference(tx.timestamp).inDays >= 7) continue;
      if (_selectedPeriod == 'Yearly' && tx.timestamp.year != now.year) continue;

      categorySpending[tx.category] = (categorySpending[tx.category] ?? 0.0) + tx.numericAmount;
    }
    
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.translate("Spending by Category", "Qaybaha Lacagtu u Baxday"),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            if (sortedCategories.isEmpty)
              const SizedBox(height: 200, child: Center(child: Text("No data for this period")))
            else
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 4,
                        centerSpaceRadius: 60,
                        sections: _isLoading ? _buildDefaultSections() : _buildRealSections(sortedCategories),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLoading ? "--" : "${sortedCategories.length}",
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            state.translate("Categories", "Qaybaha"),
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildDefaultSections() {
    return List.generate(1, (i) {
      return PieChartSectionData(color: Colors.grey.withValues(alpha: 0.1), value: 100, radius: 25, showTitle: false);
    });
  }

  List<PieChartSectionData> _buildRealSections(List<MapEntry<String, double>> categories) {
    final colors = [Colors.blue, Colors.orange, AppColors.accentTeal, Colors.purple, Colors.red, Colors.green];
    
    return List.generate(categories.length.clamp(0, 6), (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 35.0 : 25.0;
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: categories[i].value,
        radius: radius,
        showTitle: false,
      );
    });
  }

  Widget _buildTrendChart(ThemeData theme, AppState state) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedPeriod == 'Yearly' 
                ? state.translate("Monthly Trend", "Isbeddelka Billaha")
                : state.translate("Daily Trend", "Isbeddelka Maalmaha"),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: _isLoading ? _buildDefaultBars() : _buildTrendBars(state),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (_selectedPeriod == 'Yearly') {
                             const labels = ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
                             int idx = value.toInt() ~/ 2;
                             if (value.toInt() % 2 != 0 || idx >= labels.length) return const SizedBox();
                             return Padding(
                               padding: const EdgeInsets.only(top: 8),
                               child: Text(labels[idx], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                             );
                          } else {
                            const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value.toInt() < 0 || value.toInt() >= labels.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(labels[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            );
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildDefaultBars() {
    return List.generate(7, (i) {
      return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: 10, color: Colors.grey.withValues(alpha: 0.1), width: 12, borderRadius: BorderRadius.circular(4))]);
    });
  }

  List<BarChartGroupData> _buildTrendBars(AppState state) {
    final now = DateTime.now();
    if (_selectedPeriod == 'Yearly') {
      final List<double> monthlyTotals = List.filled(12, 0.0);
      for (var tx in state.transactions.where((t) => t.isNegative && t.timestamp.year == now.year)) {
        monthlyTotals[tx.timestamp.month - 1] += tx.numericAmount;
      }
      return List.generate(12, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: monthlyTotals[i] > 0 ? monthlyTotals[i] : 2,
              gradient: i == now.month - 1 ? AppColors.accentGradient : LinearGradient(colors: [Colors.grey.withValues(alpha: 0.2), Colors.grey.withValues(alpha: 0.3)]),
              width: 10,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        );
      });
    } else {
      // Last 7 days
      final List<double> dailyTotals = List.filled(7, 0.0);
      for (var tx in state.transactions.where((t) => t.isNegative)) {
        final diff = now.difference(tx.timestamp).inDays;
        if (diff >= 0 && diff < 7) {
          dailyTotals[6 - diff] += tx.numericAmount;
        }
      }
      return List.generate(7, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyTotals[i] > 0 ? dailyTotals[i] : 2,
              gradient: i == 6 ? AppColors.accentGradient : LinearGradient(colors: [Colors.grey.withValues(alpha: 0.2), Colors.grey.withValues(alpha: 0.3)]),
              width: 16,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        );
      });
    }
  }

  Widget _buildTopCategoriesList(ThemeData theme, AppState state) {
    final now = DateTime.now();
    final Map<String, double> categorySpending = {};
    for (var tx in state.transactions.where((t) => t.isNegative)) {
      if (_selectedPeriod == 'Monthly' && (tx.timestamp.month != now.month || tx.timestamp.year != now.year)) continue;
      if (_selectedPeriod == 'Weekly' && now.difference(tx.timestamp).inDays >= 7) continue;
      if (_selectedPeriod == 'Yearly' && tx.timestamp.year != now.year) continue;
      
      categorySpending[tx.category] = (categorySpending[tx.category] ?? 0.0) + tx.numericAmount;
    }
    
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpent = categorySpending.values.fold(0.0, (sum, val) => sum + val);

    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.translate("Top Categories", "Qaybaha ugu sarreeya"),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (sortedCategories.isEmpty)
             const Center(child: Padding(
               padding: EdgeInsets.all(20.0),
               child: Text("No transactions recorded yet"),
             ))
          else
            ...sortedCategories.take(5).map((entry) {
              final color = _getCategoryColor(entry.key);
              final icon = _getCategoryIcon(entry.key);
              final percentage = totalSpent > 0 ? entry.value / totalSpent : 0.0;
              
              return _buildCategoryItem(
                context, 
                entry.key, 
                NumberFormat.simpleCurrency(name: state.currencyCode).format(entry.value), 
                color, 
                icon,
                percentage
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, String amount, Color color, dynamic icon, double percentage) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: AdaptiveIcon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Shopping': return Colors.blue;
      case 'Food':
      case 'Food & Drinks': return Colors.orange;
      case 'Transfer':
      case 'Transfers': return AppColors.accentTeal;
      case 'Subscriptions': return Colors.purple;
      case 'Transport': return Colors.indigo;
      case 'Savings': return Colors.green;
      case 'Hagbad': return Colors.teal;
      case 'Investment': return Colors.amber;
      default: return Colors.grey;
    }
  }

  dynamic _getCategoryIcon(String category) {
    switch (category) {
      case 'Shopping': return FontAwesomeIcons.cartShopping;
      case 'Food':
      case 'Food & Drinks': return FontAwesomeIcons.utensils;
      case 'Transfer':
      case 'Transfers': return FontAwesomeIcons.arrowRightArrowLeft;
      case 'Subscriptions': return FontAwesomeIcons.tv;
      case 'Transport': return FontAwesomeIcons.car;
      case 'Savings': return FontAwesomeIcons.piggyBank;
      case 'Hagbad': return FontAwesomeIcons.users;
      case 'Investment': return FontAwesomeIcons.chartLine;
      default: return FontAwesomeIcons.tag;
    }
  }
}
