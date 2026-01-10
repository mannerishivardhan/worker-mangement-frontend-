/// Salary Models
///
/// Models for salary calculations based on attendance

class SalaryCalculation {
  final String userId;
  final String employeeId;
  final String employeeName;
  final String? departmentId;
  final String? departmentName;
  final String month; // Format: YYYY-MM
  final int year;
  final int monthNumber;
  final double monthlySalary;
  final int daysInMonth;
  final int daysPresent;
  final int daysAbsent;
  final int daysPending;
  final double dailyRate;
  final double calculatedSalary;
  // NEW: Overtime fields
  final double? baseSalary;
  final double? overtimeHours;
  final double? overtimeRate;
  final double? overtimePay;

  SalaryCalculation({
    required this.userId,
    required this.employeeId,
    required this.employeeName,
    this.departmentId,
    this.departmentName,
    required this.month,
    required this.year,
    required this.monthNumber,
    required this.monthlySalary,
    required this.daysInMonth,
    required this.daysPresent,
    required this.daysAbsent,
    required this.daysPending,
    required this.dailyRate,
    required this.calculatedSalary,
    this.baseSalary,
    this.overtimeHours,
    this.overtimeRate,
    this.overtimePay,
  });

  factory SalaryCalculation.fromJson(Map<String, dynamic> json) {
    return SalaryCalculation(
      userId: json['userId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      month: json['month'] ?? '',
      year: json['year'] ?? 0,
      monthNumber: json['monthNumber'] ?? 0,
      monthlySalary: (json['monthlySalary'] ?? 0).toDouble(),
      daysInMonth: json['daysInMonth'] ?? 0,
      daysPresent: json['daysPresent'] ?? 0,
      daysAbsent: json['daysAbsent'] ?? 0,
      daysPending: json['daysPending'] ?? 0,
      dailyRate: (json['dailyRate'] ?? 0).toDouble(),
      calculatedSalary: (json['calculatedSalary'] ?? 0).toDouble(),
      baseSalary: json['baseSalary'] != null
          ? (json['baseSalary'] as num).toDouble()
          : null,
      overtimeHours: json['overtimeHours'] != null
          ? (json['overtimeHours'] as num).toDouble()
          : null,
      overtimeRate: json['overtimeRate'] != null
          ? (json['overtimeRate'] as num).toDouble()
          : null,
      overtimePay: json['overtimePay'] != null
          ? (json['overtimePay'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'month': month,
      'year': year,
      'monthNumber': monthNumber,
      'monthlySalary': monthlySalary,
      'daysInMonth': daysInMonth,
      'daysPresent': daysPresent,
      'daysAbsent': daysAbsent,
      'daysPending': daysPending,
      'dailyRate': dailyRate,
      'calculatedSalary': calculatedSalary,
      'baseSalary': baseSalary,
      'overtimeHours': overtimeHours,
      'overtimeRate': overtimeRate,
      'overtimePay': overtimePay,
    };
  }

  double get deductionAmount => monthlySalary - calculatedSalary;
  double get deductionPercentage =>
      monthlySalary > 0 ? (deductionAmount / monthlySalary) * 100 : 0;
  double get attendancePercentage =>
      daysInMonth > 0 ? (daysPresent / daysInMonth) * 100 : 0;
}

class DepartmentSalaryReport {
  final String departmentId;
  final String month;
  final int employeeCount;
  final List<SalaryCalculation> salaries;
  final DepartmentSalarySummary summary;

  DepartmentSalaryReport({
    required this.departmentId,
    required this.month,
    required this.employeeCount,
    required this.salaries,
    required this.summary,
  });

  factory DepartmentSalaryReport.fromJson(Map<String, dynamic> json) {
    return DepartmentSalaryReport(
      departmentId: json['departmentId'] ?? '',
      month: json['month'] ?? '',
      employeeCount: json['employeeCount'] ?? 0,
      salaries:
          (json['salaries'] as List<dynamic>?)
              ?.map((e) => SalaryCalculation.fromJson(e))
              .toList() ??
          [],
      summary: DepartmentSalarySummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class DepartmentSalarySummary {
  final double totalMonthlySalary;
  final double totalCalculatedSalary;
  final double averageDaysPresent;

  DepartmentSalarySummary({
    required this.totalMonthlySalary,
    required this.totalCalculatedSalary,
    required this.averageDaysPresent,
  });

  factory DepartmentSalarySummary.fromJson(Map<String, dynamic> json) {
    return DepartmentSalarySummary(
      totalMonthlySalary: (json['totalMonthlySalary'] ?? 0).toDouble(),
      totalCalculatedSalary: (json['totalCalculatedSalary'] ?? 0).toDouble(),
      averageDaysPresent: (json['averageDaysPresent'] ?? 0).toDouble(),
    );
  }

  double get totalDeduction => totalMonthlySalary - totalCalculatedSalary;
}

class SystemSalaryReport {
  final String month;
  final int departmentCount;
  final List<DepartmentSalaryReport> departments;
  final SystemSalaryTotal systemTotal;

  SystemSalaryReport({
    required this.month,
    required this.departmentCount,
    required this.departments,
    required this.systemTotal,
  });

  factory SystemSalaryReport.fromJson(Map<String, dynamic> json) {
    return SystemSalaryReport(
      month: json['month'] ?? '',
      departmentCount: json['departmentCount'] ?? 0,
      departments:
          (json['departments'] as List<dynamic>?)
              ?.map((e) => DepartmentSalaryReport.fromJson(e))
              .toList() ??
          [],
      systemTotal: SystemSalaryTotal.fromJson(json['systemTotal'] ?? {}),
    );
  }
}

class SystemSalaryTotal {
  final int totalEmployees;
  final double totalMonthlySalary;
  final double totalCalculatedSalary;

  SystemSalaryTotal({
    required this.totalEmployees,
    required this.totalMonthlySalary,
    required this.totalCalculatedSalary,
  });

  factory SystemSalaryTotal.fromJson(Map<String, dynamic> json) {
    return SystemSalaryTotal(
      totalEmployees: json['totalEmployees'] ?? 0,
      totalMonthlySalary: (json['totalMonthlySalary'] ?? 0).toDouble(),
      totalCalculatedSalary: (json['totalCalculatedSalary'] ?? 0).toDouble(),
    );
  }

  double get totalDeduction => totalMonthlySalary - totalCalculatedSalary;
  double get deductionPercentage =>
      totalMonthlySalary > 0 ? (totalDeduction / totalMonthlySalary) * 100 : 0;
}
