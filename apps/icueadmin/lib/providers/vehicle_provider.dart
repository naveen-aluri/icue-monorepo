import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';

import '../dialogs/failed_vehicle_cleaning_dialog.dart';
import '../models/add_vehicle.dart';
import '../models/boarding_types.dart';
import '../models/complaint_categories.dart';
import '../models/complaint_data.dart';
import '../models/complaints_dashboard.dart';
import '../models/fuel_storage.dart';
import '../models/meta_data.dart';
import '../models/routes.dart';
import '../models/vehicle.dart';
import '../models/vehicle_arrivals.dart';
import '../models/vehicle_cleaning_parts.dart';
import '../models/vehicle_cleaning_success.dart';
import '../models/vehicle_data.dart';
import '../models/vehicle_docs.dart';
import '../models/vehicle_slots.dart' hide VehicleDetails;
import '../models/vehicle_slots_modified.dart';
import '../pages/webview_page.dart';
import '../services/api_client.dart';
import '../services/hive_service.dart';
import '../utils/app_utils.dart';
import 'students_provider.dart';

@lazySingleton
class VehicleProvider extends ChangeNotifier {
  VehicleProvider({required this._apiClient});

  bool complainsLoading = false;
  List<ComplaintAction> complaintActions = [];
  List<ComplaintCategory> complaintCategories = [];
  List<Complaint> complaints = [];
  List<ComplaintDashboard> complaintsDashboard = [];
  String? error;
  bool loading = false;
  Metadata? metadata;
  List<Routee> _routes = [];
  List<Routee> get routes => List.unmodifiable(_routes);
  List<VehicleArrival> _vehicleArrivals = [];
  List<VehicleArrival> get vehicleArrivals =>
      List.unmodifiable(_vehicleArrivals);
  List<CleaningParts> vehicleCleaningParts = [];
  Map<String, Docs?> vehicleDocs = {};
  VehicleSlotsModified? vehicleSlots;
  List<VehicleData> vehiclesData = [];
  List<BoardingType> boardingTypes = [];

  final ApiClient _apiClient;

  void clearData() {
    _routes.clear();
    notifyListeners();
  }

  Future<void> getStatus() async {
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getVehicleStartStatusReport',
      );
      if (kDebugMode) {
        log(jsonEncode(response.data));
      }
      final data = VehicleSlots.fromJson(response.data as Map<String, dynamic>);

