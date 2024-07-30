import 'package:agro_k/app/routes.dart';
import 'package:agro_k/app/setup/injectable_setup.config.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/typesense_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:typesense/typesense.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart' as prefix;

final getIt = GetIt.instance;

@injectableInit
configureDependencies(Environment environment) => getIt.init(environment: environment.name);

@module
abstract class RouteModule {
  @lazySingleton
  GoRouter router() => getRouter();

  @dev
  @singleton
  Future<Client> typesenseClientDev() => setupTypesense(prefix.Environment.qa);

  @prod
  @singleton
  Future<Client> typesenseClientProd() => setupTypesense(prefix.Environment.prod);

  @singleton
  RemoteErrorLoggingService get errorLoggingService => kIsWeb ? LocalErrorLoggingService() : FirebaseCrashlyticsService();
}
