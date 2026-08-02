import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../dialogs/resume_attendance_dialog.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/no_data_widget.dart';
import 'sections_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();

      await authProvider.getAssignedEntities(context, forAttendance: true);

      final ongoingAttendance = await attendanceProvider.getOngoingAttendance();

      if (ongoingAttendance != null && mounted) {
        await showDialog(
          barrierDismissible: false,
          useRootNavigator: false,
          context: context,
          builder: (context) => const ResumeAttendanceDialog(),
        );
      }
    });
  }

  Future<bool> _checkAndShowOngoingAttendanceDialog() async {
    final ongoingAttendance = await context
        .read<AttendanceProvider>()
        .getOngoingAttendance();

    if (ongoingAttendance != null) {
      if (mounted) {
        await showDialog(
          barrierDismissible: false,
          useRootNavigator: false,
          context: context,
          builder: (context) => const ResumeAttendanceDialog(),
        );
      }
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, size: 30),
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.assignedEntityClasses.isEmpty
          ? const NoDataWidget()
          : ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              padding: const EdgeInsets.all(16),
              itemCount: provider.assignedEntityClasses.length,
              itemBuilder: (context, index) {
                final item = provider.assignedEntityClasses[index];

                return Card(
                  elevation: 1,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      Icons.school_outlined,
                      color: theme.primaryColor,
                      size: 30,
                    ),
                    title: Text(
                      item.standard,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: theme.primaryColor,
                      size: 22,
                    ),
                    onTap: () async {
                      if (await _checkAndShowOngoingAttendanceDialog()) {
                        if (mounted) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SectionsPage(standard: item),
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
