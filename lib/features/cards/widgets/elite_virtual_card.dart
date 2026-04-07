import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui';
import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/responsive_utils.dart';
import '../models/card_model.dart';

class EliteVirtualCard extends StatefulWidget {
  final VirtualCard card;
  final bool showNumber;
  final bool showBack;
  final VoidCallback onFlip;
  final VoidCallback onToggleShowNumber;
  final VoidCallback onCopyNumber;

  const EliteVirtualCard({
    super.key,
    required this.card,
    required this.showNumber,
    required this.showBack,
    required this.onFlip,
    required this.onToggleShowNumber,
    required this.onCopyNumber,
  });

  @override
  State<EliteVirtualCard> createState() => _EliteVirtualCardState();
}

class _EliteVirtualCardState extends State<EliteVirtualCard> with SingleTickerProviderStateMixin {
  Offset _tiltOffset = Offset.zero;
  bool _isPressed = false;

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    setState(() {
      final x = (details.localPosition.dx / constraints.maxWidth) * 2 - 1;
      final y = (details.localPosition.dy / constraints.maxHeight) * 2 - 1;
      _tiltOffset = Offset(x, y);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _tiltOffset = Offset.zero;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) => _onPanUpdate(details, constraints),
          onPanEnd: _onPanEnd,
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            setState(() {
              _isPressed = true;
            });
          },
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onFlip,
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(begin: Offset.zero, end: _tiltOffset),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              builder: (context, tilt, child) {
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0, end: widget.showBack ? 180 : 0),
                  curve: Curves.easeInOutBack,
                  builder: (context, double rotation, child) {
                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.0012) // Perspective
                      ..rotateY((rotation * pi / 180) + (tilt.dx * 0.15))
                      ..rotateX(-tilt.dy * 0.15);

