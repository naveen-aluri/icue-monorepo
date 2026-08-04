import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../models/driver_document.dart';
import '../models/drivers.dart';
import '../services/api_client.dart';
import '../services/hive_service.dart';
import '../utils/app_utils.dart';

@lazySingleton
class DriverProvider extends ChangeNotifier {
  DriverProvider(this._apiClient);

  Map<String, Docs?> driverDocs = {};
  List<Driver> drivers = [];
  bool loading = false;

  final ApiClient _apiClient;

  Future<void> getDrivers() async {
    // if (drivers.isNotEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post('/v1.0/getDrivers');
      drivers = List<Driver>.from(
        (response.data as List).map(
          (x) => Driver.fromJson(x as Map<String, dynamic>),
        ),
      );
      drivers.sort((a, b) => a.firstName.compareTo(b.firstName));
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getDrivers', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addDriver(BuildContext context, AddDriver driver) async {
    AppUtils.showLoadingDialog(context, 'Submitting driver details...');
    try {
      await _apiClient.post('/v1.0/createDriver', data: driver.toJson());
      AppUtils.showSucessMessage(context, 'Driver added successfully');
      await getDrivers();
      context.go('/layout.drivers');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/createDriver', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> updateDriver(BuildContext context, AddDriver driver) async {
    AppUtils.showLoadingDialog(context, 'Updating driver details...');
    try {
      await _apiClient.post('/v1.0/updateDriver', data: driver.toJson());
      AppUtils.showSucessMessage(context, 'Driver updated successfully');
      await getDrivers();
      context.go('/layout.drivers/driver-info?driverId=${driver.id}');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/updateDriver', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> deleteDriver(BuildContext context, int driverId) async {
    AppUtils.showLoadingDialog(context, 'Deleting driver...');
    try {
      final userInfo = HiveService.userInfoBox.values.first;
      await _apiClient.post(
        '/v1.0/deleteDrivers',
        data: {
          'OrganizationId': userInfo.organizationId,
          'ZoneId': userInfo.zoneId,
          'BranchId': userInfo.branchId,
          'Ids': [driverId],
        },
      );
      drivers.removeWhere((element) => element.id == driverId);
      notifyListeners();
      AppUtils.showSucessMessage(context, 'Driver deleted successfully');
      context.go('/layout.drivers');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/deleteDrivers', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> getDriverDocs(int driverId, String type) async {
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getDriverDocs',
        data: {'Target': 'Driver', 'RecordId': driverId, 'Type': type},
      );
      final data = DriverDocument.fromJson(
        response.data as Map<String, dynamic>,
      );
      driverDocs[type] = data.docs;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getDriverDocs/$type', error, stack);
      }
      driverDocs[type] = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDriverDoc(
    BuildContext context,
    int driverId,
    String type,
    String docId,
  ) async {
    AppUtils.showLoadingDialog(context, 'Deleting driver...');
    try {
      await _apiClient.post(
        '/v1.0/deleteDriverDocs',
        data: {
          'Target': 'Driver',
          'RecordId': driverId,
          'Type': type,
          'DocumentId': docId,
        },
      );
      await getDriverDocs(driverId, type);
      AppUtils.showSucessMessage(context, 'Document deleted successfully');
      Navigator.of(context, rootNavigator: true).pop();
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/deleteDriverDocs', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> uploadDriverDocs(
    BuildContext context,
    int driverId,
    String type,
    String docId,
    XFile file,
    String fileKey,
  ) async {
    AppUtils.showLoadingDialog(context, 'Uploading document...');
    final formData = FormData.fromMap({
      'Source': 'adminapp',
      'Type': type,
      'RecordId': driverId,
      'Target': 'Driver',
      fileKey: MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: file.name,
        contentType: file.name.endsWith('.pdf')
            ? DioMediaType('application', 'pdf')
            : DioMediaType('image', file.name.split('.').last.toLowerCase()),
      ),
    });
    try {
      await _apiClient.post('/v1.0/uploadDriverDocs', data: formData);
      await getDriverDocs(driverId, type);
      AppUtils.showSucessMessage(context, 'Document uploaded successfully');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/uploadDriverDocs', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }
}
