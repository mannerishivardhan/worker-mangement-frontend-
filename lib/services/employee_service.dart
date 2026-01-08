/// Employee Service
///
/// Handles all employee-related API calls.
/// Communicates with backend /api/employees endpoints.

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/employee.dart';
import '../core/config/api_config.dart';

class EmployeeService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  EmployeeService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;

    // Add interceptor to include token in all requests
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

  /// Get all employees with optional filters
  Future<List<Employee>> getEmployees({
    String? departmentId,
    String? role,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (departmentId != null) queryParams['departmentId'] = departmentId;
      if (role != null) queryParams['role'] = role;
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final response = await _dio.get(
        '/employees',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => Employee.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load employees: ${e.toString()}');
    }
  }

  /// Get employee by ID
  Future<Employee> getEmployee(String id) async {
    try {
      final response = await _dio.get('/employees/$id');
      return Employee.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to load employee: ${e.toString()}');
    }
  }

  /// Create new employee
  Future<Employee> createEmployee(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/employees', data: data);
      return Employee.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = e.response?.data['message'] ?? e.message;
        throw Exception(message);
      }
      throw Exception('Failed to create employee: ${e.toString()}');
    }
  }

  /// Update employee
  Future<Employee> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/employees/$id', data: data);
      return Employee.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = e.response?.data['message'] ?? e.message;
        throw Exception(message);
      }
      throw Exception('Failed to update employee: ${e.toString()}');
    }
  }

  /// Delete employee
  Future<void> deleteEmployee(String id) async {
    try {
      await _dio.delete('/employees/$id');
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = e.response?.data['message'] ?? e.message;
        throw Exception(message);
      }
      throw Exception('Failed to delete employee: ${e.toString()}');
    }
  }

  /// Deactivate employee (soft delete)
  Future<void> deactivateEmployee(String id) async {
    try {
      await _dio.post('/employees/$id/deactivate');
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message = e.response?.data['message'] ?? e.message;
        throw Exception(message);
      }
      throw Exception('Failed to deactivate employee: ${e.toString()}');
    }
  }
}
