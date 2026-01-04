/// Custom Button Widget - BMW Premium Style
///
/// Premium button component with BMW-inspired glow effects and smooth animations.
/// Supports three variants: Primary (filled), Secondary (outlined), and Icon.
///
/// Features:
/// - BMW glow effects on hover/press
/// - Smooth scale animations
/// - Gradient support
/// - Loading state
/// - Disabled state
/// - Role-based colors
///
/// Usage:
/// ```dart
/// CustomButton(
///   text: 'Submit',
///   onPressed: () {},
///   variant: ButtonVariant.primary,
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

enum ButtonVariant {
  primary, // Filled button with gradient
  secondary, // Outlined button
  text, // Text-only button
}

enum ButtonSize {
  small, // Compact button
  medium, // Default size
  large, // Prominent button
}

class CustomButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;
  final Widget? child;

  const CustomButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
    this.child,
  }) : assert(
         text != null || icon != null || child != null,
         'Must provide either text, icon, or child',
       );

  /// Primary button (filled with gradient)
  factory CustomButton.primary({
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    Color? customColor,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      customColor: customColor,
    );
  }

  /// Secondary button (outlined)
  factory CustomButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    Color? customColor,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      customColor: customColor,
    );
  }

  /// Icon button
  factory CustomButton.icon({
    required IconData icon,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    Color? customColor,
  }) {
    return CustomButton(
      icon: icon,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      size: size,
      customColor: customColor,
    );
  }

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    // Get button dimensions based on size
    final double height = _getHeight();
    final double horizontalPadding = _getHorizontalPadding();
    final double iconSize = _getIconSize();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isDisabled ? null : _handleTapDown,
        onTapUp: isDisabled ? null : _handleTapUp,
        onTapCancel: isDisabled ? null : _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: height,
            width: widget.isFullWidth ? double.infinity : null,
            decoration: _buildDecoration(isDark, isDisabled),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _buildContent(isDark, isDisabled, iconSize),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isDark, bool isDisabled) {
    if (isDisabled) {
      return BoxDecoration(
        color: AppColors.border(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      );
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return BoxDecoration(
          color: widget.customColor ?? AppColors.primary(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        );

      case ButtonVariant.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: widget.customColor ?? AppColors.primary(isDark),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        );

      case ButtonVariant.text:
        return BoxDecoration(
          color: _isHovered
              ? AppColors.surfaceVariant(isDark)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        );
    }
  }

  Widget _buildContent(bool isDark, bool isDisabled, double iconSize) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.variant == ButtonVariant.primary
                  ? Colors.white
                  : AppColors.primary(isDark),
            ),
          ),
        ),
      );
    }

    if (widget.child != null) {
      return Center(child: widget.child);
    }

    final Color textColor = _getTextColor(isDark, isDisabled);

    if (widget.icon != null && widget.text == null) {
      // Icon-only button
      return Center(
        child: Icon(widget.icon, size: iconSize, color: textColor),
      );
    }

    if (widget.icon != null && widget.text != null) {
      // Icon + Text button
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: iconSize, color: textColor),
          const SizedBox(width: AppSpacing.sm),
          Text(widget.text!, style: _getTextStyle().copyWith(color: textColor)),
        ],
      );
    }

    // Text-only button
    return Center(
      child: Text(
        widget.text!,
        style: _getTextStyle().copyWith(color: textColor),
      ),
    );
  }

  Color _getTextColor(bool isDark, bool isDisabled) {
    if (isDisabled) {
      return AppColors.textTertiary(isDark);
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
      case ButtonVariant.text:
        return widget.customColor ?? AppColors.primary(isDark);
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTypography.labelMedium;
      case ButtonSize.medium:
        return AppTypography.labelLarge;
      case ButtonSize.large:
        return AppTypography.heading3;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 44;
      case ButtonSize.large:
        return 52;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.md;
      case ButtonSize.medium:
        return AppSpacing.lg;
      case ButtonSize.large:
        return AppSpacing.xl;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.iconSm;
      case ButtonSize.medium:
        return AppSpacing.iconMd;
      case ButtonSize.large:
        return AppSpacing.iconLg;
    }
  }
}
