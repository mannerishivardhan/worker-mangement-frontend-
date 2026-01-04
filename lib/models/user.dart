/// User Model - User Data Structure
///
/// Represents a user in the system with role-based access.
/// Used throughout the app for authentication and authorization.
///
/// Roles:
/// - super_admin: Full system access
/// - dept_head: Department management access
/// - employee: Personal data access only
///
/// Usage:
/// ```dart
/// final user = User.fromJson(jsonData);
/// print(user.fullName); // "John Doe"
/// print(user.role); // "super_admin"
/// ```

class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? phone;
  final String? employeeId;
  final String? departmentId;
  final String? departmentName;
  final String? profilePhoto;
  final DateTime? joiningDate;
  final double? dailySalary;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.employeeId,
    this.departmentId,
    this.departmentName,
    this.profilePhoto,
    this.joiningDate,
    this.dailySalary,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create User from JSON (from API response)
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle fullName - backend returns firstName + lastName
    String fullName;
    if (json['fullName'] != null || json['full_name'] != null) {
      fullName = json['fullName'] ?? json['full_name'];
    } else if (json['firstName'] != null && json['lastName'] != null) {
      fullName = '${json['firstName']} ${json['lastName']}';
    } else {
      fullName = json['firstName'] ?? json['first_name'] ?? 'Unknown';
    }

    // Handle dates - backend returns Firebase Timestamp objects
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      if (value is Map && value['_seconds'] != null) {
        // Firebase Timestamp format
        return DateTime.fromMillisecondsSinceEpoch(
          (value['_seconds'] as int) * 1000,
        );
      }
      return null;
    }

    return User(
      id: json['id'] ?? json['_id'],
      email: json['email'],
      fullName: fullName,
      role: json['role'],
      phone: json['phone'],
      employeeId: json['employee_id'] ?? json['employeeId'],
      departmentId: json['department_id'] ?? json['departmentId'],
      departmentName: json['department_name'] ?? json['departmentName'],
      profilePhoto: json['profile_photo'] ?? json['profilePhoto'],
      joiningDate: parseDate(json['joining_date'] ?? json['joiningDate']),
      dailySalary:
          (json['daily_salary'] ?? json['dailySalary'] ?? json['monthlySalary'])
              ?.toDouble(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt:
          parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  /// Convert User to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'employee_id': employeeId,
      'department_id': departmentId,
      'department_name': departmentName,
      'profile_photo': profilePhoto,
      'joining_date': joiningDate?.toIso8601String(),
      'daily_salary': dailySalary,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Check if user is Super Admin
  bool get isSuperAdmin =>
      role.toLowerCase() == 'super_admin' || role.toLowerCase() == 'superadmin';

  /// Check if user is Department Head
  bool get isDeptHead =>
      role.toLowerCase() == 'dept_head' ||
      role.toLowerCase() == 'depthead' ||
      role.toLowerCase() == 'department_head';

  /// Check if user is Employee
  bool get isEmployee => role.toLowerCase() == 'employee';

  /// Get display name (first name only)
  String get firstName => fullName.split(' ').first;

  /// Get initials for avatar
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }

  /// Copy with method for updating user data
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    String? employeeId,
    String? departmentId,
    String? departmentName,
    String? profilePhoto,
    DateTime? joiningDate,
    double? dailySalary,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      employeeId: employeeId ?? this.employeeId,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      joiningDate: joiningDate ?? this.joiningDate,
      dailySalary: dailySalary ?? this.dailySalary,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
