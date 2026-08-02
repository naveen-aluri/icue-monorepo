import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CrashlyticsService {
  CrashlyticsService(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  Future<void> initialize() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (!kDebugMode) {
        _crashlytics.recordFlutterError(details);
      }
    };

    // Capture errors from the platform (dart:ui)
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kDebugMode) {
        _crashlytics.recordError(error, stack, fatal: true);
      }
      return true;
    };

    // Optionally disable in debug mode:
    // await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  /// Logs a non-fatal informational message.
  void log(String message) {
    _crashlytics.log(message);
  }

  /// Records a caught exception and its stack trace.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    Iterable<Object> information = const [],
    bool fatal = false,
    String? reason,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
      information: information,
    );
  }

  /// Attach custom key/value for additional context.
  Future<void> setCustomKey(String key, String value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Identify the user (e.g. for support).
  Future<void> setUserIdentifier(String uid) async {
    await _crashlytics.setUserIdentifier(uid);
  }
}
