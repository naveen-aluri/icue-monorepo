import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../core/storage/pref_service.dart';
import '../data/services/auth_service.dart';

@injectable
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final PrefService _prefService;

  AuthProvider(this._authService, this._prefService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _prefService.isLoggedIn;

  String get userName => _prefService.userName ?? 'User';
  int? get orgId => _prefService.orgId;
  int? get zoneId => _prefService.zoneId;
  int? get branchId => _prefService.branchId;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('DioException', 'Network Error');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
