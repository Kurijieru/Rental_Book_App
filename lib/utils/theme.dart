import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF6200EE); // Deep Purple
  static const Color secondaryColor = Color(0xFF3700B3); // Darker Purple
  static const Color accentColor = Color(0xFFFFC107); // Vibrant Yellow
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color textColor = Color(0xFF212121); // Dark Grey
  static const Color shadowColor = Colors.black12; // Light Shadow
  static const Color errorColor = Colors.red; // Error Color
}

ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.backgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.secondaryColor,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textColor),
    bodyMedium: TextStyle(fontSize: 16, color: AppColors.textColor),
    bodySmall: TextStyle(fontSize: 14, color: AppColors.textColor),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.secondaryColor,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textColor),
    contentTextStyle: const TextStyle(fontSize: 16, color: AppColors.textColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

// Gradient Background for FlexibleSpace
LinearGradient appGradient = const LinearGradient(
  colors: [AppColors.primaryColor, AppColors.secondaryColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
