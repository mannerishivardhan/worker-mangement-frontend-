/// App Colors - Pure NotebookLM Design
///
/// Exact color matching from NotebookLM mobile app.
/// Clean, minimal, spacious design with light blue accents.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================================
  // LIGHT THEME (NotebookLM Exact Colors)
  // ============================================================================

  /// Primary - Light Blue (NotebookLM accent)
  static const Color lightPrimary = Color(0xFF4285F4); // Google Light Blue
  static const Color lightAccent = Color(0xFF4285F4);

  /// Status Colors
  static const Color lightSuccess = Color(0xFF34A853); // Google Green
  static const Color lightWarning = Color(0xFFFBBC04); // Google Yellow
  static const Color lightError = Color(0xFFEA4335); // Google Red

  /// Backgrounds - Pure White
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurfaceVariant = Color(
    0xFFF8F9FA,
  ); // Barely Grey (for subtle contrast)

  /// Borders & Dividers - Very Subtle
  static const Color lightBorder = Color(0xFFE8EAED); // Very Light Grey
  static const Color lightDivider = Color(0xFFF1F3F4); // Almost White

  /// Text Colors
  static const Color lightTextPrimary = Color(0xFF202124); // Almost Black
  static const Color lightTextSecondary = Color(0xFF5F6368); // Medium Grey
  static const Color lightTextTertiary = Color(0xFF80868B); // Light Grey
  static const Color lightTextHint = Color(0xFF9AA0A6); // Very Light Grey

  // ============================================================================
  // DARK THEME
  // ============================================================================

  /// Primary - Light Blue
  static const Color darkPrimary = Color(0xFF8AB4F8);
  static const Color darkAccent = Color(0xFF8AB4F8);

  /// Status Colors
  static const Color darkSuccess = Color(0xFF81C995);
  static const Color darkWarning = Color(0xFFFDD663);
  static const Color darkError = Color(0xFFF28B82);

  /// Backgrounds
  static const Color darkBackground = Color(0xFF202124);
  static const Color darkSurface = Color(0xFF292A2D);
  static const Color darkSurfaceVariant = Color(0xFF3C4043);

  /// Borders & Dividers
  static const Color darkBorder = Color(0xFF5F6368);
  static const Color darkDivider = Color(0xFF3C4043);

  /// Text Colors
  static const Color darkTextPrimary = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFF9AA0A6);
  static const Color darkTextTertiary = Color(0xFF5F6368);
  static const Color darkTextHint = Color(0xFF5F6368);

  // ============================================================================
  // ROLE-BASED ACCENTS (Simple, Clean)
  // ============================================================================

  /// Super Admin - Blue
  static const Color superAdminLight = Color(0xFF4285F4);
  static const Color superAdminDark = Color(0xFF8AB4F8);

  /// Department Head - Purple
  static const Color deptHeadLight = Color(0xFF9334E6);
  static const Color deptHeadDark = Color(0xFFC58AF9);

  /// Employee - Green
  static const Color employeeLight = Color(0xFF34A853);
  static const Color employeeDark = Color(0xFF81C995);

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  static Color roleAccent(String role, {bool isDark = false}) {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return isDark ? superAdminDark : superAdminLight;
      case 'dept_head':
      case 'depthead':
      case 'department_head':
        return isDark ? deptHeadDark : deptHeadLight;
      case 'employee':
        return isDark ? employeeDark : employeeLight;
      default:
        return isDark ? darkPrimary : lightPrimary;
    }
  }

  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;

  static Color surfaceVariant(bool isDark) =>
      isDark ? darkSurfaceVariant : lightSurfaceVariant;

  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static Color textTertiary(bool isDark) =>
      isDark ? darkTextTertiary : lightTextTertiary;

  static Color textHint(bool isDark) => isDark ? darkTextHint : lightTextHint;

  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;

  static Color primary(bool isDark) => isDark ? darkPrimary : lightPrimary;

  static Color accent(bool isDark) => isDark ? darkAccent : lightAccent;

  static Color success(bool isDark) => isDark ? darkSuccess : lightSuccess;

  static Color warning(bool isDark) => isDark ? darkWarning : lightWarning;

  static Color error(bool isDark) => isDark ? darkError : lightError;
}
