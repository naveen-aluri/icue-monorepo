import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../models/create_attendance.dart';
import '../services/api_client.dart';
import '../services/hive_service.dart';
import '../utils/app_utils.dart';

@lazySingleton
class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider(this._apiClient);

  final ApiClient _apiClient;
  bool loading = false;
  CreateAttendance? ongoingAttendance;
  String? ongoingAttendanceKey;

  /// Standardized key format: yyyy-MM-dd-$classId-$section-$period
  String generateAttendanceKey({
    required int classId,
    required String section,
    String? period,
  }) {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final activePeriod = (period == null || period.isEmpty) ? '1' : period;
    return '$dateStr-$classId-$section-$activePeriod';
  }

  Future<CreateAttendance?> getOngoingAttendance() async {
    try {
      final box = HiveService.createAttendanceBox;
      final ongoingAttendanceKeys = box.keys.toList();
      if (ongoingAttendanceKeys.isNotEmpty) {
        ongoingAttendanceKey = ongoingAttendanceKeys.first.toString();
        ongoingAttendance = box.get(ongoingAttendanceKey);
        return ongoingAttendance;
      } else {
        ongoingAttendanceKey = null;
        ongoingAttendance = null;
      }
      return null;
    } catch (error, stack) {
      _apiClient.logCrash('getOngoingAttendance()', error, stack);
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteOngoingAttendance() async {
    try {
      if (ongoingAttendanceKey != null) {
        await HiveService.createAttendanceBox.delete(ongoingAttendanceKey);
      }
      ongoingAttendanceKey = null;
      ongoingAttendance = null;
    } catch (error, stack) {
      _apiClient.logCrash('deleteOngoingAttendance()', error, stack);
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateAttendance({
    required int classId,
    required String className,
    required String section,
    required String period,
    required AttendanceStudent student,
  }) async {
    try {
      final box = HiveService.createAttendanceBox;
      final key = generateAttendanceKey(
        classId: classId,
        section: section,
        period: period,
      );
      if (ongoingAttendanceKey != key) {
        ongoingAttendanceKey = key;
        notifyListeners();
      }

      final activePeriod = period.isEmpty ? '1' : period;
      final attendance = box.get(key);
      if (attendance == null) {
        await box.put(
          key,
          CreateAttendance(
            source: 'adminapp',
            students: [student],
            classId: classId,
            section: section,
            standard: className,
            attendanceDate: DateTime.now().formattedGatePassDate() ?? '',
            attendanceTime: DateTime.now().formattedAttendanceTime(),
            month: DateTime.now().month,
            year: DateTime.now().year,
            period: activePeriod,
            attendanceMode: student.attendanceMode,
          ),
        );
      } else {
        final index = attendance.students.indexWhere((e) => e.id == student.id);
        final updatedStudents = List<AttendanceStudent>.from(
          attendance.students,
        );
        if (index != -1) {
          updatedStudents[index] = student;
        } else {
          updatedStudents.add(student);
        }
        await box.put(
          key,
          attendance.copyWith(
            students: updatedStudents,
            attendanceMode: attendance.attendanceMode ?? student.attendanceMode,
          ),
        );
      }
    } catch (error, stack) {
      _apiClient.logCrash('updateAttendance()', error, stack);
    }
  }

  Future<void> updateAttendanceBulk({
    required int classId,
    required String className,
    required String section,
    required String period,
    required List<AttendanceStudent> students,
    String? attendanceMode,
  }) async {
    try {
      final box = HiveService.createAttendanceBox;
      final key = generateAttendanceKey(
        classId: classId,
        section: section,
        period: period,
      );
      if (ongoingAttendanceKey != key) {
        ongoingAttendanceKey = key;
      }

      final activePeriod = period.isEmpty ? '1' : period;
      final attendance = box.get(key);
      if (attendance == null) {
        await box.put(
          key,
          CreateAttendance(
            source: 'adminapp',
            students: students,
            classId: classId,
            section: section,
            standard: className,
            attendanceDate: DateTime.now().formattedGatePassDate() ?? '',
            attendanceTime: DateTime.now().formattedAttendanceTime(),
            month: DateTime.now().month,
            year: DateTime.now().year,
            period: activePeriod,
            attendanceMode:
                attendanceMode ??
                (students.isNotEmpty ? students.first.attendanceMode : null),
          ),
        );
      } else {
        final studentMap = {for (var s in attendance.students) s.id: s};
        for (var student in students) {
          studentMap[student.id] = student;
        }
        final updatedStudents = studentMap.values.toList();
        await box.put(
          key,
          attendance.copyWith(
            students: updatedStudents,
            attendanceMode: attendanceMode ?? attendance.attendanceMode,
          ),
        );
      }
    } catch (error, stack) {
      _apiClient.logCrash('updateAttendanceBulk()', error, stack);
    } finally {
      notifyListeners();
    }
  }

  Future<void> createAttendance(BuildContext context) async {
    final box = HiveService.createAttendanceBox;
    final keys = box.keys.toList();
    if (keys.isEmpty) return;

    AppUtils.showLoadingDialog(context, 'Updating attendance...Please wait...');
    try {
      bool hasError = false;
      bool isSuccess = false;
      String? errorMessage;
      String? successMessage;

      for (final key in keys) {
        final data = box.get(key);
        if (data == null) continue;

        final response = await _apiClient.post(
          '/v1.0/createAttendance',
          data: createAttendanceToJson(data),
        );

        if (response.statusCode == 200) {
          await box.delete(key);
          successMessage =
              response.data['message'] ?? 'Attendance submitted successfully.';
          isSuccess = true;
        } else if (response.statusCode == 202) {
          hasError = true;
          errorMessage =
              response.data['message'] ??
              'Attendance has already been submitted for this date.';
        } else {
          hasError = true;
          final responseData = response.data;
          if (responseData is Map && responseData['err'] == true) {
            errorMessage =
                responseData['message'] ?? 'Failed to save attendance';
          } else {
            errorMessage =
                (responseData is Map ? responseData['message'] : null) ??
                'Failed to save attendance';
          }
        }
      }

      if (context.mounted) {
        if (hasError && errorMessage != null) {
          AppUtils.showErrorMessage(context, errorMessage);
        } else if (successMessage != null) {
          AppUtils.showSucessMessage(context, successMessage);
        }
      }

      if (isSuccess && !hasError) {
        ongoingAttendanceKey = null;
        ongoingAttendance = null;
        if (context.mounted) {
          context.go('/');
        }
      }
    } catch (error, stack) {
      _apiClient.logCrash('/createAttendance', error, stack);
    } finally {
      if (context.mounted) {
        AppUtils.hideLoadingDialog(context);
      }
    }
  }

  Future<bool> checkAttendanceExists({
    required BuildContext context,
    required int classId,
    required String section,
    required String date,
    required String period,
  }) async {
    try {
      final response = await _apiClient.post(
        '/v1.0/getClassAttendancesByDate',
        data: {
          'ClassId': classId,
          'Section': section,
          'AttendanceDate': date,
          'Period': period.isEmpty ? '1' : period,
          'Source': 'adminapp',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          if (data.isEmpty) {
            return false;
          } else {
            if (context.mounted) {
              AppUtils.showErrorMessage(
                context,
                'Attendance has already been submitted for this section.',
              );
            }
            return true;
          }
        } else if (data is Map && data['err'] == true) {
          if (context.mounted) {
            AppUtils.showErrorMessage(
              context,
              data['message'] ?? 'Failed to check attendance status.',
            );
          }
          return true;
        }
      }

      if (context.mounted) {
        AppUtils.showErrorMessage(
          context,
          'Failed to check attendance status. Please try again.',
        );
      }
      return true;
    } catch (error, stack) {
      _apiClient.logCrash('/getClassAttendancesByDate check', error, stack);
      return true;
    }
  }

  Future<void> getAttendance({
    required BuildContext context,
    required int classId,
    required String section,
    required String date,
  }) async {
    loading = true;
    notifyListeners();
    try {
      await _apiClient.post(
        '/v1.0/getClassAttendancesByDate',
        data: {'ClassId': classId, 'Section': section, 'AttendanceDate': date},
      );

      if (context.mounted) {
        AppUtils.showSucessMessage(context, 'Attendance updated successfully!');
      }
    } catch (error, stack) {
      _apiClient.logCrash('/getClassAttendancesByDate', error, stack);
    } finally {
      if (context.mounted) {
        AppUtils.hideLoadingDialog(context);
      }
    }
  }

  Future<void> toggleStudentAttendance(AttendanceStudent student) async {
    try {
      final box = HiveService.createAttendanceBox;
      if (ongoingAttendanceKey == null) return;
      final attendance = box.get(ongoingAttendanceKey);
      if (attendance == null) return;

      final index = attendance.students.indexWhere((e) => e.id == student.id);
      if (index != -1) {
        final updatedStudents = List<AttendanceStudent>.from(
          attendance.students,
        );
        updatedStudents[index] = student.copyWith(
          isPresent: !student.isPresent,
        );
        await box.put(
          ongoingAttendanceKey!,
          attendance.copyWith(students: updatedStudents),
        );
        notifyListeners();
      }
    } catch (error, stack) {
      _apiClient.logCrash('toggleStudentAttendance()', error, stack);
    }
  }
}
