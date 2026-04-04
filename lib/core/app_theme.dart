import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        primary: AppColors.primaryDark,
        secondary: AppColors.accentTeal,
        onSurface: AppColors.textPrimary,
        brightness: Brightness.light,
      ),
      // Inter font is the gold standard for Fintech apps (Clean & Readable)
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary.withValues(alpha: 0.8), fontSize: 14),
        labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF010813),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accentTeal,
        primary: AppColors.accentTeal,
        secondary: AppColors.accentTeal,
        surface: const Color(0xFF0B121F),
        onSurface: const Color(0xFFE2E8F0), // Soft off-white for eye comfort
        brightness: Brightness.dark,
      ),
      // Dark Mode typography uses softer whites to prevent eye strain
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFF8FAFC)),
        displayMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFF8FAFC)),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFFF8FAFC)),
        bodyLarge: GoogleFonts.inter(color: const Color(0xFFE2E8F0), fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
        labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentTeal,
          foregroundColor: Colors.black,
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