      vehicleSlots = VehicleSlotsModified(
        activeSlot: data.activeSlot,
        slots: data.slotNames,
        status: VehicleStatus(
          slot1: Slot1Class(
            notStarted: data.slot1NotStarted,
            inprogress: data.slot1InProgress,
            completed: data.slot1Completed,
          ),
          slot2: Slot1Class(
            notStarted: data.slot2NotStarted,
            inprogress: data.slot2InProgress,
            completed: data.slot2Completed,
          ),
          slot3: Slot1Class(
            notStarted: data.slot3NotStarted,
            inprogress: data.slot3InProgress,
            completed: data.slot3Completed,
          ),
        ),
      );
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVehicleStartStatusReport', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateSocketData(dynamic response) async {
    try {
      final data = VehicleSlots.fromJson(response);

      vehicleSlots = VehicleSlotsModified(
        activeSlot: data.activeSlot,
        slots: data.slotNames,
        status: VehicleStatus(
          slot1: Slot1Class(
            notStarted: data.slot1NotStarted,
            inprogress: data.slot1InProgress,
            completed: data.slot1Completed,
          ),
          slot2: Slot1Class(
            notStarted: data.slot2NotStarted,
            inprogress: data.slot2InProgress,
            completed: data.slot2Completed,
          ),
          slot3: Slot1Class(
            notStarted: data.slot3NotStarted,
            inprogress: data.slot3InProgress,
            completed: data.slot3Completed,
          ),
        ),
      );
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('updateSocketData()', error, stack);
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> getRoutesAndPoints(Mode? mode) async {
    try {
      _routes.clear();
      loading = true;
      notifyListeners();
      final response = await _apiClient.post(
        '/v1.0/getRoutesAndPoints',
        data: {
          ...(mode != null ? {'Mode': modeValues.reverse[mode]} : {}),
        },
      );
      final data = Routes.fromJson(response.data as Map<String, dynamic>);

      _routes = data.route;
      // if (mode != null) {
      //   await routeBox.put(mode.name, data.route);
      // } else {
      //   await routeBox.put('All', data.route);
      // }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getRoutesAndPoints', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> changeRoute(
    BuildContext context, {
    required Mode mode,
    required int studentId,
    required int classId,
    required List<String> sections,
    int? existingRouteId,
    int? route,
    String? point,
  }) async {
    AppUtils.showLoadingDialog(context, 'Updating... Please wait...');
    try {
      final data = {
        'IsInTransport': existingRouteId != null ? 'yes' : 'no',
        'ChangeMode': modeValues.reverse[mode],
        'StudentId': studentId,
        ...(mode == Mode.PICKUP
            ? {
                ...(existingRouteId != null
                    ? {'PickupRouteId': existingRouteId}
                    : {}),
                'TargetPickupRoute': route,
                'TargetPickPoint': point,
              }
            : {
                ...(existingRouteId != null
                    ? {'DropRouteId': existingRouteId}
                    : {}),
                'TargetDropRoute': route,
                'TargetDropPoint': point,
              }),
      };

      final response = await _apiClient.post(
        '/v1.0/changeStudentRoute',
        data: data,
      );
      if (response.data['err'] == true) {
        AppUtils.showErrorMessage(context, response.data['message']);
      } else {
        await Provider.of<StudentsProvider>(
          context,
          listen: false,
        ).getStudents(context, classId, sections, pageNo: 1);
        AppUtils.showSucessMessage(context, response.data['message']);
      }
      return response.data['err'] == false;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/changeStudentRoute', error, stack);
      }
      return false;
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<bool> changeBothRoutes(
    BuildContext context, {
    int? existingPickupRouteId,
    int? existingDropRouteId,
    String? existingPickupPoint,
    required int studentId,
    required int classId,
    required List<String> sections,
    required int pickupRoute,
    required String pickupPoint,
    required int dropRoute,
    required String dropPoint,
  }) async {
    AppUtils.showLoadingDialog(context, 'Updating... Please wait...');
    try {
      // Prepare request data
      final pickupData = {
        'IsInTransport': existingPickupRouteId != null ? 'yes' : 'no',
        'StudentId': studentId,
        'ChangeMode': 'Pickup',
        ...(existingPickupRouteId != null
            ? {'PickupRouteId': existingPickupRouteId}
            : {}),
        'TargetPickupRoute': pickupRoute,
        'TargetPickPoint': pickupPoint,
      };

      final dropData = {
        'IsInTransport': existingDropRouteId != null ? 'yes' : 'no',
        'StudentId': studentId,
        'ChangeMode': 'Drop',
        ...(existingDropRouteId != null
            ? {'DropRouteId': existingDropRouteId}
            : {}),
        'TargetDropRoute': dropRoute,
        'TargetDropPoint': dropPoint,
      };

      // Execute the first API call
      final pickupResponse = await _apiClient.post(
        '/v1.0/changeStudentRoute',
        data: pickupData,
      );
      if (pickupResponse.data['err'] == true) {
        AppUtils.showErrorMessage(context, pickupResponse.data['message']);
        return false;
      }

      await Future.delayed(const Duration(seconds: 2));

      // Execute the second API call
      final dropResponse = await _apiClient.post(
        '/v1.0/changeStudentRoute',
        data: dropData,
      );
      if (dropResponse.data['err'] == true) {
        AppUtils.showErrorMessage(context, dropResponse.data['message']);

        // Attempt to revert the first change if the second fails
        await _apiClient.post(
          '/v1.0/changeStudentRoute',
          data: {
            'IsInTransport': existingPickupRouteId != null ? 'yes' : 'no',
            'StudentId': studentId,
            'ChangeMode': 'Pickup',
            'PickupRouteId': existingPickupRouteId, // Swap to revert
            'TargetPickupRoute': existingPickupRouteId,
            'TargetPickPoint': existingPickupPoint, // Adjust as necessary
          },
        );

        return false;
      } else {
        await Provider.of<StudentsProvider>(
          context,
          listen: false,
        ).getStudents(context, classId, sections, pageNo: 1);
        AppUtils.showSucessMessage(context, dropResponse.data['message']);
      }

      return true;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/changeStudentRoute', error, stack);
      }
      AppUtils.showErrorMessage(
        context,
        'Something went wrong... Please try again...',
      );
      return false;
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> getLiveTrackUrl(
    BuildContext context, {
    required int routeDetailsId,
    required String routeNo,
    required Mode mode,
  }) async {
    AppUtils.showLoadingDialog(context, 'Processing... Please wait...');
    try {
      final response = await _apiClient.post(
        '/v1.0/getLiveTrackUrl',
        data: {
          'RouteDetailsId': routeDetailsId,
          'RouteNo': routeNo,
          'Mode': modeValues.reverse[mode],
        },
      );
      AppUtils.hideLoadingDialog(context);
      if (response.data['err'] == false) {
        final trackLink = response.data['data']['trackLink'];
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WebviewPage(url: trackLink, title: '$routeNo - Live Tracking'),
          ),
        );
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getLiveTrackUrl', error, stack);
      }
      AppUtils.hideLoadingDialog(context);
      AppUtils.showSucessMessage(
        context,
        'Something went wrong... Please try again...',
      );
    }
  }

  Future<void> getVehicles() async {
    // if (HiveService.vehicleBox.values.isNotEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final userInfo = HiveService.userInfoBox.values.first;
      final response = await _apiClient.post(
        '/v1.0/getVehiclesNumbersByBranch',
        data: {
          'Number': userInfo.organizationId,
          'ZoneId': userInfo.zoneId,
          'BranchId': userInfo.branchId,
          'OrganizationId': userInfo.organizationId,
        },
      );
      final data = List<Vehicle>.from(
        (response.data as List).map(
          (x) => Vehicle.fromJson(x as Map<String, dynamic>),
        ),
      );
      for (final e in data) {
        if (e.fuelType != null) {
          HiveService.fuelPriceBox.put(e.fuelType, e.price ?? '');
        }
      }
      await HiveService.vehicleBox.clear();
      await HiveService.vehicleBox.addAll(data);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVehiclesNumbersByBranch', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getFuelStorages(String? fuelType) async {
    loading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/v1.0/getFuelStorages',
        data: {'FuelType': fuelType},
      );
      final data = FuelStorage.fromJson(response.data as Map<String, dynamic>);

      final storageItems = data.data
          .expand(
            (e) => e.items.map(
              (f) => StorageItem(
                capacity: f.capacity,
                fuelPrice: f.fuelPrice,
                fuelType: f.fuelType,
                name: f.name,
                type: e.type,
              ),
            ),
          )
          .toList();

      await HiveService.fuelStorageBox.clear();
      if (data.toFill ?? false) {
        await HiveService.fuelStorageBox.addAll(storageItems);
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getFuelStorages', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getVehicleDetails(String vehicleNumber) async {
    // if (HiveService.vehicleDetailsBox.containsKey(vehicleNumber)) return;
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getVehicleByNumber',
        data: {'Number': vehicleNumber},
      );
      final data = VehicleDetails.fromJson(
        response.data as Map<String, dynamic>,
      );
      HiveService.vehicleDetailsBox.put(vehicleNumber, data);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVehicleByNumber', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addFuelReading({
    required BuildContext context,
    required String vehicleNumber,
    required String km,
    required String fuelLiters,
    required XFile file,
  }) async {
    AppUtils.showLoadingDialog(context, 'Updating... Please wait...');
    try {
      // final branchId = HiveService.zonalBranch.get('selected')?.id;
      final formData = FormData.fromMap({
        'Source': 'adminapp',
        // 'BranchId': branchId,
        'VehicleNumber': vehicleNumber,
        'KM': km,
        'FuelAmount': fuelLiters,
        'File': MultipartFile.fromBytes(
          await file.readAsBytes(),
          filename: file.name,
        ),
      });

      final response = await _apiClient.post(
        '/v1.0/addVehicleFuelReading',
        data: formData,
      );
      if (response.data['err'] == false) {
        AppUtils.showSucessMessage(context, 'Data submitted successfully!');
        Navigator.pop(context);
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/addVehicleFuelReading', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<bool> updateFuelPrice({
    required BuildContext context,
    required String fuelType,
    required String price,
  }) async {
    AppUtils.showLoadingDialog(context, 'Updating... Please wait...');
    try {
      final response = await _apiClient.post(
        '/v1.0/updateFuelPrice',
        data: {'FuelType': fuelType, 'Price': price},
      );
      if (response.data['err'] == false) {
        await HiveService.fuelPriceBox.put(fuelType, price);
        AppUtils.showSucessMessage(context, 'Fuel Price updated successfully!');
        return true;
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
        return false;
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/updateFuelPrice', error, stack);
      }
      return false;
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<bool> changeRouteTime({
    required BuildContext context,
    required String time,
    required Mode mode,
    required String changeMode,
    required List<int> selected,
  }) async {
    AppUtils.showLoadingDialog(context, 'Updating... Please wait...');
    try {
      final response = await _apiClient.post(
        '/v2.0/updateStartTimeForRoutes',
        data: {
          'RouteStartTime': time,
          'Mode': modeValues.reverse[mode],
          'ChangeMode': changeMode,
          ...(changeMode == 'ALL' ? {} : {'RouteIds': selected}),
        },
      );
      if (response.statusCode == 200) {
        AppUtils.showSucessMessage(context, 'Route time updated successfully!');
        Navigator.pop(context);
        Navigator.pop(context);
        return true;
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
        return false;
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/updateStartTimeForRoutes', error, stack);
      }
      return false;
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> getVehiclesData() async {
    loading = true;
    notifyListeners();
    try {
      final userInfo = HiveService.userInfoBox.values.first;
      final response = await _apiClient.post(
        '/v1.0/getVehicles',
        data: {
          'OrganizationId': userInfo.organizationId,
          'BranchId': userInfo.branchId,
          'ZoneId': userInfo.zoneId,
        },
      );
      final data = List<VehicleData>.from(
        (response.data as List).map(
          (x) => VehicleData.fromJson(x as Map<String, dynamic>),
        ),
      );
      vehiclesData = data;
      vehiclesData.sort((a, b) => a.number!.compareTo(b.number!));
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVehicles', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addVehicle(BuildContext context, AddVehicle vehicle) async {
    AppUtils.showLoadingDialog(context, 'Adding... Please wait...');
    try {
      await _apiClient.post('/v1.0/createVehicle', data: vehicle.toJson());
      AppUtils.showSucessMessage(context, 'Vehicle added successfully!');
      await getVehiclesData();
      Navigator.pop(context);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/createVehicle', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> updateVehicle(BuildContext context, AddVehicle vehicle) async {
    AppUtils.showLoadingDialog(context, 'Updating... Please wait...');
    try {
      await _apiClient.post('/v1.0/updateVehicle', data: vehicle.toJson());
      AppUtils.showSucessMessage(context, 'Vehicle updated successfully!');
      await getVehiclesData();
      context.go('/layout.vehicles/vehicle-details?id=${vehicle.id}');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/updateVehicle', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> deleteVehicle(BuildContext context, int vehicleId) async {
    AppUtils.showLoadingDialog(context, 'Deleting... Please wait...');
    try {
      final userInfo = HiveService.userInfoBox.values.first;
      await _apiClient.post(
        '/v1.0/deleteVehicles',
        data: {
          'OrganizationId': userInfo.organizationId,
          'BranchId': userInfo.branchId,
          'ZoneId': userInfo.zoneId,
          'Ids': [vehicleId],
        },
      );
      AppUtils.showSucessMessage(context, 'Vehicle deleted successfully!');
      await getVehiclesData();
      context.go('/layout.vehicles');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/deleteVehicles', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<Docs?> getVehicleDocs({required int id, required String type}) async {
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getVehicleDocs',
        data: {'Target': 'Vehicle', 'RecordId': id, 'Type': type},
      );
      if (kDebugMode) {
        log('Response: ${response.data}');
      }
      final data = VehicleDocs.fromJson(response.data as Map<String, dynamic>);
      vehicleDocs[type] = data.docs;
      return data.docs;
    } catch (error, stack) {
      vehicleDocs[type] = null;
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVehicleDocs', error, stack);
      }
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> uploadVehicleDocs(
    BuildContext context,
    int vehicleId,
    String type,
    XFile file,
    Map<String, String> data,
  ) async {
    AppUtils.showLoadingDialog(context, 'Uploading document...');
    final formData = FormData.fromMap({
      'Source': 'adminapp',
      'Type': type,
      'RecordId': vehicleId,
      'Target': 'Vehicle',
      'File': MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: file.name,
        contentType: file.name.endsWith('.pdf')
            ? DioMediaType('application', 'pdf')
            : DioMediaType('image', file.name.split('.').last.toLowerCase()),
      ),
      ...data,
    });
    try {
      await _apiClient.post('/v1.0/uploadVehicleDocs', data: formData);
      await getVehicleDocs(id: vehicleId, type: type);
      AppUtils.showSucessMessage(context, 'Document uploaded successfully');
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/uploadVehicleDocs', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> deleteVehicleDoc(
    BuildContext context,
    int vehicleId,
    String type,
    // String docId,
  ) async {
    AppUtils.showLoadingDialog(context, 'Deleting driver...');
    try {
      await _apiClient.post(
        '/v1.0/deleteVehicleDocs',
        data: {
          'Target': 'Vehicle',
          'RecordId': vehicleId,
          'Type': type,
          // 'DocumentId': docId,
        },
      );
      await getVehicleDocs(id: vehicleId, type: type);
      AppUtils.showSucessMessage(context, 'Document deleted successfully');
      Navigator.of(context, rootNavigator: true).pop();
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/deleteVehicleDocs', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<bool> checkVehicleNumber(String number) async {
    try {
      final response = await _apiClient.post(
        '/v1.0/checkVehicleNumber',
        data: {'Number': number},
      );
      return response.data['IsAlreadyRegistered'];
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/checkVehicleNumber', error, stack);
      }
      return false;
    }
  }

  Future<void> getComplaintCategories() async {
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getVhComplaintCategories',
        data: {'IsActive': 'true'},
      );
      final data = ComplaintCategories.fromJson(
        response.data as Map<String, dynamic>,
      );
      complaintCategories = data.data;
      complaintActions = data.actions;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVhComplaintCategories', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addComplaint({
    required BuildContext context,
    required String vehicleNumber,
    required int vehicleId,
    required int categoryId,
    required String categoryName,
    String? description,
    required String action,
    required String status,
    List<XFile?> files = const [],
  }) async {
    AppUtils.showLoadingDialog(context, 'Submitting... Please wait...');
    try {
      final userInfo = HiveService.userInfoBox.values.first;
      final formData = FormData.fromMap({
        'Source': 'adminapp',
        'ZoneId': userInfo.zoneId,
        // 'BranchId': userInfo.branchId,
        'OrganizationId': userInfo.organizationId,
        'VehicleNo': vehicleNumber,
        'VehicleId': vehicleId,
        'CategoryId': categoryId,
        'CategoryName': categoryName,
        'Desc': description,
        'Action': action,
        'Status': status,
        'Images': files.isNotEmpty
            ? await Future.wait(
                files.map(
                  (file) async => MultipartFile.fromBytes(
                    await file!.readAsBytes(),
                    filename: file.name,
                  ),
                ),
              )
            : null,
      });

      final response = await _apiClient.post(
        '/v1.0/submitVhComplaint',
        data: formData,
      );
      if (response.data['err'] == false) {
        await getComplaints();
        if (categoryId == 0) {
          await getComplaintCategories();
        }
        AppUtils.showSucessMessage(context, 'Data submitted successfully!');
        context.pop();
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/addVehicleFuelReading', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> updateComplaint({
    required BuildContext context,
    required int id,
    required String action,
    required String status,
    String? description,
    List<XFile?> files = const [],
  }) async {
    AppUtils.showLoadingDialog(context, 'Updating... Please wait...');
    try {
      final userInfo = HiveService.userInfoBox.values.first;
      final formData = FormData.fromMap({
        'Source': 'adminapp',
        'ZoneId': userInfo.zoneId,
        // 'BranchId': userInfo.branchId,
        'OrganizationId': userInfo.organizationId,
        'Id': id,
        'Desc': description,
        'Action': action,
        'Status': status,
        'Photos': files.isNotEmpty
            ? await Future.wait(
                files.map(
                  (file) async => MultipartFile.fromBytes(
                    await file!.readAsBytes(),
                    filename: file.name,
                  ),
                ),
              )
            : null,
      });

      final response = await _apiClient.post(
        '/v1.0/updateVhComplaint',
        data: formData,
      );
      if (response.data['err'] == false) {
        await getComplaints();
        AppUtils.showSucessMessage(context, 'Complaint updated successfully!');
        context.pop();
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/updateVhComplaint', error, stack);
      }
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> getComplaints({
    int? vehicleId,
    String? status,
    String? complaintNo,
    int? category,
    String? action,
    int page = 1,
  }) async {
    if (page == 1) {
      complaints.clear();
      complainsLoading = true;
    } else {
      loading = true;
    }
    notifyListeners();
    final userInfo = HiveService.userInfoBox.values.first;
    try {
      final response = await _apiClient.post(
        '/v1.0/getVhComplaints',
        data: {
          'ZoneId': userInfo.zoneId,
          'BranchId': userInfo.branchId,
          'OrganizationId': userInfo.organizationId,
          'VehicleId': vehicleId,
          'Status': status,
          'CategoryId': category,
          'Action': action,
          'ComplaintNo': complaintNo,
          'PageNumber': page,
          'PageSize': 10,
        },
      );
      final data = ComplaintData.fromJson(
        response.data as Map<String, dynamic>,
      );
      complaints.addAll(data.data);
      metadata = data.metadata;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVhComplaints', error, stack);
      }
    } finally {
      complainsLoading = false;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getComplaintsStats({
    required String countBy,
    int page = 1,
  }) async {
    if (page == 1) {
      complaintsDashboard.clear();
      complainsLoading = true;
    } else {
      loading = true;
    }
    notifyListeners();
    final userInfo = HiveService.userInfoBox.values.first;
    try {
      final response = await _apiClient.post(
        '/v1.0/getVhComplaintsStats',
        data: {
          'ZoneId': userInfo.zoneId,
          'BranchId': userInfo.branchId,
          'OrganizationId': userInfo.organizationId,
          'PageNumber': page,
          'PageSize': 10,
          'CountsBy': countBy,
        },
      );
      final data = ComplaintsDashboard.fromJson(
        response.data as Map<String, dynamic>,
      );
      complaintsDashboard.addAll(data.data);
      metadata = data.metadata;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVhComplaintsStats', error, stack);
      }
    } finally {
      complainsLoading = false;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getVehicleCleaningParts() async {
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getVhCleaningParts',
        data: {'IsActive': true},
      );
      final data = VehicleCleaningParts.fromJson(
        response.data as Map<String, dynamic>,
      );
      vehicleCleaningParts = data.data;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVhCleaningParts', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> submitVehicleCleaningData(
    BuildContext context,
    List<int> cleanedPartIds,
    List<Map<String, dynamic>> vehicles,
  ) async {
    AppUtils.showLoadingDialog(context, 'Submitting... Please wait...');
    try {
      final userInfo = HiveService.userInfoBox.values.first;
      final response = await _apiClient.post(
        '/v1.0/submitMultiVhCleanedData',
        data: {
          'ZoneId': userInfo.zoneId,
          'BranchId': userInfo.branchId,
          'OrganizationId': userInfo.organizationId,
          'CleanedPartIds': cleanedPartIds,
          'Vehicles': vehicles,
        },
      );
      if (response.statusCode == 200) {
        final data = VehicleCleaningSuccess.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (data.failedCnt > 0) {
          AppUtils.hideLoadingDialog(context);
          showDialog(
            context: context,
            builder: (context) =>
                FailedVehicleCleaningDialog(failedData: data.failedData),
          );
        } else {
          AppUtils.hideLoadingDialog(context);
          AppUtils.showSucessMessage(
            context,
            'Cleaning data submitted successfully!',
          );
          Navigator.pop(context);
        }
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/submitMultiVhCleanedData', error, stack);
      }
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> getVehicleArrivals() async {
    loading = true;
    notifyListeners();
    try {
      final userInfo = HiveService.userInfoBox.values.first;
      final response = await _apiClient.post(
        '/v1.0/getVhArrivals',
        data: {
          'ZoneId': userInfo.zoneId,
          'BranchId': userInfo.branchId,
          'OrganizationId': userInfo.organizationId,
        },
      );
      final data = VehicleArrivals.fromJson(
        response.data as Map<String, dynamic>,
      );
      _vehicleArrivals = data.data;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVhArrivals', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void updateArrivalsList(List<VehicleArrival> newArrivals) {
    _vehicleArrivals = newArrivals;
    notifyListeners();
  }

  Future<bool> updateVehicleArrivalStatus(
    BuildContext context,
    List<int> ids,
    String status,
    String? boardingZone,
  ) async {
    final userInfo = HiveService.userInfoBox.values.first;
    final idsSet = ids.toSet();
    final selectedRoutes = _routes.where((e) => idsSet.contains(e.id)).toList();

    if (selectedRoutes.isEmpty) {
      AppUtils.showErrorMessage(context, 'No Matching Routes');
      return false;
    }

    AppUtils.showLoadingDialog(context, 'Submitting... Please wait...');

    try {
      final response = await _apiClient.post(
        '/v1.0/updateMultiVehicleArrivalStatus',
        data: {
          'ZoneId': userInfo.zoneId,
          'BranchId': userInfo.branchId,
          'OrganizationId': userInfo.organizationId,
          'Vehicles': selectedRoutes
              .map(
                (e) => ({
                  'RouteId': e.id,
                  'RouteNo': e.routeNo,
                  'VehicleNumber': e.vehicleNumber,
                  'StartTime': e.routeStartTime,
                  'Status': status,
                  ...(boardingZone != null
                      ? {'BoardingType': boardingZone}
                      : {}),
                }),
              )
              .toList(),
        },
      );
      if (response.statusCode == 200) {
        AppUtils.showSucessMessage(
          context,
          'All statuses updated successfully!',
        );
        return true;
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
        return false;
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/updateMultiVehicleArrivalStatus', error, stack);
      }
      return false;
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> getBoardingTypes() async {
    final userInfo = HiveService.userInfoBox.values.first;
    loading = true;
    boardingTypes.clear();
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/v1.0/getBoardingTypes',
        data: {
          'ZoneId': userInfo.zoneId,
          'BranchId': userInfo.branchId,
          'OrganizationId': userInfo.organizationId,
        },
      );
      if (response.statusCode == 200) {
        final data = BoardingTypes.fromJson(
          response.data as Map<String, dynamic>,
        );
        boardingTypes = data.data;
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/updateMultiVehicleArrivalStatus', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // void _showFailedUpdatesDialog(
  //   BuildContext context,
  //   List<UpdateResult> failedResults,
  // ) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Failed to Update Some Routes'),
  //         content: SizedBox(
  //           width: double.maxFinite,
  //           height: 300.0,
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: failedResults.length,
  //             itemBuilder: (context, index) {
  //               final item = failedResults[index];
  //               return ListTile(
  //                 title: Text(
  //                   'Route No: ${item.routeNo}',
  //                   style: const TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 subtitle: Text(item.message ?? 'Unknown error'),
  //               );
  //             },
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  List<Routee> get routesForDropOff {
    final arrivedRouteIds = _vehicleArrivals.map((e) => e.id).toSet();
    return _routes
        .where((route) => !arrivedRouteIds.contains(route.id))
        .toList();
  }
}

class UpdateResult {
  UpdateResult({
    required this.id,
    required this.isSuccess,
    required this.routeNo,
    this.message,
  });

  final int id;
  final bool isSuccess;
  final String? message;
  final String routeNo;
}
