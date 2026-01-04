/// Custom Data Table - Sortable and Paginated
///
/// Clean data table with sorting, pagination, and row actions.
/// Follows NotebookLM's minimal design with BMW premium touches.
///
/// Features:
/// - Sortable columns
/// - Pagination
/// - Row selection
/// - Row actions (edit, delete, view)
/// - Responsive design
/// - Empty state
///
/// Usage:
/// ```dart
/// CustomDataTable(
///   columns: ['Name', 'Email', 'Role'],
///   rows: employeeData,
///   onSort: (columnIndex, ascending) {},
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

class CustomDataTable extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int? sortColumnIndex;
  final bool sortAscending;
  final Function(int, bool)? onSort;
  final int rowsPerPage;
  final bool showCheckboxColumn;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.rowsPerPage = 10,
    this.showCheckboxColumn = false,
  });

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  int _currentPage = 0;

  int get _totalPages => (widget.rows.length / widget.rowsPerPage).ceil();

  List<DataRow> get _currentPageRows {
    final start = _currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() => _currentPage++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.rows.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Column(
      children: [
        // Data Table
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border(isDark)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: widget.sortColumnIndex,
              sortAscending: widget.sortAscending,
              showCheckboxColumn: widget.showCheckboxColumn,
              columns: widget.columns,
              rows: _currentPageRows,
              headingRowColor: WidgetStateProperty.all(
                AppColors.surfaceVariant(isDark),
              ),
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.surfaceVariant(isDark).withOpacity(0.5);
                }
                return null;
              }),
              dividerThickness: 1,
              headingTextStyle: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
              dataTextStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Pagination Controls
        if (_totalPages > 1) _buildPaginationControls(isDark),
      ],
    );
  }

  Widget _buildPaginationControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Page info
        Text(
          'Page ${_currentPage + 1} of $_totalPages',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(isDark),
          ),
        ),

        // Navigation buttons
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 0 ? _previousPage : null,
              color: AppColors.textPrimary(isDark),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
              color: AppColors.textPrimary(isDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textTertiary(isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No data available',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
