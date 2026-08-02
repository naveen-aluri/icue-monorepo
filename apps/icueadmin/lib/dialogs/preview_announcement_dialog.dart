import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/announcements_provider.dart';

class PreviewAnnouncementDialog extends StatelessWidget {
  const PreviewAnnouncementDialog({
    super.key,
    required this.title,
    required this.description,
    required this.routes,
    required this.studentId,
    this.points,
    required this.mode,
  });

  final String description;
  final List<String>? points;
  final List<int> routes;
  final List<int> studentId;
  final String title, mode;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Preview Announcement',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(false);
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
          onPressed: () async {
            final res =
                await Provider.of<AnnouncementsProvider>(
                  context,
                  listen: false,
                ).postAnnouncement(
                  context,
                  title: title,
                  mode: mode,
                  description: description,
                  routes: routes,
                  points: points,
                  studentId: studentId,
                );
            if (res) {
              Navigator.of(context, rootNavigator: true).pop(res);
            }
          },
          child: const Text('Submit'),
        ),
      ],
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(title, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(description, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
