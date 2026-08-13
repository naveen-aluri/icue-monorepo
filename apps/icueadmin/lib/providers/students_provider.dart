import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';

import '../models/standards.dart';
import '../models/student.dart';
import '../services/api_client.dart';
import '../services/hive_service.dart';
import 'attendance_provider.dart';

@lazySingleton
class StudentsProvider extends ChangeNotifier {
  StudentsProvider(this._apiClient);

  List<StudentData> attendanceStudents = [];
  bool loading = false, studentsLoading = false;
  List<Standards> standards = [];
  List<StudentData> students = [];
  bool hasNextPage = true;
  Metadatum? metaData;
  Map<int, List<double>> studentEmbeddings = {};

  final ApiClient _apiClient;

  void reset() {
    students.clear();
    attendanceStudents.clear();
    studentEmbeddings.clear();
    notifyListeners();
  }

  Future<void> getStandards(BuildContext context) async {
    students.clear();
    // standards = HiveService.standardsBox.values.toList();
    // if (standards.isNotEmpty) {
    //   notifyListeners();
    //   return;
    // }
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post('/v1.0/getStandards');
      standards = List<Standards>.from(
        (response.data as List).map(
          (x) => Standards.fromJson(x as Map<String, dynamic>),
        ),
      );
      await HiveService.standardsBox.clear();
      await HiveService.standardsBox.addAll(standards);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getStandards', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getStudents(
    BuildContext context,
    int classId,
    List<String> sections, {
    bool forAttendance = false,
    required int pageNo,
  }) async {
    if (pageNo == 1) {
      students.clear();
      hasNextPage = true;
      studentsLoading = true;
    }
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v2.0/getStudents',
        data: {
          'ClassId': classId,
          'Sections': sections,
          'PageNumber': pageNo,
          'PageSize': 100,
        },
      );
      final data = List<Student>.from(
        (response.data as List).map(
          (x) => Student.fromJson(x as Map<String, dynamic>),
        ),
      );
      final newStudents = data[0].data;
      students.addAll(newStudents);
      metaData = data[0].metadata.isNotEmpty ? data[0].metadata[0] : metaData;
      hasNextPage = (metaData?.total ?? 0) > students.length;

      if (forAttendance) {
        final attendanceProvider = Provider.of<AttendanceProvider>(
          context,
          listen: false,
        );
        final attendance = await attendanceProvider.getOngoingAttendance();
        if (attendance != null &&
            attendance.classId == classId &&
            attendance.section == sections.first) {
          final filtered = newStudents.where(
            (e) => attendance.students.indexWhere((f) => f.id == e.id) == -1,
          );
          attendanceStudents.addAll(filtered);
        } else {
          attendanceStudents = List.from(students);
        }
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getStudents', error, stack);
      }
    } finally {
      studentsLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchStudent({
    required BuildContext context,
    required String search,
    int? classId,
    List<String>? sections,
  }) async {
    if (search.isEmpty) {
      students.clear();
      notifyListeners();
      return;
    }
    studentsLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v2.0/searchStudent',
        data: {'searchText': search, 'ClassId': classId, 'Sections': sections},
      );
      students = List<StudentData>.from(
        (response.data as List).map(
          (x) => StudentData.fromJson(x as Map<String, dynamic>),
        ),
      );
      students.sort((a, b) {
        final rollNoA = int.tryParse(a.rollNo) ?? 0;
        final rollNoB = int.tryParse(b.rollNo) ?? 0;
        return rollNoA.compareTo(rollNoB);
      });
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/searchStudent', error, stack);
      }
    } finally {
      studentsLoading = false;
      notifyListeners();
    }
  }

  Future<void> getStudentEmbeddings({required List<int> studentIds}) async {
    final user = HiveService.userInfoBox.values.firstOrNull;
    if (user == null) return;

    try {
      final response = await _apiClient.post(
        '/v2.0/getStuEmbeddings',
        data: {
          'OrganizationId': user.organizationId,
          'ZoneId': user.zoneId,
          'BranchId': user.branchId,
          'StudentIds': studentIds,
        },
      );

      if (response.data != null && response.data['err'] == false) {
        final data = response.data['data'] as List?;
        if (data != null) {
          for (var item in data) {
            final studentId = item['StudentId'] as int?;
            final embeddingList = item['Embedding'] as List?;
            if (studentId != null && embeddingList != null) {
              studentEmbeddings[studentId] = List<double>.from(
                embeddingList.map((e) => (e as num).toDouble()),
              );
            }
          }
        }
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getStuEmbeddings', error, stack);
      }
    } finally {
      notifyListeners();
    }
  }
}
