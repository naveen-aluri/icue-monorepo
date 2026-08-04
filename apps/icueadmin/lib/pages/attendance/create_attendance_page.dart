import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/assigned_entities.dart';
import '../../models/create_attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/students_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/hive_service.dart';
import '../../services/injectable.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/no_data_widget.dart';
import 'attendance_confirmation_page.dart';

class CreateAttendancePage extends StatefulWidget {
  const CreateAttendancePage({
    super.key,
    required this.standard,
    required this.section,
  });

  final String section;
  final AssignedEntityClass standard;

  @override
  State<CreateAttendancePage> createState() => _CreateAttendancePageState();
}

class _CreateAttendancePageState extends State<CreateAttendancePage> {
  final AppinioSwiperController controller = AppinioSwiperController();

  static const int _paginationThreshold = 3;

  int _activePage = 0;
  bool _isPaginating = false;
  int _pageNo = 1;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'create-attendance-page',
      parameters: {
        'standard': widget.standard.standard,
        'section': widget.section,
      },
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<StudentsProvider>().getStudents(
        context,
        widget.standard.classId,
        [widget.section],
        forAttendance: true,
        pageNo: _pageNo,
      );
    });
  }

  void openBottomSheet(String title, String key) {
    final bool isPresent = title == 'Present';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ValueListenableBuilder(
          valueListenable: HiveService.createAttendanceBox.listenable(),
          builder: (context, box, _) {
            final data = box.get(key);
            final studentsList =
                data?.students
                    .where((e) => isPresent ? e.isPresent : !e.isPresent)
                    .toList() ??
                [];

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        width: 40,
                        height: 5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '$title -  ${studentsList.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Flexible(
                      child: studentsList.isEmpty
                          ? const Center(
                              child: Text('No students in this list.'),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: studentsList.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = studentsList[index];
                                return ListTile(
                                  title: Text(
                                    '${item.name} (${item.rollNo})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: isPresent
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<AttendanceProvider>()
                                          .updateAttendance(
                                            classId: widget.standard.classId,
                                            className: widget.standard.standard,
                                            section: widget.section,
                                            period: '',
                                            student: AttendanceStudent(
                                              id: item.id,
                                              name: item.name,
                                              rollNo: item.rollNo,
                                              admissionNumber:
                                                  item.admissionNumber,
                                              isPresent: !isPresent,
                                              uid: item.uid,
                                              attendanceMode: 'MANUAL',
                                            ),
                                          );
                                    },
                                    child: Text(
                                      isPresent
                                          ? 'Mark Absent'
                                          : 'Mark Present',
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity? activity) {
    final studentProvider = context.read<StudentsProvider>();

    if (previousIndex >= studentProvider.attendanceStudents.length ||
        previousIndex < 0) {
      if (kDebugMode) {
        log('Error: Swiped index $previousIndex is out of bounds.');
      }
      return;
    }

    final swipedStudent = studentProvider.attendanceStudents[previousIndex];

    if (activity is Swipe) {
      final bool isPresent = activity.direction == AxisDirection.right;

      context.read<AttendanceProvider>().updateAttendance(
        classId: widget.standard.classId,
        className: widget.standard.standard,
        section: widget.section,
        period: '',
        student: AttendanceStudent(
          id: swipedStudent.id,
          name: swipedStudent.name,
          rollNo: swipedStudent.rollNo,
          admissionNumber: swipedStudent.admissionNumber,
          isPresent: isPresent,
          uid: swipedStudent.uid,
          attendanceMode: 'MANUAL',
        ),
      );

      setState(() => _activePage = targetIndex);
      _loadNextPageIfNeeded(targetIndex);
      return;
    }

    if (activity is Unswipe) {
      if (kDebugMode) {
        log('A ${activity.direction.name} swipe was undone.');
        log('previous index: $previousIndex, target index: $targetIndex');
      }
      setState(() => _activePage = targetIndex);
      return;
    }

    if (activity is CancelSwipe) {
      if (kDebugMode) log('A swipe was cancelled');
      return;
    }

    if (activity is DrivenActivity) {
      if (kDebugMode) log('Driven Activity');
      return;
    }
  }

  Future<void> _loadNextPageIfNeeded(int currentIndex) async {
    if (_isPaginating) return;

    final provider = context.read<StudentsProvider>();
    final int totalLoaded = provider.attendanceStudents.length;
    final int remaining = totalLoaded - 1 - currentIndex;

    if (remaining < _paginationThreshold && provider.hasNextPage) {
      setState(() {
        _isPaginating = true;
        _pageNo++;
      });

      await provider.getStudents(
        context,
        widget.standard.classId,
        [widget.section],
        forAttendance: true,
        pageNo: _pageNo,
      );

      if (!mounted) return;
      setState(() => _isPaginating = false);
    }
  }

  Widget _buildBottomBar(
    BuildContext context,
    bool attendanceComplete,
    int presentCount,
    int absentCount,
    String? attendanceKey,
  ) {
    final corner = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: attendanceComplete
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: corner,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceConfirmationPage(),
                    ),
                  );
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade200),
                        shape: corner,
                      ),
                      onPressed: attendanceKey == null
                          ? null
                          : () => openBottomSheet('Absent', attendanceKey),
                      icon: const Icon(Icons.close_rounded),
                      label: Text(
                        'Absent: $absentCount',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green.shade200),
                        shape: corner,
                      ),
                      onPressed: attendanceKey == null
                          ? null
                          : () => openBottomSheet('Present', attendanceKey),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        'Present: $presentCount',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentsProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    return ValueListenableBuilder(
      valueListenable: HiveService.createAttendanceBox.listenable(),
      builder: (context, box, _) {
        final data = box.get(attendanceProvider.ongoingAttendanceKey);
        final markedStudents = data?.students ?? [];
        final presentCount = markedStudents.where((e) => e.isPresent).length;
        final absentCount = markedStudents.where((e) => !e.isPresent).length;
        final markedCount = markedStudents.length;

        final attendanceComplete =
            studentProvider.students.isNotEmpty &&
            markedCount == (studentProvider.students.length);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('${widget.standard.standard} - ${widget.section}'),
          ),
          bottomNavigationBar: _buildBottomBar(
            context,
            attendanceComplete,
            presentCount,
            absentCount,
            attendanceProvider.ongoingAttendanceKey,
          ),
          body: attendanceComplete
              ? const NoDataWidget(
                  msg: 'You have completed the attendance!',
                  image: 'assets/attendant-d.png',
                )
              : studentProvider.studentsLoading
              ? const Center(child: CircularProgressIndicator())
              : studentProvider.attendanceStudents.isEmpty
              ? const NoDataWidget(msg: 'No Students Found!')
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Total: $markedCount/${studentProvider.metaData?.total ?? '?'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: AppinioSwiper(
                          backgroundCardCount: 2,
                          controller: controller,
                          swipeOptions: const SwipeOptions.only(
                            left: true,
                            right: true,
                          ),
                          onCardPositionChanged: (SwiperPosition _) {},
                          onSwipeEnd: _swipeEnd,
                          cardCount: studentProvider.attendanceStudents.length,
                          cardBuilder: (BuildContext context, int index) {
                            return ListenableBuilder(
                              listenable: controller,
                              builder: (context, child) {
                                final position = controller.position;
                                final activity = controller.swipeActivity;
                                double progress = 0.0;

                                if ((activity is Swipe) || activity == null) {
                                  if (position != null &&
                                      position.offset
                                          .toAxisDirection()
                                          .isHorizontal) {
                                    progress = position
                                        .progressRelativeToThreshold
                                        .clamp(-1, 1);
                                  }
                                }

                                final Color color = Color.lerp(
                                  Colors.green,
                                  Colors.red,
                                  (-1 * progress).clamp(0, 1),
                                )!;

                                final displayColor =
                                    (_activePage != index || progress == 0.0)
                                    ? Colors.white
                                    : color;

                                return AttendanceCard(
                                  color: displayColor,
                                  candidate:
                                      studentProvider.attendanceStudents[index],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    IconTheme.merge(
                      data: const IconThemeData(size: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SwipeButton(
                            controller: controller,
                            isRightSwipe: false,
                          ),
                          const SizedBox(width: 50),
                          SwipeButton(
                            controller: controller,
                            isRightSwipe: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isPaginating)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
        );
      },
    );
  }
}

class SwipeButton extends StatelessWidget {
  const SwipeButton({
    super.key,
    required this.controller,
    required this.isRightSwipe,
  });

  final AppinioSwiperController controller;
  final bool isRightSwipe;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final SwiperPosition? position = controller.position;
        final SwiperActivity? activity = controller.swipeActivity;

        double progress = 0.0;
        if ((activity is Swipe) || activity == null) {
          if (position != null &&
              position.offset.toAxisDirection().isHorizontal) {
            progress = position.progressRelativeToThreshold.clamp(-1.0, 1.0);
          }
        }

        final Color color = isRightSwipe
            ? Color.lerp(
                CupertinoColors.activeGreen,
                CupertinoColors.systemGrey2,
                (-progress).clamp(0.0, 1.0),
              )!
            : Color.lerp(
                const Color(0xFFFF3868),
                CupertinoColors.systemGrey2,
                progress.clamp(0.0, 1.0),
              )!;

        final double scale =
            1.0 +
            0.1 *
                (isRightSwipe
                    ? progress.clamp(0.0, 1.0)
                    : (-progress).clamp(0.0, 1.0));

        return GestureDetector(
          onTap: isRightSwipe ? controller.swipeRight : controller.swipeLeft,
          child: Transform.scale(
            scale: scale,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.7),
                    spreadRadius: -8,
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                isRightSwipe ? Icons.check : Icons.close,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }
}
