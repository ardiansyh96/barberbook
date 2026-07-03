import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Material Design 3 theme configuration for BarberBook.
///
/// Provides both light and dark theme variants with the signature
/// Black/White/Gold color scheme. The gold accent is used for
/// interactive elements, while black dominates text and dark surfaces.
class AppTheme {
  AppTheme._();

  // ─── Color Scheme ───────────────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryBlack,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.gold,
    onPrimaryContainer: AppColors.primaryBlack,
    secondary: AppColors.gold,
    onSecondary: AppColors.primaryBlack,
    secondaryContainer: AppColors.goldLight,
    onSecondaryContainer: AppColors.primaryBlack,
    tertiary: AppColors.accentOrange,
    onTertiary: AppColors.white,
    error: AppColors.errorRed,
    onError: AppColors.white,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.primaryBlack,
    onSurfaceVariant: AppColors.darkGrey,
    outline: AppColors.lightGrey,
    outlineVariant: AppColors.lightGrey,
    shadow: Color(0x1A000000),
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.gold,
    onPrimary: AppColors.primaryBlack,
    primaryContainer: AppColors.goldDark,
    onPrimaryContainer: AppColors.white,
    secondary: AppColors.goldLight,
    onSecondary: AppColors.primaryBlack,
    secondaryContainer: AppColors.goldDark,
    onSecondaryContainer: AppColors.white,
    tertiary: AppColors.accentOrange,
    onTertiary: AppColors.white,
    error: AppColors.errorRed,
    onError: AppColors.white,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.white,
    onSurfaceVariant: AppColors.mediumGrey,
    outline: AppColors.charcoal,
    outlineVariant: AppColors.charcoal,
    shadow: Color(0x33000000),
  );

  // ─── Light Theme ────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.from(
      colorScheme: _lightColorScheme,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: AppTextStyles.buildTextTheme(),
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryBlack,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
        titleTextStyle: AppTextStyles.withGoogleFonts(
          AppTextStyles.titleLarge,
        ),
      ),

      // Bottom Navigation Bar (matches UI reference: 4 tabs, clean style)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.accentOrange,
        unselectedItemColor: AppColors.mediumGrey,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        elevation: 8,
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.white,
      ),

      // Elevated Button (gold gradient style)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlack,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlack,
          side: const BorderSide(color: AppColors.gold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.offWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGrey, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGrey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        labelStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.darkGrey),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.mediumGrey),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.offWhite,
        selectedColor: AppColors.gold.withValues(alpha: 0.15),
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: AppColors.lightGrey),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppColors.white,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: AppColors.white,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.primaryBlack,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGrey,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.lightGrey,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }

  // ─── Dark Theme ─────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.from(
      colorScheme: _darkColorScheme,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: AppTextStyles.buildTextTheme().apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        titleTextStyle: AppTextStyles.withGoogleFonts(
          AppTextStyles.titleLarge.copyWith(color: AppColors.white),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.darkGrey,
        elevation: 8,
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surfaceDark,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.primaryBlack,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.charcoal, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.charcoal, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
      ),
    );
  }
}
