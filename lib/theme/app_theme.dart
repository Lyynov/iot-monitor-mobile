import 'package:flutter/material.dart';

class AppTheme {
  // Tokopedia-inspired color palette
  static const Color primaryColor = Color(0xFF42B549);    // Green
  static const Color secondaryColor = Color(0xFF03AC0E);  // Darker Green
  static const Color accentColor = Color(0xFF42B549);     // Accent Green
  static const Color backgroundColor = Color(0xFFF3F4F5); // Light Gray
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);     // Dark Gray
  static const Color textSecondary = Color(0xFF6D7588);   // Medium Gray
  static const Color errorColor = Color(0xFFD50000);      // Red
  static const Color warningColor = Color(0xFFFF9800);    // Orange
  static const Color successColor = Color(0xFF42B549);    // Green

  // Status colors
  static const Color activeColor = Color(0xFF42B549);     // Green
  static const Color inactiveColor = Color(0xFFE0E0E0);   // Light Gray
  static const Color manualModeColor = Color(0xFFFFC107); // Amber

  // Create theme data
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData( // <--- Ubah CardTheme menjadi CardThemeData
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 14,
      ),
    ),
  );
}