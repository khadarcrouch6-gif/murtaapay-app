import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:ui' as ui;

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
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
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
          icon: Icon(Icons.arrow_back_rounded, color: theme.iconTheme.color, size: 24 * context.fontSizeFactor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 1000,
            child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 12 * context.fontSizeFactor),
            child: Column(
              children: [
                SizedBox(height: 10 * context.fontSizeFactor),
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
                          borderRadius: BorderRadius.circular(40 * context.fontSizeFactor),
                          boxShadow: isDark ? [] : [BoxShadow(color: const Color(0xFF203A43).withValues(alpha: 0.3), blurRadius: 25 * context.fontSizeFactor, offset: Offset(0, 15 * context.fontSizeFactor))],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated background elements
                            Positioned(
                              top: -20 * context.fontSizeFactor, right: -20 * context.fontSizeFactor,
                              child: Icon(Icons.stars_rounded, color: Colors.white.withValues(alpha: 0.05), size: 150 * context.fontSizeFactor),
                            ),
                            Positioned(
                              bottom: 30 * context.fontSizeFactor, left: 40 * context.fontSizeFactor,
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
                                SizedBox(height: 20 * context.fontSizeFactor),
                                Text(l10n.rewardsWaiting, style: TextStyle(color: Colors.white, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40 * context.fontSizeFactor),
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
                SizedBox(height: 16 * context.fontSizeFactor),
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
                SizedBox(height: 48 * context.fontSizeFactor),
                
                // Referral Code UI
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Center(
                    child: MaxWidthBox(
                      maxWidth: 600,
                      child: Column(
                        children: [
                          Text(l10n.yourReferralCode, style: TextStyle(fontSize: 13 * context.fontSizeFactor, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6), fontWeight: FontWeight.bold, letterSpacing: 1 * context.fontSizeFactor)),
                          SizedBox(height: 12 * context.fontSizeFactor),
                          Container(
                            padding: EdgeInsets.all(8 * context.fontSizeFactor),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
                              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20 * context.fontSizeFactor, offset: Offset(0, 10 * context.fontSizeFactor))],
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = constraints.maxWidth < 450;
                                if (isMobile) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 24 * context.fontSizeFactor),
                                        child: Text(
                                          referralCode,
                                          style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 6 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color),
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
                                            borderRadius: BorderRadius.circular(18 * context.fontSizeFactor),
                                            boxShadow: isDark ? [] : [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 10 * context.fontSizeFactor, offset: Offset(0, 4 * context.fontSizeFactor))],
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
                                        padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor),
                                        child: Text(
                                          referralCode,
                                          style: TextStyle(fontSize: 24 * context.fontSizeFactor, fontWeight: FontWeight.bold, letterSpacing: 6 * context.fontSizeFactor, color: theme.textTheme.titleLarge?.color),
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
                                          borderRadius: BorderRadius.circular(18 * context.fontSizeFactor),
                                          boxShadow: isDark ? [] : [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 10 * context.fontSizeFactor, offset: Offset(0, 4 * context.fontSizeFactor))],
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
                
                SizedBox(height: 48 * context.fontSizeFactor),
                
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
                                borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                                boxShadow: isDark ? [] : [BoxShadow(color: const Color(0xFF25D366).withValues(alpha: 0.3), blurRadius: 12 * context.fontSizeFactor, offset: Offset(0, 6 * context.fontSizeFactor))],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.whatsapp, size: 20 * context.fontSizeFactor, color: Colors.white),
                                      SizedBox(width: 12 * context.fontSizeFactor),
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
                          SizedBox(width: 16 * context.fontSizeFactor),
                          Container(
                            width: 60 * context.fontSizeFactor, height: 60 * context.fontSizeFactor,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12 * context.fontSizeFactor, offset: Offset(0, 6 * context.fontSizeFactor))],
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
                SizedBox(height: 40 * context.fontSizeFactor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

