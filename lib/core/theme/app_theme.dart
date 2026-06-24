import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const background = Color(0xFF111015);
  static const surface = Color(0xFF1F1D23);
  static const primary = Color(0xFFCDBDFF);
  static const primaryContainer = Color(0xFF5A536D);

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme.copyWith(
        primary: primary,
        primaryContainer: primaryContainer,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2A2730),
        foregroundColor: Color(0xFFF0ECF4),
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF77717F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      ),
    );
  }
}
