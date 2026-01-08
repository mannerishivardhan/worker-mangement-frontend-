/// API Configuration
///
/// Centralized configuration for API endpoints.
/// Update the baseUrl to point to your backend server.

class ApiConfig {
  // PRODUCTION - Railway Deployment ✅
  static const String baseUrl =
      'https://worker-management-production.up.railway.app/api';

  // LOCAL TESTING - Uncomment for development
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // For Android emulator
  // static const String baseUrl = 'http://YOUR-MAC-IP:3000/api'; // For real device on WiFi

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Common headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // API Endpoints
  static const String auth = '/auth';
  static const String employees = '/employees';
  static const String departments = '/departments';
  static const String attendance = '/attendance';
}
