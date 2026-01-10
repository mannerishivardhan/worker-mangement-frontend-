import 'package:flutter/material.dart';

class RemoveHeadDialog extends StatefulWidget {
  final String departmentName;
  final String headName;

  const RemoveHeadDialog({
    Key? key,
    required this.departmentName,
    required this.headName,
  }) : super(key: key);

  @override
  State<RemoveHeadDialog> createState() => _RemoveHeadDialogState();
}

class _RemoveHeadDialogState extends State<RemoveHeadDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remove Department Head'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove "${widget.headName}" as head of "${widget.departmentName}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The department will have no assigned head after this action.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                hintText: 'Enter the reason for removing the head',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            Navigator.of(context).pop(reason.isNotEmpty ? reason : null);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Remove'),
        ),
      ],
    );
  }

  static Future<String?> show(
    BuildContext context,
    String departmentName,
    String headName,
  ) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RemoveHeadDialog(
          departmentName: departmentName,
          headName: headName,
        );
      },
    );
  }
}
