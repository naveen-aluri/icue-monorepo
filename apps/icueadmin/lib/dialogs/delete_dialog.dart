import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key, required this.onDelete});

  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text(
          'Are you sure you want to delete?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              HapticFeedback.vibrate();
              Navigator.of(context).pop();
            },
          ),
          TextButton(onPressed: onDelete, child: const Text('Delete')),
        ],
        content: const SizedBox(
          width: 500,
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text(
                'This action cannot be undone',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
