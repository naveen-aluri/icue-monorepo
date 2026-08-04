import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/create_attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/hive_service.dart';
import '../../services/injectable.dart';
import '../../widgets/no_data_widget.dart';

class AttendanceConfirmationPage extends StatefulWidget {
  const AttendanceConfirmationPage({super.key});

  @override
  State<AttendanceConfirmationPage> createState() =>
      _AttendanceConfirmationPageState();
}

class _AttendanceConfirmationPageState
    extends State<AttendanceConfirmationPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'attendance-confirmation-page',
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _showStatusChangeDialog(
    BuildContext context,
    AttendanceStudent student,
    AttendanceProvider attendanceProvider,
  ) async {
    final targetStatus = student.isPresent ? 'Absent' : 'Present';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Attendance Status?'),
        content: Text(
          'Are you sure you want to mark ${student.name} as $targetStatus?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      attendanceProvider.toggleStudentAttendance(student);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();

    return ValueListenableBuilder(
      valueListenable: HiveService.createAttendanceBox.listenable(),
      builder: (context, box, _) {
        final data = box.get(attendanceProvider.ongoingAttendanceKey);
        final students = data?.students ?? [];

        final presentStudents = students.where((e) => e.isPresent).toList();
        final absentStudents = students.where((e) => !e.isPresent).toList();

        if (_tabController == null) {
          _tabController = TabController(
            length: 2,
            vsync: this,
            initialIndex: absentStudents.isEmpty ? 1 : 0,
          );
        } else {
          if (absentStudents.isEmpty && _tabController!.index == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _tabController!.index == 0) {
                _tabController!.animateTo(1);
              }
            });
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('Attendance Confirmation'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: 'Absent (${absentStudents.length})'),
                Tab(text: 'Present (${presentStudents.length})'),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ElevatedButton(
                onPressed: students.isEmpty
                    ? null
                    : () {
                        attendanceProvider.createAttendance(context);
                      },
                child: const Text('SUBMIT ATTENDANCE'),
              ),
            ),
          ),
          body: students.isEmpty
              ? const Center(
                  child: NoDataWidget(msg: 'No attendance data to confirm.'),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStudentsList(absentStudents, attendanceProvider),
                    _buildStudentsList(presentStudents, attendanceProvider),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStudentsList(
    List<AttendanceStudent> studentsList,
    AttendanceProvider attendanceProvider,
  ) {
    if (studentsList.isEmpty) {
      return const Center(
        child: NoDataWidget(msg: 'No students in this list.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: studentsList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = studentsList[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Roll No: ${item.rollNo}  •  Adm: ${item.admissionNumber}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: OutlinedButton.icon(
              onPressed: () {
                _showStatusChangeDialog(context, item, attendanceProvider);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                foregroundColor: item.isPresent
                    ? Colors.red.shade700
                    : Colors.green.shade700,
                side: BorderSide(
                  color: item.isPresent
                      ? Colors.red.shade300
                      : Colors.green.shade300,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                item.isPresent
                    ? Icons.cancel_rounded
                    : Icons.check_circle_rounded,
                size: 16,
              ),
              label: Text(
                item.isPresent ? 'Mark Absent' : 'Mark Present',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _showStatusChangeDialog(context, item, attendanceProvider);
            },
          ),
        );
      },
    );
  }
}
