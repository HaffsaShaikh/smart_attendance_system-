import 'package:flutter/material.dart';

class AppTheme {
  static _AppColors colors = _AppColors();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme.light(
      primary: colors.primary,
      secondary: colors.secondary,
      background: colors.background,
      error: colors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.accent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );
}

class _AppColors {
  final primary = const Color(0xFF4682B4); // Blue Steel
  final secondary = const Color(0xFF1E3A5F); // Deep Navy
  final background = const Color(0xFFFFFFFF); // White
  final accent = const Color(0xFFF3F4F6); // Light Gray
  final error = const Color(0xFFDC2626); // Red
}
