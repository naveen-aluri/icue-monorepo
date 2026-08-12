import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage(
    ImageSource source,
    AttendanceProvider attendanceProvider,
    List<String> currentImages,
  ) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null) {
        final updated = List<String>.from(currentImages)..add(picked.path);
        await attendanceProvider.setAttendanceImages(updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
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

  Widget _buildPhotosSection(
    BuildContext context,
    List<String> images,
    AttendanceProvider attendanceProvider,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Photos (${images.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Take Photo'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(
                                ImageSource.camera,
                                attendanceProvider,
                                images,
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Choose from Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(
                                ImageSource.gallery,
                                attendanceProvider,
                                images,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_a_photo, size: 16),
                label: const Text('Add Photo', style: TextStyle(fontSize: 13)),
              ),
            ],
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
                  return Stack(
                    children: [
                      ClipRRect(
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
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: InkWell(
                          onTap: () {
                            final updated = List<String>.from(images)
                              ..removeAt(index);
                            attendanceProvider.setAttendanceImages(updated);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
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
        final data = box.get(attendanceProvider.ongoingAttendanceKey);
        final students = data?.students ?? [];
        final images = data?.images ?? [];
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isLiveCamera && (uploadImagesEnabled || images.isNotEmpty))
                  _buildPhotosSection(context, images, attendanceProvider),
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
