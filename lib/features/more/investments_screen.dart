import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/models/crypto_asset.dart';
import '../../l10n/app_localizations.dart';
import 'crypto_detail_screen.dart';
import 'widgets/crypto_buy_sell_sheet.dart';

class InvestmentsScreen extends StatefulWidget {
  final bool isTab;
  const InvestmentsScreen({super.key, this.isTab = false});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  int _selectedMainTab = 0; // 0: Portfolio, 1: Discover
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final Set<String> _favorites = {"BTC", "ETH"}; // Mock favorites

  List<CryptoAsset> _getAvailableAssets(AppLocalizations l10n) {
    return [
      CryptoAsset(symbol: "BTC", name: l10n.bitcoin, price: 64250.80, change24h: 5.2, icon: FontAwesomeIcons.bitcoin, color: const Color(0xFFF7931A)),
      CryptoAsset(symbol: "ETH", name: l10n.ethereum, price: 3450.50, change24h: -2.1, icon: FontAwesomeIcons.ethereum, color: const Color(0xFF627EEA)),
      CryptoAsset(symbol: "SOL", name: "Solana", price: 145.20, change24h: 12.5, icon: Icons.wb_sunny_rounded, color: const Color(0xFF14F195)),
      CryptoAsset(symbol: "USDT", name: "Tether", price: 1.00, change24h: 0.01, icon: Icons.monetization_on_rounded, color: const Color(0xFF26A17B)),
      CryptoAsset(symbol: "XRP", name: "Ripple", price: 0.62, change24h: -1.5, icon: FontAwesomeIcons.xmark, color: const Color(0xFF23292F)),
      CryptoAsset(symbol: "ADA", name: "Cardano", price: 0.45, change24h: 3.1, icon: Icons.hexagon_outlined, color: const Color(0xFF0033AD)),
      CryptoAsset(symbol: "DOT", name: "Polkadot", price: 7.20, change24h: -0.8, icon: Icons.circle_outlined, color: const Color(0xFFE6007A)),
    ];
  }

  double _calculateTotalPortfolio(AppState state, List<CryptoAsset> assets) {
    double total = 0;
    state.cryptoHoldings.forEach((symbol, amount) {
      try {
        final asset = assets.firstWhere((a) => a.symbol == symbol);
        total += amount * asset.price;
      } catch (_) {}
    });
    return total;
  }

  void _toggleFavorite(String symbol) {
    setState(() {
      if (_favorites.contains(symbol)) {
        _favorites.remove(symbol);
      } else {
        _favorites.add(symbol);
      }
    });
  }

