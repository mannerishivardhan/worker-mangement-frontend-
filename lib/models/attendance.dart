/// Attendance Model
///
/// Represents an attendance record with entry/exit times and status.

class Attendance {
  final String id;
  final String attendanceId;
  final String userId;
  final String employeeId;
  final String employeeName;
  final String departmentId;
  final String departmentName;
  final String? shiftId;
  final String? shiftName;
  final String date; // YYYY-MM-DD format
  final DateTime? entryTime;
  final DateTime? exitTime;
  final int? workDurationMinutes;
  final String status; // pending, present, absent
  final bool isCorrected;
  final String? correctedBy;
  final String? correctionReason;
  final String markedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.attendanceId,
    required this.userId,
    required this.employeeId,
    required this.employeeName,
    required this.departmentId,
    required this.departmentName,
    this.shiftId,
    this.shiftName,
    required this.date,
    this.entryTime,
    this.exitTime,
    this.workDurationMinutes,
    required this.status,
    required this.isCorrected,
    this.correctedBy,
    this.correctionReason,
    required this.markedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      attendanceId: json['attendanceId'] as String,
      userId: json['userId'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      departmentId: json['departmentId'] as String,
      departmentName: json['departmentName'] as String,
      shiftId: json['shiftId'] as String?,
      shiftName: json['shiftName'] as String?,
      date: json['date'] as String,
      entryTime: json['entryTime'] != null
          ? _parseTimestamp(json['entryTime'])
          : null,
      exitTime: json['exitTime'] != null
          ? _parseTimestamp(json['exitTime'])
          : null,
      workDurationMinutes: json['workDurationMinutes'] as int?,
      status: json['status'] as String,
      isCorrected: json['isCorrected'] as bool? ?? false,
      correctedBy: json['correctedBy'] as String?,
      correctionReason: json['correctionReason'] as String?,
      markedBy: json['markedBy'] as String,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  /// Parse timestamp from various formats (ISO string or Firebase Timestamp)
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    // If it's already a DateTime, return it
    if (timestamp is DateTime) return timestamp;

    // If it's a String (ISO 8601), parse it
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    }

    // If it's a Map (Firebase Timestamp format: {_seconds: xxx, _nanoseconds: xxx})
    if (timestamp is Map) {
      final seconds = timestamp['_seconds'] ?? timestamp['seconds'];
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }

    return DateTime.now();
  }

  String get workDurationFormatted {
    if (workDurationMinutes == null) return '--';
    final hours = workDurationMinutes! ~/ 60;
    final minutes = workDurationMinutes! % 60;
    return '${hours}h ${minutes}m';
  }

  bool get isPending => status == 'pending';
  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
}
