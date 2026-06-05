import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0D1117);
  static const surface = Color(0xFF1A2235);
  static const surfaceAlt = Color(0xFF243048);
  static const primary = Color(0xFF1A8F6F);
  static const primaryDark = Color(0xFF0E6B52);
  static const blue = Color(0xFF0E6BBA);
  static const pink = Color(0xFFE05A9A);
  static const textPrimary = Color(0xFFC9D1D9);
  static const textSecondary = Color(0xFF6B7A8D);
  static const ok = Color(0xFF1A8F6F);
  static const warn = Color(0xFFE09B3D);
  static const danger = Color(0xFFE05A5A);
  static const okBg = Color(0xFF0E2E25);
  static const warnBg = Color(0xFF2E1F0A);
  static const dangerBg = Color(0xFF2E0E0E);
  static const border = Color(0xFF2A3A55);
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
