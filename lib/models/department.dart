/// Department Model
///
/// Represents a department in the organization.
/// Used for organizing employees and managing department-specific data.

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
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

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
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
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
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      createdBy: json['created_by'] ?? json['createdBy'],
      updatedBy: json['updated_by'] ?? json['updatedBy'],
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
    String? updatedBy,
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
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  String toString() {
    return 'Department(id: $id, departmentId: $departmentId, name: $name, code: $code, employeeCount: $employeeCount)';
  }
}
