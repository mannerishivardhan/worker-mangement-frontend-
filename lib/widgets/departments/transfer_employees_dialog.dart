import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../models/department.dart';
import '../../services/employee_service.dart';
import '../../services/department_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class TransferEmployeesDialog extends StatefulWidget {
  final Department department;
  final List<Employee> employees;

  const TransferEmployeesDialog({
    Key? key,
    required this.department,
    required this.employees,
  }) : super(key: key);

  @override
  State<TransferEmployeesDialog> createState() =>
      _TransferEmployeesDialogState();
}

class _TransferEmployeesDialogState extends State<TransferEmployeesDialog> {
  final _employeeService = EmployeeService();
  final _departmentService = DepartmentService();

  List<Department> _activeDepartments = [];
  Department? _selectedTargetDepartment;
  Set<String> _selectedEmployeeIds = {};
  bool _isLoading = false;
  bool _isTransferring = false;

  @override
  void initState() {
    super.initState();
    _loadActiveDepartments();
  }

  Future<void> _loadActiveDepartments() async {
    setState(() => _isLoading = true);
    try {
      final departments = await _departmentService.getDepartments();
      setState(() {
        _activeDepartments = departments
            .where(
              (d) =>
                  d.status.toLowerCase() == 'active' &&
                  d.id != widget.department.id,
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load departments: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _transferEmployees() async {
    if (_selectedTargetDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a target department'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedEmployeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one employee to transfer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isTransferring = true);

    try {
      // Transfer each selected employee
      for (final employeeId in _selectedEmployeeIds) {
        await _employeeService.updateEmployee(employeeId, {
          'departmentId': _selectedTargetDepartment!.id,
        });
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      setState(() => _isTransferring = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedEmployeeIds.length == widget.employees.length) {
        _selectedEmployeeIds.clear();
      } else {
        _selectedEmployeeIds = widget.employees.map((e) => e.id).toSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz, color: AppColors.primary(isDark)),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: Text('Transfer Employees')),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Department "${widget.department.name}" has ${widget.employees.length} employee(s)',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Target department selector
                  Text(
                    'Select Target Department:',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border(isDark)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<Department>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text('Choose department...'),
                      value: _selectedTargetDepartment,
                      items: _activeDepartments.map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          child: Text(dept.name),
                        );
                      }).toList(),
                      onChanged: (dept) {
                        setState(() => _selectedTargetDepartment = dept);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Employee selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Employees:',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _toggleSelectAll,
                        icon: Icon(
                          _selectedEmployeeIds.length == widget.employees.length
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        label: const Text('Select All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Employee list
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border(isDark)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.employees.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: AppColors.border(isDark)),
                        itemBuilder: (context, index) {
                          final employee = widget.employees[index];
                          final isSelected = _selectedEmployeeIds.contains(
                            employee.id,
                          );

                          return CheckboxListTile(
                            dense: true,
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedEmployeeIds.add(employee.id);
                                } else {
                                  _selectedEmployeeIds.remove(employee.id);
                                }
                              });
                            },
                            title: Text(
                              employee.fullName,
                              style: AppTypography.bodyMedium,
                            ),
                            subtitle: Text(
                              'ID: ${employee.employeeId}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: _isTransferring
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isTransferring ? null : _transferEmployees,
          icon: _isTransferring
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.swap_horiz),
          label: Text(
            _isTransferring
                ? 'Transferring...'
                : 'Transfer (${_selectedEmployeeIds.length})',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(isDark),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
