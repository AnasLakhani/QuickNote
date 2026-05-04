import 'package:flutter/material.dart';

class AppColors {
  // Common
  static const Color primary = Colors.blueAccent;
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;

  // Light Mode
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardBackgroundLight = Colors.white;
  static const Color textPrimaryLight = Colors.black87;
  static const Color textSecondaryLight = Colors.black54;

  // Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Colors.white70;

  // Note colors (slightly adjusted for dark mode if needed, but these are good)
  static const Color noteRed = Color(0xFFFFCDD2);
  static const Color noteBlue = Color(0xFFBBDEFB);
  static const Color noteGreen = Color(0xFFC8E6C9);
  static const Color noteYellow = Color(0xFFFFF9C4);

  static Color background(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? backgroundDark : backgroundLight;
  static Color cardBackground(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? cardBackgroundDark : cardBackgroundLight;
  static Color textPrimary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;
}
