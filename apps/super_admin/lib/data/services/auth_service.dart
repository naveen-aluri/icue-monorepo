import 'package:injectable/injectable.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/pref_service.dart';
import '../models/login_response.dart';

@lazySingleton
class AuthService {
  final ApiClient _apiClient;
  final PrefService _prefService;

  AuthService(this._apiClient, this._prefService);

  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        '/api/v1.0/login',
        data: {'username': username, 'password': password, 'Source': 'App'},
      );

      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Save session details
      await _prefService.saveSession(
        token: loginResponse.token,
        sesid: loginResponse.sesid,
        userId: loginResponse.id,
        userName: loginResponse.name,
        orgId: loginResponse.organizationId,
        zoneId: loginResponse.zoneId,
        branchId: loginResponse.branchId,
      );

      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _prefService.clearSession();
  }
}
