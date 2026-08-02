import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../services/api_client.dart';
import '../services/hive_service.dart';
import '../utils/app_utils.dart';

@lazySingleton
class AlcoholTestProvider extends ChangeNotifier {
  AlcoholTestProvider({required this._apiClient});

  bool loading = false;

  final ApiClient _apiClient;

  Future<bool> submitAlcoholTestForm(
    BuildContext context, {
    required int personId,
    required String personName,
    required dynamic personMobile,
    required num reading,
    required String status,
    XFile? file,
  }) async {
    AppUtils.showLoadingDialog(context, 'Submitting... Please wait...');
    try {
      final user = HiveService.userInfoBox.values.firstOrNull;

      final map = {
        'Source': 'adminapp',
        'OrganizationId': user?.organizationId,
        'ZoneId': user?.zoneId,
        // 'BranchId': user?.branchId,
        'PrsnType': 'DRIVER',
        'PrsnId': personId,
        'PrsnName': personName,
        'PrsnMobile': personMobile,
        'AlcoholTestReading': reading,
        'AlcoholTest': status,
      };

      if (file != null) {
        final bytes = await file.readAsBytes();
        map['Images'] = MultipartFile.fromBytes(
          bytes,
          filename: file.name,
          contentType: DioMediaType(
            'image',
            file.name.split('.').last.toLowerCase(),
          ),
        );
      }

      final formData = FormData.fromMap(map);

      final response = await _apiClient.post(
        '/v2.0/submitPrsnAlcoholTest',
        data: formData,
      );
      if (response.statusCode == 200) {
        AppUtils.showSucessMessage(context, 'Form submitted successfully!');
        Navigator.pop(context);
      } else {
        AppUtils.showErrorMessage(
          context,
          response.data['message'] ??
              'Failed to submit form. Please try again.',
        );
      }

      return true;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/submitPrsnAlcoholTest', error, stack);
      }
      AppUtils.showErrorMessage(
        context,
        'Something went wrong... Please try again!',
      );
      return false;
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }
}
