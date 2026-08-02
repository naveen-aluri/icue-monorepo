import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'base_config.dart';
import 'dev_config.dart';
import 'prod_config.dart';

class Env {
  factory Env() {
    return _singleton;
  }

  Env._internal();

  static const String dev = 'DEV';
  static const String prod = 'PROD';

  late BaseConfig config;

  static final Env _singleton = Env._internal();

  void initEnvConfig() {
    // ignore: do_not_use_environment
    const String environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: Env.prod,
    );
    config = _getConfig(environment);
    // await Firebase.initializeApp(options: config.firebaseOptions);
  }

  BaseConfig _getConfig(String environment) {
    switch (environment) {
      case Env.dev:
        if (kDebugMode) log('💻 Development configuration loaded!');
        return DevConfig();
      default:
        if (kDebugMode) log('💻 Production configuration loaded!');
        return ProdConfig();
    }
  }
}
