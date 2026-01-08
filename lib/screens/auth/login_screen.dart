/// Login Screen - Email/Password Authentication
///
/// Premium login screen with BMW aesthetics and NotebookLM minimalism.
/// Supports email/password authentication with JWT token management.
///
/// Features:
/// - Email/password input with validation
/// - Remember me checkbox
/// - Forgot password link
/// - Loading state during authentication
/// - Error handling with user-friendly messages
/// - BMW glow effects and animations
/// - Responsive design
///
/// Backend Integration:
/// - POST /api/auth/login - Email/password login
/// - Returns JWT token and user data
/// - Stores token securely for subsequent requests
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const LoginScreen()),
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_input.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Call login
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (success && mounted) {
        // Login successful - show snackbar and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Navigate to appropriate dashboard based on role
        final user = authProvider.currentUser;
        if (user != null) {
          String routeName;
          switch (user.role) {
            case 'super_admin':
              routeName = '/super-admin-dashboard';
              break;
            case 'admin':
              routeName = '/admin-dashboard';
              break;
            case 'manager':
              routeName = '/manager-dashboard';
              break;
            case 'employee':
              routeName = '/employee-dashboard';
              break;
            default:
              routeName = '/employee-dashboard';
          }

          Navigator.of(context).pushReplacementNamed(routeName);
        }
      } else if (mounted) {
        // Login failed - show error from provider
        setState(() {
          _errorMessage =
              authProvider.errorMessage ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? AppSpacing.xxl : AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icon
                    _buildLogo(isDark),

                    const SizedBox(height: AppSpacing.xxl),

                    // Title
                    Text(
                      'Welcome Back',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.textPrimary(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Subtitle
                    Text(
                      'Sign in to continue to Security Management',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Error message
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(isDark),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Email input
                    CustomInput.email(
                      label: 'Email Address',
                      controller: _emailController,
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Password input
                    CustomInput.password(
                      label: 'Password',
                      controller: _passwordController,
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Remember me & Forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember me checkbox
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() => _rememberMe = value ?? false);
                                },
                                activeColor: AppColors.primary(isDark),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Remember me',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),

                        // Forgot password link
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to forgot password screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Forgot password - Coming soon'),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Login button
                    CustomButton.primary(
                      text: 'Sign In',
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      size: ButtonSize.large,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Footer text
                    Text(
                      '© 2025 Security Management System',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary(isDark),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.security, size: 40, color: Colors.white),
    );
  }

  Widget _buildErrorBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.error(isDark), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error(isDark),
            size: AppSpacing.iconMd,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
