/// Department Service
///
/// Handles all department-related API calls.
/// Communicates with backend /api/departments endpoints.

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/department.dart';
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

  /// Deactivate department (soft delete)
  Future<void> deactivateDepartment(String id) async {
    try {
      final response = await _dio.post('/departments/$id/deactivate');

      if (response.data['success'] != true) {
        throw Exception('Failed to deactivate department');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    if (error.response != null) {
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
