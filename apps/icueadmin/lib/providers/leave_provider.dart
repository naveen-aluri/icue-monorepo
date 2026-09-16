import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../models/leave_application.dart';
import '../models/leave_balance.dart';
import '../models/leave_request.dart';
import '../services/hive_service.dart';
import '../services/hrms_api_client.dart';

@lazySingleton
class LeaveProvider extends ChangeNotifier {
  LeaveProvider(this._hrmsApiClient);

  final HrmsApiClient _hrmsApiClient;

  bool _loading = false;
  bool _submitting = false;
  bool _loadingApplied = false;
  String? _errorMessage;
  List<LeaveBalance> _leaveBalances = [];
  int _selectedYear = DateTime.now().year;
  bool _onlyAccessibleLeaves = false;

  String _selectedAppliedStatus = 'Requested';
  final Map<String, List<LeaveApplication>> _appliedLeaves = {
    'Requested': [],
    'Approved': [],
    'Rejected': [],
  };

  bool get loading => _loading;
  bool get submitting => _submitting;
  bool get loadingApplied => _loadingApplied;
  String? get errorMessage => _errorMessage;
  List<LeaveBalance> get leaveBalances => _leaveBalances;
  int get selectedYear => _selectedYear;
  bool get onlyAccessibleLeaves => _onlyAccessibleLeaves;
  String get selectedAppliedStatus => _selectedAppliedStatus;

  List<LeaveApplication> get currentAppliedLeaves =>
      _appliedLeaves[_selectedAppliedStatus] ?? [];

  int appliedCount(String status) => _appliedLeaves[status]?.length ?? 0;

  List<LeaveBalance> get displayedLeaves {
    if (_onlyAccessibleLeaves) {
      return _leaveBalances.where((l) => l.isEmpAccess).toList();
    }
    return _leaveBalances;
  }

  double get totalAllocated =>
      _leaveBalances.fold(0.0, (sum, item) => sum + item.allocatedDays);

  double get totalTaken =>
      _leaveBalances.fold(0.0, (sum, item) => sum + item.takenDays);

  double get totalBalance =>
      _leaveBalances.fold(0.0, (sum, item) => sum + item.remainingDays);

  void setFilterAccessibleOnly(bool value) {
    _onlyAccessibleLeaves = value;
    notifyListeners();
  }

  void setYear(int year, {int? employeeId}) {
    if (_selectedYear == year) return;
    _selectedYear = year;
    notifyListeners();
    fetchLeaveBalances(employeeId: employeeId, year: year);
  }

  Future<void> fetchLeaveBalances({
    int? employeeId,
    int? year,
    bool refresh = false,
  }) async {
    final targetYear = year ?? _selectedYear;
    _selectedYear = targetYear;

    final resolvedEmpId = employeeId ?? HiveService.currentUser?.id;
    if (resolvedEmpId == null || resolvedEmpId == 0) {
      _errorMessage = 'Employee profile not found. Please log in again.';
      notifyListeners();
      return;
    }

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final path = '/api/v1/leaves/by-empid/$resolvedEmpId/$targetYear';

    try {
      final response = await _hrmsApiClient.get(path);
      if (response.statusCode == 200 && response.data != null) {
        _leaveBalances = leaveBalanceListFromJson(response.data);
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load leave balances.';
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _hrmsApiClient.logCrash(path, error, stack);
      }
      _errorMessage = 'Failed to fetch leave balances. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> submitLeaveRequest(LeaveRequestPayload payload) async {
    _submitting = true;
    _errorMessage = null;
    notifyListeners();

    const path = '/api/v1/leaves';
    try {
      final response = await _hrmsApiClient.post(path, data: payload.toJson());

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        // Refresh leave balances so balances remain up-to-date
        await fetchLeaveBalances(employeeId: payload.employeeId, refresh: true);
        // Refresh requested leaves list if already loaded
        await fetchAppliedLeaves(
          employeeId: payload.employeeId,
          status: 'Requested',
          refresh: true,
        );
        return true;
      } else {
        _errorMessage = 'Failed to submit leave request.';
        return false;
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _hrmsApiClient.logCrash(path, error, stack);
      }
      _errorMessage = 'Failed to submit leave request. Please try again.';
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void setAppliedStatus(String status, {int? employeeId}) {
    if (_selectedAppliedStatus == status) return;
    _selectedAppliedStatus = status;
    notifyListeners();
    if ((_appliedLeaves[status] ?? []).isEmpty) {
      fetchAppliedLeaves(employeeId: employeeId, status: status);
    }
  }

  Future<void> fetchAppliedLeaves({
    int? employeeId,
    String? status,
    bool refresh = false,
  }) async {
    final targetStatus = status ?? _selectedAppliedStatus;
    _selectedAppliedStatus = targetStatus;

    final resolvedEmpId = employeeId ?? HiveService.currentUser?.id;
    if (resolvedEmpId == null || resolvedEmpId == 0) {
      _errorMessage = 'Employee profile not found. Please log in again.';
      notifyListeners();
      return;
    }

    _loadingApplied = true;
    _errorMessage = null;
    notifyListeners();

    final path = '/api/v1/leaves/by-id-status/$resolvedEmpId/$targetStatus';

    try {
      final response = await _hrmsApiClient.get(path);
      if (response.statusCode == 200 && response.data != null) {
        _appliedLeaves[targetStatus] = leaveApplicationListFromJson(
          response.data,
        );
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load applied leaves for $targetStatus.';
      }
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _hrmsApiClient.logCrash(path, error, stack);
      }
      _errorMessage = 'Failed to fetch applied leaves. Please try again.';
    } finally {
      _loadingApplied = false;
      notifyListeners();
    }
  }
}
