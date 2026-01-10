/// Attendance Screen - Today's Attendance
///
/// Shows today's attendance for all employees with mark entry/exit functionality.
/// NotebookLM design: clean list, outlined icons, light blue accents.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/attendance.dart';
import '../../models/employee.dart';
import '../../models/department.dart';
import '../../services/attendance_service.dart';
import '../../services/employee_service.dart';
import '../../services/department_service.dart';
import 'correct_attendance_screen.dart';
import 'attendance_records_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final EmployeeService _employeeService = EmployeeService();
  final DepartmentService _departmentService = DepartmentService();

  List<Attendance> _attendanceRecords = [];
  List<Employee> _allEmployees = [];
  List<Department> _departments = [];
  String? _selectedDepartmentId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all data in parallel for faster performance
      final results = await Future.wait([
        _attendanceService.getTodayAttendance(),
        _employeeService.getEmployees(),
        _departmentService.getDepartments(),
      ]);

      setState(() {
        _attendanceRecords = results[0] as List<Attendance>;
        _allEmployees = (results[1] as List<Employee>)
            .where((e) => e.isActive)
            .toList();
        _departments = (results[2] as List<Department>)
            .where((d) => d.isActive)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _markEntry(Employee employee) async {
    try {
      await _attendanceService.markEntry(
        userId: employee.id,
        entryTime: DateTime.now(),
      );
      // Only reload attendance records for faster response
      final attendance = await _attendanceService.getTodayAttendance();
      setState(() {
        _attendanceRecords = attendance;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry marked for ${employee.fullName}'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  Future<void> _markExit(Employee employee) async {
    try {
      await _attendanceService.markExit(
        userId: employee.id,
        exitTime: DateTime.now(),
      );
      // Only reload attendance records for faster response
      final attendance = await _attendanceService.getTodayAttendance();
      setState(() {
        _attendanceRecords = attendance;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exit marked for ${employee.fullName}'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  /// Navigate to correct attendance screen
  void _showCorrectAttendanceDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CorrectAttendanceScreen()),
    ).then((_) {
      // Reload data when returning from correction screen
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM dd, yyyy').format(today);

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
              'Today\'s Attendance',
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
            Text(
              dateStr,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
        actions: [
          // View Records Button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceRecordsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'View Records',
          ),
          // Correct Attendance Button
          IconButton(
            onPressed: _showCorrectAttendanceDialog,
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: 'Correct Past Attendance',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState(isDark)
            : _buildContent(isDark),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error(isDark)),
          const SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    // Create a map of userId -> attendance for quick lookup
    final attendanceMap = <String, Attendance>{};
    for (var record in _attendanceRecords) {
      attendanceMap[record.userId] = record;
    }

    // Stats
    final totalEmployees = _allEmployees.length;
    final presentCount = _attendanceRecords.where((a) => a.isPresent).length;
    final pendingCount = _attendanceRecords.where((a) => a.isPending).length;
    final absentCount = totalEmployees - _attendanceRecords.length;

    return Column(
      children: [
        // Stats Cards
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  label: 'Present',
                  value: presentCount.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  label: 'Pending',
                  value: pendingCount.toString(),
                  color: Colors.orange,
                  icon: Icons.pending_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  label: 'Absent',
                  value: absentCount.toString(),
                  color: Colors.red,
                  icon: Icons.cancel_outlined,
                ),
              ),
            ],
          ),
        ),

        // Department Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: DropdownButtonFormField<String?>(
            value: _selectedDepartmentId,
            decoration: InputDecoration(
              labelText: 'Filter by Department',
              prefixIcon: Icon(
                Icons.business_outlined,
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
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Departments'),
              ),
              ..._departments.map((dept) {
                return DropdownMenuItem(value: dept.id, child: Text(dept.name));
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDepartmentId = value;
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Employee List
        Expanded(
          child: () {
            // Filter employees by department
            var filteredEmployees = _allEmployees;
            if (_selectedDepartmentId != null) {
              filteredEmployees = filteredEmployees
                  .where((e) => e.departmentId == _selectedDepartmentId)
                  .toList();
            }

            // Sort by department name, then by employee name
            filteredEmployees.sort((a, b) {
              // First sort by department
              final deptCompare = (a.departmentName ?? '').compareTo(
                b.departmentName ?? '',
              );
              if (deptCompare != 0) return deptCompare;
              // Then by name
              return a.fullName.compareTo(b.fullName);
            });

            if (filteredEmployees.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                final attendance = attendanceMap[employee.id];
                return _buildEmployeeCard(isDark, employee, attendance);
              },
            );
          }(),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(isDark), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.heading1.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(
    bool isDark,
    Employee employee,
    Attendance? attendance,
  ) {
    final hasEntry = attendance?.entryTime != null;
    final hasExit = attendance?.exitTime != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(isDark), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary(isDark).withOpacity(0.1),
                child: Text(
                  employee.firstName[0].toUpperCase(),
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Employee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${employee.employeeId} • ${employee.departmentName ?? 'No Dept'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              _buildStatusBadge(isDark, attendance),
            ],
          ),

          if (attendance != null) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entry',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary(isDark),
                        ),
                      ),
                      Text(
                        hasEntry
                            ? DateFormat(
                                'hh:mm a',
                              ).format(attendance.entryTime!)
                            : '--',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exit',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary(isDark),
                        ),
                      ),
                      Text(
                        hasExit
                            ? DateFormat('hh:mm a').format(attendance.exitTime!)
                            : '--',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary(isDark),
                        ),
                      ),
                      Text(
                        attendance.workDurationFormatted,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Show overtime if available (NEW)
                      if (attendance.overtimeHours != null &&
                          attendance.overtimeHours! > 0)
                        Text(
                          '(OT: ${attendance.overtimeHours!.toStringAsFixed(1)}h)',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success(isDark),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.sm),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasEntry ? null : () => _markEntry(employee),
                  icon: Icon(
                    hasEntry ? Icons.check : Icons.login_outlined,
                    size: 18,
                  ),
                  label: Text(hasEntry ? 'Checked In' : 'Mark Entry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasEntry
                        ? Colors.green
                        : AppColors.primary(isDark),
                    side: BorderSide(
                      color: hasEntry
                          ? Colors.green
                          : AppColors.primary(isDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (!hasEntry || hasExit)
                      ? null
                      : () => _markExit(employee),
                  icon: Icon(
                    hasExit ? Icons.check : Icons.logout_outlined,
                    size: 18,
                  ),
                  label: Text(hasExit ? 'Checked Out' : 'Mark Exit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasExit
                        ? Colors.green
                        : AppColors.primary(isDark),
                    side: BorderSide(
                      color: hasExit ? Colors.green : AppColors.primary(isDark),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark, Attendance? attendance) {
    if (attendance == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          'Absent',
          style: AppTypography.bodySmall.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    Color color;
    String label;
    if (attendance.isPresent) {
      color = Colors.green;
      label = 'Present';
    } else if (attendance.isPending) {
      color = Colors.orange;
      label = 'Pending';
    } else {
      color = Colors.red;
      label = 'Absent';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
            'No employees found',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add employees to start marking attendance',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// Employee Selection Dialog for Correction
class _EmployeeSelectionDialog extends StatefulWidget {
  final List<Employee> employees;

  const _EmployeeSelectionDialog({required this.employees});

  @override
  State<_EmployeeSelectionDialog> createState() =>
      _EmployeeSelectionDialogState();
}

class _EmployeeSelectionDialogState extends State<_EmployeeSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Employee> _filteredEmployees = [];
  String _sortMode = 'name'; // 'name' or 'department'

  @override
  void initState() {
    super.initState();
    _filteredEmployees = _sortEmployees(widget.employees);
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Sort employees based on current sort mode
  List<Employee> _sortEmployees(List<Employee> employees) {
    final sorted = List<Employee>.from(employees);

    if (_sortMode == 'department') {
      // Sort by department first, then by name
      sorted.sort((a, b) {
        final deptCompare = (a.departmentName ?? '').compareTo(
          b.departmentName ?? '',
        );
        if (deptCompare != 0) return deptCompare;
        return a.fullName.compareTo(b.fullName);
      });
    } else {
      // Sort alphabetically by name (dictionary order)
      sorted.sort((a, b) => a.fullName.compareTo(b.fullName));
    }

    return sorted;
  }

  /// Filter employees by search query (name or last 4 digits of ID)
  void _filterEmployees() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = _sortEmployees(widget.employees);
      } else {
        _filteredEmployees = _sortEmployees(
          widget.employees.where((employee) {
            // Search by full name
            if (employee.fullName.toLowerCase().contains(query)) {
              return true;
            }

            // Search by last 4 digits of employee ID (e.g., "1234" matches "EMP_1234")
            if (employee.employeeId.isNotEmpty) {
              // Extract last 4 digits from employee ID
              final idParts = employee.employeeId.split('_');
              if (idParts.length > 1) {
                final idNumber = idParts.last; // Get "00001" from "EMP_00001"
                // Check if query matches the end of the ID number
                if (idNumber.contains(query) || idNumber.endsWith(query)) {
                  return true;
                }
              }
              // Also check full employee ID
              if (employee.employeeId.toLowerCase().contains(query)) {
                return true;
              }
            }

            return false;
          }).toList(),
        );
      }
    });
  }

  /// Change sort mode and re-sort
  void _changeSortMode(String mode) {
    setState(() {
      _sortMode = mode;
      _filteredEmployees = _sortEmployees(_filteredEmployees);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppColors.background(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  topRight: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Employee',
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or ID (e.g., 1234)...',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary(isDark),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary(isDark),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppColors.textSecondary(isDark),
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
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

            // Sort Mode Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Text(
                    'Sort by:',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilterChip(
                    label: const Text('Name'),
                    selected: _sortMode == 'name',
                    onSelected: (selected) {
                      if (selected) _changeSortMode('name');
                    },
                    selectedColor: AppColors.primary(isDark).withOpacity(0.2),
                    checkmarkColor: AppColors.primary(isDark),
                    labelStyle: TextStyle(
                      color: _sortMode == 'name'
                          ? AppColors.primary(isDark)
                          : AppColors.textSecondary(isDark),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilterChip(
                    label: const Text('Department'),
                    selected: _sortMode == 'department',
                    onSelected: (selected) {
                      if (selected) _changeSortMode('department');
                    },
                    selectedColor: AppColors.primary(isDark).withOpacity(0.2),
                    checkmarkColor: AppColors.primary(isDark),
                    labelStyle: TextStyle(
                      color: _sortMode == 'department'
                          ? AppColors.primary(isDark)
                          : AppColors.textSecondary(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Results Count
            if (_filteredEmployees.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_filteredEmployees.length} employee${_filteredEmployees.length != 1 ? 's' : ''} found',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.sm),

            // Employee List (sorted by department)
            Expanded(
              child: _filteredEmployees.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: AppColors.textTertiary(isDark),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No employees found',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _filteredEmployees.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final employee = _filteredEmployees[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary(
                              isDark,
                            ).withOpacity(0.2),
                            child: Text(
                              employee.firstName[0].toUpperCase(),
                              style: TextStyle(
                                color: AppColors.primary(isDark),
                              ),
                            ),
                          ),
                          title: Text(
                            employee.fullName,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee.departmentName ?? 'No Department',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                              Text(
                                'ID: ${employee.employeeId}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textTertiary(isDark),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textTertiary(isDark),
                          ),
                          onTap: () => Navigator.of(context).pop(employee),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
