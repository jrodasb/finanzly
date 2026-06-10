import 'package:flutter/material.dart';

class AppTheme {
  static const _slate950 = Color(0xFF0B0F19);
  static const _slate900 = Color(0xFF0F172A);
  static const _slate800 = Color(0xFF1E293B);
  static const _slate400 = Color(0xFF94A3B8);
  static const esmeralda = Color(0xFF10B981);
  static const coral = Color(0xFFF43F5E);

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _slate950,
    colorScheme: ColorScheme.dark(
      surface: _slate950,
      primary: esmeralda,
      secondary: coral,
      onSurface: Colors.white,
      surfaceContainerHighest: _slate800,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _slate900,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: _slate800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: coral,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _slate900,
      selectedItemColor: esmeralda,
      unselectedItemColor: _slate400,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _slate800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
  );
}
