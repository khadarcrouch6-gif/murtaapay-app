import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../l10n/app_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

class InvestmentsScreen extends StatelessWidget {
  final bool isTab;
  const InvestmentsScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        isTab ? 24 : context.horizontalPadding,
        context.horizontalPadding,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(32 * context.fontSizeFactor),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Text(l10n.totalInvestment, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Text("\$12,450.80", style: TextStyle(color: Colors.white, fontSize: 36 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up_rounded, color: Colors.green[400], size: 18 * context.fontSizeFactor),
                        const SizedBox(width: 8),
                        Text("+\$1,240.50 (12.5%)", style: TextStyle(color: Colors.green[400], fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(l10n.yourPortfolio, style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
          const SizedBox(height: 20),
          _buildAssetCard(context, l10n, l10n.bitcoin, "BTC", "0.45", "\$18,240.00", 5.2, FontAwesomeIcons.bitcoin, const Color(0xFFF7931A), 200, theme, isDark),
          _buildAssetCard(context, l10n, l10n.ethereum, "ETH", "2.5", "\$4,820.50", -2.1, FontAwesomeIcons.ethereum, const Color(0xFF627EEA), 300, theme, isDark),
          _buildAssetCard(context, l10n, l10n.gold, "XAU", "10 oz", "\$20,450.00", 0.8, FontAwesomeIcons.coins, const Color(0xFFFFD700), 400, theme, isDark),
          
          const SizedBox(height: 40),
          Text(l10n.investmentOpportunities, style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
          const SizedBox(height: 20),
          _buildOpportunityCard(context, l10n, l10n.realEstate, "15% ROI", l10n.realEstateDesc, Icons.business_rounded, Colors.blue, 500, theme, isDark),
          _buildOpportunityCard(context, l10n, l10n.agriculture, "12% ROI", l10n.agricultureDesc, Icons.agriculture_rounded, Colors.green, 600, theme, isDark),
        ],
      ),
    );

    if (isTab) return content;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.invest, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(child: MaxWidthBox(maxWidth: 800, child: content)),
    );
  }

  Widget _buildAssetCard(BuildContext context, AppLocalizations l10n, String name, String symbol, String amount, String value, double delta, dynamic icon, Color color, int delay, ThemeData theme, bool isDark) {
    bool isUp = delta >= 0;
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
          border: isDark ? Border.all(color: theme.dividerColor.withValues(alpha: 0.1)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52 * context.fontSizeFactor, height: 52 * context.fontSizeFactor,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
              child: Center(child: AdaptiveIcon(icon, color: color, size: 24 * context.fontSizeFactor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.titleMedium?.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$amount $symbol", 
                    style: TextStyle(color: theme.textTheme.bodySmall?.color ?? AppColors.grey, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.titleMedium?.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: isUp ? Colors.green : Colors.red, size: 14 * context.fontSizeFactor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "${isUp ? '+' : ''}$delta%", 
                          style: TextStyle(color: isUp ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, AppLocalizations l10n, String title, String roi, String desc, dynamic icon, Color color, int delay, ThemeData theme, bool isDark) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(24 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? theme.dividerColor.withValues(alpha: 0.1) : color.withValues(alpha: 0.1)),
          boxShadow: isDark ? [] : [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              width: 60 * context.fontSizeFactor, height: 60 * context.fontSizeFactor,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
              child: AdaptiveIcon(icon, color: color, size: 28 * context.fontSizeFactor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.titleMedium?.color)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: theme.textTheme.bodySmall?.color ?? AppColors.grey, fontSize: 12 * context.fontSizeFactor, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark ? [] : [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Text(roi, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11 * context.fontSizeFactor)),
            ),
          ],
        ),
      ),
    );
  }
}
