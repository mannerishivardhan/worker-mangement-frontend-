/// Employee Model
///
/// Represents an employee/user in the system.
/// Handles both snake_case (backend) and camelCase (frontend) field names.

class Employee {
  final String id;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String? jobRole; // NEW: Job classification
  final String? departmentId;
  final String? departmentName;
  final String? shiftId;
  final String? shiftName;
  final double monthlySalary;
  final double? hourlyRate; // NEW: Calculated hourly rate
  final bool? overtimeEligible; // NEW: Can work overtime
  final double? overtimeMultiplier; // NEW: Overtime rate multiplier
  final double? overtimeRate; // NEW: Calculated overtime hourly rate
  final DateTime joiningDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? createdByRole;
  final String? updatedBy;
  final String? updatedByRole;

  Employee({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.jobRole,
    this.departmentId,
    this.departmentName,
    this.shiftId,
    this.shiftName,
    this.monthlySalary = 0.0,
    this.hourlyRate,
    this.overtimeEligible,
    this.overtimeMultiplier,
    this.overtimeRate,
    required this.joiningDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.createdByRole,
    this.updatedBy,
    this.updatedByRole,
  });

  String get fullName => '$firstName $lastName';

  bool get isSuperAdmin => role == 'super_admin';
  bool get isDeptHead => role == 'dept_head';
  bool get isEmployee => role == 'employee';

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? json['_id'] ?? '',
      employeeId: json['employee_id'] ?? json['employeeId'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone:
          (json['phone'] as String?) ??
          '', // Handle existing employees without phone
      role: json['role'] ?? 'employee',
      jobRole: json['job_role'] ?? json['jobRole'],
      departmentId: json['department_id'] ?? json['departmentId'],
      departmentName: json['department_name'] ?? json['departmentName'],
      shiftId: json['shift_id'] ?? json['shiftId'],
      shiftName: json['shift_name'] ?? json['shiftName'],
      monthlySalary: (json['monthly_salary'] ?? json['monthlySalary'] ?? 0)
          .toDouble(),
      hourlyRate: (json['hourly_rate'] ?? json['hourlyRate'])?.toDouble(),
      overtimeEligible: json['overtime_eligible'] ?? json['overtimeEligible'],
      overtimeMultiplier:
          (json['overtime_multiplier'] ?? json['overtimeMultiplier'])
              ?.toDouble(),
      overtimeRate: (json['overtime_rate'] ?? json['overtimeRate'])?.toDouble(),
      joiningDate: _parseDate(json['joining_date'] ?? json['joiningDate']),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      createdBy: json['created_by'] ?? json['createdBy'],
      createdByRole: json['created_by_role'] ?? json['createdByRole'],
      updatedBy: json['updated_by'] ?? json['updatedBy'],
      updatedByRole: json['updated_by_role'] ?? json['updatedByRole'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'jobRole': jobRole,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'shiftId': shiftId,
      'shiftName': shiftName,
      'monthlySalary': monthlySalary,
      'hourlyRate': hourlyRate,
      'overtimeEligible': overtimeEligible,
      'overtimeMultiplier': overtimeMultiplier,
      'overtimeRate': overtimeRate,
      'joiningDate': joiningDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'createdByRole': createdByRole,
      'updatedBy': updatedBy,
      'updatedByRole': updatedByRole,
    };
  }

  /// Parse date from various formats (ISO string or Firebase Timestamp)
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();

    if (date is DateTime) return date;

    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime.now();
      }
    }

    // Handle Firebase Timestamp format: {_seconds: xxx, _nanoseconds: xxx}
    if (date is Map) {
      final seconds = date['_seconds'] ?? date['seconds'];
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }

    return DateTime.now();
  }
}
