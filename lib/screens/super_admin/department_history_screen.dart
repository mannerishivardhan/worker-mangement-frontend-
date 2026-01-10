/// Department History Screen
///
/// Displays audit log of all changes to a department in timeline format.
/// NotebookLM design: clean timeline, outlined icons, light blue accents.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/department.dart';
import '../../models/department_history.dart';
import '../../services/department_service.dart';

class DepartmentHistoryScreen extends StatefulWidget {
  final Department department;

  const DepartmentHistoryScreen({super.key, required this.department});

  @override
  State<DepartmentHistoryScreen> createState() =>
      _DepartmentHistoryScreenState();
}

class _DepartmentHistoryScreenState extends State<DepartmentHistoryScreen> {
  final DepartmentService _departmentService = DepartmentService();
  List<DepartmentHistory> _historyItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedActionType;

  final List<Map<String, String>> _actionTypeFilters = [
    {'value': '', 'label': 'All Actions'},
    {'value': 'created', 'label': 'Created'},
    {'value': 'updated', 'label': 'Updated'},
    {'value': 'deleted', 'label': 'Deleted'},
    {'value': 'activated', 'label': 'Activated'},
    {'value': 'deactivated', 'label': 'Deactivated'},
    {'value': 'head_assigned', 'label': 'Head Assigned'},
    {'value': 'head_changed', 'label': 'Head Changed'},
    {'value': 'head_removed', 'label': 'Head Removed'},
    {'value': 'role_added', 'label': 'Role Added'},
    {'value': 'role_updated', 'label': 'Role Updated'},
    {'value': 'role_removed', 'label': 'Role Removed'},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use trim to ensure no whitespace issues
      final departmentId = widget.department.id.trim();
      
      print('Loading history for department ID: "$departmentId"');
      print('Department name: ${widget.department.name}');
      
      if (departmentId.isEmpty) {
        throw Exception('Department ID is empty');
      }

      final history = await _departmentService.getDepartmentHistory(
        departmentId,
        actionType: _selectedActionType?.isEmpty ?? true
            ? null
            : _selectedActionType,
        limit: 50,
      );

      setState(() {
        _historyItems = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              'Department History',
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
            Text(
              widget.department.name,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter History',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error(isDark)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load history',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_historyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textTertiary(isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No history available',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Changes to this department will appear here',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _historyItems.length,
        itemBuilder: (context, index) {
          final historyItem = _historyItems[index];
          final isLast = index == _historyItems.length - 1;

          return _buildTimelineItem(
            context,
            isDark: isDark,
            historyItem: historyItem,
            isLast: isLast,
          );
        },
      ),
    );
  }

  void _showFilterDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Filter by Action Type'),
          children: _actionTypeFilters.map((filter) {
            final isSelected = (_selectedActionType ?? '') == filter['value'];
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, filter['value']),
              child: Row(
                children: [
                  if (isSelected)
                    const Icon(Icons.check, size: 20, color: Colors.blue)
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 8),
                  Text(filter['label']!),
                ],
              ),
            );
          }).toList(),
        );
      },
    );

    if (selected != null && selected != _selectedActionType) {
      setState(() {
        _selectedActionType = selected.isEmpty ? null : selected;
      });
      _loadHistory();
    }
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required bool isDark,
    required DepartmentHistory historyItem,
    required bool isLast,
  }) {
    final icon = _getIconForAction(historyItem.actionType);
    final color = _getColorForAction(historyItem.actionType, isDark);

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
                height: 80,
                color: AppColors.border(isDark),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),

        const SizedBox(width: AppSpacing.md),

        // Content
        Expanded(
          child: GestureDetector(
            onTap: () => _showHistoryDetails(historyItem, isDark),
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
                  // Action description
                  Text(
                    historyItem.actionDescription ??
                        historyItem.actionTypeDisplay,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Timestamp with relative time
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textTertiary(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        historyItem.relativeTime,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${DateFormat('MMM dd, yyyy • hh:mm a').format(historyItem.timestamp)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary(isDark),
                        ),
                      ),
                    ],
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
                        'by ${historyItem.performedByName ?? 'System'}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary(isDark),
                        ),
                      ),
                      if (historyItem.performedByRole != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary(isDark).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatRole(historyItem.performedByRole!),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary(isDark),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Reason if available
                  if (historyItem.reason != null &&
                      historyItem.reason!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning(isDark).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.warning(isDark).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: AppColors.warning(isDark),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              historyItem.reason!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Changed fields indicator
                  if (historyItem.changedFields != null &&
                      historyItem.changedFields!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: historyItem.changedFields!.map((field) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            field,
                            style: AppTypography.bodySmall.copyWith(
                              color: color,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Tap to view details hint
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tap for details',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary(isDark),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showHistoryDetails(DepartmentHistory item, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border(isDark),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  Text(
                    'History Details',
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // History ID
                  _buildDetailRow(isDark, 'History ID', item.historyId),
                  _buildDetailRow(
                    isDark,
                    'Action Type',
                    item.actionTypeDisplay,
                  ),
                  _buildDetailRow(
                    isDark,
                    'Description',
                    item.actionDescription ?? 'N/A',
                  ),
                  _buildDetailRow(
                    isDark,
                    'Timestamp',
                    DateFormat(
                      'MMM dd, yyyy • hh:mm:ss a',
                    ).format(item.timestamp),
                  ),
                  _buildDetailRow(
                    isDark,
                    'Performed By',
                    item.performedByName ?? 'System',
                  ),
                  if (item.performedByRole != null)
                    _buildDetailRow(
                      isDark,
                      'Role',
                      _formatRole(item.performedByRole!),
                    ),
                  if (item.performedByEmployeeId != null)
                    _buildDetailRow(
                      isDark,
                      'Employee ID',
                      item.performedByEmployeeId!,
                    ),
                  if (item.reason != null && item.reason!.isNotEmpty)
                    _buildDetailRow(isDark, 'Reason', item.reason!),

                  // Changed fields
                  if (item.changedFields != null &&
                      item.changedFields!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Changed Fields',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...item.changedFields!.map(
                      (field) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $field',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Previous and new data
                  if (item.previousData != null || item.newData != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    if (item.previousData != null) ...[
                      Text(
                        'Previous Data',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.error(isDark).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error(isDark).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          item.previousData.toString(),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(isDark),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (item.newData != null) ...[
                      Text(
                        'New Data',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.success(isDark).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.success(isDark).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          item.newData.toString(),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(isDark),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],

                  // Related entity
                  if (item.relatedEntityType != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildDetailRow(
                      isDark,
                      'Related Entity Type',
                      item.relatedEntityType!,
                    ),
                    if (item.relatedEntityId != null)
                      _buildDetailRow(
                        isDark,
                        'Related Entity ID',
                        item.relatedEntityId!,
                      ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary(isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForAction(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'created':
        return Icons.add_circle_outline;
      case 'updated':
        return Icons.edit_outlined;
      case 'deleted':
        return Icons.delete_outline;
      case 'activated':
        return Icons.check_circle_outline;
      case 'deactivated':
        return Icons.cancel_outlined;
      case 'head_assigned':
        return Icons.person_add_outlined;
      case 'head_changed':
        return Icons.swap_horiz;
      case 'head_removed':
        return Icons.person_remove_outlined;
      case 'role_added':
        return Icons.badge_outlined;
      case 'role_updated':
        return Icons.update;
      case 'role_removed':
        return Icons.remove_circle_outline;
      default:
        return Icons.history;
    }
  }

  Color _getColorForAction(String actionType, bool isDark) {
    switch (actionType.toLowerCase()) {
      case 'created':
      case 'activated':
      case 'head_assigned':
      case 'role_added':
        return AppColors.success(isDark);
      case 'updated':
      case 'head_changed':
      case 'role_updated':
        return AppColors.primary(isDark);
      case 'deleted':
      case 'deactivated':
      case 'head_removed':
      case 'role_removed':
        return AppColors.error(isDark);
      default:
        return AppColors.textTertiary(isDark);
    }
  }

  String _formatRole(String role) {
    return role
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
