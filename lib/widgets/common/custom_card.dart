/// Custom Card Widget - BMW Premium Style
///
/// Premium card component with BMW-inspired hover effects and elevation.
/// Features smooth lift animation and subtle glow on hover.
///
/// Features:
/// - BMW premium shadows
/// - Hover lift animation
/// - Glow effect on hover
/// - Customizable padding
/// - Optional header and footer
/// - Gradient support
///
/// Usage:
/// ```dart
/// CustomCard(
///   child: Text('Card content'),
///   onTap: () {},
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class CustomCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? elevation;
  final bool enableHoverEffect;
  final Widget? header;
  final Widget? footer;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.elevation,
    this.enableHoverEffect = true,
    this.header,
    this.footer,
    this.borderRadius,
  });

  /// Card with header
  factory CustomCard.withHeader({
    required Widget header,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    bool enableHoverEffect = true,
  }) {
    return CustomCard(
      header: header,
      onTap: onTap,
      padding: padding,
      enableHoverEffect: enableHoverEffect,
      child: child,
    );
  }

  /// Card with gradient background
  factory CustomCard.gradient({
    required Widget child,
    required Gradient gradient,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomCard(
      gradient: gradient,
      onTap: onTap,
      padding: padding,
      child: child,
    );
  }

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<Offset> _offsetAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? AppSpacing.elevation2,
      end: (widget.elevation ?? AppSpacing.elevation2) + 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.01),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverEnter(PointerEvent event) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = true);
      _controller.forward();
    }
  }

  void _handleHoverExit(PointerEvent event) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: SlideTransition(
        position: _offsetAnimation,
        child: AnimatedBuilder(
          animation: _elevationAnimation,
          builder: (context, child) {
            return Container(
              margin:
                  widget.margin ?? const EdgeInsets.all(AppSpacing.cardMargin),
              decoration: BoxDecoration(
                color: widget.gradient == null
                    ? (widget.backgroundColor ?? AppColors.surface(isDark))
                    : null,
                gradient: widget.gradient,
                borderRadius:
                    widget.borderRadius ??
                    BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius:
                    widget.borderRadius ??
                    BorderRadius.circular(AppSpacing.radiusMd),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius:
                      widget.borderRadius ??
                      BorderRadius.circular(AppSpacing.radiusMd),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.header != null) ...[
                        Padding(
                          padding:
                              widget.padding ??
                              const EdgeInsets.all(AppSpacing.cardPadding),
                          child: widget.header,
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.border(isDark),
                        ),
                      ],
                      Padding(
                        padding:
                            widget.padding ??
                            const EdgeInsets.all(AppSpacing.cardPadding),
                        child: widget.child,
                      ),
                      if (widget.footer != null) ...[
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.border(isDark),
                        ),
                        Padding(
                          padding:
                              widget.padding ??
                              const EdgeInsets.all(AppSpacing.cardPadding),
                          child: widget.footer,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
