/// Department Model
///
/// Represents a department in the organization.
/// Used for organizing employees and managing department-specific data.

/// Department Role with shifts
class DepartmentRole {
  final String name;
  final List<RoleShift> shifts;

  DepartmentRole({
    required this.name,
    required this.shifts,
  });

  factory DepartmentRole.fromJson(Map<String, dynamic> json) {
    return DepartmentRole(
      name: json['name'] ?? '',
      shifts: (json['shifts'] as List<dynamic>?)
              ?.map((s) => RoleShift.fromJson(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shifts': shifts.map((s) => s.toJson()).toList(),
    };
  }
}

/// Shift within a role
class RoleShift {
  final String name;
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format

  RoleShift({
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  /// Get display format for time range (e.g., "06:00 - 14:00")
  String get timeDisplay => '$startTime - $endTime';

  factory RoleShift.fromJson(Map<String, dynamic> json) {
    return RoleShift(
      name: json['name'] ?? '',
      startTime: json['startTime'] ?? json['start_time'] ?? '',
      endTime: json['endTime'] ?? json['end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class Department {
  final String id;
  final String?
      departmentId; // Auto-generated ID like DEPT_XXXX (optional for old departments)
  final String name;
  final String? code;
  final String? description;
  final String? headId;
  final String? headName;
  final int employeeCount;
  final bool isActive;
  final bool hasShifts;
  final List<DepartmentRole> roles; // NEW: Department roles with shifts
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? createdByRole;
  final String? updatedBy;
  final String? updatedByRole;

  Department({
    required this.id,
    this.departmentId,
    required this.name,
    this.code,
    this.description,
    this.headId,
    this.headName,
    this.employeeCount = 0,
    this.isActive = true,
    this.hasShifts = false,
    this.roles = const [], // NEW
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.createdByRole,
    this.updatedBy,
    this.updatedByRole,
  });

  /// Create Department from JSON (backend response)
  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? json['_id'] ?? '',
      departmentId: json['departmentId'] ?? json['department_id'],
      name: json['name'] ?? '',
      code: json['code'],
      description: json['description'],
      headId: json['head_id'] ?? json['headId'],
      headName: json['head_name'] ?? json['headName'],
      employeeCount: json['employee_count'] ?? json['employeeCount'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      hasShifts: json['has_shifts'] ?? json['hasShifts'] ?? false,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((r) => DepartmentRole.fromJson(r))
              .toList() ??
          [], // NEW
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      createdBy: json['created_by'] ?? json['createdBy'],
      createdByRole: json['created_by_role'] ?? json['createdByRole'],
      updatedBy: json['updated_by'] ?? json['updatedBy'],
      updatedByRole: json['updated_by_role'] ?? json['updatedByRole'],
    );
  }

  /// Convert Department to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (headId != null) 'headId': headId,
      'isActive': isActive,
      'hasShifts': hasShifts,
      'roles': roles.map((r) => r.toJson()).toList(), // NEW
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

  /// Create a copy with updated fields
  Department copyWith({
    String? id,
    String? departmentId,
    String? name,
    String? code,
    String? description,
    String? headId,
    String? headName,
    int? employeeCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? createdByRole,
    String? updatedBy,
    String? updatedByRole,
  }) {
    return Department(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      headId: headId ?? this.headId,
      headName: headName ?? this.headName,
      employeeCount: employeeCount ?? this.employeeCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      createdByRole: createdByRole ?? this.createdByRole,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByRole: updatedByRole ?? this.updatedByRole,
    );
  }

  @override
  String toString() {
    return 'Department(id: $id, departmentId: $departmentId, name: $name, code: $code, employeeCount: $employeeCount)';
  }
}
