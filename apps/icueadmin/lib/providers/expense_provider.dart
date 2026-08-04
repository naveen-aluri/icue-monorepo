import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../models/expense_category.dart';
import '../models/expense_type.dart';
import '../pages/repairs_expense/expense_confirmation_page.dart';
import '../services/api_client.dart';
import '../services/hive_service.dart';
import '../utils/app_utils.dart';

@lazySingleton
class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider(this._apiClient);

  bool loading = false;

  final ApiClient _apiClient;
  String? startGaugeReading;
  List<String> filledVehicleNumbers = [];
  List<Detail> subCategories = [];

  void reset() {
    filledVehicleNumbers.clear();
    startGaugeReading = null;
    notifyListeners();
  }

  Future<void> getExpenseTypes() async {
    // if (HiveService.expenseTypesBox.values.isNotEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post('/v1.0/getExpenseTypeDetails');
      final data = List<ExpenseType>.from(
        (response.data as List).map(
          (x) => ExpenseType.fromJson(x as Map<String, dynamic>),
        ),
      );
      await HiveService.expenseTypesBox.clear();
      await HiveService.expenseTypesBox.addAll(data);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getExpenseTypeDetails', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getExpenseCategories() async {
    // if (HiveService.expenseCategorysBox.values.isNotEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post('/v1.0/getExpenseCategories');
      final data = ExpenseCategory.fromJson(
        response.data as Map<String, dynamic>,
      );
      await HiveService.expenseCategorysBox.clear();
      await HiveService.expenseCategorysBox.addAll(data.record);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getExpenseCategories', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getExpenseSubCategories(int categoryId) async {
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post(
        '/v1.0/getExpenseSubCategories',
        data: {'CategoryId': categoryId},
      );
      final data = ExpenseCategory.fromJson(
        response.data as Map<String, dynamic>,
      );
      subCategories = data.record;
      subCategories.add(Detail(id: 'others', name: 'Others'));
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getExpenseSubCategories', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSelfFillingStatus({
    required BuildContext context,
    required String fuelType,
    required String gaugeMode,
    String? startReading,
    String? endReading,
    XFile? gaugeFile,
    XFile? billFile,
  }) async {
    AppUtils.showLoadingDialog(context, 'Updating... Please wait...');
    try {
      // final branchId = HiveService.zonalBranch.get('selected')?.id;
      final formData = FormData.fromMap({
        'Source': 'adminapp',
        // 'BranchId': branchId,
        'FuelType': fuelType,
        'GaugeMode': gaugeMode,
        'StartReading': startGaugeReading ?? startReading,
        'EndReading': endReading,
        'TransDate': DateTime.now().formattedGatePassDate(),
        'File': gaugeFile == null
            ? null
            : MultipartFile.fromBytes(
                await gaugeFile.readAsBytes(),
                filename: gaugeFile.name,
              ),
        // ignore: equal_keys_in_map
        'File': billFile == null
            ? null
            : MultipartFile.fromBytes(
                await billFile.readAsBytes(),
                filename: billFile.name,
              ),
        'ImgUpload': gaugeFile == null && billFile == null
            ? null
            : gaugeFile != null && billFile != null
            ? 'ALL'
            : gaugeFile != null
            ? 'GAUGE'
            : 'BILL',
      });
      startGaugeReading = startReading;
      final response = await _apiClient.post(
        '/v1.0/updateSelfFillingStatus',
        data: formData,
      );
      if (response.data['err'] == false) {
        if (gaugeMode == 'end') {
          AppUtils.showSucessMessage(context, 'Updated Successfully!');
          context.go('/');
        }
        notifyListeners();
        return true;
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
        return false;
      }
    } catch (e) {
      log(e.toString());
      return false;
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<void> storeExpense({
    required BuildContext context,
    required Map<String, dynamic> data,
    required ExpenseType expenseType,
    XFile? odometerFile,
    XFile? billFile,
  }) async {
    AppUtils.showLoadingDialog(context, 'Updating... Please wait...');

    try {
      final addExpenseData = await _generateRefNo(context, data, odometerFile);

      if (addExpenseData != null) {
        final billNo = await _getBillNoIfEmpty(data);

        final billAmount = data['BillAmount'] ?? addExpenseData['BillAmount'];
        // final branchId = HiveService.zonalBranch.get('selected')?.id;

        final Map<String, dynamic> formDataMap = {
          'Source': 'adminapp',
          // 'BranchId': branchId,
          ...data,
          'BillNo': billNo,
          'IsMode': 'true',
          'RefNo': addExpenseData['RefNo'],
          'BillAmount': billAmount,
          'File': billFile == null
              ? null
              : MultipartFile.fromBytes(
                  await billFile.readAsBytes(),
                  filename: billFile.name,
                ),
        };

        // Remove entries with null values
        formDataMap.removeWhere((key, value) => value == null);

        final response = await _apiClient.post(
          '/v1.0/storeExpense',
          data: FormData.fromMap(formDataMap),
        );
        if (response.data['err'] == false) {
          AppUtils.hideLoadingDialog(context);
          if (data['Mode'] != null &&
              ['SelfFilling', 'FuelStation'].contains(data['Mode'])) {
            filledVehicleNumbers.add(data['StorName'] ?? data['VehicleNumber']);
          }
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseConfirmationPage(
                expenseType: expenseType,
                mode: data['Mode'],
                fuelType: data['FuelType'],
              ),
            ),
          );
        } else {
          AppUtils.hideLoadingDialog(context);
          AppUtils.showErrorMessage(context, response.data['message']);
        }
      } else {
        AppUtils.hideLoadingDialog(context);
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/storeExpense', error, stack);
      }
      AppUtils.hideLoadingDialog(context);
    }
  }

  Future<Map<String, dynamic>?> _generateRefNo(
    BuildContext context,
    Map<String, dynamic> data,
    XFile? odometerFile,
  ) async {
    try {
      // final branchId = HiveService.zonalBranch.get('selected')?.id;
      final formData = removeEmptyAndNullValues({
        'Source': 'adminapp',
        // 'BranchId': branchId,
        ...data,
        'File': odometerFile == null
            ? null
            : MultipartFile.fromBytes(
                await odometerFile.readAsBytes(),
                filename: odometerFile.name,
              ),
      });

      final response = await _apiClient.post(
        '/v1.0/addExpense',
        data: FormData.fromMap(formData),
      );
      if (response.data['err'] == false) {
        log('addExpense Response => ${response.data['data']}');
        return response.data['data'];
      } else {
        AppUtils.showErrorMessage(context, response.data['message']);
        return null;
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/addExpense', error, stack);
      }
      return null;
    }
  }

  Future<String?> _getBillNoIfEmpty(Map<String, dynamic> data) async {
    if (data['BillNo'] == null || data['BillNo'].isEmpty) {
      try {
        final billNoResponse = await _apiClient.post(
          '/v1.0/generateBillNo',
          data: {
            'InitiatedDate': data['BillDate'],
            'InitiatedTime': DateTime.now().formattedTimeWithSecs(),
          },
        );
        log('generateBillNo => ${billNoResponse.data}');
        return billNoResponse.data['BillNo'];
      } catch (error, stack) {
        if (error.runtimeType.toString() != 'DioException') {
          _apiClient.logCrash('/generateBillNo', error, stack);
        }
      }
    }
    return data['BillNo'];
  }
}
