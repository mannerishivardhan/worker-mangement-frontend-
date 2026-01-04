/// Correct Attendance Screen - Full Screen View
///
/// Shows employee selection and attendance correction in full screen format.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/attendance.dart';
import '../../models/employee.dart';
import '../../models/department.dart';
import '../../services/attendance_service.dart';
import '../../services/employee_service.dart';
import '../../services/department_service.dart';

class CorrectAttendanceScreen extends StatefulWidget {
  const CorrectAttendanceScreen({super.key});

  @override
  State<CorrectAttendanceScreen> createState() =>
      _CorrectAttendanceScreenState();
}

class _CorrectAttendanceScreenState extends State<CorrectAttendanceScreen> {
  final EmployeeService _employeeService = EmployeeService();
  final DepartmentService _departmentService = DepartmentService();

  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  List<Department> _departments = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _sortMode = 'name'; // 'name' or 'department'
  String? _selectedDepartmentId;

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
      final departments = await _departmentService.getDepartments();
      final employees = await _employeeService.getEmployees();

      setState(() {
        _departments = departments;
        _allEmployees = employees;
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
        // Filter by search
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

        return true;
      }).toList();

      _sortEmployees();
    });
  }

  void _sortEmployees() {
    if (_sortMode == 'name') {
      _filteredEmployees.sort((a, b) => a.fullName.compareTo(b.fullName));
    } else {
      _filteredEmployees.sort((a, b) {
        final deptCompare = (a.departmentName ?? '').compareTo(
          b.departmentName ?? '',
        );
        if (deptCompare != 0) return deptCompare;
        return a.fullName.compareTo(b.fullName);
      });
    }
  }

  void _changeSortMode(String mode) {
    setState(() {
      _sortMode = mode;
      _sortEmployees();
    });
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
                _filterEmployees();
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
                  _filterEmployees();
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _selectEmployee(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _EmployeeAttendanceCorrectionScreen(employee: employee),
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
          'Correct Attendance',
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
        // Sort Toggles
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: Text('Name'),
                  selected: _sortMode == 'name',
                  onSelected: (selected) {
                    if (selected) _changeSortMode('name');
                  },
                  backgroundColor: AppColors.surface(isDark),
                  selectedColor: AppColors.primary(isDark).withOpacity(0.2),
                  checkmarkColor: AppColors.primary(isDark),
                  labelStyle: TextStyle(
                    color: _sortMode == 'name'
                        ? AppColors.primary(isDark)
                        : AppColors.textPrimary(isDark),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilterChip(
                  label: Text('Department'),
                  selected: _sortMode == 'department',
                  onSelected: (selected) {
                    if (selected) _changeSortMode('department');
                  },
                  backgroundColor: AppColors.surface(isDark),
                  selectedColor: AppColors.primary(isDark).withOpacity(0.2),
                  checkmarkColor: AppColors.primary(isDark),
                  labelStyle: TextStyle(
                    color: _sortMode == 'department'
                        ? AppColors.primary(isDark)
                        : AppColors.textPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search and Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
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
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
        ),

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

  Widget _buildEmployeeCard(Employee employee, bool isDark) {
    return InkWell(
      onTap: () => _selectEmployee(employee),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Row(
          children: [
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
                  const SizedBox(height: 4),
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
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary(isDark),
            ),
          ],
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

/// Employee Attendance Correction Screen (reusing dialog widget)
class _EmployeeAttendanceCorrectionScreen extends StatelessWidget {
  final Employee employee;

  const _EmployeeAttendanceCorrectionScreen({required this.employee});

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
              employee.fullName,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'ID: ${employee.employeeId}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(isDark),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: _EmployeeAttendanceCorrectionWidget(employee: employee),
    );
  }
}

/// Widget for displaying employee's past 7 days attendance and correction form
class _EmployeeAttendanceCorrectionWidget extends StatefulWidget {
  final Employee employee;

  const _EmployeeAttendanceCorrectionWidget({required this.employee});

  @override
  State<_EmployeeAttendanceCorrectionWidget> createState() =>
      _EmployeeAttendanceCorrectionWidgetState();
}

class _EmployeeAttendanceCorrectionWidgetState
    extends State<_EmployeeAttendanceCorrectionWidget> {
  final AttendanceService _attendanceService = AttendanceService();

  List<Attendance> _past7DaysAttendance = [];
  bool _isLoading = true;
  String? _errorMessage;
  Attendance? _selectedAttendance;

  @override
  void initState() {
    super.initState();
    _loadPast7DaysAttendance();
  }

  Future<void> _loadPast7DaysAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final attendance = await _attendanceService.getPast7DaysAttendance(
        widget.employee.id,
      );
      setState(() {
        _past7DaysAttendance = attendance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error(isDark),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _loadPast7DaysAttendance,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedAttendance != null) {
      return _CorrectionFormWidget(
        attendance: _selectedAttendance!,
        employee: widget.employee,
        onBack: () {
          setState(() {
            _selectedAttendance = null;
          });
          _loadPast7DaysAttendance();
        },
        onSuccess: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance corrected successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    }

    if (_past7DaysAttendance.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: AppColors.textTertiary(isDark),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No attendance records found',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No records available for correction in the past 7 days',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary(isDark),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _past7DaysAttendance.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final attendance = _past7DaysAttendance[index];
        final date = DateTime.parse(attendance.date);
        final dateStr = DateFormat('EEE, MMM dd').format(date);
        final entryTime = attendance.entryTime != null
            ? DateFormat('hh:mm a').format(attendance.entryTime!)
            : '--';
        final exitTime = attendance.exitTime != null
            ? DateFormat('hh:mm a').format(attendance.exitTime!)
            : '--';

        Color statusColor;
        switch (attendance.status) {
          case 'present':
            statusColor = Colors.green;
            break;
          case 'absent':
            statusColor = Colors.red;
            break;
          case 'pending':
            statusColor = Colors.orange;
            break;
          default:
            statusColor = Colors.grey;
        }

        return InkWell(
          onTap: () {
            setState(() {
              _selectedAttendance = attendance;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface(isDark),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Row(
              children: [
                // Date Badge
                Container(
                  width: 50,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('dd').format(date),
                        style: AppTypography.bodyLarge.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(date),
                        style: AppTypography.bodySmall.copyWith(
                          color: statusColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Attendance Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dateStr,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (attendance.isCorrected)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.edit,
                                      size: 10,
                                      color: statusColor,
                                    ),
                                  ),
                                Text(
                                  attendance.status.toUpperCase(),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'In: $entryTime',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary(isDark),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              'Out: $exitTime',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary(isDark),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedAttendance = attendance;
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary(isDark),
                    size: 20,
                  ),
                  tooltip: 'Correct',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Correction Form Widget (reusing from dialog)
class _CorrectionFormWidget extends StatefulWidget {
  final Attendance attendance;
  final Employee employee;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const _CorrectionFormWidget({
    required this.attendance,
    required this.employee,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<_CorrectionFormWidget> createState() => _CorrectionFormWidgetState();
}

class _CorrectionFormWidgetState extends State<_CorrectionFormWidget> {
  final AttendanceService _attendanceService = AttendanceService();
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  String _selectedStatus = '';
  TimeOfDay? _entryTime;
  TimeOfDay? _exitTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.attendance.status;

    if (widget.attendance.entryTime != null) {
      _entryTime = TimeOfDay.fromDateTime(widget.attendance.entryTime!);
    }
    if (widget.attendance.exitTime != null) {
      _exitTime = TimeOfDay.fromDateTime(widget.attendance.exitTime!);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitCorrection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final date = DateTime.parse(widget.attendance.date);

      DateTime? entryDateTime;
      DateTime? exitDateTime;

      if (_entryTime != null) {
        entryDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _entryTime!.hour,
          _entryTime!.minute,
        );
      }

      if (_exitTime != null) {
        exitDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _exitTime!.hour,
          _exitTime!.minute,
        );
      }

      await _attendanceService.correctAttendance(
        attendanceId: widget.attendance.id,
        entryTime: entryDateTime,
        exitTime: exitDateTime,
        status: _selectedStatus,
        reason: _reasonController.text.trim(),
      );

      widget.onSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.parse(widget.attendance.date);
    final dateStr = DateFormat('EEEE, MMMM dd, yyyy').format(date);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Display
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primary(isDark)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Status Selection
            Text(
              'Status',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: const Text('Present'),
                  selected: _selectedStatus == 'present',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = 'present';
                      });
                    }
                  },
                  selectedColor: Colors.green.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'present'
                        ? Colors.green
                        : AppColors.textPrimary(isDark),
                  ),
                ),
                ChoiceChip(
                  label: const Text('Absent'),
                  selected: _selectedStatus == 'absent',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = 'absent';
                      });
                    }
                  },
                  selectedColor: Colors.red.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'absent'
                        ? Colors.red
                        : AppColors.textPrimary(isDark),
                  ),
                ),
                ChoiceChip(
                  label: const Text('Pending'),
                  selected: _selectedStatus == 'pending',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = 'pending';
                      });
                    }
                  },
                  selectedColor: Colors.orange.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'pending'
                        ? Colors.orange
                        : AppColors.textPrimary(isDark),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Time Selection
            Text(
              'Times',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _entryTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _entryTime = time;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border(isDark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entry Time',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _entryTime?.format(context) ?? 'Not set',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _exitTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _exitTime = time;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border(isDark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exit Time',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _exitTime?.format(context) ?? 'Not set',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Reason
            Text(
              'Reason for Correction',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter reason for correction (min 10 characters)',
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a reason';
                }
                if (value.trim().length < 10) {
                  return 'Reason must be at least 10 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : widget.onBack,
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitCorrection,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Correction'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
