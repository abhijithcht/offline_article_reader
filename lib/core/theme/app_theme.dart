import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:offline_article_reader/app_imports.dart';

class AppTheme {
  // Call this before runApp() to disable network font fetching
  static void init() {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  // Light Theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight.withValues(alpha: 0.2),
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.dividerLight,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: AppSizes.fontTitle,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          side: const BorderSide(color: AppColors.dividerLight),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p16,
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p24,
            vertical: AppSizes.p16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p24,
            vertical: AppSizes.p16,
          ),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primaryLight,
      primaryContainer: AppColors.primary.withValues(alpha: 0.3),
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.accentLight,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.dividerDark,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: AppSizes.fontTitle,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          side: const BorderSide(color: AppColors.dividerDark),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p16,
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p24,
            vertical: AppSizes.p16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p24,
            vertical: AppSizes.p16,
          ),
          side: const BorderSide(color: AppColors.primaryLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        contentTextStyle: const TextStyle(color: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
