// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:icue_face_sdk/icue_face_sdk.dart' as _i959;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:super_admin/core/di/register_module.dart' as _i783;
import 'package:super_admin/core/network/api_client.dart' as _i449;
import 'package:super_admin/core/storage/pref_service.dart' as _i691;
import 'package:super_admin/data/services/auth_service.dart' as _i399;
import 'package:super_admin/data/services/student_service.dart' as _i885;
import 'package:super_admin/providers/auth_provider.dart' as _i1072;
import 'package:super_admin/providers/embedding_provider.dart' as _i1011;
import 'package:super_admin/providers/identify_provider.dart' as _i932;
import 'package:super_admin/providers/student_provider.dart' as _i786;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i959.IcueFaceSdk>(() => registerModule.faceSdk);
    gh.lazySingleton<_i691.PrefService>(
      () => _i691.PrefService(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i1011.EmbeddingProvider>(
      () => _i1011.EmbeddingProvider(gh<_i959.IcueFaceSdk>()),
    );
    gh.factory<_i932.IdentifyProvider>(
      () => _i932.IdentifyProvider(gh<_i959.IcueFaceSdk>()),
    );
    gh.lazySingleton<_i449.ApiClient>(
      () => _i449.ApiClient(gh<_i691.PrefService>()),
    );
    gh.lazySingleton<_i399.AuthService>(
      () => _i399.AuthService(gh<_i449.ApiClient>(), gh<_i691.PrefService>()),
    );
    gh.lazySingleton<_i885.StudentService>(
      () =>
          _i885.StudentService(gh<_i449.ApiClient>(), gh<_i691.PrefService>()),
    );
    gh.factory<_i1072.AuthProvider>(
      () =>
          _i1072.AuthProvider(gh<_i399.AuthService>(), gh<_i691.PrefService>()),
    );
    gh.factory<_i786.StudentProvider>(
      () => _i786.StudentProvider(
        gh<_i885.StudentService>(),
        gh<_i691.PrefService>(),
        gh<_i959.IcueFaceSdk>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i783.RegisterModule {}
