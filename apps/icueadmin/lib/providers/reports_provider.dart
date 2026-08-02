import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../models/alcohol_test_report.dart';
import '../models/arrival_time_report.dart';
import '../models/cleaning_report.dart';
import '../models/fuel_report.dart';
import '../models/meta_data.dart';
import '../models/mileage_report.dart';
import '../models/overspeed_report.dart';
import '../services/api_client.dart';
import '../services/hive_service.dart';
import '../utils/constants.dart';

@lazySingleton
class ReportsProvider extends ChangeNotifier {
  ReportsProvider({required this._apiClient});

  List<AlcoholTest> alcoholTestReport = [];
  List<TimeReport> arrivalTimeReports = [];
  List<CleaningReportData> cleaningReport = [];
  List<Fuelreading> fuelReadings = [];
  bool loading = false;
  Metadata? metadata;
  List<MileageReport> mileageReports = [];
  List<OverSpeed> overSpeedList = [];

  final ApiClient _apiClient;

  void clearData() {
    metadata = null;
    fuelReadings.clear();
    mileageReports.clear();
    overSpeedList.clear();
    alcoholTestReport.clear();
    notifyListeners();
  }

  Future<void> getFuelReadingReport({
    required String vehicleNumber,
    required String month,
    required String year,
  }) async {
    loading = true;
    fuelReadings.clear();
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v2.0/getVehicleFuelReadingReport',
        data: {'Month': month, 'Year': year, 'VehicleNumber': vehicleNumber},
      );
      final data = List<FuelReport>.from(
        (response.data as List).map(
          (x) => FuelReport.fromJson(x as Map<String, dynamic>),
        ),
      );
      if (data.isNotEmpty) fuelReadings = data[0].fuelreading;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVehicleFuelReadingReport', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getMileageReport({
    required String vehicleNumber,
    required String month,
    required String year,
  }) async {
    loading = true;
    mileageReports.clear();
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getVehicleMileageReport',
        data: {'Month': month, 'Year': year, 'VehicleNumber': vehicleNumber},
      );
      mileageReports = List<MileageReport>.from(
        (response.data as List).map(
          (x) => MileageReport.fromJson(x as Map<String, dynamic>),
        ),
      );
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVehicleMileageReport', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getOverSpeedReport({
    required String vehicleNumber,
    required String month,
    required String year,
    required String speedLimit,
  }) async {
    loading = true;
    overSpeedList.clear();
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getVehicleOverSpeedReport',
        data: {
          'Month': month,
          'Year': year,
          'speedLimit': speedLimit,
          'VehicleNumber': vehicleNumber,
        },
      );
      if (response.data.runtimeType != List<dynamic>) {
        return;
      }
      final overSpeedReport = List<OverSpeedReport>.from(
        (response.data as List).map(
          (x) => OverSpeedReport.fromJson(x as Map<String, dynamic>),
        ),
      );

      for (final e in overSpeedReport) {
        for (final f in e.overSpeedData) {
          overSpeedList.add(
            OverSpeed(
              vehicleNumber: e.vehicleNumber,
              mode: e.mode,
              routeNo: e.routeNo,
              averageSpeed: e.averageSpeed ?? 0,
              speed: f.speed,
              gpsTime: DateTime.fromMillisecondsSinceEpoch(f.gpsTime),
            ),
          );
        }
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVehicleOverSpeedReport', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getCleaningReport({
    required FilterMode reportMode,
    String? month,
    String? year,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int? vehicleId,
    String? vehicleNo,
  }) async {
    if (page == 1) {
      loading = true;
      cleaningReport.clear();
      notifyListeners();
    }
    try {
      final user = HiveService.userInfoBox.values.firstOrNull;
      final response = await _apiClient.post(
        '/v1.0/getVhCleanedReport',
        data: {
          'VehicleId': vehicleId,
          'VehicleNo': vehicleNo,
          'Source': 'adminapp',
          'OrganizationId': user?.organizationId,
          'ZoneId': user?.zoneId,
          'BranchId': user?.branchId,
          'PageNumber': page,
          'PageSize': 10,
          'ReportMode': reportMode.name,
          ...(reportMode == FilterMode.bymonth
              ? {'Month': month, 'Year': year}
              : {
                  'FromDate': startDate != null
                      ? DateFormat('MM/dd/yyyy').format(startDate)
                      : null,
                  'ToDate': endDate != null
                      ? DateFormat('MM/dd/yyyy').format(endDate)
                      : null,
                }),
        },
      );

      final report = CleaningReport.fromJson(
        response.data as Map<String, dynamic>,
      );
      metadata = report.metadata;
      cleaningReport.addAll(report.data ?? []);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVhCleanedReport', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getAlcoholTestReport({
    required FilterMode reportMode,
    String? month,
    String? year,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int? personId,
  }) async {
    if (page == 1) {
      loading = true;
      alcoholTestReport.clear();
      notifyListeners();
    }

    try {
      final user = HiveService.userInfoBox.values.firstOrNull;
      final response = await _apiClient.post(
        '/v2.0/getPrsnAlcoholTestReport',
        data: {
          'OrganizationId': user?.organizationId,
          'ZoneId': user?.zoneId,
          'BranchId': user?.branchId,
          'ReportMode': reportMode.name,
          ...(reportMode == FilterMode.bymonth
              ? {'Month': month, 'Year': year}
              : {
                  'FromDate': startDate != null
                      ? DateFormat('MM/dd/yyyy').format(startDate)
                      : null,
                  'ToDate': endDate != null
                      ? DateFormat('MM/dd/yyyy').format(endDate)
                      : null,
                }),
          'PersonId': personId,
          'PageNumber': page,
          'PageSize': 10,
        },
      );

      final report = AlcoholTestReport.fromJson(
        response.data as Map<String, dynamic>,
      );
      metadata = report.metadata;
      alcoholTestReport.addAll(report.data);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getPrsnAlcoholTestReport', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getArrivalTimeReport({
    required FilterMode reportMode,
    String? month,
    String? year,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    String mode = 'Pickup',
    String? vehicleNo,
  }) async {
    if (page == 1) {
      loading = true;
      arrivalTimeReports.clear();
      notifyListeners();
    }
    try {
      final user = HiveService.userInfoBox.values.firstOrNull;
      final response = await _apiClient.post(
        '/v2.0/getVhArrivalTime',
        data: {
          'Source': 'adminapp',
          'OrganizationId': user?.organizationId,
          'ZoneId': user?.zoneId,
          'BranchId': user?.branchId,
          'Mode': mode,
          'PageNumber': page,
          'PageSize': 10,
          'VehicleNo': vehicleNo,
          'ReportMode': reportMode.name,
          ...(reportMode == FilterMode.bymonth
              ? {'Month': month, 'Year': year}
              : {
                  'FromDate': startDate != null
                      ? DateFormat('MM/dd/yyyy').format(startDate)
                      : null,
                  'ToDate': endDate != null
                      ? DateFormat('MM/dd/yyyy').format(endDate)
                      : null,
                }),
        },
      );

      final report = ArrivalTimeReport.fromJson(
        response.data as Map<String, dynamic>,
      );
      metadata = report.data.metadata;
      arrivalTimeReports.addAll(report.data.data);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getVhArrivalTime', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
