import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  String? redeemedCode;

  void _redeemVoucher(String code, AppState state) {
    setState(() {
      redeemedCode = code;
    });
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.translate("Voucher code copied! Ready to use.", "Koodhka waatsharka waa la koobiyeeyay!", ar: "تم نسخ كود القسيمة! جاهز للاستخدام.", de: "Gutscheincode kopiert! Bereit zur Verwendung.")),
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
    final state = AppState();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(state.translate("My Vouchers", "Waatsharradayda", ar: "قسائمي", de: "Meine Gutscheine"), 
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
                          state.translate("Active Rewards", "Abaalmarinnada Firfircoon", ar: "المكافآت النشطة", de: "Aktive Belohnungen"),
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
                          children: _buildVoucherList(context, state, theme, isDark),
                        )
                      else
                        Column(
                          children: _buildVoucherList(context, state, theme, isDark),
                        ),
                      
                      const SizedBox(height: 48),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Text(state.translate("How to use", "Sida loo isticmaalo", ar: "كيفية الاستخدام", de: "So wird's verwendet"), 
                            style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                      ),
                      const SizedBox(height: 20),
                      _buildStep(context, state, theme, 1, state.translate("Tap 'Redeem Now' to copy the code.", "Riix 'Hadda Fur' si aad u koobiyeysato koodhka.", ar: "اضغط على 'استرداد الآن' لنسخ الرمز.", de: "Tippen Sie auf „Jetzt einlösen“, um den Code zu kopieren."), 500),
                      _buildStep(context, state, theme, 2, state.translate("Start a new money transfer.", "Bilow xawaalad lacageed oo cusub.", ar: "ابدأ تحويل أموال جديد.", de: "Starten Sie eine neue Geldüberweisung."), 600),
                      _buildStep(context, state, theme, 3, state.translate("Paste code in the 'Promo Code' field.", "Dhig koodhka qaybta 'Promo Code'.", ar: "الصق الرمز في حقل 'كود الخصم'.", de: "Fügen Sie den Code in das Feld „Promo-Code“ ein."), 700),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVoucherList(BuildContext context, AppState state, ThemeData theme, bool isDark) {
    return [
      _buildTicketVoucher(
        context: context,
        state: state,
        theme: theme,
        isDark: isDark,
        title: state.translate("Welcome Bonus", "Abaalmarinta Soo-dhaweynta", ar: "مكافأة الترحيب", de: "Willkommensbonus"),
        desc: state.translate("Get 5% cashback on your next transfer.", "Hel 5% lacag celin ah xawaaladdaada xigta.", ar: "احصل على 5% كاش باك على تحويلك القادم.", de: "Erhalten Sie 5 % Cashback auf Ihre nächste Überweisung."),
        code: "WELCOME5",
        color: const Color(0xFFF59E0B),
        expiry: state.translate("Expires: 30 Dec", "Dhacaya: 30 Dec", ar: "ينتهي في: 30 ديسمبر", de: "Läuft am 30. Dez. ab"),
        icon: Icons.card_giftcard_rounded,
        delay: 100,
      ),
      _buildTicketVoucher(
        context: context,
        state: state,
        theme: theme,
        isDark: isDark,
        title: state.translate("Family Friday", "Jimcaha Qoyska", ar: "جمعة العائلة", de: "Familienfreitag"),
        desc: state.translate("Zero fees for any transfer to Somalia today!", "Khidmad la'aan xawaalad kasta oo Soomaaliya maanta!", ar: "رسوم صفرية لأي تحويل إلى الصومال اليوم!", de: "Heute keine Gebühren für Überweisungen nach Somalia!"),
        code: "FREEFRI",
        color: AppColors.accentTeal,
        expiry: state.translate("Expires: Tomorrow", "Dhacaya: Berri", ar: "ينتهي: غداً", de: "Läuft morgen ab"),
        icon: Icons.family_restroom_rounded,
        delay: 200,
      ),
      _buildTicketVoucher(
        context: context,
        state: state,
        theme: theme,
        isDark: isDark,
        title: state.translate("Eid Special", "Gaar u ah Ciidda", ar: "خاص بالعيد", de: "Eid-Spezial"),
        desc: state.translate("\$10 bonus on transfers over \$100.", "\$10 oo gunno ah xawaaladaha ka badan \$100.", ar: "مكافأة 10 دولار على التحويلات التي تزيد عن 100 دولار.", de: "10 \$ Bonus auf Überweisungen über 100 \$."),
        code: "EID2024",
        color: const Color(0xFF8B5CF6),
        expiry: state.translate("Expires: in 5 days", "Dhacaya: 5 maalin", ar: "ينتهي: خلال 5 أيام", de: "Läuft in 5 Tagen ab"),
        icon: Icons.mosque_rounded,
        delay: 300,
      ),
    ];
  }

  Widget _buildTicketVoucher({
    required BuildContext context,
    required AppState state,
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
                          state.translate("REWARD", "ABAALMARIN", ar: "مكافأة", de: "BELOHNUNG"),
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
                          onTap: () => _redeemVoucher(code, state),
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
                                isRedeemed ? state.translate("Copied!", "Waa la koobiyey!", ar: "تم النسخ!", de: "Kopiert!") : state.translate("Redeem Now", "Hadda Fur", ar: "استرداد الآن", de: "Jetzt einlösen"),
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

  Widget _buildStep(BuildContext context, AppState state, ThemeData theme, int number, String text, int delay) {
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
