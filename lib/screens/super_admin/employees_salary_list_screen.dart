/// Employees Salary List - Super Admin
///
/// Displays all employee salaries in a sortable list with PDF export

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/salary.dart';
import '../../models/department.dart';
import '../../models/employee.dart';
import '../../services/salary_service.dart';
import '../../services/employee_service.dart';
import '../../services/department_service.dart';

class EmployeesSalaryListScreen extends StatefulWidget {
  const EmployeesSalaryListScreen({super.key});

  @override
  State<EmployeesSalaryListScreen> createState() =>
      _EmployeesSalaryListScreenState();
}

class _EmployeesSalaryListScreenState extends State<EmployeesSalaryListScreen> {
  final SalaryService _salaryService = SalaryService();
  final EmployeeService _employeeService = EmployeeService();
  final DepartmentService _departmentService = DepartmentService();

  List<SalaryCalculation> _allSalaries = [];
  List<SalaryCalculation> _filteredSalaries = [];
  List<Department> _departments = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedDepartmentId;
  
  late int _selectedYear;
  late int _selectedMonth;
  
  // Sorting
  String _sortColumn = 'name'; // 'name', 'department', 'salary', 'attendance'
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load departments and employees in parallel
      final results = await Future.wait([
        _departmentService.getDepartments(),
        _employeeService.getEmployees(),
      ]);

      final departments = results[0] as List<Department>;
      final employees = results[1] as List<Employee>;

      // Calculate salary for each active employee
      final salaryFutures = employees
          .where((emp) => emp.isActive)
          .map((emp) => _calculateSalarySafely(emp.id, emp.employeeId));

      final salaries = await Future.wait(salaryFutures);
      final validSalaries = salaries.whereType<SalaryCalculation>().toList();

      setState(() {
        _departments = departments;
        _allSalaries = validSalaries;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<SalaryCalculation?> _calculateSalarySafely(
      String userId, String empId) async {
    try {
      return await _salaryService.calculateEmployeeSalary(
        userId,
        _selectedYear,
        _selectedMonth,
      );
    } catch (e) {
      debugPrint('Error calculating salary for $empId: $e');
      return null;
    }
  }

  void _applyFiltersAndSort() {
    // Filter by department
    List<SalaryCalculation> filtered = _selectedDepartmentId == null
        ? List.from(_allSalaries)
        : _allSalaries
            .where((s) => s.departmentId == _selectedDepartmentId)
            .toList();

    // Sort
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortColumn) {
        case 'name':
          comparison = a.employeeName.compareTo(b.employeeName);
          break;
        case 'department':
          comparison = (a.departmentName ?? '').compareTo(b.departmentName ?? '');
          break;
        case 'salary':
          comparison = a.calculatedSalary.compareTo(b.calculatedSalary);
          break;
        case 'attendance':
          comparison = a.daysPresent.compareTo(b.daysPresent);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredSalaries = filtered;
    });
  }

