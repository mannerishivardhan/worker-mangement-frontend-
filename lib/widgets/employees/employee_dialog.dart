/// Employee Dialog - Add/Edit Employee
///
/// Modal dialog for creating new employees and editing existing ones.
/// NotebookLM design: clean inputs, light blue accents, rounded corners.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/employee.dart';
import '../../models/department.dart';
import '../../services/employee_service.dart';
import '../../services/department_service.dart';

class EmployeeDialog extends StatefulWidget {
  final Employee? employee;
  final List<Department>? departments; // Optional pre-loaded departments

  const EmployeeDialog({super.key, this.employee, this.departments});

  @override
  State<EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<EmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _employeeService = EmployeeService();
  final DepartmentService _departmentService = DepartmentService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  List<Department> _departments = [];
  String? _selectedDepartmentId;
  String? _selectedJobRole; // Selected job role from department

  String _selectedRole = 'employee';
  bool _overtimeEligible = true;
  DateTime _joiningDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Use pre-loaded departments if provided, otherwise load them
    if (widget.departments != null && widget.departments!.isNotEmpty) {
      _departments = widget.departments!.where((d) => d.isActive).toList();
      _initializeEmployeeData();
    } else {
      _loadDepartments();
    }

    if (widget.employee != null) {
      // Editing existing employee
      _firstNameController.text = widget.employee!.firstName;
      _lastNameController.text = widget.employee!.lastName;
      _emailController.text = widget.employee!.email;

      // Phone number handling (remove +91 prefix if exists for display)
      if (widget.employee!.phone.isNotEmpty) {
        String phoneNumber = widget.employee!.phone;
        // Remove +91 prefix if present
        if (phoneNumber.startsWith('+91')) {
          phoneNumber = phoneNumber.substring(3);
        }
        _phoneController.text = phoneNumber;
      }

      _employeeIdController.text = widget.employee!.employeeId;
      _salaryController.text = widget.employee!.monthlySalary.toString();
      _selectedRole = widget.employee!.role;
      _overtimeEligible = widget.employee!.overtimeEligible ?? true; // NEW
      _joiningDate = widget.employee!.joiningDate;
      // Note: _selectedDepartmentId and _selectedJobRole will be set after departments load
    }
  }

  void _initializeEmployeeData() {
    if (widget.employee != null) {
      final employeeDeptId = widget.employee!.departmentId;
      // Only set if department exists in loaded list
      if (_departments.any((d) => d.id == employeeDeptId)) {
        setState(() {
          _selectedDepartmentId = employeeDeptId;
          _selectedJobRole = widget.employee!.jobRole;
        });
      }
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _departmentService.getDepartments();
      setState(() {
        _departments = departments.where((d) => d.isActive).toList();
      });
      _initializeEmployeeData();
    } catch (e) {
      // Silently fail - departments dropdown will be empty
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim().isNotEmpty
            ? '+91${_phoneController.text.trim()}'
            : null,
        'role': _selectedRole,
        'jobRole': _selectedRole == 'admin' ? null : _selectedJobRole,
        'departmentId': _selectedDepartmentId,
        'monthlySalary': double.parse(_salaryController.text.trim()),
        'overtimeEligible': _selectedRole == 'admin'
            ? false
            : _overtimeEligible,
        'joiningDate': _joiningDate.toIso8601String(),
        'password': 'Welcome@123', // Default password for new employees
      };

      if (widget.employee == null) {
        // Create new employee
        await _employeeService.createEmployee(data);
      } else {
        // Update existing employee
        await _employeeService.updateEmployee(widget.employee!.id, data);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _joiningDate = picked;
      });
    }
  }

  /// Get job roles for the selected department
  List<DropdownMenuItem<String>>? _getJobRolesForDepartment() {
    if (_selectedDepartmentId == null || _departments.isEmpty) {
      return [];
    }

    // Find the department
    final departmentIndex = _departments.indexWhere(
      (dept) => dept.id == _selectedDepartmentId,
    );

    if (departmentIndex == -1) {
      return [];
    }

    final department = _departments[departmentIndex];

    // Get roles from department configuration
    if (department.roles.isEmpty) {
      return [const DropdownMenuItem(value: 'General', child: Text('General'))];
    }

    return department.roles.map((role) {
      return DropdownMenuItem(value: role.name, child: Text(role.name));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppColors.surface(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
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
                  widget.employee == null ? 'Add Employee' : 'Edit Employee',
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error(isDark).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name *',
                    hintText: 'Enter first name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'First name must be at least 2 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: AppSpacing.md),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name *',
                    hintText: 'Enter last name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Last name must be at least 2 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: AppSpacing.md),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'employee@company.com',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: '9876543210',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.textSecondary(isDark),
                    ),
                    prefixText: '+91 ',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.trim().length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Employee ID (read-only when editing, hidden when creating)
                if (widget.employee != null)
                  TextFormField(
                    controller: _employeeIdController,
                    decoration: InputDecoration(
                      labelText: 'Employee ID',
                      hintText: 'Auto-generated',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                    enabled: false, // Read-only
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary(isDark),
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // Department Dropdown (REQUIRED)
                DropdownButtonFormField<String>(
                  value: _departments.any((d) => d.id == _selectedDepartmentId)
                      ? _selectedDepartmentId
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Department *',
                    prefixIcon: Icon(
                      Icons.business_outlined,
                      color: AppColors.textSecondary(isDark),
                    ),
                    helperText: _departments.isEmpty
                        ? 'Loading departments...'
                        : null,
                  ),
                  items: _departments.isEmpty
                      ? [
                          const DropdownMenuItem(
                            value: '',
                            enabled: false,
                            child: Text('Loading...'),
                          ),
                        ]
                      : _departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept.id,
                            child: Text(dept.name),
                          );
                        }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Department is required';
                    }
                    return null;
                  },
                  onChanged: _departments.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _selectedDepartmentId = value;
                            // Clear job role when department changes
                            _selectedJobRole = null;
                          });
                        },
                ),

                const SizedBox(height: AppSpacing.md),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role *',
                    prefixIcon: Icon(
                      Icons.work_outline,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'employee',
                      child: Text('Employee'),
                    ),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                      // Clear job role when role changes to admin
                      if (_selectedRole == 'admin') {
                        _selectedJobRole = null;
                      }
                    });
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Job Role Dropdown - Only show for employees, not admins
                if (_selectedRole == 'employee')
                  Builder(
                    builder: (context) {
                      final jobRoles = _getJobRolesForDepartment() ?? [];
                      final hasValidJobRole = jobRoles.any(
                        (item) => item.value == _selectedJobRole,
                      );

                      return DropdownButtonFormField<String>(
                        value: hasValidJobRole ? _selectedJobRole : null,
                        decoration: InputDecoration(
                          labelText: 'Job Role',
                          prefixIcon: Icon(
                            Icons.assignment_ind_outlined,
                            color: AppColors.textSecondary(isDark),
                          ),
                          helperText: _selectedDepartmentId == null
                              ? 'Select a department first'
                              : 'Specific job classification within department',
                          helperMaxLines: 2,
                        ),
                        items: jobRoles,
                        onChanged: _selectedDepartmentId == null
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedJobRole = value;
                                });
                              },
                      );
                    },
                  ),

                if (_selectedRole == 'employee')
                  const SizedBox(height: AppSpacing.md),

                // Overtime Eligible Toggle - Only show for employees
                if (_selectedRole == 'employee')
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border(isDark),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          color: AppColors.textSecondary(isDark),
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overtime Eligible',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                              Text(
                                'Can this employee work overtime?',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _overtimeEligible,
                          onChanged: (value) {
                            setState(() {
                              _overtimeEligible = value;
                            });
                          },
                          activeColor: AppColors.primary(isDark),
                        ),
                      ],
                    ),
                  ),

                if (_selectedRole == 'employee')
                  const SizedBox(height: AppSpacing.md),

                // Monthly Salary
                TextFormField(
                  controller: _salaryController,
                  decoration: InputDecoration(
                    labelText: 'Monthly Salary *',
                    hintText: '50000',
                    prefixIcon: Icon(
                      Icons.attach_money_outlined,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Salary is required';
                    }
                    final salary = double.tryParse(value.trim());
                    if (salary == null || salary <= 0) {
                      return 'Enter a valid salary';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Trigger rebuild to update calculated rates
                    setState(() {});
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Joining Date
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Joining Date *',
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(_joiningDate),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(isDark),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              widget.employee == null ? 'Create' : 'Save',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
}
