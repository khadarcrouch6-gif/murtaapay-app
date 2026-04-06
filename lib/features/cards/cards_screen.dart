import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool _showNumber = false;
  bool _isFrozen = false;

  void _toggleShowNumber() => setState(() => _showNumber = !_showNumber);
  void _toggleFreeze() => setState(() => _isFrozen = !_isFrozen);

  void _copyCardNumber(BuildContext context, AppState state) {
    // Scoped copy logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.translate("Card number copied", "Lambarka kaarka waa la koobiyeeyay", ar: "تم نسخ رقم البطاقة", de: "Kartennummer kopiert"))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppState();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(state.translate("My Cards", "Kaararkayga", ar: "بطاقاتي", de: "Meine Karten"), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildCardFront(context, state),
            const SizedBox(height: 32),
            _buildCardSettings(context, state, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(BuildContext context, AppState state) {
    return Hero(
      tag: 'virtual_card',
      child: Container(
        width: double.infinity,
        height: 200 * context.fontSizeFactor,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentTeal.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primaryDark.withValues(alpha: 0.8), AppColors.accentTeal.withValues(alpha: 0.6)],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/walletlogo.png", 
                            width: 16, 
                            height: 16, 
                            color: Colors.white,
                            errorBuilder: (c, e, s) => const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Murtaax Pay", 
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 12, 
                              letterSpacing: -0.5
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Security Chip
                  SizedBox(
                    width: 40,
                    height: 28,
                    child: CustomPaint(painter: RealisticCardChipPainter()),
                  ),

                  // Card Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _showNumber ? "4580 1234 5678 9012" : "**** **** **** 4580",
                            style: const TextStyle(
                              color: Colors.white,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'monospace',
                              shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            onPressed: () => _copyCardNumber(context, state), 
                            icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 16)
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            onPressed: _toggleShowNumber, 
                            icon: Icon(_showNumber ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70, size: 16)
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Bottom Row: Holder and Expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.translate("Card Holder", "Milkiilaha", ar: "صاحب البطاقة", de: "Karteninhaber").toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 8, letterSpacing: 0.5)),
                            const Text("KHADAR RAYAALE", style: TextStyle(color: Colors.white, letterSpacing: 1.0, fontWeight: FontWeight.w600, fontSize: 11), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.translate("Expires", "Dhicitaanka", ar: "تنتهي في", de: "Ablauf").toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 8, letterSpacing: 0.5)),
                          const Text("12/26", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Freeze Overlay
            if (_isFrozen)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.lock_rounded, color: Colors.white, size: 36),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                state.translate("FROZEN", "XANIBAN", ar: "مجمدة", de: "GESPERRT"),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSettings(BuildContext context, AppState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(state.translate("Card Management", "Maamulka Kaarka", ar: "إدارة البطاقة", de: "Kartenverwaltung"), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSettingsToggle(
          context, 
          state.translate("Freeze Card", "Xanib Kaarka", ar: "تجميد البطاقة", de: "Karte sperren"), 
          state.translate("Temporarily disable this card", "Si ku meel gaadh ah u jooji kaarkan", ar: "تعطيل هذه البطاقة مؤقتًا", de: "Diese Karte vorübergehend deaktivieren"),
          FontAwesomeIcons.snowflake, 
          _isFrozen, 
          (val) => _toggleFreeze()
        ),
        _buildSettingsOption(context, state.translate("View PIN", "Fiiri PIN-ka", ar: "عرض PIN", de: "PIN anzeigen"), FontAwesomeIcons.key, () {}),
        _buildSettingsOption(context, state.translate("Replacement Card", "Kaar Cusub", ar: "استبدال البطاقة", de: "Ersatzkarte"), FontAwesomeIcons.creditCard, () {}),
      ],
    );
  }

  Widget _buildSettingsToggle(BuildContext context, String title, String subtitle, dynamic icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: AdaptiveIcon(icon, color: AppColors.primaryDark),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.accentTeal),
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context, String title, dynamic icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: AdaptiveIcon(icon, color: AppColors.primaryDark),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class RealisticCardChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37) // Gold chip
      ..style = PaintingStyle.fill;
    
    final rRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(4));
    canvas.drawRRect(rRect, paint);

    final linePaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Standard chip lines pattern
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), linePaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
