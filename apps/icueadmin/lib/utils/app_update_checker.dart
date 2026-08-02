// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:in_app_update/in_app_update.dart';

class AppUpdateChecker {
  Future<void> checkForUpdate() async {
    if (kReleaseMode && !kIsWeb) {
      await InAppUpdate.checkForUpdate()
          .then((info) {
            if (info.updateAvailability == UpdateAvailability.updateAvailable) {
              InAppUpdate.performImmediateUpdate();
            }
          })
          .catchError((e) {
            debugPrint('APP CHECKER => $e');
          });
    } else {
      debugPrint('InAppUpdate is disabled in Debug mode.');
    }
  }
}
