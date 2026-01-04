/// Attendance Records Screen - View Historical Attendance with Calendar
///
/// Shows employees list with calendar view for attendance tracking.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/attendance.dart';
import '../../models/department.dart';
import '../../models/employee.dart';
import '../../services/attendance_service.dart';
import '../../services/department_service.dart';
import '../../services/employee_service.dart';

class AttendanceRecordsScreen extends StatefulWidget {
  const AttendanceRecordsScreen({super.key});

  @override
  State<AttendanceRecordsScreen> createState() =>
      _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends State<AttendanceRecordsScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final DepartmentService _departmentService = DepartmentService();
  final EmployeeService _employeeService = EmployeeService();

  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  List<Department> _departments = [];
  Map<String, List<Attendance>> _employeeAttendance = {};

  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedDepartmentId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
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
      // Load departments and employees
      final departments = await _departmentService.getDepartments();
      final employees = await _employeeService.getEmployees();

      // Load attendance records
      final startDateStr =
          '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}';
      final endDateStr =
          '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}';

      final attendance = await _attendanceService.getAttendance(
        startDate: startDateStr,
        endDate: endDateStr,
        departmentId: _selectedDepartmentId,
      );

      // Group attendance by employee
      final Map<String, List<Attendance>> grouped = {};
      for (var record in attendance) {
        if (!grouped.containsKey(record.userId)) {
          grouped[record.userId] = [];
        }
        grouped[record.userId]!.add(record);
      }

