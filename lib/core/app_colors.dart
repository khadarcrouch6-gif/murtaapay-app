import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF0F172A); // Midnight Blue (More Premium)
  static const Color accentTeal = Color(0xFF10B981); // Emerald Teal
  static const Color background = Color(0xFFF1F5F9); // Soft Off-White (Eye Comfort)
  static const Color surface = Colors.white;
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF64748B); // Slate Grey
  static const Color textPrimary = Color(0xFF1E293B); // Slate Dark
  static const Color textSecondary = Color(0xFF475569); // Muted Slate
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, Color(0xFF1A4B7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentTeal, Color(0xFF26B08A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
