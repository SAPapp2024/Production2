// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:agro_k/app/setup/injectable_setup.dart' as _i14;
import 'package:agro_k/app/setup/min_version_bloc.dart' as _i8;
import 'package:agro_k/app/setup/user_state.dart' as _i13;
import 'package:agro_k/services/auth_service.dart' as _i3;
import 'package:agro_k/services/location_service.dart' as _i6;
import 'package:agro_k/services/members_service.dart' as _i7;
import 'package:agro_k/services/payment_service.dart' as _i9;
import 'package:agro_k/services/profile_service.dart' as _i10;
import 'package:agro_k/services/sample_service.dart' as _i12;
import 'package:agro_k/utilities/remote_error_logging_service.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:go_router/go_router.dart' as _i5;
import 'package:injectable/injectable.dart' as _i2;
import 'package:typesense/typesense.dart' as _i4;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final routeModule = _$RouteModule();
    gh.factory<_i3.AuthService>(() => _i3.AuthService());
    gh.singletonAsync<_i4.Client>(
      () => routeModule.typesenseClientDev(),
      registerFor: {_dev},
    );
    gh.singletonAsync<_i4.Client>(
      () => routeModule.typesenseClientProd(),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i5.GoRouter>(() => routeModule.router());
    gh.factory<_i6.LocationService>(() => _i6.LocationService());
    gh.factory<_i7.MembersService>(() => _i7.MembersService());
    gh.factory<_i8.MinVersionBloc>(() => _i8.MinVersionBloc());
    gh.factory<_i9.PaymentService>(() => _i9.PaymentService());
    gh.factory<_i10.ProfileService>(() => _i10.ProfileService());
    gh.singleton<_i11.RemoteErrorLoggingService>(
        routeModule.errorLoggingService);
    gh.factory<_i12.SampleService>(() => _i12.SampleService());
    gh.singleton<_i13.UserState>(_i13.UserState());
    return this;
  }
}

class _$RouteModule extends _i14.RouteModule {}
