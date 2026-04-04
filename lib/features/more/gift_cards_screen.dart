import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';

class GiftCardsScreen extends StatefulWidget {
  final bool isTab;
  const GiftCardsScreen({super.key, this.isTab = false});

  @override
  State<GiftCardsScreen> createState() => _GiftCardsScreenState();
}

class _GiftCardsScreenState extends State<GiftCardsScreen> {
  void _showPurchaseSheet(String brand, Color color, AppState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: EdgeInsets.all(32 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32))
        ),
        child: Center(
          child: MaxWidthBox(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, 
                    height: 4, 
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300], 
                      borderRadius: BorderRadius.circular(2)
                    )
                  )
                ),
                const SizedBox(height: 32),
                Text("${state.translate("Buy", "Iibso", ar: "شراء", de: "Kaufen")} $brand", 
                    style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                const SizedBox(height: 8),
                Text(state.translate("Select amount for your gift card", "Dooro cadadka kaarkaaga", ar: "اختر المبلغ لبطاقة الهدايا الخاصة بك", de: "Wählen Sie den Betrag für Ihre Geschenkkarte"), 
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14 * context.fontSizeFactor)),
                const SizedBox(height: 32),
                SizedBox(
                  height: 300 * context.fontSizeFactor,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2,
                    children: ["\$10", "\$25", "\$50", "\$100", "\$200", "\$500"].map((amount) {
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? theme.colorScheme.surfaceContainerHighest : AppColors.background, 
                          borderRadius: BorderRadius.circular(12), 
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1))
                        ),
                        child: Center(child: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color, fontSize: 16 * context.fontSizeFactor))),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 60 * context.fontSizeFactor,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      shadowColor: isDark ? Colors.transparent : color.withValues(alpha: 0.4),
                    ),
                    child: Text(state.translate("Confirm Purchase", "Xaqiiji Iibka", ar: "تأكيد الشراء", de: "Kauf bestätigen"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget body = Center(
      child: MaxWidthBox(
        maxWidth: 1200,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: context.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.translate("Popular Brands", "Shirkadaha Caanka ah", ar: "العلامات التجارية الشهيرة", de: "Beliebte Marken"), 
                  style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
              const SizedBox(height: 16),
              SizedBox(
                height: 220 * context.fontSizeFactor,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                     _buildGraphicalCard(context, theme, isDark, "Netflix", state.translate("Movies & TV", "Filimada & TV-ga", ar: "أفلام وتلفزيون", de: "Filme & TV"), const Color(0xFFE50914), const Color(0xFF831010), FontAwesomeIcons.film, 100, state),
                     _buildGraphicalCard(context, theme, isDark, "Amazon", state.translate("Shopping", "Adeegga", ar: "تسوق", de: "Shopping"), const Color(0xFFFF9900), const Color(0xFFB36B00), FontAwesomeIcons.amazon, 200, state),
                     _buildGraphicalCard(context, theme, isDark, "App Store", state.translate("Games & Apps", "Ciyaaraha & Apps-ka", ar: "ألعاب وتطبيقات", de: "Spiele & Apps"), const Color(0xFF007AFF), const Color(0xFF0055B3), FontAwesomeIcons.apple, 300, state),
                     _buildGraphicalCard(context, theme, isDark, "PlayStation", state.translate("Gaming", "Ciyaaraha", ar: "ألعاب", de: "Gaming"), const Color(0xFF003791), const Color(0xFF001F52), FontAwesomeIcons.playstation, 400, state),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Text(state.translate("Somali Airtime", "Ku-shubashada Soomaaliya", ar: "شحن الرصيد في الصومال", de: "Somali-Guthaben"), 
                  style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  if (isWide) {
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 0,
                      childAspectRatio: 3.5,
                      children: [
                        _buildAirtimeItem(context, theme, isDark, "Hormuud", "EVC Plus Recharge", const Color(0xFF003366), 100, state),
                        _buildAirtimeItem(context, theme, isDark, "Somtel", "EDahab Recharge", const Color(0xFFE60000), 200, state),
                        _buildAirtimeItem(context, theme, isDark, "Telesom", "ZAAD Recharge", const Color(0xFF008000), 300, state),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildAirtimeItem(context, theme, isDark, "Hormuud", "EVC Plus Recharge", const Color(0xFF003366), 100, state),
                      _buildAirtimeItem(context, theme, isDark, "Somtel", "EDahab Recharge", const Color(0xFFE60000), 200, state),
                      _buildAirtimeItem(context, theme, isDark, "Telesom", "ZAAD Recharge", const Color(0xFF008000), 300, state),
                    ],
                  );
                }
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) => widget.isTab ? body : Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(state.translate("Gift Cards & Airtime", "Kaararka & Ku-shubashada", ar: "بطاقات الهدايا والرصيد", de: "Geschenkkarten & Guthaben"), 
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color, fontSize: 20 * context.fontSizeFactor)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(state.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: body,
      ),
    );
  }


  Widget _buildGraphicalCard(BuildContext context, ThemeData theme, bool isDark, String title, String desc, Color colorStart, Color colorEnd, IconData icon, int delay, AppState state) {
    return FadeInRight(
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: () => _showPurchaseSheet(title, colorStart, state),
        child: Container(
          width: 300 * context.fontSizeFactor,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.all(28 * context.fontSizeFactor),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [colorStart, colorEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(32),
            boxShadow: isDark ? [] : [BoxShadow(color: colorStart.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FaIcon(icon, color: Colors.white, size: 40 * context.fontSizeFactor),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: Text(state.translate("Digital", "Digital", ar: "رقمي", de: "Digital"), style: TextStyle(color: Colors.white, fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirtimeItem(BuildContext context, ThemeData theme, bool isDark, String title, String desc, Color color, int delay, AppState state) {
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
              width: 56 * context.fontSizeFactor, height: 56 * context.fontSizeFactor,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
              child: Center(child: Icon(Icons.phone_android_rounded, color: color, size: 28 * context.fontSizeFactor)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17 * context.fontSizeFactor, color: theme.textTheme.titleMedium?.color)),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SizedBox(
              height: 40 * context.fontSizeFactor,
              child: ElevatedButton(
                onPressed: () => _showPurchaseSheet(title, color, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Text(state.translate("Buy", "Iibso", ar: "شراء", de: "Kaufen"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

