/// Shifts Management Screen - Create and manage work shifts
///
/// Allows Super Admin to define shifts with job roles and overtime settings

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/shift.dart';
import '../../models/department.dart';
import '../../services/shift_service.dart';
import '../../services/department_service.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  final ShiftService _shiftService = ShiftService();
  final DepartmentService _departmentService = DepartmentService();

  List<Shift> _shifts = [];
  List<Department> _departments = [];
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
      // Load shifts and departments in parallel
      final results = await Future.wait([
        _shiftService.getAllShifts(),
        _departmentService.getDepartments(),
      ]);

      setState(() {
        _shifts = results[0] as List<Shift>;
        _departments = results[1] as List<Department>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showShiftDialog([Shift? shift]) {
    showDialog(
      context: context,
      builder: (context) => ShiftDialog(
        shift: shift,
        departments: _departments,
        onSaved: () {
          Navigator.pop(context);
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteShift(Shift shift) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shift'),
        content: Text('Are you sure you want to delete ${shift.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _shiftService.deleteShift(shift.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shift deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
        title: Text(
          'Shift Management',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState(isDark)
          : _shifts.isEmpty
          ? _buildEmptyState(isDark)
          : _buildShiftsList(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showShiftDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Create Shift'),
        backgroundColor: AppColors.primary(isDark),
      ),
    );
  }

  Widget _buildShiftsList(bool isDark) {
    // Group shifts by department
    final Map<String, List<Shift>> shiftsByDept = {};
    for (var shift in _shifts) {
      if (!shiftsByDept.containsKey(shift.departmentId)) {
        shiftsByDept[shift.departmentId] = [];
      }
      shiftsByDept[shift.departmentId]!.add(shift);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: shiftsByDept.length,
        itemBuilder: (context, index) {
          final deptId = shiftsByDept.keys.elementAt(index);
          final shifts = shiftsByDept[deptId]!;
          final dept = _departments.firstWhere((d) => d.id == deptId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.xs,
                ),
                child: Text(
                  dept.name,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Shifts for this department
              ...shifts.map((shift) => _buildShiftCard(shift, isDark)),
              const SizedBox(height: AppSpacing.md),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShiftCard(Shift shift, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: AppColors.surface(isDark),
      child: InkWell(
        onTap: () => _showShiftDialog(shift),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shift Name and ID
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shift.displayName,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textPrimary(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'ID: ${shift.shiftId}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary(isDark),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteShift(shift),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red,
                    tooltip: 'Delete',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Job Role Badge
              if (shift.jobRole != null && shift.jobRole!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary(isDark).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.assignment_ind_outlined,
                        size: 14,
                        color: AppColors.primary(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shift.jobRole!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.sm),

              // Timing
              Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: AppColors.textSecondary(isDark),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    shift.timeDisplay,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.timelapse_outlined,
                    size: 16,
                    color: AppColors.textSecondary(isDark),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${shift.totalHours}h',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),

              // Overtime Badge
              if (shift.overtimeAllowed)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success(isDark).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: AppColors.success(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Overtime: ${shift.overtimeMultiplier}x',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success(isDark),
                            fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time_outlined,
            size: 64,
            color: AppColors.textTertiary(isDark),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No shifts created yet',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create a shift to get started',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Error loading shifts',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _errorMessage ?? 'Unknown error',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Shift Dialog for creating/editing shifts
class ShiftDialog extends StatefulWidget {
  final Shift? shift;
  final List<Department> departments;
  final VoidCallback onSaved;

  const ShiftDialog({
    super.key,
    this.shift,
    required this.departments,
    required this.onSaved,
  });

  @override
  State<ShiftDialog> createState() => _ShiftDialogState();
}

class _ShiftDialogState extends State<ShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  final ShiftService _shiftService = ShiftService();

  final TextEditingController _nameController = TextEditingController();

  String? _selectedDepartmentId;
  String? _selectedJobRole; // Changed from TextEditingController
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _overtimeAllowed = true;
  double _overtimeMultiplier = 1.5;

  bool _isLoading = false;

  // Department-specific job roles mapping
  final Map<String, List<String>> _departmentJobRoles = {
    'Security': [
      'Normal Security Staff',
      'Nepali Workers',
      'Supervisor',
      'Team Lead',
    ],
    'Canteen': ['Mori Workers', 'Tiffin Masters', 'Chef', 'Kitchen Helper'],
    'Housekeeping': ['Cleaning Staff', 'Janitor', 'Supervisor'],
    'Maintenance': [
      'Electrician',
      'Plumber',
      'Carpenter',
      'General Maintenance',
    ],
    'Administration': ['Office Staff', 'Clerk', 'Manager', 'Assistant'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.shift != null) {
      _nameController.text = widget.shift!.name;
      _selectedJobRole = widget.shift!.jobRole;
      _selectedDepartmentId = widget.shift!.departmentId;
      _startTime = _parseTimeString(widget.shift!.startTime);
      _endTime = _parseTimeString(widget.shift!.endTime);
      _overtimeAllowed = widget.shift!.overtimeAllowed;
      _overtimeMultiplier = widget.shift!.overtimeMultiplier;
    }
  }

  TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'departmentId': _selectedDepartmentId,
        'startTime': _formatTimeOfDay(_startTime),
        'endTime': _formatTimeOfDay(_endTime),
        'jobRole': _selectedJobRole,
        'overtimeAllowed': _overtimeAllowed,
        'overtimeMultiplier': _overtimeMultiplier,
      };

      if (widget.shift == null) {
        await _shiftService.createShift(data);
      } else {
        await _shiftService.updateShift(widget.shift!.id, data);
      }

      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppColors.background(isDark),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  widget.shift == null ? 'Create Shift' : 'Edit Shift',
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Shift Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Shift Name *',
                    hintText: 'Morning Shift',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Shift name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Department
                DropdownButtonFormField<String>(
                  value: _selectedDepartmentId,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  items: widget.departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept.id,
                      child: Text(dept.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartmentId = value;
                      // Clear job role when department changes
                      _selectedJobRole = null;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Department is required';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Job Role Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedJobRole,
                  decoration: InputDecoration(
                    labelText: 'Job Role',
                    prefixIcon: const Icon(Icons.assignment_ind_outlined),
                    helperText: _selectedDepartmentId == null
                        ? 'Select a department first'
                        : 'Optional: Specific job classification',
                  ),
                  items: _getJobRolesForDepartment(),
                  onChanged: _selectedDepartmentId == null
                      ? null
                      : (value) {
                          setState(() {
                            _selectedJobRole = value;
                          });
                        },
                ),

                const SizedBox(height: AppSpacing.md),

                // Timing
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Time *',
                            prefixIcon: Icon(Icons.access_time_outlined),
                          ),
                          child: Text(_formatTimeOfDay(_startTime)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Time *',
                            prefixIcon: Icon(Icons.access_time_outlined),
                          ),
                          child: Text(_formatTimeOfDay(_endTime)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Overtime Toggle
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border(isDark)),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            color: AppColors.textSecondary(isDark),
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Overtime Allowed',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                          ),
                          Switch(
                            value: _overtimeAllowed,
                            onChanged: (value) {
                              setState(() => _overtimeAllowed = value);
                            },
                          ),
                        ],
                      ),
                      if (_overtimeAllowed) ...[
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<double>(
                          value: _overtimeMultiplier,
                          decoration: const InputDecoration(
                            labelText: 'Overtime Multiplier',
                            prefixIcon: Icon(Icons.close_outlined),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 1.5,
                              child: Text('1.5x (Standard)'),
                            ),
                            DropdownMenuItem(
                              value: 1.75,
                              child: Text('1.75x (Night)'),
                            ),
                            DropdownMenuItem(
                              value: 2.0,
                              child: Text('2.0x (Weekend)'),
                            ),
                            DropdownMenuItem(
                              value: 2.5,
                              child: Text('2.5x (Holiday)'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _overtimeMultiplier = value!);
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.shift == null ? 'Create' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Get job roles for the selected department
  List<DropdownMenuItem<String>>? _getJobRolesForDepartment() {
    if (_selectedDepartmentId == null) {
      return [];
    }

    // Find the department name
    final department = widget.departments.firstWhere(
      (dept) => dept.id == _selectedDepartmentId,
      orElse: () => widget.departments.first,
    );

    // Get job roles for this department name
    final roles = _departmentJobRoles[department.name] ?? [];

    if (roles.isEmpty) {
      // Return a generic "Other" option if no specific roles are defined
      return [const DropdownMenuItem(value: 'Other', child: Text('Other'))];
    }

    return roles.map((role) {
      return DropdownMenuItem(value: role, child: Text(role));
    }).toList();
  }
}
