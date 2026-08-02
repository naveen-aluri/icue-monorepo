import 'base_config.dart';

class ProdConfig extends BaseConfig {
  @override
  String get baseUrl => 'https://icuepro.com';

  @override
  String get env => 'PROD';
}
