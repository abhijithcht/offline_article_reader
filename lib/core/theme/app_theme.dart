import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:offline_article_reader/app_imports.dart';

class AppTheme {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: AppColors.surfaceLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: GoogleFonts.merriweatherTextTheme(ThemeData.light().textTheme)
        .copyWith(
          bodyMedium: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontSize: AppSizes.fontBody,
          ),
          titleLarge: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontSize: AppSizes.fontTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.bold,
        fontFamily: 'Merriweather',
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary, // Keep primary branding
      surface: AppColors.surfaceDark,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: GoogleFonts.merriweatherTextTheme(ThemeData.dark().textTheme)
        .copyWith(
          bodyMedium: const TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: AppSizes.fontBody,
          ),
          titleLarge: const TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: AppSizes.fontTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.bold,
        fontFamily: 'Merriweather',
      ),
    ),
  );

  // TODO(user): Add Sepia Theme logic later (requires custom theme extension or provider logic swapper)
}
