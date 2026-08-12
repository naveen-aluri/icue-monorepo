import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/pref_service.dart';
import '../models/embedding_request.dart';
import '../models/standards_model.dart';
import '../models/student_embeddings_response.dart';
import '../models/student_model.dart';

@lazySingleton
class StudentService {
  final ApiClient _apiClient;
  final PrefService _prefService;

  StudentService(this._apiClient, this._prefService);

  Future<StudentPhotosResponse> getStudentPhotos({
    required int classId,
    required int pageNumber,
    required int pageSize,
    bool? studentPhoto, // true, false, or null (omitted)
  }) async {
    final orgId = _prefService.orgId;
    final zoneId = _prefService.zoneId;
    final branchId = _prefService.branchId;

    final requestBody = {
      'OrganizationId': orgId,
      'ZoneId': zoneId,
      'BranchId': branchId,
      'ClassId': classId,
      if (studentPhoto != null) 'StudentPhoto': studentPhoto ? 'true' : 'false',
      'PageNumber': pageNumber,
      'PageSize': pageSize,
      'Source': 'App',
    };

    try {
      final response = await _apiClient.post(
        '/api/v1.0/getStudentPhotos',
        data: requestBody,
      );

      if (response.data['data'].isEmpty) {
        throw Exception('No students found');
      }

      return StudentPhotosResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateStuEmbeddings(EmbeddingRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v2.0/updateStuEmbeddings',
        data: request.toJson(),
      );

      // Let's check the response structure. Usually it will have some indicator.
      // We will parse it or check if status is 200 and err is false.
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['err'] == false ||
              data['error'] == false ||
              data['message'] == 'success';
        }
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentEmbeddingsResponse> getStuEmbeddings({
    List<int>? studentIds,
  }) async {
    final orgId = _prefService.orgId;
    final zoneId = _prefService.zoneId;
    final branchId = _prefService.branchId;

    final requestBody = {
      'OrganizationId': orgId,
      'ZoneId': zoneId,
      'BranchId': branchId,
      if (studentIds != null && studentIds.isNotEmpty) 'StudentIds': studentIds,
    };

    try {
      final response = await _apiClient.post(
        '/api/v2.0/getStuEmbeddings',
        data: requestBody,
      );

      return StudentEmbeddingsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StandardModel>> getStandards() async {
    try {
      final response = await _apiClient.post('/api/v1.0/getStandards');
      final data = standardModelFromJson(jsonEncode(response.data));
      return data.where((e) => e.standardType == 'STUDENT').toList();
    } catch (e) {
      rethrow;
    }
  }
}
