import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/attendance.dart';
import '../../models/employee.dart';
import '../../services/attendance_service.dart';

/// Dialog to correct attendance for past 7 days
class CorrectAttendanceDialog extends StatefulWidget {
  final Employee employee;

  const CorrectAttendanceDialog({super.key, required this.employee});

  @override
  State<CorrectAttendanceDialog> createState() =>
      _CorrectAttendanceDialogState();
}

class _CorrectAttendanceDialogState extends State<CorrectAttendanceDialog> {
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

  void _showCorrectionForm(Attendance attendance) {
    setState(() {
      _selectedAttendance = attendance;
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
        width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
        constraints: BoxConstraints(
          maxWidth: 600, // Max 600 on large screens
          maxHeight:
              MediaQuery.of(context).size.height * 0.85, // 85% of screen height
        ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correct Attendance',
                          style: AppTypography.heading2.copyWith(
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.employee.fullName,
                          style: AppTypography.bodyMedium.copyWith(
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
              child: _selectedAttendance == null
                  ? _buildAttendanceList(isDark)
                  : _buildCorrectionForm(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList(bool isDark) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary(isDark)),
      );
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

    if (_past7DaysAttendance.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
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
                'Past 7 days attendance',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary(isDark),
                ),
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
        return _buildAttendanceCard(attendance, isDark);
      },
    );
  }

  Widget _buildAttendanceCard(Attendance attendance, bool isDark) {
    final date = DateTime.parse(attendance.date);
    final dateStr = DateFormat('EEE, MMM dd, yyyy').format(date);

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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary(isDark),
                    ),
                    const SizedBox(width: AppSpacing.xs),
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
                    if (attendance.isCorrected) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.textTertiary(isDark),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Entry: $entryTime',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'Exit: $exitTime',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    attendance.status.toUpperCase(),
                    style: AppTypography.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: () => _showCorrectionForm(attendance),
            icon: Icon(Icons.edit, color: AppColors.primary(isDark), size: 20),
            tooltip: 'Correct',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionForm(bool isDark) {
    return _CorrectionForm(
      attendance: _selectedAttendance!,
      employee: widget.employee,
      onCancel: () {
        setState(() {
          _selectedAttendance = null;
        });
      },
      onSuccess: () {
        Navigator.of(context).pop(true);
      },
    );
  }
}

/// Correction form widget
class _CorrectionForm extends StatefulWidget {
  final Attendance attendance;
  final Employee employee;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const _CorrectionForm({
    required this.attendance,
    required this.employee,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<_CorrectionForm> createState() => _CorrectionFormState();
}

class _CorrectionFormState extends State<_CorrectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final AttendanceService _attendanceService = AttendanceService();

  late DateTime? _entryTime;
  late DateTime? _exitTime;
  late String _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _entryTime = widget.attendance.entryTime;
    _exitTime = widget.attendance.exitTime;
    _status = widget.attendance.status;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isEntry) async {
    final date = DateTime.parse(widget.attendance.date);
    final initialTime = isEntry
        ? (_entryTime ?? DateTime(date.year, date.month, date.day, 9, 0))
        : (_exitTime ?? DateTime(date.year, date.month, date.day, 17, 0));

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );

    if (pickedTime != null) {
      setState(() {
        final newTime = DateTime(
          date.year,
          date.month,
          date.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (isEntry) {
          _entryTime = newTime;
        } else {
          _exitTime = newTime;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _attendanceService.correctAttendance(
        attendanceId: widget.attendance.id,
        entryTime: _entryTime,
        exitTime: _exitTime,
        status: _status,
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance corrected successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
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
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.parse(widget.attendance.date);
    final dateStr = DateFormat('EEEE, MMM dd, yyyy').format(date);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Date info
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.primary(isDark).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary(isDark),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Correcting attendance for $dateStr',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Entry Time
          Text(
            'Entry Time *',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => _selectDateTime(context, true),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.textSecondary(isDark),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _entryTime != null
                        ? DateFormat('hh:mm a').format(_entryTime!)
                        : 'Not set',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Exit Time
          Text(
            'Exit Time *',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => _selectDateTime(context, false),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.textSecondary(isDark),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _exitTime != null
                        ? DateFormat('hh:mm a').format(_exitTime!)
                        : 'Not set',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Status
          Text(
            'Status *',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(isDark)),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'present', child: Text('Present')),
              DropdownMenuItem(value: 'absent', child: Text('Absent')),
              DropdownMenuItem(value: 'half_day', child: Text('Half Day')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _status = value;
                });
              }
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Reason
          Text(
            'Reason for Correction *',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Explain why you are correcting this attendance...',
              filled: true,
              fillColor: AppColors.surface(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(isDark)),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Reason is required';
              }
              if (value.trim().length < 10) {
                return 'Reason must be at least 10 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Warning
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'This will update the attendance record permanently',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSubmitting ? null : widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(isDark),
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
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
                    : const Text('Save Correction'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
