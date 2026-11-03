import 'package:flutter/material.dart';

class AppTheme {
  // Sophisticated minimal palette inspired by Scandinavian curation and modern gallery aesthetics
  static const Color accentWarm = Color(0xFFC29B38); // Refined antique gold
  static const Color accentWarmLight = Color(0xFFF4EEDC);

  // Light Mode Colors
  static const Color lightBg = Color(0xFFFBFBF9); // Clean alabaster off-white
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF14171A);
  static const Color lightTextSecondary = Color(0xFF657786);
  static const Color lightBorder = Color(0xFFEBECEF);

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF0F141C); // Ultra-deep midnight slate
  static const Color darkSurface = Color(0xFF17202C);
  static const Color darkTextPrimary = Color(0xFFF7F9FA);
  static const Color darkTextSecondary = Color(0xFF8B98A5);
  static const Color darkBorder = Color(0xFF263242);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: lightTextPrimary,
      secondary: accentWarm,
      surface: lightSurface,
      onPrimary: Colors.white,
      onSurface: lightTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: lightTextPrimary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: Color(0xFFAAB8C2), fontSize: 14),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: accentWarm,
      secondary: accentWarm,
      surface: darkSurface,
      onPrimary: darkBg,
      onSurface: darkTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentWarm, width: 1.5),
      ),
      labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: Color(0xFF657786), fontSize: 14),
    ),
  );
}
