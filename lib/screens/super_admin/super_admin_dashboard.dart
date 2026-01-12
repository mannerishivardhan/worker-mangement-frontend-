/// Super Admin Dashboard - NotebookLM Clean Design
///
/// Clean, minimal dashboard following NotebookLM design principles.
///
/// Features:
/// - Outlined Material icons
/// - Light blue accent color
/// - Pure white backgrounds
/// - Generous spacing
/// - Rounded corners (16px)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  // TODO: Replace with actual data from backend
  final Map<String, dynamic> _dashboardData = {
    'totalEmployees': 156,
    'activeDepartments': 12,
    'todayAttendance': 142,
    'monthlySalary': 2450000,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // TODO: Fetch real data from backend
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background(isDark),
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Dashboard',
          style: AppTypography.heading1.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
        ),
        actions: [
          // Profile avatar
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary(isDark).withOpacity(0.1),
              child: Text(
                user.initials,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, user, isDark),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome back, ${user.firstName}',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Here\'s your overview for today',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(isDark),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Stats Grid
              _buildStatsGrid(context, isDark),

              const SizedBox(height: AppSpacing.lg),

              // Quick Actions
              _buildQuickActions(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// Build stats grid - 2x2 layout with NotebookLM style
  Widget _buildStatsGrid(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          context,
          isDark: isDark,
          icon: Icons.people_outline,
          label: 'Employees',
          value: _dashboardData['totalEmployees'].toString(),
        ),
        _buildStatCard(
          context,
          isDark: isDark,
          icon: Icons.business_outlined,
          label: 'Departments',
          value: _dashboardData['activeDepartments'].toString(),
        ),
        _buildStatCard(
          context,
          isDark: isDark,
          icon: Icons.check_circle_outline,
          label: 'Attendance',
          value: _dashboardData['todayAttendance'].toString(),
        ),
        _buildStatCard(
          context,
          isDark: isDark,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Salary',
          value:
              '₹${(_dashboardData['monthlySalary'] / 100000).toStringAsFixed(1)}L',
        ),
      ],
    );
  }

  /// Build individual stat card - NotebookLM style
  Widget _buildStatCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(isDark), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon with light blue background (NotebookLM style)
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 24, color: AppColors.primary(isDark)),
          ),
          const Spacer(),
          // Value
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Label
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick actions - NotebookLM style
  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButton(
          context,
          isDark: isDark,
          icon: Icons.person_add_outlined,
          label: 'Add Employee',
          onTap: () {
            Navigator.of(context).pushNamed('/employees');
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButton(
          context,
          isDark: isDark,
          icon: Icons.business_outlined,
          label: 'Manage Departments',
          onTap: () {
            Navigator.of(context).pushNamed('/departments');
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButton(
          context,
          isDark: isDark,
          icon: Icons.schedule_outlined,
          label: 'Mark Attendance',
          onTap: () {
            Navigator.of(context).pushNamed('/attendance');
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButton(
          context,
          isDark: isDark,
          icon: Icons.payments_outlined,
          label: 'Salary Reports',
          onTap: () {
            Navigator.of(context).pushNamed('/system-salary');
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActionButton(
          context,
          isDark: isDark,
          icon: Icons.list_alt_outlined,
          label: 'Employee Salary List',
          onTap: () {
            Navigator.of(context).pushNamed('/employees-salary-list');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border(isDark), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary(isDark)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary(isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// Build navigation drawer - NotebookLM style
  Widget _buildDrawer(BuildContext context, user, bool isDark) {
    return Drawer(
      backgroundColor: AppColors.surface(isDark),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: AppColors.surfaceVariant(isDark)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary(isDark).withOpacity(0.1),
                  child: Text(
                    user.initials,
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.primary(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  user.fullName,
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                Text(
                  'Super Admin',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Menu items with outlined icons
          _buildDrawerItem(
            context,
            isDark: isDark,
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context,
            isDark: isDark,
            icon: Icons.business_outlined,
            label: 'Departments',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/departments');
            },
          ),
          _buildDrawerItem(
            context,
            isDark: isDark,
            icon: Icons.people_outline,
            label: 'Employees',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/employees');
            },
          ),
          _buildDrawerItem(
            context,
            isDark: isDark,
            icon: Icons.schedule_outlined,
            label: 'Shifts',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context,
            isDark: isDark,
            icon: Icons.access_time_outlined,
            label: 'Attendance',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/attendance');
            },
          ),
          _buildDrawerItem(
            context,
            isDark: isDark,
            icon: Icons.account_balance_wallet_outlined,
            label: 'Salary',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/system-salary');
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            isDark: isDark,
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context,
            isDark: isDark,
            icon: Icons.logout_outlined,
            label: 'Logout',
            onTap: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String label,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? AppColors.primary(isDark)
            : AppColors.textSecondary(isDark),
        size: 22,
      ),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: selected
              ? AppColors.primary(isDark)
              : AppColors.textPrimary(isDark),
          fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: AppColors.primary(isDark).withOpacity(0.08),
      onTap: onTap,
    );
  }
}
