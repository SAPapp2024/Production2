// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:agro_k/app/setup/injectable_setup.dart' as _i787;
import 'package:agro_k/app/setup/min_version_bloc.dart' as _i1033;
import 'package:agro_k/app/setup/user_state.dart' as _i284;
import 'package:agro_k/services/auth_service.dart' as _i89;
import 'package:agro_k/services/location_service.dart' as _i449;
import 'package:agro_k/services/members_service.dart' as _i454;
import 'package:agro_k/services/payment_service.dart' as _i937;
import 'package:agro_k/services/profile_service.dart' as _i249;
import 'package:agro_k/services/sample_service.dart' as _i281;
import 'package:agro_k/utilities/remote_error_logging_service.dart' as _i491;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:injectable/injectable.dart' as _i526;
import 'package:typesense/typesense.dart' as _i47;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final routeModule = _$RouteModule();
    gh.factory<_i1033.MinVersionBloc>(() => _i1033.MinVersionBloc());
    gh.factory<_i449.LocationService>(() => _i449.LocationService());
    gh.factory<_i281.SampleService>(() => _i281.SampleService());
    gh.factory<_i249.ProfileService>(() => _i249.ProfileService());
    gh.factory<_i454.MembersService>(() => _i454.MembersService());
    gh.factory<_i89.AuthService>(() => _i89.AuthService());
    gh.factory<_i937.PaymentService>(() => _i937.PaymentService());
    gh.singleton<_i491.RemoteErrorLoggingService>(
        () => routeModule.errorLoggingService);
    gh.singleton<_i284.UserState>(() => _i284.UserState());
    gh.lazySingleton<_i583.GoRouter>(() => routeModule.router());
    gh.singletonAsync<_i47.Client>(
      () => routeModule.typesenseClientDev(),
      registerFor: {_dev},
    );
    gh.singletonAsync<_i47.Client>(
      () => routeModule.typesenseClientProd(),
      registerFor: {_prod},
    );
    return this;
  }
}

class _$RouteModule extends _i787.RouteModule {}
