import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.deepGreen,
        secondary: AppColors.sage,
        surface: AppColors.lightSurface,
        onPrimary: AppColors.cream,
        onSurface: AppColors.deepGreen,
      ),
      textTheme: _textTheme(AppColors.deepGreen, AppColors.lightSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.deepGreen,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.sage,
        secondary: AppColors.sage,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkBackground,
        onSurface: AppColors.sage,
      ),
      textTheme: _textTheme(AppColors.sage, AppColors.darkSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.sage,
        elevation: 0,
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 3,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelSmall: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: AppColors.sage,
      ),
    );
  }
}
