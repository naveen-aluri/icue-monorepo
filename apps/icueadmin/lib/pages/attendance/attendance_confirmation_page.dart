import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

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
    extends State<AttendanceConfirmationPage> {
  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'attendance-confirmation-page',
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Confirmation')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: ElevatedButton(
            onPressed: () {
              attendanceProvider.createAttendance(context);
            },
            child: const Text('SUBMIT ATTENDANCE'),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.createAttendanceBox.listenable(),
        builder: (context, box, _) {
          final data = box.get(attendanceProvider.ongoingAttendanceKey);
          final students = data?.students ?? [];

          if (students.isEmpty) {
            return const Center(
              child: NoDataWidget(msg: 'No attendance data to confirm.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final item = students[index];
              return ListTile(
                selectedTileColor: const Color(0XFFFAFAFA),
                selected: true,
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Roll No: ${item.rollNo}'),
                trailing: Text(
                  item.isPresent ? 'Present' : 'Absent',
                  style: TextStyle(
                    color: item.isPresent ? Colors.green[700] : Colors.red[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: students.length,
          );
        },
      ),
    );
  }
}
