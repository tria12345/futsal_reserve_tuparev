// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors - Clean Premium Commercial Sports Aesthetic
  static const Color background = Color(0xFFF5F7FB); // Soft off-white background
  static const Color cardColor = Colors.white; // Crisp white for cards
  static const Color primary = Color(0xFF10B981); // Vibrant Emerald/Mint Green (Fresh & Modern)
  static const Color primaryGlow = Color(0x1F10B981); // Soft Translucent Emerald/Mint
  static const Color secondary = Color(0xFF059669); // Rich Emerald Accent Green
  static const Color accent = Color(0xFFEF4444); // Coral Red for alerts
  static const Color textPrimary = Color(0xFF0F172A); // Ultra-Dark Charcoal Slate
  static const Color textSecondary = Color(0xFF64748B); // Slate Medium Grey

  static const Color backgroundDark = Color(0xFF0F172A); // Deep slate/navy background
  static const Color cardColorDark = Color(0xFF1E293B); // Slate grey card
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Crisp off-white text
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate Light Grey

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF5F7FB), Color(0xFFE2E8F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Soft Premium Shadows (Commercial standard)
  static List<BoxShadow> softShadow() {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Material 3 Light Theme Config
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: cardColor,
        error: accent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Material 3 Dark Theme Config (iOS-like Dark Mode)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: cardColorDark,
        error: accent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColorDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColorDark,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade800, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: cardColorDark,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
