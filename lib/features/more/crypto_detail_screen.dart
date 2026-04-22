import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/models/crypto_asset.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBuy ? "Crypto purchased successfully!" : "Crypto sold successfully!"),
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
        title: Text(widget.asset.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.star_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Header Section
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      if (holdings > 0) ...[
                        Text(
                          "${holdings.toStringAsFixed(6)} ${widget.asset.symbol}",
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "≈ \$${holdingsValue.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 18, color: theme.hintColor, fontWeight: FontWeight.w500),
                        ),
                      ] else ...[
                        Text(
                          "\$${widget.asset.price.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.asset.change24h >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: widget.asset.change24h >= 0 ? Colors.green : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.asset.change24h >= 0 ? '+' : ''}${widget.asset.change24h}%",
                              style: TextStyle(
                                color: widget.asset.change24h >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text("Past 24h", style: TextStyle(color: theme.hintColor, fontSize: 13)),
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
              height: 220,
              width: double.infinity,
              child: CustomPaint(
                painter: LineChartPainter(
                  data: _chartData,
                  color: widget.asset.change24h >= 0 ? AppColors.accentTeal : Colors.redAccent,
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildTimeframeSelector(theme),

            // Portfolio Details (If owned)
            if (holdings > 0) ...[
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(theme, "Avg. Cost", "\$${(widget.asset.price * 0.98).toStringAsFixed(2)}"),
                    _buildStatCard(theme, "Return", "+12.4%", valueColor: Colors.green),
                  ],
                ),
              ),
            ],

            // Transaction History Section (Dedicated Wallet Style)
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (assetTransactions.length > 3)
                    TextButton(onPressed: () {}, child: const Text("See All")),
                ],
              ),
            ),
            if (assetTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, size: 48, color: theme.hintColor.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text("No transactions yet", style: TextStyle(color: theme.hintColor)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assetTransactions.take(5).length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final tx = assetTransactions[index];
                  final isBuy = tx.type == 'crypto_buy';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (isBuy ? AppColors.accentTeal : Colors.redAccent).withValues(alpha: 0.1),
                      child: Icon(
                        isBuy ? Icons.add_rounded : Icons.remove_rounded,
                        color: isBuy ? AppColors.accentTeal : Colors.redAccent,
                      ),
                    ),
                    title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(tx.date),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          tx.amount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isBuy ? Colors.redAccent : Colors.green, // Buying spends money (-), Selling adds (+)
                          ),
                        ),
                        Text(
                          tx.status,
                          style: TextStyle(fontSize: 12, color: theme.hintColor),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // About Section
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text("About ${widget.asset.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${widget.asset.name} is a decentralized digital currency, without a central bank or single administrator, that can be sent from user to user on the peer-to-peer network without the need for intermediaries.",
                  style: TextStyle(color: theme.hintColor, height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 140),
          ],
        ),
      ),
      bottomSheet: _buildActionButtons(context, theme, l10n, holdings),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, {Color? valueColor}) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor, fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, AppLocalizations l10n, double holdings) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (holdings > 0) ...[
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _showBuySellSheet(false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Sell", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showBuySellSheet(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Buy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector(ThemeData theme) {
    final timeframes = ["1H", "24H", "1W", "1M", "1Y", "ALL"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: timeframes.map((tf) {
          final isSelected = _selectedTimeframe == tf;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeframe = tf),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tf,
                style: TextStyle(
                  color: isSelected ? AppColors.accentTeal : theme.hintColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
