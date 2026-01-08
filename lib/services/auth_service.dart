/// Auth Service - Backend API Integration
///
/// Handles all authentication-related API calls to the backend.
/// Manages JWT tokens, login, logout, and token validation.
///
/// Backend Endpoints:
/// - POST /api/auth/login - Email/password login
/// - POST /api/auth/logout - Logout (optional)
/// - GET /api/auth/verify - Validate token and get user
/// - POST /api/auth/refresh - Refresh JWT token
///
/// Features:
/// - Dio HTTP client with interceptors
/// - JWT token management
/// - Error handling with user-friendly messages
/// - Request/response logging (debug mode)
///
/// Usage:
/// ```dart
/// final authService = AuthService();
/// final response = await authService.login(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// ```

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../core/config/api_config.dart';

class AuthService {
  late final Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.headers,
      ),
    );

    // Add interceptors for logging (debug mode only)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }

  /// Login with email and password
  ///
  /// Returns: Map with 'token' and 'user' keys
  /// Throws: DioException on network/server errors
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting login for: $email');
      debugPrint('📡 Backend URL: ${ApiConfig.baseUrl}/auth/login');

      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📦 Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        // Backend returns: { success: true, message: '...', data: { accessToken, refreshToken, user } }
        final responseData = response.data;

        // Check if response has success field
        if (responseData['success'] != true) {
          debugPrint('❌ Login failed: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Login failed');
        }

        // Get the actual data (nested inside 'data' field)
        final data = responseData['data'];

        if (data == null) {
          debugPrint('❌ No data in response!');
          throw Exception('Login failed: No data received');
        }

        // Check for token (could be 'token', 'accessToken', or 'access_token')
        final token =
            data['token'] ?? data['accessToken'] ?? data['access_token'];
        if (token == null) {
          debugPrint('❌ No token in response data!');
          debugPrint('📦 Available keys: ${data.keys}');
          throw Exception('Login failed: No token received');
        }

        if (data['user'] == null) {
          debugPrint('❌ No user data in response!');
          throw Exception('Login failed: No user data received');
        }

        debugPrint('✅ Login successful! Token received.');
        return {'token': token, 'user': data['user']};
      } else {
        debugPrint('❌ Invalid response status or data');
        throw Exception('Login failed: Invalid response');
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type}');
      debugPrint('❌ Error Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// Logout user (optional backend call)
  ///
  /// Some backends track active sessions and need logout notification
  Future<void> logout(String token) async {
    try {
      await _dio.post(
        '/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      // Logout errors are non-critical, just log them
      debugPrint('Logout error: ${e.message}');
    }
  }

  /// Validate token and get current user
  ///
  /// Returns: User object if token is valid, null otherwise
  Future<User?> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '/auth/verify',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Backend returns: { success: true, data: { user fields } }
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          return User.fromJson(responseData['data']);
        }
      }

      return null;
    } on DioException catch (e) {
      debugPrint('Token validation error: ${e.message}');
      return null;
    }
  }

  /// Refresh JWT token
  ///
  /// Returns: New token string if successful, null otherwise
  Future<String?> refreshToken(String oldToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $oldToken'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['token'];
      }

      return null;
    } on DioException catch (e) {
      debugPrint('Token refresh error: ${e.message}');
      return null;
    }
  }

  /// Handle Dio errors and convert to user-friendly messages
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'];

        if (statusCode == 401) {
          return message ?? 'Invalid email or password';
        } else if (statusCode == 403) {
          return message ?? 'Access denied';
        } else if (statusCode == 404) {
          return 'Service not found. Please contact support.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }

        return message ?? 'An error occurred. Please try again.';

      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'No internet connection. Please check your network.';
        }
        return 'An unexpected error occurred. Please try again.';

      default:
        return 'An error occurred. Please try again.';
    }
  }
}
