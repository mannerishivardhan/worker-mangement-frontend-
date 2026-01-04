/// Stats Card Widget - Responsive Dashboard Card
///
/// Responsive stats card for dashboard overview.
/// Displays key metrics with icon, value, label, and trend.
/// Adapts to 4-column desktop and 2x2 mobile layouts.
///
/// Features:
/// - Responsive layout (4-col desktop, 2x2 mobile)
/// - Icon with background color
/// - Large value display
/// - Trend indicator (up/down)
/// - Subtitle/description
/// - BMW premium styling
///
/// Usage:
/// ```dart
/// StatsCard(
///   title: 'Total Employees',
///   value: '156',
///   icon: Icons.people,
///   trend: '+8 this month',
///   trendUp: true,
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../common/custom_card.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final String? trend;
  final bool? trendUp;
  final Color? iconColor;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.trend,
    this.trendUp,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = iconColor ?? AppColors.primary(isDark);

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and Title Row
          Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, size: AppSpacing.iconMd, color: accentColor),
              ),
              const Spacer(),
              // Trend indicator (if provided)
              if (trend != null) ...[
                Icon(
                  trendUp == true ? Icons.trending_up : Icons.trending_down,
                  size: AppSpacing.iconSm,
                  color: trendUp == true
                      ? AppColors.success(isDark)
                      : AppColors.error(isDark),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Value (large number)
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textPrimary(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Title
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),

          // Subtitle/Trend text
          if (subtitle != null || trend != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle ?? trend!,
              style: AppTypography.bodySmall.copyWith(
                color: trendUp == null
                    ? AppColors.textTertiary(isDark)
                    : (trendUp == true
                          ? AppColors.success(isDark)
                          : AppColors.error(isDark)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Responsive Stats Grid - Auto-adapts to screen size
///
/// Desktop: 4 columns
/// Tablet: 2 columns
/// Mobile: 2x2 grid
class StatsGrid extends StatelessWidget {
  final List<StatsCard> cards;

  const StatsGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine columns based on screen width
        int crossAxisCount;
        if (constraints.maxWidth >= 1024) {
          crossAxisCount = 4; // Desktop: 4 columns
        } else if (constraints.maxWidth >= 768) {
          crossAxisCount = 2; // Tablet: 2 columns
        } else {
          crossAxisCount = 2; // Mobile: 2x2 grid
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: constraints.maxWidth >= 1024 ? 1.5 : 1.2,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}
