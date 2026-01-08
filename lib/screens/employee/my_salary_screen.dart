/// My Salary Screen - Employee View
///
/// Shows employee's own salary calculation based on attendance

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/salary.dart';
import '../../services/salary_service.dart';

class MySalaryScreen extends StatefulWidget {
  const MySalaryScreen({super.key});

  @override
  State<MySalaryScreen> createState() => _MySalaryScreenState();
}

class _MySalaryScreenState extends State<MySalaryScreen> {
  final SalaryService _salaryService = SalaryService();
  SalaryCalculation? _salaryData;
  bool _isLoading = false;
  String? _errorMessage;

  // Default to current month
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadSalary();
  }

  Future<void> _loadSalary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final salary = await _salaryService.getMySalary(
        _selectedYear,
        _selectedMonth,
      );
      setState(() {
        _salaryData = salary;
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
      _loadSalary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Salary'),
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
            Text('Failed to load salary', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSalary,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_salaryData == null) {
      return const Center(child: Text('No salary data available'));
    }

    return RefreshIndicator(
      onRefresh: _loadSalary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthCard(theme),
            const SizedBox(height: 16),
            _buildSalaryOverviewCard(theme),
            const SizedBox(height: 16),
            _buildAttendanceCard(theme),
            const SizedBox(height: 16),
            _buildBreakdownCard(theme),
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
                Text(
                  'Salary Period',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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

  Widget _buildSalaryOverviewCard(ThemeData theme) {
    final salary = _salaryData!;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Calculated Salary',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(salary.calculatedSalary),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(
                  theme,
                  'Base',
                  currencyFormat.format(salary.monthlySalary),
                  Icons.account_balance_wallet,
                ),
                _buildInfoChip(
                  theme,
                  'Deduction',
                  currencyFormat.format(salary.deductionAmount),
                  Icons.remove_circle_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(ThemeData theme) {
    final salary = _salaryData!;
    final attendancePercent = salary.attendancePercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: attendancePercent / 100,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                attendancePercent >= 90
                    ? Colors.green
                    : attendancePercent >= 75
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${attendancePercent.toStringAsFixed(1)}% Attendance',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttendanceStat(
                  theme,
                  'Present',
                  salary.daysPresent.toString(),
                  Colors.green,
                ),
                _buildAttendanceStat(
                  theme,
                  'Absent',
                  salary.daysAbsent.toString(),
                  Colors.red,
                ),
                _buildAttendanceStat(
                  theme,
                  'Pending',
                  salary.daysPending.toString(),
                  Colors.orange,
                ),
                _buildAttendanceStat(
                  theme,
                  'Total Days',
                  salary.daysInMonth.toString(),
                  theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(ThemeData theme) {
    final salary = _salaryData!;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculation Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownRow(
              theme,
              'Monthly Salary',
              currencyFormat.format(salary.monthlySalary),
            ),
            _buildBreakdownRow(
              theme,
              'Days in Month',
              '${salary.daysInMonth} days',
            ),
            _buildBreakdownRow(
              theme,
              'Daily Rate',
              currencyFormat.format(salary.dailyRate),
              isHighlight: true,
            ),
            const Divider(height: 24),
            _buildBreakdownRow(
              theme,
              'Days Present',
              '${salary.daysPresent} days',
            ),
            _buildBreakdownRow(
              theme,
              'Calculated Salary',
              currencyFormat.format(salary.calculatedSalary),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceStat(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildBreakdownRow(
    ThemeData theme,
    String label,
    String value, {
    bool isHighlight = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? theme.colorScheme.primary : null,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
