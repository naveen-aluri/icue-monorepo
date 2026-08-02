import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../models/create_attendance.dart';
import '../services/api_client.dart';
import '../services/hive_service.dart';
import '../utils/app_utils.dart';

@lazySingleton
class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider({required this._apiClient});

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
      if (ongoingAttendanceKey == null) {
        ongoingAttendanceKey ??= key;
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
          ),
        );
      } else {
        final index = attendance.students.indexWhere((e) => e.id == student.id);
        if (index != -1) {
          attendance.students[index] = student;
        } else {
          attendance.students.add(student);
        }
        await box.put(key, attendance);
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('updateAttendance()', error, stack);
      }
    } finally {}
  }

  Future<void> createAttendance(BuildContext context) async {
    final attendanceList = HiveService.createAttendanceBox.values.toList();
    AppUtils.showLoadingDialog(context, 'Updating attendance...Please wait...');
    try {
      for (var i = 0; i < attendanceList.length; i++) {
        final data = attendanceList[i];
        await _apiClient.post(
          '/v1.0/createAttendance',
          data: createAttendanceToJson(data),
        );
        await HiveService.createAttendanceBox.deleteAt(i);
      }

      AppUtils.showSucessMessage(context, 'Attendance updated successfully!');
      context.go('/');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/createAttendance', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
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
}
