import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static Color getThemePrimary(String themeColor) {
    switch (themeColor) {
      case 'teal':
        return const Color(0xFF0D9488);
      case 'blue':
        return const Color(0xFF2563EB);
      case 'emerald':
        return const Color(0xFF059669);
      case 'amber':
        return const Color(0xFFD97706);
      case 'violet':
        return const Color(0xFF7C3AED);
      case 'rose':
        return const Color(0xFFE11D48);
      case 'orange':
        return const Color(0xFFEA580C);
      case 'cyan':
        return const Color(0xFF0891B2);
      case 'indigo':
        return const Color(0xFF4F46E5);
      case 'black':
      default:
        return const Color(0xFF0F172A);
    }
  }

  static Color getThemeAccent(String themeColor) {
    switch (themeColor) {
      case 'teal':
        return const Color(0xFF14B8A6);
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'emerald':
        return const Color(0xFF10B981);
      case 'amber':
        return const Color(0xFFF59E0B);
      case 'violet':
        return const Color(0xFF8B5CF6);
      case 'rose':
        return const Color(0xFFF43F5E);
      case 'orange':
        return const Color(0xFFF97316);
      case 'cyan':
        return const Color(0xFF06B6D4);
      case 'indigo':
        return const Color(0xFF6366F1);
      case 'black':
      default:
        return const Color(0xFF3B82F6);
    }
  }
}

class AppTheme {
  static ThemeData light(String themeColor) {
    final primary = AppColors.getThemePrimary(themeColor);
    final accent = AppColors.getThemeAccent(themeColor);

    final baseTextTheme = GoogleFonts.vazirmatnTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: AppColors.lightSurface,
        onSurface: const Color(0xFF0F172A),
        outline: AppColors.lightBorder,
        error: AppColors.danger,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: const Color(0xFF0F172A),
        displayColor: const Color(0xFF0F172A),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  static ThemeData dark(String themeColor) {
    final primary = AppColors.getThemePrimary(themeColor);
    final accent = AppColors.getThemeAccent(themeColor);

    final baseTextTheme = GoogleFonts.vazirmatnTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: AppColors.darkSurface,
        onSurface: const Color(0xFFF8FAFC),
        outline: AppColors.darkBorder,
        error: AppColors.danger,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: const Color(0xFFF8FAFC),
        displayColor: const Color(0xFFF8FAFC),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF8FAFC),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
