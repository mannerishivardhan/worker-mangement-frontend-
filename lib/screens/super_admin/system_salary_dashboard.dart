/// System Salary Dashboard - Super Admin
///
/// Shows system-wide salary report with all departments

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/salary.dart';
import '../../services/salary_service.dart';

class SystemSalaryDashboard extends StatefulWidget {
  const SystemSalaryDashboard({super.key});

  @override
  State<SystemSalaryDashboard> createState() => _SystemSalaryDashboardState();
}

class _SystemSalaryDashboardState extends State<SystemSalaryDashboard> {
  final SalaryService _salaryService = SalaryService();
  SystemSalaryReport? _reportData;
  bool _isLoading = false;
  String? _errorMessage;

  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final report = await _salaryService.getSystemReport(
        _selectedYear,
        _selectedMonth,
      );
      setState(() {
        _reportData = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showMonthYearPicker() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.year,
    );

    if (selectedDate != null) {
      setState(() {
        _selectedYear = selectedDate.year;
        _selectedMonth = selectedDate.month;
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Salary Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showMonthYearPicker,
            tooltip: 'Select Month',
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load report', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reportData == null) {
      return const Center(child: Text('No report data available'));
    }

    return RefreshIndicator(
      onRefresh: _loadReport,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthCard(theme),
            const SizedBox(height: 16),
            _buildSystemOverviewCards(theme),
            const SizedBox(height: 16),
            _buildDepartmentsSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(ThemeData theme) {
    final monthName = DateFormat.MMMM().format(
      DateTime(_selectedYear, _selectedMonth),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report Period', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  '$monthName $_selectedYear',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.edit_calendar),
              onPressed: _showMonthYearPicker,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverviewCards(ThemeData theme) {
    final total = _reportData!.systemTotal;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Total Employees',
                total.totalEmployees.toString(),
                Icons.people,
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Departments',
                _reportData!.departmentCount.toString(),
                Icons.business,
                theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Total Budget',
                currencyFormat.format(total.totalMonthlySalary),
                Icons.account_balance_wallet,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Calculated Payout',
                currencyFormat.format(total.totalCalculatedSalary),
                Icons.payments,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Deduction', style: theme.textTheme.bodyMedium),
                    Text(
                      currencyFormat.format(total.totalDeduction),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${total.deductionPercentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department Breakdown',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...(_reportData!.departments.map(
          (dept) => _buildDepartmentCard(theme, dept),
        )),
      ],
    );
  }

  Widget _buildDepartmentCard(ThemeData theme, DepartmentSalaryReport dept) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          dept.departmentId,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${dept.employeeCount} employees'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDepartmentRow(
                  theme,
                  'Total Budget',
                  currencyFormat.format(dept.summary.totalMonthlySalary),
                ),
                _buildDepartmentRow(
                  theme,
                  'Calculated Payout',
                  currencyFormat.format(dept.summary.totalCalculatedSalary),
                ),
                _buildDepartmentRow(
                  theme,
                  'Deduction',
                  currencyFormat.format(dept.summary.totalDeduction),
                  isHighlight: true,
                ),
                _buildDepartmentRow(
                  theme,
                  'Avg Days Present',
                  dept.summary.averageDaysPresent.toStringAsFixed(1),
                ),
                const SizedBox(height: 8),
                if (dept.salaries.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Employees',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...dept.salaries.map(
                    (emp) => ListTile(
                      dense: true,
                      title: Text(emp.employeeName),
                      subtitle: Text(
                        '${emp.daysPresent}/${emp.daysInMonth} days present',
                      ),
                      trailing: Text(
                        currencyFormat.format(emp.calculatedSalary),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentRow(
    ThemeData theme,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isHighlight ? theme.colorScheme.error : null,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isHighlight ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }
}