  void _changeSortColumn(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
      _applyFiltersAndSort();
    });
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
      _loadData();
    }
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final monthName = DateFormat.MMMM().format(
      DateTime(_selectedYear, _selectedMonth),
    );

    // Calculate totals
    final totalBudget = _filteredSalaries.fold<double>(
      0,
      (sum, s) => sum + s.monthlySalary,
    );
    final totalPayout = _filteredSalaries.fold<double>(
      0,
      (sum, s) => sum + s.calculatedSalary,
    );
    final totalDeduction = totalBudget - totalPayout;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Employee Salary Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '$monthName $_selectedYear',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                if (_selectedDepartmentId != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Department: ${_departments.firstWhere((d) => d.id == _selectedDepartmentId).name}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildPdfRow('Total Employees:', '${_filteredSalaries.length}'),
                _buildPdfRow('Total Budget:', currencyFormat.format(totalBudget)),
                _buildPdfRow('Total Payout:', currencyFormat.format(totalPayout)),
                _buildPdfRow(
                  'Total Deduction:',
                  currencyFormat.format(totalDeduction),
                  isHighlight: true,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Employee Table
          pw.Text(
            'Employee Details',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildPdfTableCell('Employee', isHeader: true),
                  _buildPdfTableCell('Department', isHeader: true),
                  _buildPdfTableCell('Days', isHeader: true, align: pw.TextAlign.center),
                  _buildPdfTableCell('Base Salary', isHeader: true, align: pw.TextAlign.right),
                  _buildPdfTableCell('OT Pay', isHeader: true, align: pw.TextAlign.right),
                  _buildPdfTableCell('Total', isHeader: true, align: pw.TextAlign.right),
                ],
              ),
              // Data rows
              ..._filteredSalaries.map((salary) {
                return pw.TableRow(
                  children: [
                    _buildPdfTableCell(
                      '${salary.employeeName}\n${salary.employeeId}',
                      fontSize: 9,
                    ),
                    _buildPdfTableCell(
                      salary.departmentName ?? '-',
                      fontSize: 9,
                    ),
                    _buildPdfTableCell(
                      '${salary.daysPresent}/${salary.daysInMonth}',
                      fontSize: 9,
                      align: pw.TextAlign.center,
                    ),
                    _buildPdfTableCell(
                      currencyFormat.format(salary.baseSalary ?? salary.calculatedSalary),
                      fontSize: 9,
                      align: pw.TextAlign.right,
                    ),
                    _buildPdfTableCell(
                      salary.overtimePay != null && salary.overtimePay! > 0
                          ? currencyFormat.format(salary.overtimePay)
                          : '-',
                      fontSize: 9,
                      align: pw.TextAlign.right,
                    ),
                    _buildPdfTableCell(
                      currencyFormat.format(salary.calculatedSalary),
                      fontSize: 9,
                      align: pw.TextAlign.right,
                      isBold: true,
                    ),
                  ],
                );
              }),
              // Total row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildPdfTableCell('TOTAL', isBold: true, colSpan: 3),
                  _buildPdfTableCell(
                    currencyFormat.format(
                      _filteredSalaries.fold<double>(
                        0,
                        (sum, s) => sum + (s.baseSalary ?? s.calculatedSalary),
                      ),
                    ),
                    align: pw.TextAlign.right,
                    isBold: true,
                  ),
                  _buildPdfTableCell(
                    currencyFormat.format(
                      _filteredSalaries.fold<double>(
                        0,
                        (sum, s) => sum + (s.overtimePay ?? 0),
                      ),
                    ),
                    align: pw.TextAlign.right,
                    isBold: true,
                  ),
                  _buildPdfTableCell(
                    currencyFormat.format(totalPayout),
                    align: pw.TextAlign.right,
                    isBold: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // Show print/save dialog
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'salary_report_${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}.pdf',
    );
  }

  pw.Widget _buildPdfRow(String label, String value, {bool isHighlight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: isHighlight ? PdfColors.red : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    double fontSize = 10,
    pw.TextAlign align = pw.TextAlign.left,
    int colSpan = 1,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Salaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showMonthYearPicker,
            tooltip: 'Select Month',
          ),
          if (_filteredSalaries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _exportToPDF,
              tooltip: 'Export to PDF',
            ),
        ],
      ),
      body: _buildBody(theme, isDark),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
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
            Text('Failed to load data', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFiltersBar(theme, isDark),
        _buildSummaryCards(theme, isDark),
        Expanded(child: _buildSalaryList(theme, isDark)),
      ],
    );
  }

  Widget _buildFiltersBar(ThemeData theme, bool isDark) {
    final monthName = DateFormat.MMMM().format(
      DateTime(_selectedYear, _selectedMonth),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '$monthName $_selectedYear',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredSalaries.length} employees',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Info banner if overtime data is missing
          if (_filteredSalaries.isNotEmpty &&
              _filteredSalaries.every((s) => s.baseSalary == null))
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Overtime breakdown not available. Deploy updated backend for full features.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_filteredSalaries.isNotEmpty &&
              _filteredSalaries.every((s) => s.baseSalary == null))
            const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: _selectedDepartmentId,
            decoration: const InputDecoration(
              labelText: 'Filter by Department',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Departments'),
              ),
              ..._departments.map(
                (dept) => DropdownMenuItem(
                  value: dept.id,
                  child: Text(dept.name),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDepartmentId = value;
                _applyFiltersAndSort();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme, bool isDark) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final totalBudget = _filteredSalaries.fold<double>(
      0,
      (sum, s) => sum + s.monthlySalary,
    );
    final totalPayout = _filteredSalaries.fold<double>(
      0,
      (sum, s) => sum + s.calculatedSalary,
    );
    final totalDeduction = totalBudget - totalPayout;
    final totalOvertimePay = _filteredSalaries.fold<double>(
      0,
      (sum, s) => sum + (s.overtimePay ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              theme,
              'Budget',
              currencyFormat.format(totalBudget),
              Icons.account_balance_wallet,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              theme,
              'Payout',
              currencyFormat.format(totalPayout),
              Icons.payments,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              theme,
              'OT Pay',
              currencyFormat.format(totalOvertimePay),
              Icons.access_time,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              theme,
              'Deduction',
              currencyFormat.format(totalDeduction),
              Icons.trending_down,
              theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryList(ThemeData theme, bool isDark) {
    if (_filteredSalaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              'No employee salaries found',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: ['name', 'department', 'salary', 'attendance']
                .indexOf(_sortColumn),
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: const Text('Employee'),
                onSort: (_, __) => _changeSortColumn('name'),
              ),
              DataColumn(
                label: const Text('Department'),
                onSort: (_, __) => _changeSortColumn('department'),
              ),
              DataColumn(
                label: const Text('Attendance'),
                numeric: true,
                onSort: (_, __) => _changeSortColumn('attendance'),
              ),
              const DataColumn(
                label: Text('Monthly Salary'),
                numeric: true,
              ),
              const DataColumn(
                label: Text('Base Pay'),
                numeric: true,
              ),
              const DataColumn(
                label: Text('OT Hours'),
                numeric: true,
              ),
              const DataColumn(
                label: Text('OT Pay'),
                numeric: true,
              ),
              DataColumn(
                label: const Text('Calculated Salary'),
                numeric: true,
                onSort: (_, __) => _changeSortColumn('salary'),
              ),
            ],
            rows: _filteredSalaries.map((salary) {
              final attendancePercent =
                  (salary.daysPresent / salary.daysInMonth * 100).round();
              final hasOvertime = salary.overtimePay != null && salary.overtimePay! > 0;

              return DataRow(
                cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          salary.employeeName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          salary.employeeId,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(salary.departmentName ?? '-')),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${salary.daysPresent}/${salary.daysInMonth}'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: attendancePercent >= 90
                                ? Colors.green.withOpacity(0.2)
                                : attendancePercent >= 75
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$attendancePercent%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: attendancePercent >= 90
                                  ? Colors.green[700]
                                  : attendancePercent >= 75
                                      ? Colors.orange[700]
                                      : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(currencyFormat.format(salary.monthlySalary))),
                  DataCell(
                    Text(
                      currencyFormat.format(
                        salary.baseSalary ?? salary.calculatedSalary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      salary.overtimeHours != null && salary.overtimeHours! > 0
                          ? '${salary.overtimeHours!.toStringAsFixed(1)}h'
                          : '-',
                    ),
                  ),
                  DataCell(
                    Text(
                      hasOvertime ? currencyFormat.format(salary.overtimePay) : '-',
                      style: TextStyle(
                        color: hasOvertime ? Colors.green[700] : null,
                        fontWeight: hasOvertime ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(salary.calculatedSalary),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