  void _showTradeSheet(BuildContext context, List<CryptoAsset> allAssets, {required bool isBuy}) {
    final state = Provider.of<AppState>(context, listen: false);
    final assets = isBuy 
        ? allAssets 
        : allAssets.where((a) => (state.cryptoHoldings[a.symbol] ?? 0) > 0).toList();

    if (assets.isEmpty && !isBuy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You don't have any assets to sell")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                isBuy ? "Select Asset to Buy" : "Select Asset to Sell", 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  final holdings = state.cryptoHoldings[asset.symbol] ?? 0;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: asset.color.withValues(alpha: 0.1),
                      child: AdaptiveIcon(asset.icon, color: asset.color, size: 20),
                    ),
                    title: Text(asset.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      isBuy ? asset.symbol : "$holdings ${asset.symbol} available", 
                      style: const TextStyle(color: AppColors.textSecondary)
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CryptoBuySellSheet(asset: asset, isBuy: isBuy),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            _buildMoreMenuItem(context, Icons.notifications_active_outlined, "Price Alerts", "Get notified when prices change"),
            _buildMoreMenuItem(context, Icons.history_rounded, "Transaction History", "View your past crypto trades"),
            _buildMoreMenuItem(context, Icons.account_balance_outlined, "Tax Reports", "Download your investment data"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenuItem(BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.secondary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);
    final allAssets = _getAvailableAssets(l10n);
    
    // Filter logic
    List<CryptoAsset> displayAssets = List.from(allAssets);
    if (_searchQuery.isNotEmpty) {
      displayAssets = displayAssets.where((a) => 
        a.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
        a.symbol.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    final totalPortfolio = _calculateTotalPortfolio(state, allAssets);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: "Search assets...",
                hintStyle: TextStyle(color: AppColors.grey),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            )
          : Text(l10n.invest, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: _isSearching 
          ? IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => setState(() {
                _isSearching = false;
                _searchQuery = "";
                _searchController.clear();
              }),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
        actions: [
          if (!_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.credit_card, color: AppColors.textPrimary),
              onPressed: () {
                state.setNavIndex(1);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textPrimary),
              onPressed: () => setState(() => _isSearching = true),
            ),
          ]
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) setState(() {});
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Portfolio Value Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeInDown(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.totalInvestment,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "\$${totalPortfolio.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "+5.2% Today",
                                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMurtaaxAction(l10n.buy, Icons.add_circle_outline, AppColors.secondary, () => _showTradeSheet(context, allAssets, isBuy: true)),
                    _buildMurtaaxAction(l10n.sell, Icons.remove_circle_outline, Colors.orange, () => _showTradeSheet(context, allAssets, isBuy: false)),
                    _buildMurtaaxAction("Exchange", Icons.swap_horizontal_circle_outlined, AppColors.accentTeal, () {
                      _showTradeSheet(context, allAssets, isBuy: true);
                    }),
                    _buildMurtaaxAction("More", Icons.more_horiz_rounded, AppColors.grey, () {
                      _showMoreMenu(context);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Custom Tab Switcher
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildMurtaaxTab("Portfolio", 0, _selectedMainTab == 0),
                    const SizedBox(width: 16),
                    _buildMurtaaxTab("Discover", 1, _selectedMainTab == 1),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Asset List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedMainTab == 0 
                  ? (state.cryptoHoldings.isEmpty ? 1 : state.cryptoHoldings.length)
                  : displayAssets.length,
                itemBuilder: (context, index) {
                  if (_selectedMainTab == 0 && state.cryptoHoldings.isEmpty) {
                    return _buildEmptyPortfolio();
                  }

                  var asset = _selectedMainTab == 0
                      ? allAssets.firstWhere(
                          (a) => a.symbol == state.cryptoHoldings.keys.elementAt(index),
                          orElse: () => allAssets[0],
                        )
                      : displayAssets[index];
                  
                  if (state.cryptoHoldings.containsKey(asset.symbol)) {
                     asset = asset.copyWith(holdings: state.cryptoHoldings[asset.symbol] ?? 0);
                  }

                  return _buildMurtaaxAssetItem(context, asset);
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildMurtaaxBottomNav(context, state),
    );
  }

  Widget _buildMurtaaxBottomNav(BuildContext context, AppState state) {
    return Container(
      margin: EdgeInsets.only(left: 24, right: 24, bottom: MediaQuery.of(context).padding.bottom + 10),
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(0, FontAwesomeIcons.house, state),
          _buildBottomNavItem(1, FontAwesomeIcons.clockRotateLeft, state),
          _buildCenterNavItem(state),
          _buildBottomNavItem(3, FontAwesomeIcons.creditCard, state),
          _buildBottomNavItem(4, FontAwesomeIcons.user, state),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(int index, dynamic icon, AppState state) {
    bool isSelected = state.selectedNavIndex == index;
    return IconButton(
      onPressed: () {
        state.setNavIndex(index);
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      icon: AdaptiveIcon(icon, color: isSelected ? AppColors.accentTeal : Colors.white.withValues(alpha: 0.5), size: 20),
    );
  }

  Widget _buildCenterNavItem(AppState state) {
    bool isSelected = state.selectedNavIndex == 2;
    return GestureDetector(
      onTap: () {
        state.setNavIndex(2);
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Container(
        height: 50, width: 50,
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.accentGradient : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle
        ),
        child: const Center(child: AdaptiveIcon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 22)),
      ),
    );
  }

  Widget _buildMurtaaxAction(String label, dynamic icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AdaptiveIcon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildMurtaaxTab(String label, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMainTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.textPrimary : AppColors.grey,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 30 : 0,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMurtaaxAssetItem(BuildContext context, CryptoAsset asset) {
    final isUp = asset.change24h >= 0;
    final isFavorite = _favorites.contains(asset.symbol);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CryptoDetailScreen(asset: asset))),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: asset.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: AdaptiveIcon(asset.icon, color: asset.color, size: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      const SizedBox(width: 4),
                      if (_selectedMainTab == 1)
                        GestureDetector(
                          onTap: () => _toggleFavorite(asset.symbol),
                          child: Icon(
                            isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: isFavorite ? Colors.orange : AppColors.grey,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    asset.holdings > 0 ? "${asset.holdings} ${asset.symbol}" : asset.symbol,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Sparkline Mock
            SizedBox(
              width: 60,
              height: 30,
              child: CustomPaint(
                painter: SparklinePainter(color: isUp ? Colors.green : Colors.red, isUp: isUp),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${(asset.holdings > 0 ? asset.totalValue : asset.price).toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(isUp ? Icons.trending_up : Icons.trending_down, color: isUp ? Colors.green : Colors.red, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${asset.change24h.abs()}%",
                      style: TextStyle(color: isUp ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPortfolio() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text("No Investments Yet", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            "Start building your crypto portfolio today with Murtaax Pay.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final Color color;
  final bool isUp;

  SparklinePainter({required this.color, required this.isUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    if (isUp) {
      path.moveTo(0, size.height * 0.8);
      path.quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.4, size.height * 0.5);
      path.quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.4);
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, 0);
      path.quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.5, size.height * 0.3);
      path.quadraticBezierTo(size.width * 0.8, size.height * 0.1, size.width, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
