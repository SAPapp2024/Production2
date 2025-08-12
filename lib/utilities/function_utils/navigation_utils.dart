import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension Navigation on BuildContext {
  void goBackWeb([String fallbackRoute = DashboardScreen.id]) {
    if (canPop()) {
      pop();
    } else {
      goNamed(fallbackRoute);
    }
  }

  void tryPop<T extends Object?>([T? result]) {
    try {
      pop(result);
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>()
          .recordError(exception, stacktrace);
    }
  }
}