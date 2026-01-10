/// Department History Model
///
/// Represents a historical change to a department.
/// Tracks all modifications for audit and compliance purposes.

class DepartmentHistory {
  final String id;
  final String historyId;
  final String departmentId;
  final String departmentName;
  final String actionType;
  final String actionDescription;
  final List<String> changedFields;
  final Map<String, dynamic>? previousData;
  final Map<String, dynamic>? newData;
  final String performedBy;
  final String performedByName;
  final String performedByRole;
  final String? performedByEmployeeId;
  final DateTime timestamp;
  final String? reason;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? ipAddress;
  final String? userAgent;

  DepartmentHistory({
    required this.id,
    required this.historyId,
    required this.departmentId,
    required this.departmentName,
    required this.actionType,
    required this.actionDescription,
    required this.changedFields,
    this.previousData,
    this.newData,
    required this.performedBy,
    required this.performedByName,
    required this.performedByRole,
    this.performedByEmployeeId,
    required this.timestamp,
    this.reason,
    this.relatedEntityType,
    this.relatedEntityId,
    this.ipAddress,
    this.userAgent,
  });

  /// Create DepartmentHistory from JSON (backend response)
  factory DepartmentHistory.fromJson(Map<String, dynamic> json) {
    return DepartmentHistory(
      id: json['id'] ?? '',
      historyId: json['historyId'] ?? '',
      departmentId: json['departmentId'] ?? '',
      departmentName: json['departmentName'] ?? '',
      actionType: json['actionType'] ?? '',
      actionDescription: json['actionDescription'] ?? '',
      changedFields: List<String>.from(json['changedFields'] ?? []),
      previousData: json['previousData'] as Map<String, dynamic>?,
      newData: json['newData'] as Map<String, dynamic>?,
      performedBy: json['performedBy'] ?? '',
      performedByName: json['performedByName'] ?? '',
      performedByRole: json['performedByRole'] ?? '',
      performedByEmployeeId: json['performedByEmployeeId'],
      timestamp: _parseDate(json['timestamp']),
      reason: json['reason'],
      relatedEntityType: json['relatedEntityType'],
      relatedEntityId: json['relatedEntityId'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'historyId': historyId,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'actionType': actionType,
      'actionDescription': actionDescription,
      'changedFields': changedFields,
      'previousData': previousData,
      'newData': newData,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'performedByRole': performedByRole,
      'performedByEmployeeId': performedByEmployeeId,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
      'relatedEntityType': relatedEntityType,
      'relatedEntityId': relatedEntityId,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
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

  /// Get display-friendly action type
  String get actionTypeDisplay {
    switch (actionType) {
      case 'created':
        return 'Created';
      case 'updated':
        return 'Updated';
      case 'deleted':
        return 'Deleted';
      case 'activated':
        return 'Activated';
      case 'deactivated':
        return 'Deactivated';
      case 'head_assigned':
        return 'Head Assigned';
      case 'head_changed':
        return 'Head Changed';
      case 'head_removed':
        return 'Head Removed';
      case 'role_added':
        return 'Role Added';
      case 'role_updated':
        return 'Role Updated';
      case 'role_removed':
        return 'Role Removed';
      case 'shifts_configuration_changed':
        return 'Shifts Changed';
      default:
        return actionType;
    }
  }

  /// Get relative time display (e.g., "2 hours ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  @override
  String toString() {
    return 'DepartmentHistory(id: $id, historyId: $historyId, actionType: $actionType, timestamp: $timestamp)';
  }
}
