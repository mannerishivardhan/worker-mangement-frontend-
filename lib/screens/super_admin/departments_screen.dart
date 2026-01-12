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
import '../../services/employee_service.dart';
import '../../widgets/departments/comprehensive_department_dialog.dart';
import '../../widgets/departments/department_status_badge.dart';
import '../../widgets/departments/department_head_card.dart';
import '../../widgets/departments/deactivate_department_dialog.dart';
import '../../widgets/departments/activate_department_dialog.dart';
import '../../widgets/departments/assign_head_dialog.dart';
import '../../widgets/departments/remove_head_dialog.dart';
import '../../widgets/departments/transfer_employees_dialog.dart';
import 'department_history_screen.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  final DepartmentService _departmentService = DepartmentService();
  final EmployeeService _employeeService = EmployeeService();
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
            builder: (context) => const ComprehensiveDepartmentDialog(),
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
    return GestureDetector(
      onTap: () {
        _showDepartmentDetails(department, isDark);
      },
      child: Container(
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
                  if (department.code != null)
                    Text(
                      'Code: ${department.code}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  if (department.headName != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.textTertiary(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          department.headName!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary(isDark),
                          ),
                        ),
                      ],
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

            // Chevron icon to indicate tappable
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary(isDark),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showDepartmentDetails(Department department, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            children: [
              // Handle bar and close button
              SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border(isDark),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Close button
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.textSecondary(isDark),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon and name
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary(isDark).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.business_outlined,
                                color: AppColors.primary(isDark),
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  department.name,
                                  style: AppTypography.heading2.copyWith(
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                                if (department.code != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary(
                                            isDark,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusSm,
                                          ),
                                        ),
                                        child: Text(
                                          department.code!,
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                                color: AppColors.primary(
                                                  isDark,
                                                ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      DepartmentStatusBadge(
                                        status: department.status,
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  DepartmentStatusBadge(
                                    status: department.status,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),

                      // Department Head Card
                      DepartmentHeadCard(
                        head: department.departmentHead,
                        canEdit: true,
                        onAssign: () async {
                          Navigator.pop(context);
                          await _handleAssignHead(department);
                        },
                        onRemove: () async {
                          Navigator.pop(context);
                          await _handleRemoveHead(department);
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),

                      // Department Details
                      Text(
                        'Department Information',
                        style: AppTypography.heading3.copyWith(
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _buildDetailRow(
                        'Department ID',
                        department.departmentId ?? 'N/A',
                        Icons.badge_outlined,
                        isDark,
                      ),
                      if (department.code != null)
                        _buildDetailRow(
                          'Department Code',
                          department.code!,
                          Icons.code_outlined,
                          isDark,
                        ),
                      if (department.headName != null)
                        _buildDetailRow(
                          'Department Head',
                          department.headName!,
                          Icons.person_outline,
                          isDark,
                        ),
                      _buildDetailRow(
                        'Total Employees',
                        '${department.employeeCount}',
                        Icons.people_outline,
                        isDark,
                      ),
                      _buildDetailRow(
                        'Status',
                        department.isActive ? 'Active' : 'Inactive',
                        department.isActive
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        isDark,
                        valueColor: department.isActive
                            ? Colors.green
                            : Colors.red,
                      ),
                      if (department.description != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Description',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          department.description!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),

                      // Shifts & Roles Section
                      Text(
                        'Shifts & Roles Configuration',
                        style: AppTypography.heading3.copyWith(
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _buildDetailRow(
                        'Has Shifts',
                        department.hasShifts ? 'Yes' : 'No',
                        department.hasShifts
                            ? Icons.access_time
                            : Icons.access_time_outlined,
                        isDark,
                        valueColor: department.hasShifts
                            ? AppColors.primary(isDark)
                            : AppColors.textSecondary(isDark),
                      ),

                      if (department.hasShifts &&
                          department.roles.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Job Roles (${department.roles.length})',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...department.roles.map((role) {
                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.background(isDark),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                              border: Border.all(
                                color: AppColors.border(isDark),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.work_outline,
                                      size: 16,
                                      color: AppColors.primary(isDark),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      role.name,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textPrimary(isDark),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary(
                                          isDark,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${role.shifts.length} ${role.shifts.length == 1 ? 'shift' : 'shifts'}',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: AppColors.primary(isDark),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (role.shifts.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  ...role.shifts.map((shift) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: AppSpacing.md,
                                        bottom: AppSpacing.xs,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: 14,
                                            color: AppColors.textTertiary(
                                              isDark,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          Text(
                                            shift.name,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary(
                                                        isDark,
                                                      ),
                                                ),
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          Text(
                                            '•',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color: AppColors.textTertiary(
                                                    isDark,
                                                  ),
                                                ),
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          Text(
                                            shift.timeDisplay,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color: AppColors.textPrimary(
                                                    isDark,
                                                  ),
                                                  fontFamily: 'monospace',
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            ),
                          );
                        }),
                      ] else if (department.hasShifts &&
                          department.roles.isEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'No roles configured yet. Edit department to add roles and shifts.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DepartmentHistoryScreen(
                                          department: department,
                                        ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.history_outlined,
                                color: AppColors.primary(isDark),
                              ),
                              label: Text(
                                'View History',
                                style: TextStyle(
                                  color: AppColors.primary(isDark),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.primary(isDark),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(context);
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) =>
                                      ComprehensiveDepartmentDialog(
                                        department: department,
                                      ),
                                );
                                if (result == true) {
                                  _loadDepartments();
                                }
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit Department'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary(isDark),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Status Management Button
                      SizedBox(
                        width: double.infinity,
                        child: department.status.toLowerCase() == 'active'
                            ? OutlinedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _handleDeactivate(department);
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Deactivate Department'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.orange),
                                  foregroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _handleActivate(department);
                                },
                                icon: const Icon(Icons.check_circle_outlined),
                                label: const Text('Activate Department'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeactivate(Department department) async {
    // First, check if department has employees
    if (department.employeeCount > 0) {
      try {
        print('Fetching employees for department: ${department.id}');

        // Fetch employees in this department
        final employees = await _employeeService.getEmployees(
          departmentId: department.id,
          isActive: true,
        );

        print('Found ${employees.length} employees');

        if (employees.isNotEmpty) {
          // Show transfer dialog
          final transferred = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => TransferEmployeesDialog(
              department: department,
              employees: employees,
            ),
          );

          if (transferred != true) {
            // User cancelled transfer
            return;
          }

          // Employees transferred, reload departments to update count
          await _loadDepartments();
        }
      } catch (e) {
        print('Error loading employees: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load employees: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Now proceed with deactivation
    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeactivateDepartmentDialog(
        departmentName: department.name,
        onConfirm: () {},
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        await _departmentService.deactivateDepartment(department.id, reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Department deactivated successfully'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadDepartments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to deactivate: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleActivate(Department department) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ActivateDepartmentDialog(departmentName: department.name),
    );

    if (confirmed == true) {
      try {
        await _departmentService.activateDepartment(department.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Department activated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDepartments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to activate: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleAssignHead(Department department) async {
    try {
      // Fetch employees for this department
      final employees = await _employeeService.getEmployees(
        departmentId: department.id,
        isActive: true,
      );

      if (!mounted) return;

      final selectedEmployeeId = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AssignHeadDialog(
          departmentName: department.name,
          employees: employees,
          currentHeadId: department.departmentHead?.employeeId,
        ),
      );

      if (selectedEmployeeId != null) {
        await _departmentService.assignDepartmentHead(
          department.id,
          selectedEmployeeId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Department head assigned successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDepartments();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign head: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRemoveHead(Department department) async {
    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RemoveHeadDialog(
        departmentName: department.name,
        headName: department.departmentHead?.employeeName ?? 'Unknown',
      ),
    );

    if (reason != null) {
      try {
        await _departmentService.removeDepartmentHead(
          department.id,
          reason: reason.isEmpty ? null : reason,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Department head removed successfully'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadDepartments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove head: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary(isDark)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
