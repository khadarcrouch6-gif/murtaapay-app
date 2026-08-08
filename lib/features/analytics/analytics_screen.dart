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
            title: Text(state.translate("Analytics", "Taxliilka", ar: "التحليلات", de: "Analysen"), style: TextStyle(fontSize: (theme.appBarTheme.titleTextStyle?.fontSize ?? 20) * context.fontSizeFactor)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.calendar_month_rounded, size: 24 * context.fontSizeFactor),
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
                  SizedBox(height: 24 * context.fontSizeFactor),
                  _buildCategoryDistribution(theme, state),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  _buildTrendChart(theme, state),
                  SizedBox(height: 24 * context.fontSizeFactor),
                  _buildTopCategoriesList(theme, state),
                  SizedBox(height: 100 * context.fontSizeFactor),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20 * context.fontSizeFactor))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24 * context.fontSizeFactor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.translate("Select Period", "Xulo Muddada"),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor),
              ),
              SizedBox(height: 16 * context.fontSizeFactor),
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
      title: Text(label, style: TextStyle(fontSize: 16 * context.fontSizeFactor)),
      trailing: _selectedPeriod == value ? Icon(Icons.check_circle, color: AppColors.accentTeal, size: 24 * context.fontSizeFactor) : null,
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
        padding: EdgeInsets.all(24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(28 * context.fontSizeFactor),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.3),
              blurRadius: 20 * context.fontSizeFactor,
              offset: Offset(0, 10 * context.fontSizeFactor),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${state.translate("Total Spent", "Wixii baxay")} $periodLabel",
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14 * context.fontSizeFactor),
            ),
            SizedBox(height: 8 * context.fontSizeFactor),
            ShimmerLoading(
              isLoading: _isLoading,
              child: Text(
                NumberFormat.simpleCurrency(name: state.currencyCode).format(spending),
                style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16 * context.fontSizeFactor),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor, vertical: 6 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.analytics_outlined, color: AppColors.accentTeal, size: 16 * context.fontSizeFactor),
                  SizedBox(width: 4 * context.fontSizeFactor),
                  Text(
                    state.translate("Insights ready", "Taxliilka waa diyaar"),
                    style: TextStyle(color: Colors.white, fontSize: 12 * context.fontSizeFactor),
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
        padding: EdgeInsets.all(24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28 * context.fontSizeFactor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.translate("Spending by Category", "Qaybaha Lacagtu u Baxday"),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * context.fontSizeFactor),
            ),
            SizedBox(height: 32 * context.fontSizeFactor),
            if (sortedCategories.isEmpty)
              SizedBox(height: 200 * context.fontSizeFactor, child: Center(child: Text("No data for this period", style: TextStyle(fontSize: 14 * context.fontSizeFactor))))
            else
              SizedBox(
                height: 200 * context.fontSizeFactor,
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
                        sectionsSpace: 4 * context.fontSizeFactor,
                        centerSpaceRadius: 60 * context.fontSizeFactor,
                        sections: _isLoading ? _buildDefaultSections(context) : _buildRealSections(context, sortedCategories),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLoading ? "--" : "${sortedCategories.length}",
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (theme.textTheme.headlineMedium?.fontSize ?? 28) * context.fontSizeFactor),
                          ),
                          Text(
                            state.translate("Categories", "Qaybaha"),
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: (theme.textTheme.labelSmall?.fontSize ?? 11) * context.fontSizeFactor),
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

  List<PieChartSectionData> _buildDefaultSections(BuildContext context) {
    return List.generate(1, (i) {
      return PieChartSectionData(color: Colors.grey.withOpacity(0.1), value: 100, radius: 25 * context.fontSizeFactor, showTitle: false);
    });
  }

  List<PieChartSectionData> _buildRealSections(BuildContext context, List<MapEntry<String, double>> categories) {
    final colors = [Colors.blue, Colors.orange, AppColors.accentTeal, Colors.purple, Colors.red, Colors.green];
    
    return List.generate(categories.length.clamp(0, 6), (i) {
      final isTouched = i == _touchedIndex;
      final radius = (isTouched ? 35.0 : 25.0) * context.fontSizeFactor;
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
        padding: EdgeInsets.all(24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28 * context.fontSizeFactor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedPeriod == 'Yearly' 
                ? state.translate("Monthly Trend", "Isbeddelka Billaha")
                : state.translate("Daily Trend", "Isbeddelka Maalmaha"),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * context.fontSizeFactor),
            ),
            SizedBox(height: 32 * context.fontSizeFactor),
            SizedBox(
              height: 180 * context.fontSizeFactor,
              child: BarChart(
                BarChartData(
                  barGroups: _isLoading ? _buildDefaultBars(context) : _buildTrendBars(context, state),
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
                               padding: EdgeInsets.only(top: 8 * context.fontSizeFactor),
                               child: Text(labels[idx], style: TextStyle(color: Colors.grey, fontSize: 10 * context.fontSizeFactor)),
                             );
                          } else {
                            const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value.toInt() < 0 || value.toInt() >= labels.length) return const SizedBox();
                            return Padding(
                              padding: EdgeInsets.only(top: 8 * context.fontSizeFactor),
                              child: Text(labels[value.toInt()], style: TextStyle(color: Colors.grey, fontSize: 10 * context.fontSizeFactor)),
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

  List<BarChartGroupData> _buildDefaultBars(BuildContext context) {
    return List.generate(7, (i) {
      return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: 10, color: Colors.grey.withOpacity(0.1), width: 12 * context.fontSizeFactor, borderRadius: BorderRadius.circular(4 * context.fontSizeFactor))]);
    });
  }

  List<BarChartGroupData> _buildTrendBars(BuildContext context, AppState state) {
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
              gradient: i == now.month - 1 ? AppColors.accentGradient : LinearGradient(colors: [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.3)]),
              width: 10 * context.fontSizeFactor,
              borderRadius: BorderRadius.circular(4 * context.fontSizeFactor),
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
              gradient: i == 6 ? AppColors.accentGradient : LinearGradient(colors: [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.3)]),
              width: 16 * context.fontSizeFactor,
              borderRadius: BorderRadius.circular(4 * context.fontSizeFactor),
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
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * context.fontSizeFactor),
          ),
          SizedBox(height: 16 * context.fontSizeFactor),
          if (sortedCategories.isEmpty)
             Center(child: Padding(
               padding: EdgeInsets.all(20.0 * context.fontSizeFactor),
               child: Text("No transactions recorded yet", style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
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
      margin: EdgeInsets.only(bottom: 12 * context.fontSizeFactor),
      padding: EdgeInsets.all(16 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12 * context.fontSizeFactor),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: AdaptiveIcon(icon, color: color, size: 18 * context.fontSizeFactor),
          ),
          SizedBox(width: 16 * context.fontSizeFactor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                SizedBox(height: 4 * context.fontSizeFactor),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4 * context.fontSizeFactor),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4 * context.fontSizeFactor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16 * context.fontSizeFactor),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
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
