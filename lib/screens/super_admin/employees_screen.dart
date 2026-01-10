/// Employees Screen - Super Admin
///
/// List all employees with search, filters, add/edit capabilities.
/// NotebookLM design: pure white, outlined icons, light blue accents.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/employee.dart';
import '../../models/department.dart';
import '../../services/employee_service.dart';
import '../../services/department_service.dart';
import '../../widgets/employees/employee_dialog.dart';
import 'employee_history_screen.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});
  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final EmployeeService _employeeService = EmployeeService();
  final DepartmentService _departmentService = DepartmentService();
  final TextEditingController _searchController = TextEditingController();

  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  List<Department> _departments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedDepartment;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadData(); // Load both employees and departments in parallel
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load employees and departments in parallel for better performance
      final results = await Future.wait([
        _employeeService.getEmployees(),
        _departmentService.getDepartments(),
      ]);

      setState(() {
        _employees = results[0] as List<Employee>;
        _filteredEmployees = results[0] as List<Employee>;
        _departments = (results[1] as List<Department>)
            .where((d) => d.isActive)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final employees = await _employeeService.getEmployees();
      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _departmentService.getDepartments();
      setState(() {
        _departments = departments.where((d) => d.isActive).toList();
      });
    } catch (e) {
      // Silently fail - department filter will be empty
    }
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = _employees.where((emp) {
        // Check name and email
        bool matchesSearch =
            emp.fullName.toLowerCase().contains(query) ||
            emp.email.toLowerCase().contains(query);

        // Check employee ID - allow searching by full ID or just suffix
        if (!matchesSearch) {
          final empId = emp.employeeId.toLowerCase();
          // Match full ID (e.g., "emp_1234")
          if (empId.contains(query)) {
            matchesSearch = true;
          }
          // Match just the suffix after EMP_ (e.g., "1234")
          else if (empId.startsWith('emp_') &&
              empId.substring(4).contains(query)) {
            matchesSearch = true;
          }
        }

        final matchesDepartment =
            _selectedDepartment == null ||
            emp.departmentId == _selectedDepartment;

        final matchesRole = _selectedRole == null || emp.role == _selectedRole;

        return matchesSearch && matchesDepartment && matchesRole;
      }).toList();

      // Sort alphabetically by full name
      _filteredEmployees.sort((a, b) => a.fullName.compareTo(b.fullName));
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
          'Employees',
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
              inputFormatters: [
                // If the input is purely numeric, limit to 5 digits
                TextInputFormatter.withFunction((oldValue, newValue) {
                  // Check if new value is purely numeric
                  if (newValue.text.isNotEmpty &&
                      RegExp(r'^\d+$').hasMatch(newValue.text)) {
                    // Limit to 5 digits and pad with zeros
                    if (newValue.text.length <= 5) {
                      return newValue;
                    } else {
                      // Only keep first 5 digits
                      return TextEditingValue(
                        text: newValue.text.substring(0, 5),
                        selection: TextSelection.collapsed(offset: 5),
                      );
                    }
                  }
                  // Allow non-numeric (for name/email search)
                  return newValue;
                }),
              ],
              decoration: InputDecoration(
                hintText: 'Search by name, ID (5 digits), or email...',
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

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                // Role filter
                DropdownButton<String?>(
                  value: _selectedRole,
                  hint: const Text('All Roles'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Roles'),
                    ),
                    const DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admin'),
                    ),
                    const DropdownMenuItem(
                      value: 'employee',
                      child: Text('Employee'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                      _filterEmployees();
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                // Department filter
                DropdownButton<String?>(
                  value: _selectedDepartment,
                  hint: const Text('All Departments'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Departments'),
                    ),
                    ..._departments.map((dept) {
                      return DropdownMenuItem(
                        value: dept.id,
                        child: Text(dept.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value;
                      _filterEmployees();
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                // Clear filters
                if (_selectedRole != null || _selectedDepartment != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedRole = null;
                        _selectedDepartment = null;
                        _filterEmployees();
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // Employee list
          Expanded(child: _buildContent(isDark)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => EmployeeDialog(departments: _departments),
          );
          if (result == true) {
            _loadEmployees(); // Reload list after adding
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
              'Error loading employees',
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
              onPressed: _loadEmployees,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredEmployees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textTertiary(isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _searchController.text.isEmpty
                  ? 'No employees yet'
                  : 'No employees found',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _searchController.text.isEmpty
                  ? 'Tap + to add your first employee'
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
      onRefresh: _loadData, // Use parallel loading on refresh too
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _filteredEmployees.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final employee = _filteredEmployees[index];
          return _buildEmployeeCard(employee, isDark);
        },
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee, bool isDark) {
    return GestureDetector(
      onTap: () {
        _showEmployeeDetails(employee, isDark);
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
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary(isDark).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  employee.firstName[0].toUpperCase(),
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.primary(isDark),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Employee info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    employee.employeeId,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  if (employee.departmentName != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 14,
                          color: AppColors.textTertiary(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          employee.departmentName!,
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

            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor(employee.role, isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                _getRoleLabel(employee.role),
                style: AppTypography.labelSmall.copyWith(
                  color: _getRoleColor(employee.role, isDark),
                ),
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

  void _showEmployeeDetails(Employee employee, bool isDark) {
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
                      // Header with avatar and name
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary(isDark).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                employee.firstName[0].toUpperCase(),
                                style: AppTypography.heading1.copyWith(
                                  color: AppColors.primary(isDark),
                                  fontSize: 36,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee.fullName,
                                  style: AppTypography.heading2.copyWith(
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(
                                      employee.role,
                                      isDark,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                  ),
                                  child: Text(
                                    _getRoleLabel(employee.role),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: _getRoleColor(
                                        employee.role,
                                        isDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),

                      // Employee Details
                      Text(
                        'Employee Information',
                        style: AppTypography.heading3.copyWith(
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _buildDetailRow(
                        'Employee ID',
                        employee.employeeId,
                        Icons.badge_outlined,
                        isDark,
                      ),
                      _buildDetailRow(
                        'Email',
                        employee.email,
                        Icons.email_outlined,
                        isDark,
                      ),
                      if (employee.departmentName != null)
                        _buildDetailRow(
                          'Department',
                          employee.departmentName!,
                          Icons.business_outlined,
                          isDark,
                        ),
                      if (employee.jobRole != null &&
                          employee.jobRole!.isNotEmpty &&
                          employee.jobRole != 'null')
                        _buildDetailRow(
                          'Job Role',
                          employee.jobRole!,
                          Icons.work_outline,
                          isDark,
                        ),
                      if (employee.shiftName != null &&
                          employee.shiftName != 'null')
                        _buildDetailRow(
                          'Shift',
                          employee.shiftName!,
                          Icons.schedule_outlined,
                          isDark,
                        ),
                      if (employee.monthlySalary > 0)
                        _buildDetailRow(
                          'Monthly Salary',
                          '\$${employee.monthlySalary.toStringAsFixed(2)}',
                          Icons.payments_outlined,
                          isDark,
                        ),
                      if (employee.joiningDate != null)
                        _buildDetailRow(
                          'Joining Date',
                          _formatDate(employee.joiningDate!),
                          Icons.calendar_today_outlined,
                          isDark,
                        ),
                      _buildDetailRow(
                        'Status',
                        employee.isActive ? 'Active' : 'Inactive',
                        employee.isActive
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        isDark,
                        valueColor: employee.isActive
                            ? Colors.green
                            : Colors.red,
                      ),

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
                                    builder: (context) => EmployeeHistoryScreen(
                                      employee: employee,
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
                                  builder: (context) => EmployeeDialog(
                                    employee: employee,
                                    departments: _departments,
                                  ),
                                );
                                if (result == true) {
                                  _loadEmployees();
                                }
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit Employee'),
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getRoleColor(String role, bool isDark) {
    switch (role) {
      case 'super_admin':
        return AppColors.error(isDark);
      case 'dept_head':
        return AppColors.warning(isDark);
      default:
        return AppColors.primary(isDark);
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'dept_head':
        return 'Dept Head';
      default:
        return 'Employee';
    }
  }
}
