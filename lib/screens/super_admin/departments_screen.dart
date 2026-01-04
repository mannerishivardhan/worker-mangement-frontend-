/// Departments Screen - Super Admin
///
/// List all departments with search, add/edit capabilities.
/// NotebookLM design: pure white, outlined icons, light blue accents.

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/department.dart';
import '../../services/department_service.dart';
import '../../widgets/departments/department_dialog.dart';
import 'department_history_screen.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  final DepartmentService _departmentService = DepartmentService();
  final TextEditingController _searchController = TextEditingController();

  List<Department> _departments = [];
  List<Department> _filteredDepartments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _searchController.addListener(_filterDepartments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final departments = await _departmentService.getDepartments();
      setState(() {
        _departments = departments;
        _filteredDepartments = departments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterDepartments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDepartments = _departments.where((dept) {
        // Check department name
        if (dept.name.toLowerCase().contains(query)) return true;

        // Check department ID - allow searching by full ID or just last 4 chars
        if (dept.departmentId != null) {
          final deptId = dept.departmentId!.toLowerCase();
          // Match full ID (e.g., "dept_9k4r")
          if (deptId.contains(query)) return true;
          // Match just the suffix after DEPT_ (e.g., "9k4r")
          if (deptId.startsWith('dept_') &&
              deptId.substring(5).contains(query)) {
            return true;
          }
        }

        // Check department code
        if (dept.code?.toLowerCase().contains(query) ?? false) return true;

        return false;
      }).toList();

      // Sort alphabetically by name
      _filteredDepartments.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background(isDark),
        title: Text(
          'Departments',
          style: AppTypography.heading1.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID (e.g., 9K4R), or code...',
                prefixIcon: Icon(
                  Icons.search_outlined,
                  color: AppColors.textSecondary(isDark),
                ),
                filled: true,
                fillColor: AppColors.surface(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.border(isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.border(isDark)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(
                    color: AppColors.primary(isDark),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Department list
          Expanded(child: _buildContent(isDark)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const DepartmentDialog(),
          );
          if (result == true) {
            _loadDepartments(); // Reload list after adding
          }
        },
        backgroundColor: AppColors.primary(isDark),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary(isDark)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error(isDark)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Error loading departments',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadDepartments,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredDepartments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: AppColors.textTertiary(isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _searchController.text.isEmpty
                  ? 'No departments yet'
                  : 'No departments found',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _searchController.text.isEmpty
                  ? 'Tap + to add your first department'
                  : 'Try a different search term',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDepartments,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _filteredDepartments.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final department = _filteredDepartments[index];
          return _buildDepartmentCard(department, isDark);
        },
      ),
    );
  }

  Widget _buildDepartmentCard(Department department, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(isDark), width: 1),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              Icons.business_outlined,
              color: AppColors.primary(isDark),
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Department info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.name,
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'ID: ${department.departmentId ?? 'N/A'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
                if (department.code != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Code: ${department.code}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
                if (department.headName != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Head: ${department.headName}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Employee count badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: AppColors.primary(isDark),
                ),
                const SizedBox(width: 4),
                Text(
                  '${department.employeeCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary(isDark),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // History button
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      DepartmentHistoryScreen(department: department),
                ),
              );
            },
            icon: Icon(
              Icons.history_outlined,
              color: AppColors.textSecondary(isDark),
              size: 20,
            ),
          ),

          // Edit button
          IconButton(
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => DepartmentDialog(department: department),
              );
              if (result == true) {
                _loadDepartments(); // Reload list after editing
              }
            },
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.textSecondary(isDark),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
