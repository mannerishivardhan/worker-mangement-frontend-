/// App Theme - Material Theme Configuration
///
/// This file configures the complete Material theme for the Security Management App.
/// Combines BMW's premium aesthetics with NotebookLM's clean minimalism.
///
/// Features:
/// - Light and Dark themes
/// - Role-based accent colors
/// - Premium component styles
/// - BMW-inspired animations
/// - Accessibility compliance (WCAG AA)
///
/// Developer Notes:
/// - Use `AppTheme.light()` for light theme
/// - Use `AppTheme.dark()` for dark theme
/// - Pass user role to get role-specific accent colors
/// - All themes are optimized for Material 3

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._(); // Private constructor

  // ============================================================================
  // LIGHT THEME
  // ============================================================================

  /// Get light theme with optional role-based accent
  ///
  /// Usage:
  /// ```dart
  /// MaterialApp(
  ///   theme: AppTheme.light(userRole: 'super_admin'),
  /// )
  /// ```
  static ThemeData light({String? userRole}) {
    final accentColor = userRole != null
        ? AppColors.roleAccent(userRole, isDark: false)
        : AppColors.lightPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ========================================================================
      // COLOR SCHEME
      // ========================================================================
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: accentColor,
        tertiary: AppColors.lightAccent,
        error: AppColors.lightError,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightBorder.withOpacity(0.5),
      ),

      // ========================================================================
      // SCAFFOLD
      // ========================================================================
      scaffoldBackgroundColor: AppColors.lightBackground,

      // ========================================================================
      // APP BAR
      // ========================================================================
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.lightBackground, // Pure white!
        foregroundColor: AppColors.lightTextPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.withColor(
          AppTypography.heading2,
          AppColors.lightTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.lightTextPrimary,
          size: AppSpacing.iconMd,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // ========================================================================
      // CARD
      // ========================================================================
      cardTheme: const CardThemeData(
        elevation: AppSpacing.elevation2,
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
        ),
        margin: EdgeInsets.all(AppSpacing.cardMargin),
      ),

      // ========================================================================
      // ELEVATED BUTTON
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.lightBorder,
          disabledForegroundColor: AppColors.lightTextTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ========================================================================
      // OUTLINED BUTTON
      // ========================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          disabledForegroundColor: AppColors.lightTextTertiary,
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ========================================================================
      // TEXT BUTTON
      // ========================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          disabledForegroundColor: AppColors.lightTextTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ========================================================================
      // INPUT DECORATION
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingH,
          vertical: AppSpacing.inputPaddingV,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.lightError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.lightError, width: 2),
        ),
        labelStyle: AppTypography.withColor(
          AppTypography.bodyMedium,
          AppColors.lightTextSecondary,
        ),
        hintStyle: AppTypography.withColor(
          AppTypography.bodyMedium,
          AppColors.lightTextTertiary,
        ),
        errorStyle: AppTypography.withColor(
          AppTypography.bodySmall,
          AppColors.lightError,
        ),
      ),

      // ========================================================================
      // DIALOG
      // ========================================================================
      dialogTheme: DialogThemeData(
        elevation: AppSpacing.elevation4,
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
        ),
        titleTextStyle: AppTypography.withColor(
          AppTypography.heading2,
          AppColors.lightTextPrimary,
        ),
        contentTextStyle: AppTypography.withColor(
          AppTypography.bodyMedium,
          AppColors.lightTextSecondary,
        ),
      ),

      // ========================================================================
      // DIVIDER
      // ========================================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // ========================================================================
      // ICON
      // ========================================================================
      iconTheme: const IconThemeData(
        color: AppColors.lightTextPrimary,
        size: AppSpacing.iconMd,
      ),

      // ========================================================================
      // TEXT THEME
      // ========================================================================
      textTheme: TextTheme(
        displayLarge: AppTypography.withColor(
          AppTypography.displayLarge,
          AppColors.lightTextPrimary,
        ),
        displayMedium: AppTypography.withColor(
          AppTypography.displayMedium,
          AppColors.lightTextPrimary,
        ),
        displaySmall: AppTypography.withColor(
          AppTypography.displaySmall,
          AppColors.lightTextPrimary,
        ),
        headlineLarge: AppTypography.withColor(
          AppTypography.heading1,
          AppColors.lightTextPrimary,
        ),
        headlineMedium: AppTypography.withColor(
          AppTypography.heading2,
          AppColors.lightTextPrimary,
        ),
        headlineSmall: AppTypography.withColor(
          AppTypography.heading3,
          AppColors.lightTextPrimary,
        ),
        bodyLarge: AppTypography.withColor(
          AppTypography.bodyLarge,
          AppColors.lightTextPrimary,
        ),
        bodyMedium: AppTypography.withColor(
          AppTypography.bodyMedium,
          AppColors.lightTextSecondary,
        ),
        bodySmall: AppTypography.withColor(
          AppTypography.bodySmall,
          AppColors.lightTextTertiary,
        ),
        labelLarge: AppTypography.withColor(
          AppTypography.labelLarge,
          AppColors.lightTextPrimary,
        ),
        labelMedium: AppTypography.withColor(
          AppTypography.labelMedium,
          AppColors.lightTextSecondary,
        ),
        labelSmall: AppTypography.withColor(
          AppTypography.labelSmall,
          AppColors.lightTextTertiary,
        ),
      ),
    );
  }

  // ============================================================================
  // DARK THEME
  // ============================================================================

  /// Get dark theme with optional role-based accent
  ///
  /// Usage:
  /// ```dart
  /// MaterialApp(
  ///   darkTheme: AppTheme.dark(userRole: 'super_admin'),
  /// )
  /// ```
  static ThemeData dark({String? userRole}) {
    final accentColor = userRole != null
        ? AppColors.roleAccent(userRole, isDark: true)
        : AppColors.darkPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ========================================================================
      // COLOR SCHEME
      // ========================================================================
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: accentColor,
        tertiary: AppColors.darkAccent,
        error: AppColors.darkError,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkBackground,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorder.withOpacity(0.5),
      ),

      // ========================================================================
      // SCAFFOLD
      // ========================================================================
      scaffoldBackgroundColor: AppColors.darkBackground,

      // ========================================================================
      // APP BAR
      // ========================================================================
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.withColor(
          AppTypography.heading2,
          AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: AppSpacing.iconMd,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // ========================================================================
      // CARD
      // ========================================================================
      cardTheme: const CardThemeData(
        elevation: AppSpacing.elevation2,
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
        ),
        margin: EdgeInsets.all(AppSpacing.cardMargin),
      ),

      // ========================================================================
      // ELEVATED BUTTON
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBackground,
          disabledBackgroundColor: AppColors.darkBorder,
          disabledForegroundColor: AppColors.darkTextTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ========================================================================
      // OUTLINED BUTTON
      // ========================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          disabledForegroundColor: AppColors.darkTextTertiary,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ========================================================================
      // TEXT BUTTON
      // ========================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          disabledForegroundColor: AppColors.darkTextTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ========================================================================
      // INPUT DECORATION
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingH,
          vertical: AppSpacing.inputPaddingV,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkError, width: 2),
        ),
        labelStyle: AppTypography.withColor(
          AppTypography.bodyMedium,
          AppColors.darkTextSecondary,
        ),
        hintStyle: AppTypography.withColor(
          AppTypography.bodyMedium,
          AppColors.darkTextTertiary,
        ),
        errorStyle: AppTypography.withColor(
          AppTypography.bodySmall,
          AppColors.darkError,
        ),
      ),

      // ========================================================================
      // DIALOG
      // ========================================================================
      dialogTheme: DialogThemeData(
        elevation: AppSpacing.elevation4,
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
        ),
        titleTextStyle: AppTypography.withColor(
          AppTypography.heading2,
          AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTypography.withColor(
          AppTypography.bodyMedium,
          AppColors.darkTextSecondary,
        ),
      ),

      // ========================================================================
      // DIVIDER
      // ========================================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // ========================================================================
      // ICON
      // ========================================================================
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: AppSpacing.iconMd,
      ),

      // ========================================================================
      // TEXT THEME
      // ========================================================================
      textTheme: TextTheme(
        displayLarge: AppTypography.withColor(
          AppTypography.displayLarge,
          AppColors.darkTextPrimary,
        ),
        displayMedium: AppTypography.withColor(
          AppTypography.displayMedium,
          AppColors.darkTextPrimary,
        ),
        displaySmall: AppTypography.withColor(
          AppTypography.displaySmall,
          AppColors.darkTextPrimary,
        ),
        headlineLarge: AppTypography.withColor(
          AppTypography.heading1,
          AppColors.darkTextPrimary,
        ),
        headlineMedium: AppTypography.withColor(
          AppTypography.heading2,
          AppColors.darkTextPrimary,
        ),
        headlineSmall: AppTypography.withColor(
          AppTypography.heading3,
          AppColors.darkTextPrimary,
        ),
        bodyLarge: AppTypography.withColor(
          AppTypography.bodyLarge,
          AppColors.darkTextPrimary,
        ),
        bodyMedium: AppTypography.withColor(
          AppTypography.bodyMedium,
          AppColors.darkTextSecondary,
        ),
        bodySmall: AppTypography.withColor(
          AppTypography.bodySmall,
          AppColors.darkTextTertiary,
        ),
        labelLarge: AppTypography.withColor(
          AppTypography.labelLarge,
          AppColors.darkTextPrimary,
        ),
        labelMedium: AppTypography.withColor(
          AppTypography.labelMedium,
          AppColors.darkTextSecondary,
        ),
        labelSmall: AppTypography.withColor(
          AppTypography.labelSmall,
          AppColors.darkTextTertiary,
        ),
      ),
    );
  }
}
