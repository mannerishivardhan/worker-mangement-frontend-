/// Employee History Screen
///
/// Displays audit log of all changes to an employee in timeline format.
/// NotebookLM design: clean timeline, outlined icons, light blue accents.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/employee.dart';

class EmployeeHistoryScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeHistoryScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // TODO: Fetch actual audit logs from backend
    // For now, show placeholder with employee creation
    final historyItems = [
      {
        'action': 'Employee Created',
        'timestamp': employee.createdAt,
        'performedBy': employee.createdBy ?? 'System',
        'icon': Icons.person_add_outlined,
        'color': AppColors.success(isDark),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background(isDark),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(isDark)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee History',
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
            Text(
              employee.fullName,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          final isLast = index == historyItems.length - 1;

          return _buildTimelineItem(
            context,
            isDark: isDark,
            action: item['action'] as String,
            timestamp: item['timestamp'] as DateTime,
            performedBy: item['performedBy'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color,
            isLast: isLast,
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required bool isDark,
    required String action,
    required DateTime timestamp,
    required String performedBy,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            // Vertical line
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: AppColors.border(isDark),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),

        const SizedBox(width: AppSpacing.md),

        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface(isDark),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border(isDark), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action
                Text(
                  action,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Timestamp
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Performed by
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.textTertiary(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'by $performedBy',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
