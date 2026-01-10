import 'package:flutter/material.dart';
import '../../models/department.dart';

class DepartmentHeadCard extends StatelessWidget {
  final DepartmentHead? head;
  final VoidCallback? onAssign;
  final VoidCallback? onRemove;
  final bool canEdit;

  const DepartmentHeadCard({
    Key? key,
    required this.head,
    this.onAssign,
    this.onRemove,
    this.canEdit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (head == null || head!.employeeId == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Department Head',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_alt,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No department head assigned',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    if (canEdit && onAssign != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: onAssign,
                        icon: const Icon(Icons.add),
                        label: const Text('Assign Head'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Department Head',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (canEdit)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'change' && onAssign != null) {
                        onAssign!();
                      } else if (value == 'remove' && onRemove != null) {
                        onRemove!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'change',
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz, size: 20),
                            SizedBox(width: 8),
                            Text('Change Head'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_remove,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Remove Head',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  head!.employeeName?.substring(0, 1).toUpperCase() ?? '?',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                head!.employeeName ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Employee ID: ${head!.employeeId ?? 'N/A'}'),
                  if (head!.assignedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Assigned: ${_formatDate(head!.assignedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
