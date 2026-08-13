import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/create_attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/common_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/hive_service.dart';
import '../../services/injectable.dart';
import '../../utils/app_utils.dart';
import '../../widgets/no_data_widget.dart';

class AttendanceConfirmationPage extends StatefulWidget {
  const AttendanceConfirmationPage({super.key});

  @override
  State<AttendanceConfirmationPage> createState() =>
      _AttendanceConfirmationPageState();
}

class _AttendanceConfirmationPageState extends State<AttendanceConfirmationPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getIt<AnalyticsService>().logScreenView(
      screenName: 'attendance-confirmation-page',
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _toggleStudentStatus(
    BuildContext context,
    AttendanceStudent student,
    AttendanceProvider attendanceProvider,
  ) async {
    final newStatus = student.isPresent ? 'Absent' : 'Present';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Attendance Status'),
        content: Text(
          'Are you sure you want to mark ${student.name} as $newStatus?',
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.selectionClick();
      attendanceProvider.toggleStudentAttendance(student);
    }
  }

  Widget _buildPhotosSection(List<String> images) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Photos (${images.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final imgPath = images[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imgPath.startsWith('data:image')
                        ? Image.memory(
                            const Base64Decoder().convert(
                              imgPath.split(',').last,
                            ),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(imgPath),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 72,
                              height: 72,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleBack(
    BuildContext context,
    AttendanceProvider attendanceProvider,
    CreateAttendance? data,
  ) async {
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Discard Attendance Data?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to discard attendance data?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop('ADD_MORE');
                },
                child: const Text(
                  'Add more attendance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop('DISCARD');
                },
                child: const Text(
                  'Discard',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop('CLOSE');
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );

    if (!context.mounted || action == null || action == 'CLOSE') {
      return;
    }

    if (action == 'DISCARD') {
      await attendanceProvider.deleteOngoingAttendance();
      if (context.mounted) {
        Navigator.of(context).pop('DISCARD');
      }
      return;
    }

    if (action == 'ADD_MORE') {
      Navigator.of(context).pop('ADD_MORE');
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final commonProvider = context.watch<CommonProvider>();
    final uploadImagesEnabled =
        commonProvider.appSettings?.attendCnfg?.uploadAttendImages ?? false;

    return ValueListenableBuilder(
      valueListenable: HiveService.createAttendanceBox.listenable(),
      builder: (context, box, _) {
        final key = attendanceProvider.effectiveAttendanceKey;
        final data = key != null ? box.get(key) : null;
        final students = data?.students ?? [];
        final images =
            data?.images?.where((img) => img.trim().isNotEmpty).toList() ?? [];
        final isLiveCamera = data?.attendanceMode == 'FACIAL_LIVE';
        final requiresPhotoUpload = uploadImagesEnabled && !isLiveCamera;

        final presentStudents = students.where((e) => e.isPresent).toList();
        final absentStudents = students.where((e) => !e.isPresent).toList();

        if (absentStudents.isEmpty &&
            _tabController != null &&
            _tabController!.index == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _tabController!.index == 0) {
              _tabController!.animateTo(1);
            }
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _handleBack(context, attendanceProvider, data);
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: const Text('Attendance Confirmation'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBack(context, attendanceProvider, data),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: absentStudents.isNotEmpty
                                    ? Colors.red.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${absentStudents.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: absentStudents.isNotEmpty
                                      ? Colors.red.shade700
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Absent'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: presentStudents.isNotEmpty
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${presentStudents.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: presentStudents.isNotEmpty
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Present'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isLiveCamera &&
                      (uploadImagesEnabled || images.isNotEmpty))
                    _buildPhotosSection(images),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton(
                      onPressed: students.isEmpty
                          ? null
                          : () {
                              if (requiresPhotoUpload && images.isEmpty) {
                                AppUtils.showErrorMessage(
                                  context,
                                  'Please upload or capture at least one attendance photo.',
                                );
                                return;
                              }
                              attendanceProvider.createAttendance(context);
                            },
                      child: const Text('SUBMIT ATTENDANCE'),
                    ),
                  ),
                ],
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
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: item.isPresent
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Icon(
                item.isPresent
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                color: item.isPresent
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                size: 20,
              ),
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
                _toggleStudentStatus(context, item, attendanceProvider);
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
          ),
        );
      },
    );
  }
}
