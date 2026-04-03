import 'package:flutter/material.dart';

class AppColors {
  // Garden of Peace palette
  static const sage = Color(0xFFA8C5A0);
  static const sand = Color(0xFFD4C9A8);
  static const cream = Color(0xFFF5F1EA);
  static const deepGreen = Color(0xFF3D5A3A);
  static const charcoal = Color(0xFF2C2C2C);

  // Light mode
  static const lightBackground = cream;
  static const lightSurface = Color(0xFFEDE8DF);
  static const lightPrimary = deepGreen;
  static const lightSecondary = Color(0xFF8A8275);

  // Dark mode
  static const darkBackground = Color(0xFF1E1E1C);
  static const darkSurface = Color(0xFF2A2A27);
  static const darkPrimary = sage;
  static const darkSecondary = Color(0xFF6B6B62);

  // Next prayer card gradient
  static const cardGradientLight = [deepGreen, Color(0xFF4A6D47)];
  static const cardGradientDark = [Color(0xFF2A4228), deepGreen];

  // Highlighted prayer row
  static const highlightLight = sand;
  static const highlightDark = Color(0xFF3A3529);
}
