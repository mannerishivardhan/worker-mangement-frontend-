/// Security Management App - Main Entry Point
///
/// Integrates:
/// - Provider for state management (AuthProvider)
/// - GoRouter for navigation with role-based guards
/// - Custom theme system (BMW + NotebookLM design)
/// - Authentication flow (Splash → Login → Dashboard)
///
/// Phase 1: Theme system ✅
/// Phase 2: Authentication ✅
/// Phase 3: Super Admin (Coming next)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'models/user.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/super_admin/super_admin_dashboard.dart';
import 'screens/super_admin/departments_screen.dart';
import 'screens/super_admin/employees_screen.dart';
import 'screens/super_admin/attendance_screen.dart';
import 'screens/super_admin/system_salary_dashboard.dart';
import 'screens/super_admin/employees_salary_list_screen.dart';
import 'screens/employee/my_salary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider for authentication state management
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Rebuild MaterialApp when auth state changes
          return MaterialApp(
            title: 'Security Management',
            debugShowCheckedModeBanner: false,

            // Use our custom theme system
            theme: AppTheme.light(userRole: authProvider.userRole),
            darkTheme: AppTheme.dark(userRole: authProvider.userRole),
            themeMode: ThemeMode.system,

            // Use builder to rebuild on auth state change
            home: Builder(
              builder: (context) => _getInitialScreen(authProvider),
            ),

            // Named routes for navigation
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/super-admin-dashboard': (context) =>
                  const SuperAdminDashboard(),
              '/admin-dashboard': (context) =>
                  const SuperAdminDashboard(), // TODO: Create AdminDashboard
              '/manager-dashboard': (context) =>
                  const SuperAdminDashboard(), // TODO: Create ManagerDashboard
              '/employee-dashboard': (context) =>
                  const SuperAdminDashboard(), // TODO: Create EmployeeDashboard
              '/departments': (context) => const DepartmentsScreen(),
              '/employees': (context) => const EmployeesScreen(),
              '/attendance': (context) => const AttendanceScreen(),
              '/my-salary': (context) => const MySalaryScreen(),
              '/system-salary': (context) => const SystemSalaryDashboard(),
              '/employees-salary-list': (context) =>
                  const EmployeesSalaryListScreen(),
            },
          );
        },
      ),
    );
  }

  /// Determine initial screen based on auth state
  Widget _getInitialScreen(AuthProvider authProvider) {
    // Show splash while initializing
    if (authProvider.isLoading) {
      return const SplashScreen();
    }

    // If authenticated, show role-based dashboard
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      final user = authProvider.currentUser!;

      // Navigate based on role
      if (user.isSuperAdmin) {
        return const SuperAdminDashboard();
      } else if (user.isDeptHead) {
        // TODO: Department Head dashboard (Phase 4)
        return Placeholder(user: user);
      } else {
        // TODO: Employee dashboard (Phase 5)
        return Placeholder(user: user);
      }
    }

    // Not authenticated, show login
    return const LoginScreen();
  }
}

/// Placeholder widget for authenticated state
class Placeholder extends StatelessWidget {
  final User user;

  const Placeholder({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Login Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, ${user.fullName}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${user.role}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              'Dashboard - Coming in Phase 3',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
