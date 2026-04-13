import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  void _copyCode(BuildContext context, String code, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.referralCodeCopied),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    const referralCode = "MURTAAX77";
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.referAndEarn, 
            style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 1000,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 10),
                FadeInDown(
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Container(
                        height: 240 * context.fontSizeFactor,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: isDark ? [] : [BoxShadow(color: const Color(0xFF203A43).withValues(alpha: 0.3), blurRadius: 25, offset: const Offset(0, 15))],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated background elements
                            Positioned(
                              top: -20, right: -20,
                              child: Icon(Icons.stars_rounded, color: Colors.white.withValues(alpha: 0.05), size: 150 * context.fontSizeFactor),
                            ),
                            Positioned(
                              bottom: 30, left: 40,
                              child: Icon(Icons.auto_awesome_rounded, color: Colors.white.withValues(alpha: 0.1), size: 40 * context.fontSizeFactor),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 80 * context.fontSizeFactor, width: 80 * context.fontSizeFactor,
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
                                  child: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 40 * context.fontSizeFactor),
                                ),
                                const SizedBox(height: 20),
                                Text(l10n.rewardsWaiting, style: TextStyle(color: Colors.white, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  child: MaxWidthBox(
                    maxWidth: 600,
                    child: Text(
                      l10n.inviteFriendsGet10,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: MaxWidthBox(
                    maxWidth: 600,
                    child: Text(
                      l10n.referralDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 15 * context.fontSizeFactor, height: 1.6, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Referral Code UI
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Column(
                        children: [
                          Text(l10n.yourReferralCode, style: TextStyle(fontSize: 13 * context.fontSizeFactor, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6), fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = constraints.maxWidth < 450;
                                if (isMobile) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 24),
                                        child: Text(
                                          referralCode,
                                          style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 6, color: theme.textTheme.titleLarge?.color),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _copyCode(context, referralCode, l10n),
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [AppColors.accentTeal, Color(0xFF10B981)]),
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: isDark ? [] : [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                                          ),
                                          child: Center(child: Text(l10n.copy, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor))),
                                        ),
                                      )
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          referralCode,
                                          style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 6, color: theme.textTheme.titleLarge?.color),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _copyCode(context, referralCode, l10n),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 16 * context.fontSizeFactor),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [AppColors.accentTeal, Color(0xFF10B981)]),
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: isDark ? [] : [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                                        ),
                                        child: Text(l10n.copy, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Social Sharing
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 60 * context.fontSizeFactor,
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isDark ? [] : [BoxShadow(color: const Color(0xFF25D366).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.whatsapp, size: 20 * context.fontSizeFactor, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          l10n.whatsApp,
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15 * context.fontSizeFactor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 60 * context.fontSizeFactor, height: 60 * context.fontSizeFactor,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 6))],
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.ios_share_rounded, color: theme.colorScheme.primary, size: 26 * context.fontSizeFactor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

