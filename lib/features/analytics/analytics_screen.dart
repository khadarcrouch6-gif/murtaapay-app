import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/models/transaction.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/adaptive_icon.dart';

class AnalyticsScreen extends StatefulWidget {
  final String initialPeriod;
  final DateTime? targetDate;

  const AnalyticsScreen({
    super.key, 
    this.initialPeriod = 'Monthly',
    this.targetDate,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  int _touchedIndex = -1;
  int _selectedBarIndex = -1;
  late String _selectedPeriod;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.targetDate != null ? 'Daily' : widget.initialPeriod;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                  _buildRecentTransactionsHeader(theme, state),
                  SizedBox(height: 16 * context.fontSizeFactor),
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
              if (widget.targetDate != null)
                _periodItem(context, 'Daily', state.translate("Specific Day", "Maalin Cayiman")),
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
        setState(() {
          _selectedPeriod = value;
          _selectedBarIndex = -1; // Reset bar filter when period changes
          _selectedCategory = null; // Reset category filter
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildTotalSpendingCard(ThemeData theme, AppState state) {
    final now = DateTime.now();
    final double spending = state.transactions
        .where((tx) {
          if (!tx.isNegative) return false;
          final txLocal = tx.timestamp.toLocal();
          if (_selectedPeriod == 'Daily' && widget.targetDate != null) {
            final target = widget.targetDate!.toLocal();
            return txLocal.year == target.year &&
                   txLocal.month == target.month &&
                   txLocal.day == target.day;
          }
          if (_selectedPeriod == 'Monthly') {
            return txLocal.month == now.month && txLocal.year == now.year;
          }
          if (_selectedPeriod == 'Weekly') {
            final today = DateTime(now.year, now.month, now.day);
            final txDate = DateTime(txLocal.year, txLocal.month, txLocal.day);
            return today.difference(txDate).inDays < 7;
          }
          if (_selectedPeriod == 'Yearly') {
            return txLocal.year == now.year;
          }
          return true;
        })
        .fold(0.0, (sum, tx) => sum + tx.numericAmount);

    final String periodLabel;
    if (_selectedPeriod == 'Daily' && widget.targetDate != null) {
      periodLabel = DateFormat('MMM dd, yyyy').format(widget.targetDate!);
    } else {
      periodLabel = _selectedPeriod == 'Monthly' 
          ? state.translate("this Month", "bishaan") 
          : (_selectedPeriod == 'Weekly' ? state.translate("this Week", "todobaadkan") : state.translate("this Year", "sanadkan"));
    }

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
    final today = DateTime(now.year, now.month, now.day);
    final Map<String, double> categorySpending = {};
    for (var tx in state.transactions.where((t) => t.isNegative)) {
      final txLocal = tx.timestamp.toLocal();
      if (_selectedPeriod == 'Daily' && widget.targetDate != null) {
        final target = widget.targetDate!.toLocal();
        if (txLocal.year != target.year ||
            txLocal.month != target.month ||
            txLocal.day != target.day) {
          continue;
        }
      } else if (_selectedPeriod == 'Monthly' && (txLocal.month != now.month || txLocal.year != now.year)) {
        continue;
      } else if (_selectedPeriod == 'Weekly') {
        final txDate = DateTime(txLocal.year, txLocal.month, txLocal.day);
        if (today.difference(txDate).inDays >= 7) {
          continue;
        }
      } else if (_selectedPeriod == 'Yearly' && txLocal.year != now.year) {
        continue;
      }

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
                              if (event is FlTapUpEvent) {
                                final index = _touchedIndex;
                                if (index >= 0 && index < sortedCategories.length) {
                                  final category = sortedCategories[index].key;
                                  if (_selectedCategory == category) {
                                    _selectedCategory = null;
                                  } else {
                                    _selectedCategory = category;
                                  }
                                }
                              }
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
      final isTouched = i == _touchedIndex || (_selectedCategory != null && categories[i].key == _selectedCategory);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedPeriod == 'Yearly' 
                    ? state.translate("Monthly Trend", "Isbeddelka Billaha")
                    : state.translate("Daily Trend", "Isbeddelka Maalmaha"),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * context.fontSizeFactor),
                ),
                if (_selectedBarIndex != -1)
                  GestureDetector(
                    onTap: () => setState(() => _selectedBarIndex = -1),
                    child: Text(
                      state.translate("Clear Filter", "Nadiifi"),
                      style: TextStyle(color: AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 32 * context.fontSizeFactor),
            SizedBox(
              height: 180 * context.fontSizeFactor,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        return;
                      }
                      if (event is FlTapUpEvent) {
                        setState(() {
                          if (_selectedBarIndex == barTouchResponse.spot!.touchedBarGroupIndex) {
                            _selectedBarIndex = -1;
                          } else {
                            _selectedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                          }
                        });
                      }
                    },
                  ),
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
                            final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                            final label = DateFormat('E').format(date);
                            return Padding(
                              padding: EdgeInsets.only(top: 8 * context.fontSizeFactor),
                              child: Text(label, style: TextStyle(color: Colors.grey, fontSize: 10 * context.fontSizeFactor)),
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
        final isSelected = i == _selectedBarIndex;
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: monthlyTotals[i] > 0 ? monthlyTotals[i] : 2,
              gradient: isSelected || (i == now.month - 1 && _selectedBarIndex == -1) 
                  ? AppColors.accentGradient 
                  : LinearGradient(colors: [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.3)]),
              width: 10 * context.fontSizeFactor,
              borderRadius: BorderRadius.circular(4 * context.fontSizeFactor),
              borderSide: isSelected ? const BorderSide(color: AppColors.accentTeal, width: 2) : BorderSide.none,
            )
          ],
        );
      });
    } else {
      // Last 7 days
      final today = DateTime(now.year, now.month, now.day);
      final List<double> dailyTotals = List.filled(7, 0.0);
      for (var tx in state.transactions.where((t) => t.isNegative)) {
        final txLocal = tx.timestamp.toLocal();
        final txDate = DateTime(txLocal.year, txLocal.month, txLocal.day);
        final diff = today.difference(txDate).inDays;
        if (diff >= 0 && diff < 7) {
          dailyTotals[6 - diff] += tx.numericAmount;
        }
      }

      int highlightedIndex = 6;
      if (_selectedPeriod == 'Daily' && widget.targetDate != null) {
        final target = widget.targetDate!.toLocal();
        final targetDate = DateTime(target.year, target.month, target.day);
        final diff = today.difference(targetDate).inDays;
        if (diff >= 0 && diff < 7) {
          highlightedIndex = 6 - diff;
        } else {
          highlightedIndex = -1;
        }
      }

      return List.generate(7, (i) {
        final isSelected = i == _selectedBarIndex;
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyTotals[i] > 0 ? dailyTotals[i] : 2,
              gradient: isSelected || (i == highlightedIndex && _selectedBarIndex == -1) 
                  ? AppColors.accentGradient 
                  : LinearGradient(colors: [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.3)]),
              width: 16 * context.fontSizeFactor,
              borderRadius: BorderRadius.circular(4 * context.fontSizeFactor),
              borderSide: isSelected ? const BorderSide(color: AppColors.accentTeal, width: 2) : BorderSide.none,
            )
          ],
        );
      });
    }
  }

  Widget _buildRecentTransactionsHeader(ThemeData theme, AppState state) {
    String filterText = "";
    if (_selectedCategory != null) {
      filterText = "in $_selectedCategory";
    }
    if (_selectedBarIndex != -1) {
      if (_selectedPeriod == 'Yearly') {
        filterText += " for ${DateFormat('MMMM').format(DateTime(2024, _selectedBarIndex + 1))}";
      } else {
        final date = DateTime.now().subtract(Duration(days: 6 - _selectedBarIndex));
        filterText += " on ${DateFormat('MMM dd').format(date)}";
      }
    }

    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${state.translate("Filtered List", "Liiska la sifeeyay")} $filterText",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * context.fontSizeFactor),
          ),
          if (_selectedCategory != null || _selectedBarIndex != -1)
            GestureDetector(
              onTap: () => setState(() {
                _selectedCategory = null;
                _selectedBarIndex = -1;
              }),
              child: Text(
                state.translate("Show All", "Muuji Dhamaan"),
                style: TextStyle(color: AppColors.accentTeal, fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesList(ThemeData theme, AppState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final filteredTransactions = state.transactions.where((tx) {
      if (!tx.isNegative) return false;
      
      // Period/Bar Filter
      final txLocal = tx.timestamp.toLocal();
      if (_selectedBarIndex != -1) {
        if (_selectedPeriod == 'Yearly') {
          if (txLocal.year != now.year || txLocal.month != _selectedBarIndex + 1) return false;
        } else {
          final targetDate = DateTime.now().subtract(Duration(days: 6 - _selectedBarIndex));
          if (txLocal.year != targetDate.year || txLocal.month != targetDate.month || txLocal.day != targetDate.day) return false;
        }
      } else {
        if (_selectedPeriod == 'Daily' && widget.targetDate != null) {
          final target = widget.targetDate!.toLocal();
          if (txLocal.year != target.year || txLocal.month != target.month || txLocal.day != target.day) return false;
        } else if (_selectedPeriod == 'Monthly' && (txLocal.month != now.month || txLocal.year != now.year)) {
          return false;
        } else if (_selectedPeriod == 'Weekly') {
          final txDate = DateTime(txLocal.year, txLocal.month, txLocal.day);
          if (today.difference(txDate).inDays >= 7) return false;
        } else if (_selectedPeriod == 'Yearly' && txLocal.year != now.year) {
          return false;
        }
      }

      // Category Filter
      if (_selectedCategory != null && tx.category != _selectedCategory) return false;

      return true;
    }).toList();

    final Map<String, double> categorySpending = {};
    for (var tx in filteredTransactions) {
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
          if (_selectedCategory == null) ...[
            Text(
              state.translate("Top Categories", "Qaybaha ugu sarreeya"),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * context.fontSizeFactor),
            ),
            SizedBox(height: 16 * context.fontSizeFactor),
          ],
          if (filteredTransactions.isEmpty)
             Center(child: Padding(
               padding: EdgeInsets.all(20.0 * context.fontSizeFactor),
               child: Text(state.translate("No transactions found", "Wax macaamil ah lama helin"), style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
             ))
          else if (_selectedCategory != null)
            ...filteredTransactions.map((tx) => _buildTransactionItem(context, tx, state))
          else
            ...sortedCategories.take(5).map((entry) {
              final color = _getCategoryColor(entry.key);
              final icon = _getCategoryIcon(entry.key);
              final percentage = totalSpent > 0 ? entry.value / totalSpent : 0.0;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = entry.key),
                child: _buildCategoryItem(
                  context, 
                  entry.key, 
                  NumberFormat.simpleCurrency(name: state.currencyCode).format(entry.value), 
                  color, 
                  icon,
                  percentage
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction tx, AppState state) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(tx.category);
    final icon = _getCategoryIcon(tx.category);

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
                Text(tx.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                if (tx.subCategory != null)
                   Text(tx.subCategory!, style: TextStyle(color: Colors.grey, fontSize: 12 * context.fontSizeFactor)),
                Text(DateFormat('MMM dd, hh:mm a').format(tx.timestamp), style: TextStyle(color: Colors.grey, fontSize: 11 * context.fontSizeFactor)),
              ],
            ),
          ),
          Text(
            NumberFormat.simpleCurrency(name: state.currencyCode).format(tx.numericAmount),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14 * context.fontSizeFactor)
          ),
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
      case 'Bills': return Colors.redAccent;
      case 'Fundraiser': return Colors.deepPurple;
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
      case 'Bills': return FontAwesomeIcons.fileInvoiceDollar;
      case 'Fundraiser': return FontAwesomeIcons.handHoldingHeart;
      default: return FontAwesomeIcons.tag;
    }
  }
}
