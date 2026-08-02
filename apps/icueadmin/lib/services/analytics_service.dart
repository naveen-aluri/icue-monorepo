import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;
  String? _currentScreen;
  DateTime? _screenStartTime;

  /// Log app open
  Future<void> logAppOpen() => _analytics.logAppOpen();

  /// Log a custom event
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) =>
      _analytics.logEvent(name: name, parameters: parameters);

  /// Log screen views with timer start
  Future<void> logScreenView({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) async {
    // Prepare parameters, ensuring no null values
    final Map<String, Object> params = {
      'app': 'admin-mobile-app',
      if (parameters != null) ...parameters.map((k, v) => MapEntry(k, v ?? '')),
    };

    // Log screen
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
      parameters: params,
    );

    // Track screen time
    _currentScreen = screenName;
    _screenStartTime = DateTime.now();
  }

  /// Call this when user leaves the screen
  Future<void> logScreenDurationIfNeeded() async {
    if (_currentScreen != null && _screenStartTime != null) {
      final duration = DateTime.now().difference(_screenStartTime!).inSeconds;

      await _analytics.logEvent(
        name: 'screen_time',
        parameters: {
          'screen_name': _currentScreen!,
          'duration_seconds': duration,
        },
      );
    }

    _currentScreen = null;
    _screenStartTime = null;
  }

  Future<void> logLogin({required String method}) =>
      _analytics.logLogin(loginMethod: method);

  Future<void> setUserId(String id) => _analytics.setUserId(id: id);

  Future<void> setUserProperty({required String name, required String value}) =>
      _analytics.setUserProperty(name: name, value: value);
}
