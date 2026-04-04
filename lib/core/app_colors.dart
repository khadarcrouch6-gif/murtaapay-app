import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF0B2C4A); // Dark Blue
  static const Color accentTeal = Color(0xFF2FD1A5); // Teal Green
  static const Color background = Color(0xFFF8F9FB);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF94A3B8);
  static const Color textPrimary = Color(0xFF1E293B);
  
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
