import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkCyberpunkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.voidBackground,
      colorScheme: const ColorScheme.dark(
        background: AppColors.voidBackground,
        primary: AppColors.neonCyan,
        secondary: AppColors.glitchRed,
        surface: AppColors.hologramBlue,
      ),
      textTheme: GoogleFonts.jetbrainsMonoTextTheme().apply(
        bodyColor: AppColors.neonCyan,
        displayColor: AppColors.neonCyan,
      ),
      fontFamily: GoogleFonts.jetbrainsMono().fontFamily,
    );
  }
}
