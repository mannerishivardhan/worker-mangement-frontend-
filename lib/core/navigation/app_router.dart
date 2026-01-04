/// App Router - GoRouter Configuration
///
/// Centralized routing configuration with role-based guards.
/// Handles navigation for all user roles with deep linking support.
///
/// Features:
/// - Role-based route guards
/// - Deep linking support
/// - Redirect logic for authentication
/// - Named routes for easy navigation
/// - Nested navigation for complex flows
///
/// Usage:
/// ```dart
/// MaterialApp.router(
///   routerConfig: AppRouter.router,
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App Routes - Named route constants
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';

  // Super Admin routes
  static const String superAdminDashboard = '/super-admin';
  static const String departments = '/super-admin/departments';
  static const String employees = '/super-admin/employees';
  static const String shifts = '/super-admin/shifts';
  static const String attendance = '/super-admin/attendance';
  static const String salary = '/super-admin/salary';
  static const String analytics = '/super-admin/analytics';
  static const String settings = '/super-admin/settings';

  // Department Head routes
  static const String deptHeadDashboard = '/dept-head';
  static const String deptEmployees = '/dept-head/employees';
  static const String deptAttendance = '/dept-head/attendance';
  static const String deptProfile = '/dept-head/profile';

  // Employee routes
  static const String employeeDashboard = '/employee';
  static const String employeeAttendance = '/employee/attendance';
  static const String employeeSalary = '/employee/salary';
  static const String employeeProfile = '/employee/profile';
}

/// App Router Configuration
class AppRouter {
  /// Get the configured GoRouter instance
  ///
  /// Pass the current user role to enable role-based routing
  static GoRouter router({String? userRole, bool isAuthenticated = false}) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        // Redirect logic based on authentication and role
        if (!isAuthenticated && state.matchedLocation != AppRoutes.login) {
          return AppRoutes.login;
        }

        // Redirect to appropriate dashboard after login
        if (isAuthenticated && state.matchedLocation == AppRoutes.login) {
          return _getDashboardRoute(userRole);
        }

        return null; // No redirect needed
      },
      routes: [
        // ======================================================================
        // AUTH ROUTES
        // ======================================================================
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),

        // ======================================================================
        // SUPER ADMIN ROUTES
        // ======================================================================
        GoRoute(
          path: AppRoutes.superAdminDashboard,
          builder: (context, state) => const SuperAdminDashboardScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'super_admin'),
        ),
        GoRoute(
          path: AppRoutes.departments,
          builder: (context, state) => const DepartmentsScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'super_admin'),
        ),
        GoRoute(
          path: AppRoutes.employees,
          builder: (context, state) => const EmployeesScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'super_admin'),
        ),
        GoRoute(
          path: AppRoutes.shifts,
          builder: (context, state) => const ShiftsScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'super_admin'),
        ),
        GoRoute(
          path: AppRoutes.attendance,
          builder: (context, state) => const AttendanceScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'super_admin'),
        ),
        GoRoute(
          path: AppRoutes.salary,
          builder: (context, state) => const SalaryScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'super_admin'),
        ),

        // ======================================================================
        // DEPARTMENT HEAD ROUTES
        // ======================================================================
        GoRoute(
          path: AppRoutes.deptHeadDashboard,
          builder: (context, state) => const DeptHeadDashboardScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'dept_head'),
        ),
        GoRoute(
          path: AppRoutes.deptEmployees,
          builder: (context, state) => const DeptEmployeesScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'dept_head'),
        ),
        GoRoute(
          path: AppRoutes.deptAttendance,
          builder: (context, state) => const DeptAttendanceScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'dept_head'),
        ),

        // ======================================================================
        // EMPLOYEE ROUTES
        // ======================================================================
        GoRoute(
          path: AppRoutes.employeeDashboard,
          builder: (context, state) => const EmployeeDashboardScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'employee'),
        ),
        GoRoute(
          path: AppRoutes.employeeAttendance,
          builder: (context, state) => const EmployeeAttendanceScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'employee'),
        ),
        GoRoute(
          path: AppRoutes.employeeSalary,
          builder: (context, state) => const EmployeeSalaryScreen(),
          redirect: (context, state) => _roleGuard(userRole, 'employee'),
        ),
      ],
    );
  }

  /// Role-based guard - Redirects if user doesn't have required role
  static String? _roleGuard(String? userRole, String requiredRole) {
    if (userRole != requiredRole) {
      // Redirect to appropriate dashboard or login
      return userRole != null ? _getDashboardRoute(userRole) : AppRoutes.login;
    }
    return null; // Allow access
  }

  /// Get dashboard route based on user role
  static String _getDashboardRoute(String? role) {
    switch (role?.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return AppRoutes.superAdminDashboard;
      case 'dept_head':
      case 'depthead':
      case 'department_head':
        return AppRoutes.deptHeadDashboard;
      case 'employee':
        return AppRoutes.employeeDashboard;
      default:
        return AppRoutes.login;
    }
  }
}

// ============================================================================
// PLACEHOLDER SCREENS (To be implemented in later phases)
// ============================================================================

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Login Screen - Phase 2')));
}

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Super Admin Dashboard - Phase 3')),
  );
}

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Departments - Phase 3')));
}

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Employees - Phase 3')));
}

class ShiftsScreen extends StatelessWidget {
  const ShiftsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Shifts - Phase 3')));
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Attendance - Phase 3')));
}

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Salary - Phase 3')));
}

class DeptHeadDashboardScreen extends StatelessWidget {
  const DeptHeadDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Dept Head Dashboard - Phase 4')),
  );
}

class DeptEmployeesScreen extends StatelessWidget {
  const DeptEmployeesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Dept Employees - Phase 4')));
}

class DeptAttendanceScreen extends StatelessWidget {
  const DeptAttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Dept Attendance - Phase 4')));
}

class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Employee Dashboard - Phase 5')));
}

class EmployeeAttendanceScreen extends StatelessWidget {
  const EmployeeAttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Employee Attendance - Phase 5')),
  );
}

class EmployeeSalaryScreen extends StatelessWidget {
  const EmployeeSalaryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Employee Salary - Phase 5')));
}
