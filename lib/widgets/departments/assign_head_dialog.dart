import 'package:flutter/material.dart';
import '../../models/employee.dart';

class AssignHeadDialog extends StatefulWidget {
  final String departmentName;
  final List<Employee> employees;
  final String? currentHeadId;

  const AssignHeadDialog({
    Key? key,
    required this.departmentName,
    required this.employees,
    this.currentHeadId,
  }) : super(key: key);

  @override
  State<AssignHeadDialog> createState() => _AssignHeadDialogState();
}

class _AssignHeadDialogState extends State<AssignHeadDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployeeId;
  final _searchController = TextEditingController();
  List<Employee> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _filteredEmployees = widget.employees
        .where((e) => e.id != widget.currentHeadId && e.isActive)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEmployees(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = widget.employees
            .where((e) => e.id != widget.currentHeadId && e.isActive)
            .toList();
      } else {
        _filteredEmployees = widget.employees
            .where(
              (e) =>
                  e.id != widget.currentHeadId &&
                  e.isActive &&
                  (e.name.toLowerCase().contains(query.toLowerCase()) ||
                      e.employeeId.toLowerCase().contains(query.toLowerCase())),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.currentHeadId != null
            ? 'Change Department Head'
            : 'Assign Department Head',
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select employee for "${widget.departmentName}"',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Employee',
                  hintText: 'Search by name or ID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterEmployees('');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: _filterEmployees,
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _filteredEmployees.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No active employees found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          final isSelected = _selectedEmployeeId == employee.id;
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                employee.name.substring(0, 1).toUpperCase(),
                              ),
                            ),
                            title: Text(employee.name),
                            subtitle: Text('ID: ${employee.employeeId}'),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : null,
                            tileColor: isSelected ? Colors.green.shade50 : null,
                            onTap: () {
                              setState(() {
                                _selectedEmployeeId = employee.id;
                              });
                            },
                          );
                        },
                      ),
              ),
              if (_selectedEmployeeId != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'The selected employee will be set as department head.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedEmployeeId == null
              ? null
              : () => Navigator.of(context).pop(_selectedEmployeeId),
          child: const Text('Assign'),
        ),
      ],
    );
  }

  static Future<String?> show(
    BuildContext context,
    String departmentName,
    List<Employee> employees, {
    String? currentHeadId,
  }) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AssignHeadDialog(
          departmentName: departmentName,
          employees: employees,
          currentHeadId: currentHeadId,
        );
      },
    );
  }
}
