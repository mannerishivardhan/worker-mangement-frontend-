/// Salary Service - Backend API Integration
///
/// Handles all salary-related API calls based on attendance.
/// Salary is calculated on-demand from attendance records.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/salary.dart';
import '../core/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SalaryService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SalaryService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.headers,
      ),
    );

    // Add interceptors for logging
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Calculate salary for specific employee (Admin/Super Admin)
  Future<SalaryCalculation> calculateEmployeeSalary(
    String userId,
    int year,
    int month,
  ) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/salary/calculate/$userId',
        queryParameters: {'year': year, 'month': month},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SalaryCalculation.fromJson(response.data['data']);
      }

      throw Exception('Failed to calculate salary');
    } on DioException catch (e) {
      debugPrint('Error calculating employee salary: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to calculate salary',
      );
    }
  }

  /// Get my salary (All users can view their own)
  Future<SalaryCalculation> getMySalary(int year, int month) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/salary/my',
        queryParameters: {'year': year, 'month': month},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SalaryCalculation.fromJson(response.data['data']);
      }

      throw Exception('Failed to get salary');
    } on DioException catch (e) {
      debugPrint('Error getting my salary: ${e.message}');
      throw Exception(e.response?.data['message'] ?? 'Failed to get salary');
    }
  }

  /// Get department salary report (Admin/Super Admin)
  Future<DepartmentSalaryReport> getDepartmentReport(
    String departmentId,
    int year,
    int month,
  ) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/salary/reports/department/$departmentId',
        queryParameters: {'year': year, 'month': month},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return DepartmentSalaryReport.fromJson(response.data['data']);
      }

      throw Exception('Failed to get department report');
    } on DioException catch (e) {
      debugPrint('Error getting department report: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get department report',
      );
    }
  }

  /// Get system-wide salary report (Super Admin only)
  Future<SystemSalaryReport> getSystemReport(int year, int month) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/salary/reports/system',
        queryParameters: {'year': year, 'month': month},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SystemSalaryReport.fromJson(response.data['data']);
      }

      throw Exception('Failed to get system report');
    } on DioException catch (e) {
      debugPrint('Error getting system report: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get system report',
      );
    }
  }
}
