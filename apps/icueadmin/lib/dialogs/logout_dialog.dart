import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const SizedBox(
        width: 500,
        child: Text('Are you sure you want to logout?'),
      ),
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () {
            HapticFeedback.vibrate();
            Navigator.of(context).pop();
          },
        ),
        FilledButton(
          child: const Text('Yes'),
          onPressed: () async {
            HapticFeedback.vibrate();
            Provider.of<AuthProvider>(context, listen: false).logout(context);
          },
        ),
      ],
    );
  }
}
