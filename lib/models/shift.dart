/// Shift Model
///
/// Represents a work shift with timing and job role classification.
/// Includes overtime eligibility and multiplier for salary calculations.

class Shift {
  final String id;
  final String shiftId; // SHFT_XXXX format
  final String name;
  final String?
  jobRole; // Job classification (e.g., "Normal Security Staff", "Nepali Workers")
  final String departmentId;
  final String departmentName;
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final double workDurationHours;
  final bool overtimeAllowed; // Can this shift have overtime?
  final double overtimeMultiplier; // Overtime pay rate multiplier (default 1.5)
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Shift({
    required this.id,
    required this.shiftId,
    required this.name,
    this.jobRole,
    required this.departmentId,
    required this.departmentName,
    required this.startTime,
    required this.endTime,
    required this.workDurationHours,
    this.overtimeAllowed = true,
    this.overtimeMultiplier = 1.5,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create Shift from JSON (backend response)
  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? json['_id'] ?? '',
      shiftId: json['shiftId'] ?? json['shift_id'] ?? '',
      name: json['name'] ?? '',
      jobRole: json['jobRole'] ?? json['job_role'],
      departmentId: json['departmentId'] ?? json['department_id'] ?? '',
      departmentName: json['departmentName'] ?? json['department_name'] ?? '',
      startTime: json['startTime'] ?? json['start_time'] ?? '',
      endTime: json['endTime'] ?? json['end_time'] ?? '',
      workDurationHours:
          (json['workDurationHours'] ?? json['work_duration_hours'] ?? 8)
              .toDouble(),
      overtimeAllowed:
          json['overtimeAllowed'] ?? json['overtime_allowed'] ?? true,
      overtimeMultiplier:
          (json['overtimeMultiplier'] ?? json['overtime_multiplier'] ?? 1.5)
              .toDouble(),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  /// Convert Shift to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'jobRole': jobRole,
      'departmentId': departmentId,
      'startTime': startTime,
      'endTime': endTime,
      'overtimeAllowed': overtimeAllowed,
      'overtimeMultiplier': overtimeMultiplier,
    };
  }

  /// Helper to parse dates (handles both ISO strings and Firebase Timestamps)
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is Map && date.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        date['_seconds'] * 1000 + (date['_nanoseconds'] ~/ 1000000),
      );
    }
    return DateTime.now();
  }

  /// Get formatted shift timing display
  String get timeDisplay => '$startTime - $endTime';

  /// Get shift total hours
  double get totalHours => workDurationHours;

  /// Get shift with job role display
  String get displayName => jobRole != null ? '$name ($jobRole)' : name;

  @override
  String toString() {
    return 'Shift(id: $id, shiftId: $shiftId, name: $name, jobRole: $jobRole, time: $timeDisplay)';
  }
}