      setState(() {
        _departments = departments;
        _allEmployees = employees;
        _employeeAttendance = grouped;
        _filterEmployees();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredEmployees = _allEmployees.where((employee) {
        // Filter by search query (name or last 4 digits of ID)
        if (query.isNotEmpty) {
          final last4Digits = employee.employeeId.length >= 4
              ? employee.employeeId.substring(employee.employeeId.length - 4)
              : employee.employeeId;

          if (!employee.fullName.toLowerCase().contains(query) &&
              !employee.employeeId.toLowerCase().contains(query) &&
              !last4Digits.contains(query)) {
            return false;
          }
        }

        // Filter by department
        if (_selectedDepartmentId != null) {
          if (employee.departmentId != _selectedDepartmentId) {
            return false;
          }
        }

        // Only show employees with attendance records
        return _employeeAttendance.containsKey(employee.id);
      }).toList();

      // Sort alphabetically
      _filteredEmployees.sort((a, b) => a.fullName.compareTo(b.fullName));
    });
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary(false)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
      _loadData();
    }
  }

  void _showEmployeeCalendar(Employee employee) {
    final attendance = _employeeAttendance[employee.id] ?? [];

    showDialog(
      context: context,
      builder: (context) => _EmployeeCalendarDialog(
        employee: employee,
        attendance: attendance,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
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
        title: Text(
          'Attendance Records',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildError(isDark)
            : _buildContent(isDark),
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      children: [
        // Filters
        _buildFilters(isDark),

        const SizedBox(height: AppSpacing.md),

        // Employee Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Text(
                '${_filteredEmployees.length} employee${_filteredEmployees.length != 1 ? 's' : ''}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Employee List
        Expanded(
          child: _filteredEmployees.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _filteredEmployees.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return _buildEmployeeCard(
                      _filteredEmployees[index],
                      isDark,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Row
          Row(
            children: [
              // Start Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    InkWell(
                      onTap: () => _selectDate(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface(isDark),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(color: AppColors.border(isDark)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppColors.primary(isDark),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(_startDate),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textPrimary(isDark),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // End Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Date',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    InkWell(
                      onTap: () => _selectDate(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface(isDark),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(color: AppColors.border(isDark)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppColors.primary(isDark),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(_endDate),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textPrimary(isDark),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Search and Department Filter Row
          Row(
            children: [
              // Search
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID...',
                    hintStyle: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary(isDark),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.textSecondary(isDark),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 20,
                              color: AppColors.textSecondary(isDark),
                            ),
                            onPressed: _searchController.clear,
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    isDense: true,
                  ),
                  style: AppTypography.bodySmall,
                  inputFormatters: [LengthLimitingTextInputFormatter(5)],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Filter Icon Button
              Container(
                decoration: BoxDecoration(
                  color: _selectedDepartmentId != null
                      ? AppColors.primary(isDark).withOpacity(0.1)
                      : AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _selectedDepartmentId != null
                        ? AppColors.primary(isDark)
                        : AppColors.border(isDark),
                  ),
                ),
                child: IconButton(
                  onPressed: () => _showFilterDialog(isDark),
                  icon: Icon(
                    Icons.filter_list,
                    color: _selectedDepartmentId != null
                        ? AppColors.primary(isDark)
                        : AppColors.textSecondary(isDark),
                  ),
                  tooltip: 'Filter by Department',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background(isDark),
        title: Text(
          'Filter by Department',
          style: AppTypography.heading3.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.all_inclusive,
                color: _selectedDepartmentId == null
                    ? AppColors.primary(isDark)
                    : AppColors.textSecondary(isDark),
              ),
              title: Text(
                'All Departments',
                style: TextStyle(
                  color: _selectedDepartmentId == null
                      ? AppColors.primary(isDark)
                      : AppColors.textPrimary(isDark),
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedDepartmentId = null;
                });
                _loadData();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ..._departments.map((dept) {
              final isSelected = _selectedDepartmentId == dept.id;
              return ListTile(
                leading: Icon(
                  Icons.business,
                  color: isSelected
                      ? AppColors.primary(isDark)
                      : AppColors.textSecondary(isDark),
                ),
                title: Text(
                  dept.name,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary(isDark)
                        : AppColors.textPrimary(isDark),
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary(isDark))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedDepartmentId = dept.id;
                  });
                  _loadData();
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee, bool isDark) {
    final attendance = _employeeAttendance[employee.id] ?? [];

    // Calculate stats
    int present = 0;
    int absent = 0;
    int pending = 0;

    for (var record in attendance) {
      switch (record.status) {
        case 'present':
          present++;
          break;
        case 'absent':
          absent++;
          break;
        case 'pending':
          pending++;
          break;
      }
    }

    return InkWell(
      onTap: () => _showEmployeeCalendar(employee),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: AppColors.primary(isDark).withOpacity(0.2),
              child: Text(
                employee.firstName[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Details
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    employee.departmentName ?? 'No Department',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'ID: ${employee.employeeId}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary(isDark),
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatBadge(present, Colors.green),
                    const SizedBox(width: 4),
                    _buildStatBadge(absent, Colors.red),
                    const SizedBox(width: 4),
                    _buildStatBadge(pending, Colors.orange),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.textTertiary(isDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
              'Try adjusting your filters',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Employee Calendar Dialog
class _EmployeeCalendarDialog extends StatelessWidget {
  final Employee employee;
  final List<Attendance> attendance;
  final DateTime startDate;
  final DateTime endDate;

  const _EmployeeCalendarDialog({
    required this.employee,
    required this.attendance,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Create attendance map by date
    final Map<DateTime, Attendance> attendanceMap = {};
    for (var record in attendance) {
      final date = DateTime.parse(record.date);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      attendanceMap[normalizedDate] = record;
    }

    return Dialog(
      backgroundColor: AppColors.background(isDark),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.fullName,
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                        Text(
                          employee.departmentName ?? 'No Department',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Legend
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('Present', Colors.green),
                  _buildLegendItem('Absent', Colors.red),
                  _buildLegendItem('Pending', Colors.orange),
                ],
              ),
            ),

            // Calendar
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TableCalendar(
                  firstDay: startDate,
                  lastDay: endDate,
                  focusedDay: endDate,
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(isDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary(isDark).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary(isDark),
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final normalizedDay = DateTime(
                        day.year,
                        day.month,
                        day.day,
                      );
                      final record = attendanceMap[normalizedDay];

                      if (record != null) {
                        Color bgColor;
                        switch (record.status) {
                          case 'present':
                            bgColor = Colors.green;
                            break;
                          case 'absent':
                            bgColor = Colors.red;
                            break;
                          case 'pending':
                            bgColor = Colors.orange;
                            break;
                          default:
                            bgColor = Colors.grey;
                        }

                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: bgColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: bgColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: bgColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }

                      return null;
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
