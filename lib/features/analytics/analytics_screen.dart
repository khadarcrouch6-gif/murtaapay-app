import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
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

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(state.translate("Analytics", "Taxliilka", ar: "التحليلات", de: "Analysen")),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalSpendingCard(theme, state),
            const SizedBox(height: 24),
            _buildCategoryDistribution(theme, state),
            const SizedBox(height: 24),
            _buildMonthlyComparison(theme, state),
            const SizedBox(height: 24),
            _buildTopCategoriesList(theme, state),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSpendingCard(ThemeData theme, AppState state) {
    final double monthlySpending = state.transactions
        .where((tx) => tx.isNegative && tx.timestamp.month == DateTime.now().month)
        .fold(0.0, (sum, tx) => sum + tx.numericAmount);

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
              state.translate("Total Spent this Month", "Wixii bishaan baxay", ar: "إجمالي الإنفاق هذا الشهر", de: "Gesamtausgaben diesen Monat"),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
            const SizedBox(height: 8),
            ShimmerLoading(
              isLoading: _isLoading,
              child: Text(
                NumberFormat.simpleCurrency(name: state.currencyCode).format(monthlySpending),
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
                  const Icon(Icons.trending_up_rounded, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "Calculated from ${state.transactions.length} txs",
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
    final Map<String, double> categorySpending = {};
    for (var tx in state.transactions.where((t) => t.isNegative)) {
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
              state.translate("Spending by Category", "Qaybaha Lacagtu u Baxday", ar: "الإنفاق حسب الفئة", de: "Ausgaben nach Kategorie"),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
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
                      sections: _isLoading || sortedCategories.isEmpty 
                        ? _buildDefaultSections() 
                        : _buildRealSections(sortedCategories),
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
                          state.translate("Categories", "Qaybaha", ar: "الفئات", de: "Kategorien"),
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

  Widget _buildMonthlyComparison(ThemeData theme, AppState state) {
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
              state.translate("Monthly Comparison", "Is-barbardhigga Billaha", ar: "مقارنة شهرية", de: "Monatlicher Vergleich"),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: _isLoading ? _buildDefaultBars() : _buildRealBars(state),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          if (value.toInt() < 0 || value.toInt() >= labels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          );
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
    return List.generate(6, (i) {
      return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: 10, color: Colors.grey.withValues(alpha: 0.1), width: 16, borderRadius: BorderRadius.circular(4))]);
    });
  }

  List<BarChartGroupData> _buildRealBars(AppState state) {
    // Group transactions by month for the last 6 months
    final now = DateTime.now();
    final List<double> monthlyTotals = List.filled(6, 0.0);
    
    for (var tx in state.transactions.where((t) => t.isNegative)) {
      final diff = (now.year - tx.timestamp.year) * 12 + now.month - tx.timestamp.month;
      if (diff >= 0 && diff < 6) {
        monthlyTotals[5 - diff] += tx.numericAmount;
      }
    }

    return List.generate(6, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: monthlyTotals[i] > 0 ? monthlyTotals[i] : 5, // Show small bar if 0
            gradient: i == 5 ? AppColors.accentGradient : LinearGradient(colors: [Colors.grey.withValues(alpha: 0.2), Colors.grey.withValues(alpha: 0.3)]),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });
  }

  Widget _buildTopCategoriesList(ThemeData theme, AppState state) {
    final Map<String, double> categorySpending = {};
    for (var tx in state.transactions.where((t) => t.isNegative)) {
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
            state.translate("Top Categories", "Qaybaha ugu sarreeya", ar: "أعلى الفئات", de: "Top-Kategorien"),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (sortedCategories.isEmpty)
             const Center(child: Text("No data yet"))
          else
            ...sortedCategories.take(4).map((entry) {
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
      default: return FontAwesomeIcons.tag;
    }
  }
}
