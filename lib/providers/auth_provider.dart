/// Auth Provider - Authentication State Management
///
/// Manages authentication state across the app using Provider pattern.
/// Handles login, logout, token management, and user state.
///
/// Features:
/// - User authentication state
/// - JWT token storage and retrieval
/// - Auto token refresh
/// - Role-based access control
/// - Persistent login (remember me)
///
/// Usage:
/// ```dart
/// // In main.dart
/// ChangeNotifierProvider(
///   create: (_) => AuthProvider(),
///   child: MyApp(),
/// )
///
/// // In widgets
/// final authProvider = Provider.of<AuthProvider>(context);
/// await authProvider.login(email, password);
/// ```

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Auth state
  User? _currentUser;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _currentUser?.role;

  /// Initialize auth state on app start
  /// Checks for stored token and validates it
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Check for stored token
      final storedToken = await _storage.read(key: 'auth_token');

      if (storedToken != null) {
        _token = storedToken;

        // Validate token with backend
        final user = await _authService.validateToken(storedToken);

        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;
        } else {
          // Token invalid, clear it
          await logout();
        }
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  /// Check auth status without backend validation (for auto-login)
  /// Just checks if token and user data exist in storage
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      // Check for stored token
      final storedToken = await _storage.read(key: 'auth_token');
      final storedUserJson = await _storage.read(key: 'user_data');

      if (storedToken != null && storedUserJson != null) {
        _token = storedToken;

        // Parse stored user data
        try {
          final userMap = Map<String, dynamic>.from(
            // Simple JSON parsing
            _parseJson(storedUserJson),
          );
          _currentUser = User.fromJson(userMap);
          _isAuthenticated = true;

          debugPrint('✅ Auto-login successful: ${_currentUser?.email}');
        } catch (e) {
          debugPrint('❌ Failed to parse stored user data: $e');
          await logout();
        }
      } else {
        debugPrint('ℹ️ No stored credentials found');
        _isAuthenticated = false;
      }
    } catch (e) {
      debugPrint('❌ Auth check error: $e');
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  /// Simple JSON parser helper
  dynamic _parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint('❌ JSON parse error: $e');
      return {};
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    debugPrint('🔑 AuthProvider: Starting login...');
    _setLoading(true);
    _clearError();

    try {
      // Call auth service
      debugPrint('📞 Calling auth service...');
      final response = await _authService.login(
        email: email,
        password: password,
      );

      debugPrint('📦 Got response: $response');

      // Store token
      _token = response['token'];
      debugPrint('🎫 Token: ${_token?.substring(0, 20)}...');

      _currentUser = User.fromJson(response['user']);
      debugPrint('👤 User: ${_currentUser?.fullName} (${_currentUser?.role})');

      _isAuthenticated = true;

      // Save token to secure storage
      await _storage.write(key: 'auth_token', value: _token);
      debugPrint('💾 Token saved to storage');

      // Save user data to secure storage for auto-login
      await _storage.write(
        key: 'user_data',
        value: jsonEncode(response['user']),
      );
      debugPrint('💾 User data saved to storage');

      // Save remember me preference
      if (rememberMe) {
        await _storage.write(key: 'remember_me', value: 'true');
      }

      _setLoading(false);
      debugPrint('✅ Login complete!');

      // Trigger rebuild to navigate to dashboard
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Call logout API (optional, for server-side cleanup)
      if (_token != null) {
        await _authService.logout(_token!);
      }
    } catch (e) {
      debugPrint('Logout API error: $e');
    }

    // Clear local state
    _currentUser = null;
    _token = null;
    _isAuthenticated = false;

    // Clear secure storage
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'remember_me');

    _setLoading(false);
  }

  /// Refresh auth token
  Future<bool> refreshToken() async {
    if (_token == null) return false;

    try {
      final newToken = await _authService.refreshToken(_token!);

      if (newToken != null) {
        _token = newToken;
        await _storage.write(key: 'auth_token', value: newToken);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  /// Update user profile
  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
