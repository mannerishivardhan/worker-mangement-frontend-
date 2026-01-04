/// Attendance Service
///
/// Handles all attendance-related API calls.

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/attendance.dart';

class AttendanceService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String baseUrl = 'http://192.168.55.104:3000/api/attendance';

  AttendanceService() {
    // Add interceptor to attach JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// Get attendance records with optional filters
  Future<List<Attendance>> getAttendance({
    String? userId,
    String? departmentId,
    String? date,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['userId'] = userId;
      if (departmentId != null) queryParams['departmentId'] = departmentId;
      if (date != null) queryParams['date'] = date;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _dio.get(baseUrl, queryParameters: queryParams);

      final List<dynamic> data = response.data['data'] as List;
      return data.map((json) => Attendance.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load attendance: ${e.toString()}');
    }
  }

  /// Mark entry (check-in)
  Future<Attendance> markEntry({
    required String userId,
    required DateTime entryTime,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/entry',
        data: {'userId': userId, 'entryTime': entryTime.toIso8601String()},
      );

      return Attendance.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = e.response!.data['message'] ?? 'Failed to mark entry';
        throw Exception(message);
      }
      throw Exception('Failed to mark entry: ${e.toString()}');
    }
  }

  /// Mark exit (check-out)
  Future<Attendance> markExit({
    required String userId,
    required DateTime exitTime,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/exit',
        data: {'userId': userId, 'exitTime': exitTime.toIso8601String()},
      );

      return Attendance.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = e.response!.data['message'] ?? 'Failed to mark exit';
        throw Exception(message);
      }
      throw Exception('Failed to mark exit: ${e.toString()}');
    }
  }

  /// Correct attendance record
  Future<Attendance> correctAttendance({
    required String attendanceId,
    DateTime? entryTime,
    DateTime? exitTime,
    String? status,
    required String reason,
  }) async {
    try {
      final data = <String, dynamic>{'reason': reason};
      if (entryTime != null) data['entryTime'] = entryTime.toIso8601String();
      if (exitTime != null) data['exitTime'] = exitTime.toIso8601String();
      if (status != null) data['status'] = status;

      final response = await _dio.post(
        '$baseUrl/$attendanceId/correct',
        data: data,
      );

      return Attendance.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message =
            e.response!.data['message'] ?? 'Failed to correct attendance';
        throw Exception(message);
      }
      throw Exception('Failed to correct attendance: ${e.toString()}');
    }
  }

  /// Get today's attendance for all employees
  Future<List<Attendance>> getTodayAttendance() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getAttendance(date: dateStr);
  }

  /// Get past 7 days attendance for a user (for corrections)
  /// Returns attendance from yesterday to 7 days ago
  Future<List<Attendance>> getPast7DaysAttendance(String userId) async {
    try {
      final now = DateTime.now();

      // Yesterday
      final yesterday = now.subtract(const Duration(days: 1));
      final endDate =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      // 7 days ago
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final startDate =
          '${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}';

      return getAttendance(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to load past 7 days attendance: ${e.toString()}');
    }
  }
}
