import 'package:icue_face_sdk/icue_face_sdk.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  IcueFaceSdk get faceSdk => IcueFaceSdk();
}
