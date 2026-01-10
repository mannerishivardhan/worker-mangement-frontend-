/// Department Service
///
/// Handles all department-related API calls.
/// Communicates with backend /api/departments endpoints.

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/department.dart';
import '../models/department_history.dart';
import '../core/config/api_config.dart';

class DepartmentService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DepartmentService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;

    // Add interceptor to include token in all requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// Get all departments
  Future<List<Department>> getDepartments({
    bool? isActive,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _dio.get(
        '/departments',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Department.fromJson(json)).toList();
      }

      throw Exception('Failed to load departments');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get single department by ID
  Future<Department> getDepartment(String id) async {
    try {
      final response = await _dio.get('/departments/$id');

      if (response.data['success'] == true) {
        return Department.fromJson(response.data['data']);
      }

      throw Exception('Failed to load department');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new department
  Future<Department> createDepartment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/departments', data: data);

      if (response.data['success'] == true) {
        return Department.fromJson(response.data['data']);
      }

      throw Exception('Failed to create department');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update existing department
  Future<Department> updateDepartment(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/departments/$id', data: data);

      if (response.data['success'] == true) {
        return Department.fromJson(response.data['data']);
      }

      throw Exception('Failed to update department');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete department
  Future<void> deleteDepartment(String id) async {
    try {
      final response = await _dio.delete('/departments/$id');

      if (response.data['success'] != true) {
        throw Exception('Failed to delete department');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Deactivate department (with reason)
  Future<Department> deactivateDepartment(String id, String reason) async {
    try {
      final response = await _dio.put(
        '/departments/$id/deactivate',
        data: {'reason': reason},
      );

      if (response.data['success'] == true) {
        return Department.fromJson(response.data['data']);
      }

      throw Exception('Failed to deactivate department');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Activate department
  Future<Department> activateDepartment(String id) async {
    try {
      final response = await _dio.put('/departments/$id/activate');

      if (response.data['success'] == true) {
        return Department.fromJson(response.data['data']);
      }

      throw Exception('Failed to activate department');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Assign department head
  Future<Department> assignDepartmentHead(
    String departmentId,
    String employeeId,
  ) async {
    try {
      final response = await _dio.put(
        '/departments/$departmentId/head',
        data: {'employeeId': employeeId},
      );

      if (response.data['success'] == true) {
        return Department.fromJson(response.data['data']);
      }

      throw Exception('Failed to assign department head');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove department head
  Future<Department> removeDepartmentHead(
    String departmentId, {
    String? reason,
  }) async {
    try {
      final response = await _dio.delete(
        '/departments/$departmentId/head',
        data: reason != null ? {'reason': reason} : null,
      );

      if (response.data['success'] == true) {
        return Department.fromJson(response.data['data']);
      }

      throw Exception('Failed to remove department head');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get department history
  Future<List<DepartmentHistory>> getDepartmentHistory(
    String departmentId, {
    String? actionType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (actionType != null) queryParams['actionType'] = actionType;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get(
        '/departments/$departmentId/history',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => DepartmentHistory.fromJson(json)).toList();
      }

      throw Exception('Failed to load department history');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    print('DioException occurred: ${error.type}');
    print('Request URL: ${error.requestOptions.uri}');
    print('Error message: ${error.message}');

    if (error.response != null) {
      print('Response status: ${error.response?.statusCode}');
      print('Response data: ${error.response?.data}');
      final message = error.response?.data['message'] ?? 'An error occurred';
      return Exception(message);
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return Exception('Connection timeout');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return Exception('Receive timeout');
    } else {
      return Exception('Network error: ${error.message}');
    }
  }
}
