/// Spacing System - NotebookLM Design
///
/// Generous spacing following NotebookLM's spacious, clean layout.
/// Uses 4px base grid with emphasis on breathing room.
///
/// Spacing Scale:
/// - xs: 4px - Minimal spacing
/// - sm: 8px - Small spacing
/// - md: 16px - Medium spacing (default)
/// - lg: 24px - Large spacing (generous)
/// - xl: 32px - Extra large spacing
/// - xxl: 48px - Double extra large
///
/// Border Radius: More rounded (NotebookLM style)
/// - sm: 12px - Small elements
/// - md: 16px - Default (cards, buttons)
/// - lg: 20px - Large cards
/// - xl: 24px - Modals, dialogs

class AppSpacing {
  AppSpacing._();

  // ============================================================================
  // SPACING SCALE (4px base grid, generous spacing)
  // ============================================================================

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ============================================================================
  // COMPONENT-SPECIFIC SPACING
  // ============================================================================

  /// Card Padding - 20px (generous)
  static const double cardPadding = 20.0;

  /// Card Margin - 16px
  static const double cardMargin = md;

  /// Button Padding Horizontal - 24px
  static const double buttonPaddingH = lg;

  /// Button Padding Vertical - 12px
  static const double buttonPaddingV = 12.0;

  /// Input Padding Horizontal - 16px
  static const double inputPaddingH = md;

  /// Input Padding Vertical - 14px (taller for better touch)
  static const double inputPaddingV = 14.0;

  /// List Item Padding - 16px
  static const double listItemPadding = md;

  /// Dialog Padding - 24px
  static const double dialogPadding = lg;

  /// Screen Padding - 16px (Mobile), 24px (Tablet+)
  static const double screenPaddingMobile = md;
  static const double screenPaddingTablet = lg;

  /// Section Spacing - 32px
  static const double sectionSpacing = xl;

  // ============================================================================
  // BORDER RADIUS (More rounded - NotebookLM style)
  // ============================================================================

  /// Small Radius - 12px
  static const double radiusSm = 12.0;

  /// Medium Radius - 16px (Default for cards, buttons)
  static const double radiusMd = 16.0;

  /// Large Radius - 20px
  static const double radiusLg = 20.0;

  /// Extra Large Radius - 24px (Modals, dialogs)
  static const double radiusXl = 24.0;

  /// Full Radius - 9999px (Circular)
  static const double radiusFull = 9999.0;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ============================================================================
  // ELEVATION (Subtle shadows)
  // ============================================================================

  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 4.0;
  static const double elevation4 = 8.0;
  static const double elevation5 = 12.0;
}
