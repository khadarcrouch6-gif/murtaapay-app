import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
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
      builder: (context) => MaxWidthBox(
        maxWidth: 600,
        child: MaxWidthBox(
          maxWidth: 600,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor)),
            ),
            child: Column(
              children: [
                SizedBox(height: 12 * context.fontSizeFactor),
                Container(
                  width: 40 * context.fontSizeFactor,
                  height: 4 * context.fontSizeFactor,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2 * context.fontSizeFactor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24.0 * context.fontSizeFactor),
                  child: Text(
                    isBuy ? "Select Asset to Buy" : "Select Asset to Sell", 
                    style: TextStyle(
                      fontSize: 20 * context.fontSizeFactor,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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
                          child: AdaptiveIcon(asset.icon, color: asset.color, size: 20 * context.fontSizeFactor),
                        ),
                        title: Text(
                          asset.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * context.fontSizeFactor,
                          ),
                        ),
                        subtitle: Text(
                          isBuy ? asset.symbol : "$holdings ${asset.symbol} available", 
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14 * context.fontSizeFactor,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right, color: AppColors.grey, size: 24 * context.fontSizeFactor),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => MaxWidthBox(
                              maxWidth: 600,
                              child: CryptoBuySellSheet(asset: asset, isBuy: isBuy),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MaxWidthBox(
        maxWidth: 600,
        child: Container(
          padding: EdgeInsets.all(24 * context.fontSizeFactor),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32 * context.fontSizeFactor)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40 * context.fontSizeFactor,
                height: 4 * context.fontSizeFactor,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2 * context.fontSizeFactor),
                ),
              ),
              SizedBox(height: 24 * context.fontSizeFactor),
              _buildMoreMenuItem(context, Icons.notifications_active_outlined, "Price Alerts", "Get notified when prices change"),
              _buildMoreMenuItem(context, Icons.history_rounded, "Transaction History", "View your past crypto trades"),
              _buildMoreMenuItem(context, Icons.account_balance_outlined, "Tax Reports", "Download your investment data"),
              SizedBox(height: 20 * context.fontSizeFactor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMenuItem(BuildContext context, IconData icon, String title, String subtitle) {
    final scale = context.fontSizeFactor;
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 24 * scale),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12 * scale),
      ),
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

    final scale = context.fontSizeFactor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18 * scale),
              decoration: InputDecoration(
                hintText: "Search assets...",
                hintStyle: TextStyle(color: AppColors.grey, fontSize: 18 * scale),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            )
          : Text(l10n.invest, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20 * scale)),
        centerTitle: true,
        leading: _isSearching 
          ? IconButton(
              icon: Icon(Icons.close, color: AppColors.textPrimary, size: 24 * scale),
              onPressed: () => setState(() {
                _isSearching = false;
                _searchQuery = "";
                _searchController.clear();
              }),
            )
          : IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24 * scale),
              onPressed: () => Navigator.pop(context),
            ),
        actions: [
          if (!_isSearching) ...[
            IconButton(
              icon: Icon(Icons.credit_card, color: AppColors.textPrimary, size: 24 * scale),
              onPressed: () {
                state.setNavIndex(1);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            IconButton(
              icon: Icon(Icons.search, color: AppColors.textPrimary, size: 24 * scale),
              onPressed: () => setState(() => _isSearching = true),
            ),
          ]
        ],
      ),
      body: MaxWidthBox(
        maxWidth: 1000,
        child: RefreshIndicator(
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
                  padding: EdgeInsets.all(16.0 * scale),
                  child: FadeInDown(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24 * scale),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.2),
                            blurRadius: 15 * scale,
                            offset: Offset(0, 8 * scale),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.totalInvestment,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            "\$${totalPortfolio.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16 * scale),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.trending_up, color: Colors.greenAccent, size: 16 * scale),
                                SizedBox(width: 4 * scale),
                                Text(
                                  "+5.2% Today",
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12 * scale,
                                  ),
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
                  padding: EdgeInsets.symmetric(vertical: 8 * scale),
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
  
                SizedBox(height: 24 * scale),
  
                // 3. Custom Tab Switcher
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Row(
                    children: [
                      _buildMurtaaxTab("Portfolio", 0, _selectedMainTab == 0),
                      SizedBox(width: 16 * scale),
                      _buildMurtaaxTab("Discover", 1, _selectedMainTab == 1),
                    ],
                  ),
                ),
  
                SizedBox(height: 16 * scale),
  
                // 4. Asset List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
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
                SizedBox(height: 100 * scale),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildMurtaaxBottomNav(context, state),
    );
  }

  Widget _buildMurtaaxBottomNav(BuildContext context, AppState state) {
    final scale = context.fontSizeFactor;
    return MaxWidthBox(
      maxWidth: 800,
      child: Container(
        margin: EdgeInsets.only(
          left: 24 * scale,
          right: 24 * scale,
          bottom: MediaQuery.of(context).padding.bottom + (10 * scale),
        ),
        height: 70 * scale,
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(35 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 25 * scale,
              offset: Offset(0, 10 * scale),
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
      ),
    );
  }

  Widget _buildBottomNavItem(int index, dynamic icon, AppState state) {
    final scale = context.fontSizeFactor;
    bool isSelected = state.selectedNavIndex == index;
    return IconButton(
      onPressed: () {
        state.setNavIndex(index);
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      icon: AdaptiveIcon(
        icon,
        color: isSelected ? AppColors.accentTeal : Colors.white.withValues(alpha: 0.5),
        size: 20 * scale,
      ),
    );
  }

  Widget _buildCenterNavItem(AppState state) {
    final scale = context.fontSizeFactor;
    bool isSelected = state.selectedNavIndex == 2;
    return GestureDetector(
      onTap: () {
        state.setNavIndex(2);
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Container(
        height: 50 * scale,
        width: 50 * scale,
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.accentGradient : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AdaptiveIcon(
            FontAwesomeIcons.paperPlane,
            color: Colors.white,
            size: 22 * scale,
          ),
        ),
      ),
    );
  }

  Widget _buildMurtaaxAction(String label, dynamic icon, Color color, VoidCallback onTap) {
    final scale = context.fontSizeFactor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16 * scale),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16 * scale),
            ),
            child: AdaptiveIcon(icon, color: color, size: 28 * scale),
          ),
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMurtaaxTab(String label, int index, bool isSelected) {
    final scale = context.fontSizeFactor;
    return GestureDetector(
      onTap: () => setState(() => _selectedMainTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.textPrimary : AppColors.grey,
            ),
          ),
          SizedBox(height: 4 * scale),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3 * scale,
            width: isSelected ? 30 * scale : 0,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMurtaaxAssetItem(BuildContext context, CryptoAsset asset) {
    final scale = context.fontSizeFactor;
    final isUp = asset.change24h >= 0;
    final isFavorite = _favorites.contains(asset.symbol);

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CryptoDetailScreen(asset: asset))),
        child: Row(
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                color: asset.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: AdaptiveIcon(asset.icon, color: asset.color, size: 24 * scale)),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        asset.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * scale,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4 * scale),
                      if (_selectedMainTab == 1)
                        GestureDetector(
                          onTap: () => _toggleFavorite(asset.symbol),
                          child: Icon(
                            isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: isFavorite ? Colors.orange : AppColors.grey,
                            size: 18 * scale,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    asset.holdings > 0 ? "${asset.holdings} ${asset.symbol}" : asset.symbol,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12 * scale),
                  ),
                ],
              ),
            ),
            // Sparkline Mock
            SizedBox(
              width: 60 * scale,
              height: 30 * scale,
              child: CustomPaint(
                painter: SparklinePainter(color: isUp ? Colors.green : Colors.red, isUp: isUp),
              ),
            ),
            SizedBox(width: 12 * scale),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${(asset.holdings > 0 ? asset.totalValue : asset.price).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16 * scale,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.trending_up : Icons.trending_down,
                      color: isUp ? Colors.green : Colors.red,
                      size: 14 * scale,
                    ),
                    SizedBox(width: 4 * scale),
                    Text(
                      "${asset.change24h.abs()}%",
                      style: TextStyle(
                        color: isUp ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12 * scale,
                      ),
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
    final scale = context.fontSizeFactor;
    return Container(
      padding: EdgeInsets.all(32 * scale),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64 * scale,
            color: AppColors.grey.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16 * scale),
          Text(
            "No Investments Yet",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 18 * scale,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            "Start building your crypto portfolio today with Murtaax Pay.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14 * scale),
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
