import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../models/gatepass_requests.dart';
import '../models/gatepass_type.dart';
import '../models/student.dart';
import '../services/api_client.dart';
import '../utils/app_utils.dart';

@lazySingleton
class GatePassProvider extends ChangeNotifier {
  GatePassProvider({required this._apiClient});

  List<GatePassType> gatepassTypes = [];
  bool loading = false;
  List<GatePassRequest> requests = [];

  final ApiClient _apiClient;

  Future<bool> issueGatePass(
    BuildContext context,
    StudentData student,
    String gatePassType,
    String personType,
  ) async {
    AppUtils.showLoadingDialog(context, 'Issuing Gate Pass...Please wait...');
    try {
      await _apiClient.post(
        '/v1.0/createGatePass',
        data: {
          'ClassId': student.classId,
          'PersonId': student.id,
          'Class': student.standard,
          'Section': student.section,
          'Name': student.name,
          'UniqueNo': student.admissionNumber,
          'IsHostelite': false,
          'HostelType': 'InCampus',
          'GatePassDate': DateTime.now().formattedGatePassDate(),
          'GatePassType': gatePassType,
          'RFID': '',
          'PersonType': personType,
        },
      );
      return true;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/createGatePass', error, stack);
      }
      return false;
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> getGatePassTypes() async {
    if (gatepassTypes.isNotEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post('/v1.0/getGatePassTypes');
      final data = GatePassTypes.fromJson(
        response.data as Map<String, dynamic>,
      );
      gatepassTypes = data.data;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getGatePassTypes', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateGatePassStatus({
    required BuildContext context,
    required int id,
    required int personId,
    required String date,
    required String status,
  }) async {
    AppUtils.showLoadingDialog(context, 'Updating status...Please wait...');
    try {
      await _apiClient.post(
        '/v1.0/approveGPRequest',
        data: {
          'Id': id,
          'PersonId': personId,
          'RequestDate': date,
          'Status': status,
        },
      );
      final msg = status == 'APPROVE' ? 'Approved' : 'Rejected';
      AppUtils.showSucessMessage(context, 'Gate Pass $msg successfully!');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/approveGPRequest', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> getGatePassRequests(String date) async {
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getRequestedGatePass',
        data: {'Date': date},
      );
      final data = GatePassRequests.fromJson(
        response.data as Map<String, dynamic>,
      );
      requests = data.data;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getRequestedGatePass', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
