import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/attendance/create_attendance_page.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';

class ResumeAttendanceDialog extends StatefulWidget {
  const ResumeAttendanceDialog({super.key});

  @override
  State<ResumeAttendanceDialog> createState() => _ResumeAttendanceDialogState();
}

class _ResumeAttendanceDialogState extends State<ResumeAttendanceDialog> {
  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final ongoingAttendance = attendanceProvider.ongoingAttendance;
    final provider = Provider.of<AuthProvider>(context);

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('There is an ongoing attendance!'),
        content: Text(
          'For ${ongoingAttendance?.standard} - ${ongoingAttendance?.section}\n${ongoingAttendance?.attendanceDate}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAttendancePage(
                    standard: provider.assignedEntityClasses.firstWhere(
                      (e) => e.classId == ongoingAttendance!.classId,
                    ),
                    section: ongoingAttendance!.section,
                  ),
                ),
              );
            },
            child: const Text('Continue'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                side: BorderSide(color: Colors.red),
              ),
            ),
            onPressed: () {
              attendanceProvider.deleteOngoingAttendance(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
