import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  void _copyCode(BuildContext context, String code, AppState state) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.translate("Referral code copied to clipboard!", "Koodhka tixraaca waa la koobiyeeyay!", ar: "تم نسخ رمز الإحالة!", de: "Empfehlungscode kopiert!")),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const referralCode = "MURTAAX77";
    
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(state.translate("Refer & Earn", "Tixraac & Guulayso", ar: "أحل واربح", de: "Empfehlen & Verdienen"), 
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color, fontSize: 20 * context.fontSizeFactor)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(state.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: theme.iconTheme.color),
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
                                  Text(state.translate("Rewards Waiting", "Abaalmarino ku sugaya", ar: "مكافآت بانتظارك", de: "Belohnungen warten"), style: TextStyle(color: Colors.white, fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
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
                        state.translate("Invite Friends, Get \$10", "Saaxiibbadaa casuun, hel \$10", ar: "ادعُ الأصدقاء، واحصل على 10 دولار", de: "Freunde einladen, 10 \$ erhalten"),
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
                        state.translate("Share MurtaaxPay with your friends and you both get \$10 when they make their first transfer of \$50 or more.", "La wadaag MurtaaxPay saaxiibbadaa oo labadiinaba waxaad helaysaan \$10 marka ay sameeyaan xawaaladdooda ugu horreysa oo \$50 ama ka badan ah.", ar: "شارك MurtaaxPay مع أصدقائك وستحصلان كلاكما على 10 دولارات عند قيامهم بأول تحويل بقيمة 50 دولارًا أو أكثر.", de: "Teilen Sie MurtaaxPay mit Ihren Freunden und Sie beide erhalten 10 \$, wenn diese ihre erste Überweisung von 50 \$ oder mehr tätigen."),
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
                            Text(state.translate("Your Referral Code", "Koodhkaaga Tixraaca", ar: "رمز الإحالة الخاص بك", de: "Ihr Empfehlungscode"), style: TextStyle(fontSize: 13 * context.fontSizeFactor, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6), fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                                          onTap: () => _copyCode(context, referralCode, state),
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(vertical: 16 * context.fontSizeFactor),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [AppColors.accentTeal, Color(0xFF10B981)]),
                                              borderRadius: BorderRadius.circular(18),
                                              boxShadow: isDark ? [] : [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                                            ),
                                            child: Center(child: Text(state.translate("COPY", "KOOBIYEEY", ar: "نسخ", de: "KOPIEREN"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor))),
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
                                        onTap: () => _copyCode(context, referralCode, state),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 24 * context.fontSizeFactor, vertical: 16 * context.fontSizeFactor),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [AppColors.accentTeal, Color(0xFF10B981)]),
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: isDark ? [] : [BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                                          ),
                                          child: Text(state.translate("COPY", "KOOBIYEEY", ar: "نسخ", de: "KOPIEREN"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
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
                                            state.translate("WhatsApp", "WhatsApp", ar: "واتساب", de: "WhatsApp"),
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
      ),
    );
  }
}

