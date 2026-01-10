/// Shift Service - API calls for shift management

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/shift.dart';
import '../core/config/api_config.dart';

class ShiftService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ShiftService({Dio? dio}) : _dio = dio ?? Dio() {
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

  /// Get all shifts
  Future<List<Shift>> getAllShifts() async {
    try {
      final response = await _dio.get('/shifts');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Shift.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load shifts');
    }
  }

  /// Get shifts by department
  Future<List<Shift>> getShiftsByDepartment(String departmentId) async {
    try {
      final response = await _dio.get(
        '/shifts',
        queryParameters: {'departmentId': departmentId},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Shift.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load shifts');
    }
  }

  /// Get shift by ID
  Future<Shift> getShiftById(String shiftId) async {
    try {
      final response = await _dio.get('/shifts/$shiftId');
      return Shift.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load shift');
    }
  }

  /// Create new shift
  Future<Shift> createShift(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/shifts', data: data);
      return Shift.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create shift');
    }
  }

  /// Update shift
  Future<Shift> updateShift(String shiftId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/shifts/$shiftId', data: data);
      return Shift.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update shift');
    }
  }

  /// Delete shift
  Future<void> deleteShift(String shiftId) async {
    try {
      await _dio.delete('/shifts/$shiftId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete shift');
    }
  }
}
