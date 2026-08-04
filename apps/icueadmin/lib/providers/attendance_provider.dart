import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

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

  Future<CreateAttendance?> getOngoingAttendance() async {
    try {
      final box = HiveService.createAttendanceBox;
      final ongoingAttendanceKeys = box.keys.toList();
      if (ongoingAttendanceKeys.isNotEmpty) {
        ongoingAttendanceKey = ongoingAttendanceKeys.first;
        ongoingAttendance = box.get(ongoingAttendanceKey);
        return box.get(ongoingAttendanceKey);
      } else {
        ongoingAttendanceKey = null;
        ongoingAttendance = null;
      }
      return null;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('getOngoingAttendance()', error, stack);
      }
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteOngoingAttendance(BuildContext context) async {
    try {
      await HiveService.createAttendanceBox.delete(ongoingAttendanceKey);
      ongoingAttendanceKey = null;
      ongoingAttendance = null;
      Navigator.of(context, rootNavigator: true).pop();
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('deleteOngoingAttendance()', error, stack);
      }
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
      final key = '${DateTime.now().formattedDate()}-$classId-$section';
      if (ongoingAttendanceKey != key) {
        ongoingAttendanceKey = key;
        notifyListeners();
      }

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
            period: period,
            attendanceMode: student.attendanceMode,
          ),
        );
      } else {
        final index = attendance.students.indexWhere((e) => e.id == student.id);
        if (index != -1) {
          attendance.students[index] = student;
        } else {
          attendance.students.add(student);
        }
        await box.put(
          key,
          CreateAttendance(
            source: attendance.source,
            students: attendance.students,
            classId: attendance.classId,
            section: attendance.section,
            standard: attendance.standard,
            attendanceDate: attendance.attendanceDate,
            attendanceTime: attendance.attendanceTime,
            month: attendance.month,
            year: attendance.year,
            period: attendance.period,
            attendanceMode: attendance.attendanceMode ?? student.attendanceMode,
          ),
        );
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('updateAttendance()', error, stack);
      }
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
      final key = '${DateTime.now().formattedDate()}-$classId-$section';
      if (ongoingAttendanceKey != key) {
        ongoingAttendanceKey = key;
      }

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
            period: period,
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
          CreateAttendance(
            source: attendance.source,
            students: updatedStudents,
            classId: attendance.classId,
            section: attendance.section,
            standard: attendance.standard,
            attendanceDate: attendance.attendanceDate,
            attendanceTime: attendance.attendanceTime,
            month: attendance.month,
            year: attendance.year,
            period: attendance.period,
            attendanceMode: attendanceMode ?? attendance.attendanceMode,
          ),
        );
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('updateAttendanceBulk()', error, stack);
      }
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

      if (hasError && errorMessage != null) {
        AppUtils.showErrorMessage(context, errorMessage);
      } else if (successMessage != null) {
        AppUtils.showSucessMessage(context, successMessage);
      }

      if (isSuccess && !hasError) {
        ongoingAttendanceKey = null;
        ongoingAttendance = null;
        if (context.mounted) {
          context.go('/');
        }
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/createAttendance', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
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
          'Period': period,
          'Source': 'adminapp',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          if (data.isEmpty) {
            return false;
          } else {
            AppUtils.showErrorMessage(
              context,
              'Attendance has already been submitted for this section.',
            );
            return true;
          }
        } else if (data is Map && data['err'] == true) {
          AppUtils.showErrorMessage(
            context,
            data['message'] ?? 'Failed to check attendance status.',
          );
          return true;
        }
      }

      AppUtils.showErrorMessage(
        context,
        'Failed to check attendance status. Please try again.',
      );
      return true;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getClassAttendancesByDate check', error, stack);
      }
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

      AppUtils.showSucessMessage(context, 'Attendance updated successfully!');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getClassAttendancesByDate', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
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
        attendance.students[index] = AttendanceStudent(
          id: student.id,
          name: student.name,
          rollNo: student.rollNo,
          admissionNumber: student.admissionNumber,
          isPresent: !student.isPresent,
          uid: student.uid,
          attendanceMode: student.attendanceMode,
        );
        await box.put(ongoingAttendanceKey!, attendance);
        notifyListeners();
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('toggleStudentAttendance()', error, stack);
      }
    }
  }
}