                    return Transform(
                      alignment: Alignment.center,
                      transform: transform,
                      child: rotation <= 90 
                        ? _buildCardFront(context, state) 
                        : Transform(
                            alignment: Alignment.center, 
                            transform: Matrix4.identity()..rotateY(pi), 
                            child: _buildCardBack(context, state)
                          ),
                    );
                  },
                );
              },
            ),
          ),
        );
      }
    );
  }

  Widget _buildCardFront(BuildContext context, AppState state) {
    final themeColors = _getThemeColors();
    
    return Container(
      width: double.infinity,
      height: 200 * context.fontSizeFactor,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColors.primaryGlow.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Base Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: themeColors.baseGradient,
                ),
              ),
            ),
          ),

          // Liquid Mesh Accents
          _buildMeshAccent(top: -40, left: -40, color: themeColors.accent1, size: 250),
          _buildMeshAccent(top: 20, right: -60, color: themeColors.accent2, size: 200),
          _buildMeshAccent(bottom: -50, left: 20, color: themeColors.accent3, size: 180),

          // Holographic Shine
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Colors.transparent,
                      themeColors.holographic1.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.2),
                      themeColors.holographic2.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.4, 0.48, 0.5, 0.52, 0.6],
                  ),
                ),
              ),
            ),
          ),

          // Border
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.8),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _cardIconButton(Icons.copy_all_rounded, widget.onCopyNumber),
                        const SizedBox(width: 10),
                        _cardIconButton(
                          widget.showNumber ? Icons.visibility_off_rounded : Icons.visibility_rounded, 
                          widget.onToggleShowNumber
                        ),
                      ],
                    ),
                    _buildBranding(),
                  ],
                ),
                
                _buildCardNumberArea(),
                
                _buildCardFooter(state),
              ],
            ),
          ),
          
          if (widget.card.isFrozen) _buildFrozenOverlay(state),
        ],
      ),
    );
  }

  Widget _buildMeshAccent({double? top, double? left, double? right, double? bottom, required Color color, required double size}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05), Colors.transparent],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("MurtaaxPay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.2)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: const Text("PLATINUM", style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w900, fontSize: 7, letterSpacing: 1.5)),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)])),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  Widget _buildCardNumberArea() {
    return Row(
      children: [
        Container(
          width: 46, height: 34,
          decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]),
          child: CustomPaint(painter: RealisticCardChipPainter()),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: _buildAnimatedNumber(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedNumber() {
    final number = widget.card.cardNumber;
    final masked = "••••  ••••  ••••  ${number.substring(number.length - 4)}";
    final visible = number.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ");

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation), child: child)),
      child: Text(
        widget.showNumber ? visible.trim() : masked,
        key: ValueKey<bool>(widget.showNumber),
        style: TextStyle(
          color: Colors.white,
          letterSpacing: widget.showNumber ? 2.5 : 3.5,
          fontWeight: FontWeight.w900, fontSize: 22, fontFamily: 'monospace',
          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.8), offset: const Offset(0, 2), blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _buildCardFooter(AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.translate("Card Holder", "Milkiilaha", ar: "صاحب البطاقة", de: "Karteninhaber").toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 7, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(widget.card.cardHolder, style: const TextStyle(color: Colors.white, letterSpacing: 1, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(state.translate("Expires", "Dhicitaanka", ar: "تنتهي في", de: "Ablauf").toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 7, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(widget.card.expiryDate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _cardIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
      ),
    );
  }

  Widget _buildFrozenOverlay(AppState state) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(24)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(state.translate("CARD FROZEN", "KAADHKA WAA XANIBAN YAHAY", ar: "البطاقة مجمدة", de: "KARTE GESPERRT"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, AppState state) {
    return Container(
      width: double.infinity, height: 200 * context.fontSizeFactor,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 15), spreadRadius: -5)]),
      child: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF020617), Color(0xFF0F172A)])))),
          
          // Mag Stripe
          Positioned(top: 28, left: 0, right: 0, child: Container(height: 38, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF020202), Color(0xFF1A1A1A), Color(0xFF080808)])))),
          
          // Signature Panel
          Positioned(
            top: 82, left: 20, right: 20,
            child: Container(
              height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: Row(
                children: [
                  Expanded(child: Text("AUTHORIZED SIGNATURE", style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 6, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
                  Container(
                    width: 60, height: 32,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("CVV", style: TextStyle(color: Colors.grey, fontSize: 6, fontWeight: FontWeight.bold, height: 1.0)), Text(widget.card.cvv, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, height: 1.1))])),
                  ),
                ],
              ),
            ),
          ),
          
          // Footer
          Positioned(
            bottom: 24, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               const Text("MurtaaxPay", style: TextStyle(color: Colors.white30, fontWeight: FontWeight.w900, fontSize: 11)),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [const Color(0xFF6366F1).withValues(alpha: 0.4), const Color(0xFF2DD4BF).withValues(alpha: 0.4)])),
                  child: const Center(child: Icon(Icons.verified_user_rounded, color: Colors.white24, size: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _CardThemeColors _getThemeColors() {
    switch (widget.card.theme) {
      case CardThemeType.gold:
        return _CardThemeColors(
          baseGradient: [const Color(0xFF1A1A1A), const Color(0xFF000000)],
          primaryGlow: const Color(0xFFFFD700),
          accent1: const Color(0xFFFFD700),
          accent2: const Color(0xFFFDB931),
          accent3: const Color(0xFF9E7E07),
          holographic1: const Color(0xFFFFE135),
          holographic2: const Color(0xFFFDB931),
        );
      case CardThemeType.emerald:
        return _CardThemeColors(
          baseGradient: [const Color(0xFF064E3B), const Color(0xFF022C22)],
          primaryGlow: const Color(0xFF10B981),
          accent1: const Color(0xFF34D399),
          accent2: const Color(0xFF059669),
          accent3: const Color(0xFF064E3B),
          holographic1: const Color(0xFF6EE7B7),
          holographic2: const Color(0xFF10B981),
        );
      case CardThemeType.midnight:
        return _CardThemeColors(
          baseGradient: [const Color(0xFF1E1B4B), const Color(0xFF0F172A)],
          primaryGlow: const Color(0xFF6366F1),
          accent1: const Color(0xFF818CF8),
          accent2: const Color(0xFF4F46E5),
          accent3: const Color(0xFF312E81),
          holographic1: const Color(0xFFA5B4FC),
          holographic2: const Color(0xFF6366F1),
        );
      case CardThemeType.obsidian:
      default:
        return _CardThemeColors(
          baseGradient: [const Color(0xFF020617), const Color(0xFF0F172A)],
          primaryGlow: AppColors.accentTeal,
          accent1: AppColors.accentTeal,
          accent2: const Color(0xFF6366F1),
          accent3: const Color(0xFF0EA5E9),
          holographic1: const Color(0xFF818CF8),
          holographic2: const Color(0xFF2DD4BF),
        );
    }
  }
}

class _CardThemeColors {
  final List<Color> baseGradient;
  final Color primaryGlow;
  final Color accent1;
  final Color accent2;
  final Color accent3;
  final Color holographic1;
  final Color holographic2;

  _CardThemeColors({
    required this.baseGradient,
    required this.primaryGlow,
    required this.accent1,
    required this.accent2,
    required this.accent3,
    required this.holographic1,
    required this.holographic2,
  });
}

class RealisticCardChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFFFFD700), const Color(0xFFFDB931), const Color(0xFF9E7E07), const Color(0xFFFDB931), const Color(0xFF8A6E05)],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);
    
    final linePaint = Paint()..color = Colors.black.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 0.8;
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width * 0.35, size.height * 0.25), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width * 0.35, size.height * 0.5), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width * 0.35, size.height * 0.75), linePaint);
    canvas.drawLine(Offset(size.width * 0.65, size.height * 0.25), Offset(size.width, size.height * 0.25), linePaint);
    canvas.drawLine(Offset(size.width * 0.65, size.height * 0.5), Offset(size.width, size.height * 0.5), linePaint);
    canvas.drawLine(Offset(size.width * 0.65, size.height * 0.75), Offset(size.width, size.height * 0.75), linePaint);

    final middleRect = RRect.fromLTRBR(size.width * 0.35, size.height * 0.1, size.width * 0.65, size.height * 0.9, const Radius.circular(3));
    canvas.drawRRect(middleRect, linePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
