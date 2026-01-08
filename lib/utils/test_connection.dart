/// Connection Test Utility
///
/// Test the connection to Railway backend before running the app.
/// Run this file: dart run lib/utils/test_connection.dart

import 'package:dio/dio.dart';
import '../core/config/api_config.dart';

void main() async {
  print('🔍 Testing connection to Railway backend...');
  print('URL: ${ApiConfig.baseUrl}');
  print('');

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ),
  );

  // Test 1: Basic connectivity
  print('Test 1: Basic Connectivity');
  try {
    final response = await dio.get('/health');
    print('✅ Health check passed');
    print('   Response: ${response.statusCode} ${response.statusMessage}');
    print('   Data: ${response.data}');
  } catch (e) {
    print('❌ Health check failed: $e');
  }

  print('');

  // Test 2: Auth endpoint (should fail without credentials, but shows endpoint is reachable)
  print('Test 2: Auth Endpoint Accessibility');
  try {
    final response = await dio.post('/auth/login', data: {
      'email': 'test@example.com',
      'password': 'test123'
    });
    print('✅ Auth endpoint is accessible');
    print('   Response: ${response.statusCode}');
  } catch (e) {
    if (e is DioException) {
      if (e.response != null) {
        print('✅ Auth endpoint is accessible (authentication failed as expected)');
        print('   Status: ${e.response?.statusCode}');
        print('   Message: ${e.response?.data}');
      } else {
        print('❌ Cannot reach auth endpoint: ${e.message}');
      }
    }
  }

  print('');
  print('📊 Connection test complete!');
}
