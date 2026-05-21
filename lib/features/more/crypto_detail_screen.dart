import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:math';
import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/models/crypto_asset.dart';
import '../../../core/responsive_utils.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/crypto_buy_sell_sheet.dart';

class CryptoDetailScreen extends StatefulWidget {
  final CryptoAsset asset;

  const CryptoDetailScreen({super.key, required this.asset});

  @override
  State<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen> {
  String _selectedTimeframe = "24H";
  late List<double> _chartData;

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    final random = Random();
    _chartData = List.generate(20, (index) => widget.asset.price * (0.95 + random.nextDouble() * 0.1));
  }

  void _showBuySellSheet(bool isBuy) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CryptoBuySellSheet(asset: widget.asset, isBuy: isBuy),
    );

    if (result == true && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBuy ? l10n.cryptoPurchased : l10n.cryptoSold),
          backgroundColor: AppColors.accentTeal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);
    final holdings = state.cryptoHoldings[widget.asset.symbol] ?? 0.0;
    final holdingsValue = holdings * widget.asset.price;

    // Filter transactions for this specific asset
    final assetTransactions = state.transactions.where((tx) => 
      (tx.type == 'crypto_buy' || tx.type == 'crypto_sell') && tx.referenceId == widget.asset.symbol
    ).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.asset.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, size: 24 * context.fontSizeFactor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.star_outline_rounded, size: 24 * context.fontSizeFactor),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 800,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Header Section
                FadeInDown(
                  child: Padding(
                    padding: EdgeInsets.all(24.0 * context.fontSizeFactor),
                    child: Center(
                      child: Column(
                        children: [
                          if (holdings > 0) ...[
                            Text(
                              "${holdings.toStringAsFixed(6)} ${widget.asset.symbol}",
                              style: TextStyle(fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4 * context.fontSizeFactor),
                            Text(
                              "≈ \$${holdingsValue.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 18 * context.fontSizeFactor, color: theme.hintColor, fontWeight: FontWeight.w500),
                            ),
                          ] else ...[
                            Text(
                              "\$${widget.asset.price.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4 * context.fontSizeFactor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.asset.change24h >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                  color: widget.asset.change24h >= 0 ? Colors.green : Colors.red,
                                  size: 18 * context.fontSizeFactor,
                                ),
                                SizedBox(width: 4 * context.fontSizeFactor),
                                Text(
                                  "${widget.asset.change24h >= 0 ? '+' : ''}${widget.asset.change24h}%",
                                  style: TextStyle(
                                    color: widget.asset.change24h >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15 * context.fontSizeFactor,
                                  ),
                                ),
                                SizedBox(width: 8 * context.fontSizeFactor),
                                Text(l10n.past24h, style: TextStyle(color: theme.hintColor, fontSize: 13 * context.fontSizeFactor)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Chart Section
                SizedBox(
                  height: 220 * context.fontSizeFactor,
                  width: double.infinity,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: LineChartPainter(
                        data: _chartData,
                        color: widget.asset.change24h >= 0 ? AppColors.accentTeal : Colors.redAccent,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16 * context.fontSizeFactor),
                _buildTimeframeSelector(theme),

                // Portfolio Details (If owned)
                if (holdings > 0) ...[
                  SizedBox(height: 32 * context.fontSizeFactor),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0 * context.fontSizeFactor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard(theme, l10n.avgCost, "\$${(widget.asset.price * 0.98).toStringAsFixed(2)}"),
                        SizedBox(width: 16 * context.fontSizeFactor),
                        _buildStatCard(theme, l10n.returnLabel, "+12.4%", valueColor: Colors.green),
                      ],
                    ),
                  ),
                ],

                // Transaction History Section (Dedicated Wallet Style)
                SizedBox(height: 40 * context.fontSizeFactor),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0 * context.fontSizeFactor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.transactions, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                      if (assetTransactions.length > 3)
                        TextButton(onPressed: () {}, child: Text(l10n.seeAll, style: TextStyle(fontSize: 14 * context.fontSizeFactor))),
                    ],
                  ),
                ),
                if (assetTransactions.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(32.0 * context.fontSizeFactor),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.history_rounded, size: 48 * context.fontSizeFactor, color: theme.hintColor.withValues(alpha: 0.3)),
                          SizedBox(height: 12 * context.fontSizeFactor),
                          Text(l10n.noTransactionsYet, style: TextStyle(color: theme.hintColor, fontSize: 14 * context.fontSizeFactor)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: assetTransactions.take(5).length,
                    padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor),
                    itemBuilder: (context, index) {
                      final tx = assetTransactions[index];
                      final isBuy = tx.type == 'crypto_buy';
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20 * context.fontSizeFactor,
                          backgroundColor: (isBuy ? AppColors.accentTeal : Colors.redAccent).withValues(alpha: 0.1),
                          child: Icon(
                            isBuy ? Icons.add_rounded : Icons.remove_rounded,
                            color: isBuy ? AppColors.accentTeal : Colors.redAccent,
                            size: 20 * context.fontSizeFactor,
                          ),
                        ),
                        title: Text(tx.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16 * context.fontSizeFactor)),
                        subtitle: Text(tx.date, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              tx.amount,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * context.fontSizeFactor,
                                color: isBuy ? Colors.redAccent : Colors.green, // Buying spends money (-), Selling adds (+)
                              ),
                            ),
                            Text(
                              tx.status,
                              style: TextStyle(fontSize: 12 * context.fontSizeFactor, color: theme.hintColor),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                // About Section
                SizedBox(height: 40 * context.fontSizeFactor),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0 * context.fontSizeFactor),
                  child: Text(l10n.aboutAsset(widget.asset.name), style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(24.0 * context.fontSizeFactor),
                  child: Container(
                    padding: EdgeInsets.all(20 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: isDark ? theme.colorScheme.surface : Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                    ),
                    child: Text(
                      l10n.cryptoDescription(widget.asset.name),
                      style: TextStyle(color: theme.hintColor, height: 1.6, fontSize: 14 * context.fontSizeFactor),
                    ),
                  ),
                ),
                SizedBox(height: 140 * context.fontSizeFactor),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _buildActionButtons(context, theme, l10n, holdings),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16 * context.fontSizeFactor),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: theme.hintColor, fontSize: 13 * context.fontSizeFactor)),
            SizedBox(height: 8 * context.fontSizeFactor),
            Text(value, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, AppLocalizations l10n, double holdings) {
    return Center(
      child: MaxWidthBox(
        maxWidth: 800,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24 * context.fontSizeFactor,
            16 * context.fontSizeFactor,
            24 * context.fontSizeFactor,
            MediaQuery.of(context).padding.bottom + 16 * context.fontSizeFactor,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              if (holdings > 0) ...[
                Expanded(
                  child: SizedBox(
                    height: 56 * context.fontSizeFactor,
                    child: OutlinedButton(
                      onPressed: () => _showBuySellSheet(false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.redAccent, width: 2 * context.fontSizeFactor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                      ),
                      child: Text(l10n.sell, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                    ),
                  ),
                ),
                SizedBox(width: 16 * context.fontSizeFactor),
              ],
              Expanded(
                child: SizedBox(
                  height: 56 * context.fontSizeFactor,
                  child: ElevatedButton(
                    onPressed: () => _showBuySellSheet(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * context.fontSizeFactor)),
                      elevation: 0,
                    ),
                    child: Text(l10n.buy, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector(ThemeData theme) {
    final timeframes = ["1H", "24H", "1W", "1M", "1Y", "ALL"];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0 * context.fontSizeFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: timeframes.map((tf) {
          final isSelected = _selectedTimeframe == tf;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeframe = tf),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
              ),
              child: Text(
                tf,
                style: TextStyle(
                  color: isSelected ? AppColors.accentTeal : theme.hintColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14 * context.fontSizeFactor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minVal) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
