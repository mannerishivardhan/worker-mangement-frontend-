/// Typography System - NotebookLM Design
///
/// Uses Google's font family: Roboto (primary font)
/// NotebookLM uses Roboto for clean, readable text across all platforms.
///
/// Font Hierarchy:
/// - Display: Large headings (32px, 28px, 24px) - Roboto Medium
/// - Heading: Section titles (20px, 18px, 16px) - Roboto Medium
/// - Body: Regular text (16px, 14px, 12px) - Roboto Regular
/// - Label: UI labels (14px, 12px, 11px) - Roboto Medium

import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // ============================================================================
  // FONT FAMILY - Roboto (Google's default)
  // ============================================================================

  static const String primaryFont = 'Roboto';

  // ============================================================================
  // DISPLAY STYLES (Large Headings)
  // ============================================================================

  /// Display Large - 32px/500 - Hero headings
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0,
  );

  /// Display Medium - 28px/500 - Page titles
  static const TextStyle displayMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0,
  );

  /// Display Small - 24px/500 - Section headers
  static const TextStyle displaySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0,
  );

  // ============================================================================
  // HEADING STYLES
  // ============================================================================

  /// Heading 1 - 20px/500 - Main section titles
  static const TextStyle heading1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Heading 2 - 18px/500 - Subsection titles
  static const TextStyle heading2 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.44,
    letterSpacing: 0,
  );

  /// Heading 3 - 16px/500 - Card titles
  static const TextStyle heading3 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
  );

  // ============================================================================
  // BODY STYLES (Regular Text)
  // ============================================================================

  /// Body Large - 16px/400 - Primary body text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );

  /// Body Medium - 14px/400 - Secondary body text (most common)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  /// Body Small - 12px/400 - Captions, hints
  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // ============================================================================
  // LABEL STYLES (UI Elements)
  // ============================================================================

  /// Label Large - 14px/500 - Button text, form labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  /// Label Medium - 12px/500 - Small buttons, chips
  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );

  /// Label Small - 11px/500 - Tiny labels
  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to any text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply size to any text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Create a bold version
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  /// Create a medium version
  static TextStyle medium(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w500);
  }

  /// Create an italic version
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }
}
