import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../dialogs/attendance_mode_dialog.dart';
import '../../dialogs/resume_attendance_dialog.dart';
import '../../models/assigned_entities.dart';
import '../../models/create_attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/common_provider.dart';
import '../../widgets/no_data_widget.dart';
import 'create_attendance_page.dart';
import 'sdk_attendance_page.dart';
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
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final commonProvider = context.read<CommonProvider>();

      commonProvider.getAdminAppSettings();
      await authProvider.getAssignedEntities(context, forAttendance: true);
      if (!mounted) return;

      await attendanceProvider.getOngoingAttendance();
    });
  }

  Future<bool> _checkAndShowOngoingAttendanceDialog() async {
    final ongoingAttendance = await context
        .read<AttendanceProvider>()
        .getOngoingAttendance();

    if (!mounted) return false;

    if (ongoingAttendance != null) {
      await showDialog(
        barrierDismissible: false,
        useRootNavigator: false,
        context: context,
        builder: (context) => const ResumeAttendanceDialog(),
      );
      return false;
    }

    return true;
  }

  Widget _buildOngoingHeader(BuildContext context, CreateAttendance ongoing) {
    final authProvider = context.read<AuthProvider>();
    final targetClass = authProvider.assignedEntityClasses
        .where((e) => e.classId == ongoing.classId)
        .firstOrNull;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade700.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.timelapse_rounded,
                      color: Color(0xFFD97706),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SESSION IN PROGRESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB45309),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.read<AttendanceProvider>().deleteOngoingAttendance();
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${ongoing.standard} - Section ${ongoing.section}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${ongoing.students.length} students marked so far',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: () {
                    context
                        .read<AttendanceProvider>()
                        .deleteOngoingAttendance();
                  },
                  child: const Text(
                    'Discard',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: () {
                    if (targetClass != null) {
                      final mode = ongoing.attendanceMode?.toUpperCase();
                      if (mode == 'FACIAL_LIVE') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SdkAttendancePage(
                              standard: targetClass,
                              section: ongoing.section,
                              initialMode: AttendanceModeOption.sdkLive,
                            ),
                          ),
                        );
                      } else if (mode == 'FACIAL_PHOTO') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SdkAttendancePage(
                              standard: targetClass,
                              section: ongoing.section,
                              initialMode: AttendanceModeOption.sdkPhoto,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateAttendancePage(
                              standard: targetClass,
                              section: ongoing.section,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Resume Session',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>((p) => p.loading);
    final assignedClasses = context
        .select<AuthProvider, List<AssignedEntityClass>>(
          (p) => p.assignedEntityClasses,
        );
    final ongoingAttendance = context
        .watch<AttendanceProvider>()
        .ongoingAttendance;
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (ongoingAttendance != null)
                  _buildOngoingHeader(context, ongoingAttendance),
                Expanded(
                  child: assignedClasses.isEmpty
                      ? const NoDataWidget()
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          padding: const EdgeInsets.all(16),
                          itemCount: assignedClasses.length,
                          itemBuilder: (context, index) {
                            final item = assignedClasses[index];

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
                                      if (mounted) {
                                        context
                                            .read<AttendanceProvider>()
                                            .getOngoingAttendance();
                                      }
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
