import 'package:flutter/material.dart';

class AnnouncementWarningDialog extends StatelessWidget {
  const AnnouncementWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text('This message goes to all parents!'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
