import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark theme
  static const darkBg = Color(0xFF0D0D0F);
  static const darkSurface = Color(0xFF161618);
  static const darkBorder = Color(0xFF2A2A2E);
  static const darkTextPrimary = Color(0xFFF0F0F0);
  static const darkTextMuted = Color(0xFF888890);

  // Light theme
  static const lightBg = Color(0xFFFAF8F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE8E4DF);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextMuted = Color(0xFF777777);

  // Fallback accent
  static const accent = Color(0xFFFF4E00);
  static const accentGlow = Color(0x33FF4E00);

  // Star / universe
  static const starWhite = Color(0xFFFFFFFF);
  static const universeBg = Color(0xFF03030A);
}

class AppTheme {
  static ThemeData dark([Color customAccent = AppColors.accent]) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: customAccent,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.dark(
        primary: customAccent,
        secondary: customAccent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      dividerColor: AppColors.darkBorder,
      cardColor: AppColors.darkSurface,
    );
  }

  static ThemeData light([Color customAccent = AppColors.accent]) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: customAccent,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.light(
        primary: customAccent,
        secondary: customAccent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
      dividerColor: AppColors.lightBorder,
      cardColor: AppColors.lightSurface,
    );
  }
}
