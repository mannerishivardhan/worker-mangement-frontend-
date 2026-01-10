/// Comprehensive Department Dialog - Create/Edit with Roles & Shifts
///
/// Advanced department configuration with:
/// - Department name and description
/// - Has shifts toggle
/// - Dynamic role builder with shift configuration per role

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/department.dart';
import '../../services/department_service.dart';

class ComprehensiveDepartmentDialog extends StatefulWidget {
  final Department? department;

  const ComprehensiveDepartmentDialog({super.key, this.department});

  @override
  State<ComprehensiveDepartmentDialog> createState() =>
      _ComprehensiveDepartmentDialogState();
}

class _ComprehensiveDepartmentDialogState
    extends State<ComprehensiveDepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DepartmentService _departmentService = DepartmentService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasShifts = false;
  List<RoleBuilder> _roles = [];

  @override
  void initState() {
    super.initState();
    if (widget.department != null) {
      _nameController.text = widget.department!.name;
      _descriptionController.text = widget.department!.description ?? '';
      _hasShifts = widget.department!.hasShifts;

      // Load existing roles
      _roles = widget.department!.roles
          .map(
            (role) => RoleBuilder(
              name: role.name,
              shifts: role.shifts
                  .map(
                    (shift) => ShiftBuilder(
                      name: shift.name,
                      startTime: _parseTime(shift.startTime),
                      endTime: _parseTime(shift.endTime),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addRole() {
    setState(() {
      _roles.add(RoleBuilder(name: '', shifts: []));
    });
  }

  void _removeRole(int index) {
    setState(() {
      _roles.removeAt(index);
    });
  }

  void _addShift(int roleIndex) {
    setState(() {
      _roles[roleIndex].shifts.add(
        ShiftBuilder(
          name: '',
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 17, minute: 0),
        ),
      );
    });
  }

  void _removeShift(int roleIndex, int shiftIndex) {
    setState(() {
      _roles[roleIndex].shifts.removeAt(shiftIndex);
    });
  }

  Future<void> _selectTime(
    int roleIndex,
    int shiftIndex,
    bool isStartTime,
  ) async {
    final shift = _roles[roleIndex].shifts[shiftIndex];
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? shift.startTime : shift.endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _roles[roleIndex].shifts[shiftIndex].startTime = picked;
        } else {
          _roles[roleIndex].shifts[shiftIndex].endTime = picked;
        }
        // Force rebuild by creating a new list reference
        _roles = List.from(_roles);
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate roles if shifts are enabled
    if (_hasShifts) {
      if (_roles.isEmpty) {
        setState(() {
          _errorMessage = 'Please add at least one role with shifts';
        });
        return;
      }

      for (var role in _roles) {
        if (role.name.trim().isEmpty) {
          setState(() {
            _errorMessage = 'All roles must have a name';
          });
          return;
        }
        if (role.shifts.isEmpty) {
          setState(() {
            _errorMessage = 'Each role must have at least one shift';
          });
          return;
        }
        for (var shift in role.shifts) {
          if (shift.name.trim().isEmpty) {
            setState(() {
              _errorMessage = 'All shifts must have a name';
            });
            return;
          }
        }
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = {
        'name': _nameController.text.trim(),
        'hasShifts': _hasShifts,
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        'roles': _roles
            .map(
              (role) => {
                'name': role.name.trim(),
                'shifts': role.shifts
                    .map(
                      (shift) => {
                        'name': shift.name.trim(),
                        'startTime': _formatTime(shift.startTime),
                        'endTime': _formatTime(shift.endTime),
                      },
                    )
                    .toList(),
              },
            )
            .toList(),
      };

      if (widget.department == null) {
        await _departmentService.createDepartment(data);
      } else {
        await _departmentService.updateDepartment(widget.department!.id, data);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
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
    final isEditing = widget.department != null;

    return Dialog(
      backgroundColor: AppColors.background(isDark),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Department' : 'Create Department',
                          style: AppTypography.heading2.copyWith(
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Configure roles and shifts for this department',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ],
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

            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Department Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Department Name *',
                          hintText: 'e.g., Canteen, Security',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Department name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Brief description of this department',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Has Shifts Toggle
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border(isDark)),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              color: AppColors.textSecondary(isDark),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Has Shifts',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textPrimary(isDark),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Enable role-based shift management',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _hasShifts,
                              onChanged: (value) {
                                setState(() {
                                  _hasShifts = value;
                                  if (!value) {
                                    _roles.clear();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // Roles Section
                      if (_hasShifts) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Department Roles & Shifts',
                                style: AppTypography.heading3.copyWith(
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            ElevatedButton.icon(
                              onPressed: _addRole,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Role'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary(isDark),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Role List
                        if (_roles.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: AppColors.surface(isDark),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              border: Border.all(
                                color: AppColors.border(isDark),
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.work_outline,
                                    size: 48,
                                    color: AppColors.textTertiary(isDark),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'No roles added yet',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Click "Add Role" to create your first role',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textTertiary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._roles.asMap().entries.map((entry) {
                            final roleIndex = entry.key;
                            final role = entry.value;
                            return _buildRoleCard(roleIndex, role, isDark);
                          }),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppSpacing.radiusLg),
                  bottomRight: Radius.circular(AppSpacing.radiusLg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(isDark),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isEditing ? 'Save Changes' : 'Create Department',
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(int roleIndex, RoleBuilder role, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        children: [
          // Role Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary(isDark).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusMd),
                topRight: Radius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_ind_outlined,
                  color: AppColors.primary(isDark),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    initialValue: role.name,
                    decoration: InputDecoration(
                      hintText: 'Role name (e.g., Mori Workers)',
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary(isDark),
                      ),
                    ),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (value) {
                      role.name = value;
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _removeRole(roleIndex),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  tooltip: 'Remove role',
                ),
              ],
            ),
          ),

          // Shifts
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Shifts',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _addShift(roleIndex),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Shift'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (role.shifts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background(isDark),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: AppColors.border(isDark),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'No shifts added for this role',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary(isDark),
                        ),
                      ),
                    ),
                  )
                else
                  ...role.shifts.asMap().entries.map((entry) {
                    final shiftIndex = entry.key;
                    final shift = entry.value;
                    return _buildShiftRow(roleIndex, shiftIndex, shift, isDark);
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftRow(
    int roleIndex,
    int shiftIndex,
    ShiftBuilder shift,
    bool isDark,
  ) {
    return Container(
      key: ValueKey(
        'shift_${roleIndex}_${shiftIndex}_${shift.startTime.hour}_${shift.startTime.minute}_${shift.endTime.hour}_${shift.endTime.minute}',
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        children: [
          // Shift Name
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: shift.name,
              decoration: InputDecoration(
                hintText: 'Shift name',
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary(isDark),
                ),
              ),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
              onChanged: (value) {
                shift.name = value;
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Start Time
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(roleIndex, shiftIndex, true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border(isDark)),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary(isDark),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _formatTime(shift.startTime),
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
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'to',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary(isDark),
              ),
            ),
          ),

          // End Time
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(roleIndex, shiftIndex, false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border(isDark)),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary(isDark),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _formatTime(shift.endTime),
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
          ),

          // Remove button
          IconButton(
            onPressed: () => _removeShift(roleIndex, shiftIndex),
            icon: const Icon(Icons.close, size: 16),
            color: Colors.red,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Remove shift',
          ),
        ],
      ),
    );
  }
}

// Helper classes for building roles and shifts
class RoleBuilder {
  String name;
  List<ShiftBuilder> shifts;

  RoleBuilder({required this.name, required this.shifts});
}

class ShiftBuilder {
  String name;
  TimeOfDay startTime;
  TimeOfDay endTime;

  ShiftBuilder({
    required this.name,
    required this.startTime,
    required this.endTime,
  });
}
