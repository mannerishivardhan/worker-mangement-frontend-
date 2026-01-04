/// Splash Screen - Initial Loading Screen
///
/// Premium splash screen with BMW aesthetics.
/// Handles initial app loading, token validation, and routing.
///
/// Features:
/// - BMW logo with glow effect
/// - Loading animation
/// - Auto-navigation based on auth state
/// - Smooth fade transitions
///
/// Flow:
/// 1. Check for stored JWT token
/// 2. Validate token with backend
/// 3. Navigate to appropriate screen:
///    - If valid token → Dashboard (based on role)
///    - If invalid/no token → Login screen
///
/// Usage:
/// Set as initial route in app_router.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _controller.forward();

    // Check auth and navigate
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // TODO: Implement actual auth check in Phase 2
    // Example:
    // final authService = Provider.of<AuthService>(context, listen: false);
    // final isAuthenticated = await authService.checkAuthStatus();
    //
    // if (isAuthenticated) {
    //   final userRole = authService.currentUser?.role;
    //   context.go(AppRouter._getDashboardRoute(userRole));
    // } else {
    //   context.go(AppRoutes.login);
    // }

    // For now, navigate to login (will be replaced with actual logic)
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clean logo - NotebookLM style
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary(isDark),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // App name
                Text(
                  'Security Management',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Tagline
                Text(
                  'Premium Workforce Management',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
