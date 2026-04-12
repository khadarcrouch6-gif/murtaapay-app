import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../l10n/app_localizations.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  String? redeemedCode;

  void _redeemVoucher(String code, AppLocalizations l10n) {
    setState(() {
      redeemedCode = code;
    });
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.voucherCopied),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => redeemedCode = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.vouchers,
            style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Directionality.of(context) == TextDirection.rtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 1000,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.horizontalPadding,
                  12,
                  context.horizontalPadding,
                  context.responsiveValue(mobile: 120, tablet: 24, desktop: 24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: Text(
                        l10n.vouchers,
                        style: TextStyle(fontSize: 20 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isWide)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 0,
                        childAspectRatio: 1.8,
                        children: _buildVoucherList(context, l10n, theme, isDark),
                      )
                    else
                      Column(
                        children: _buildVoucherList(context, l10n, theme, isDark),
                      ),
                    
                    const SizedBox(height: 48),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Text(l10n.howToUse, 
                          style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                    ),
                    const SizedBox(height: 20),
                    _buildStep(context, theme, 1, l10n.stepRedeem, 500),
                    _buildStep(context, theme, 2, l10n.stepTransfer, 600),
                    _buildStep(context, theme, 3, l10n.stepPaste, 700),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVoucherList(BuildContext context, AppLocalizations l10n, ThemeData theme, bool isDark) {
    return [
      _buildTicketVoucher(
        context: context,
        l10n: l10n,
        theme: theme,
        isDark: isDark,
        title: l10n.welcomeBonus,
        desc: l10n.welcomeBonusDesc,
        code: "WELCOME5",
        color: const Color(0xFFF59E0B),
        expiry: l10n.expires30Dec,
        icon: Icons.card_giftcard_rounded,
        delay: 100,
      ),
      _buildTicketVoucher(
        context: context,
        l10n: l10n,
        theme: theme,
        isDark: isDark,
        title: l10n.familyFriday,
        desc: l10n.familyFridayDesc,
        code: "FREEFRI",
        color: AppColors.accentTeal,
        expiry: l10n.expiresTomorrow,
        icon: Icons.family_restroom_rounded,
        delay: 200,
      ),
      _buildTicketVoucher(
        context: context,
        l10n: l10n,
        theme: theme,
        isDark: isDark,
        title: l10n.eidSpecial,
        desc: l10n.eidSpecialDesc,
        code: "EID2024",
        color: const Color(0xFF8B5CF6),
        expiry: l10n.expiresIn5Days,
        icon: Icons.mosque_rounded,
        delay: 300,
      ),
    ];
  }

  Widget _buildTicketVoucher({
    required BuildContext context,
    required AppLocalizations l10n,
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String desc,
    required String code,
    required Color color,
    required String expiry,
    required IconData icon,
    required int delay,
  }) {
    bool isRedeemed = redeemedCode == code;
    double stubWidth = 90 * context.fontSizeFactor;

    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isDark ? [] : [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 25, offset: const Offset(0, 10))],
        ),
        child: ClipPath(
          clipper: TicketClipper(stubWidth: stubWidth),
          child: Container(
            color: theme.colorScheme.surface,
            child: Row(
              children: [
                // Left Ticket Stub
                Container(
                  width: stubWidth,
                  height: 160 * context.fontSizeFactor,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 32 * context.fontSizeFactor),
                      const SizedBox(height: 10),
                      RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          l10n.reward,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 10 * context.fontSizeFactor),
                        ),
                      ),
                    ],
                  ),
                ),
                // Ticket Body
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(expiry, style: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6), fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            if (isRedeemed) Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 16 * context.fontSizeFactor),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor, color: theme.textTheme.titleMedium?.color)),
                        const SizedBox(height: 4),
                        Text(desc, style: TextStyle(fontSize: 13 * context.fontSizeFactor, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), height: 1.4)),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _redeemVoucher(code, l10n),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: isRedeemed ? const Color(0xFF10B981) : color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isRedeemed ? const Color(0xFF10B981) : color.withValues(alpha: 0.2)),
                            ),
                            child: Center(
                              child: Text(
                                isRedeemed ? l10n.copied : l10n.redeemNow,
                                style: TextStyle(
                                  color: isRedeemed ? Colors.white : color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14 * context.fontSizeFactor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, ThemeData theme, int number, String text, int delay) {
    final isDark = theme.brightness == Brightness.dark;
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Container(
              width: 36 * context.fontSizeFactor, height: 36 * context.fontSizeFactor,
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surfaceContainerHighest : AppColors.primaryDark.withValues(alpha: 0.08), 
                shape: BoxShape.circle
              ),
              child: Center(child: Text(number.toString(), style: TextStyle(color: isDark ? theme.colorScheme.primary : AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 15 * context.fontSizeFactor, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  final double stubWidth;
  TicketClipper({required this.stubWidth});

  @override
  Path getClip(Size size) {
    final path = Path();
    const double holeRadius = 16;
    // double stubWidth = 100; // Use the passed stubWidth

    path.lineTo(stubWidth - holeRadius, 0);
    path.arcToPoint(
      Offset(stubWidth + holeRadius, 0),
      radius: const Radius.circular(holeRadius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(stubWidth + holeRadius, size.height);
    path.arcToPoint(
      Offset(stubWidth - holeRadius, size.height),
      radius: const Radius.circular(holeRadius),
      clockwise: false,
    );
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
