import 'package:flutter/material.dart';

class DepartmentStatusBadge extends StatelessWidget {
  final String status;
  final bool showLabel;

  const DepartmentStatusBadge({
    Key? key,
    required this.status,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(
          color: isActive ? Colors.green.shade300 : Colors.red.shade300,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isActive ? Colors.green.shade700 : Colors.red.shade700,
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              isActive ? 'Active' : 'Deactivated',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
