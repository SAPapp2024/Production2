import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:agro_k/utilities/function_utils/version_utils.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract class RemoteErrorLoggingService {
  Future<void> setCurrentUser(String? id);
  Future<void> init(Environment environment);
  Future<void> setCustomKey(String key, dynamic value);
  Future<void> log(String message);
  Future<void> recordError(dynamic exception, StackTrace stack,
      {bool fatal = false});
}

class LocalErrorLoggingService implements RemoteErrorLoggingService {
  @override
  Future<void> setCurrentUser(String? id) async {}

  @override
  Future<void> init(Environment environment) async {}

  @override
  Future<void> setCustomKey(String key, dynamic value) async {}

  @override
  Future<void> log(String message) async {
    debugPrint(message);
  }

  @override
  Future<void> recordError(dynamic exception, StackTrace stack,
      {bool fatal = false}) async {
    debugPrint("Error recorded: $exception $stack");
  }
}

class FirebaseCrashlyticsService implements RemoteErrorLoggingService {
  @override
  Future<void> setCurrentUser(String? id) =>
      FirebaseCrashlytics.instance.setUserIdentifier(id ?? "");

  @override
  Future<void> init(Environment environment) async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    var appVersionLabel = await _getAppVersionCrashlyticsLabel(environment);
    await FirebaseCrashlytics.instance
        .setCustomKey("app_version", appVersionLabel);
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) =>
      FirebaseCrashlytics.instance.setCustomKey(key, value);

  @override
  Future<void> log(String message) async {
    await FirebaseCrashlytics.instance.log(message);
  }

  @override
  Future<void> recordError(dynamic exception, StackTrace stack,
      {bool fatal = false}) async {
    await FirebaseCrashlytics.instance
        .recordError(exception, stack, fatal: fatal);
    debugPrint("Error recorded: $exception $stack");
  }

  Future<String> _getAppVersionCrashlyticsLabel(Environment environment) async {
    String appVersion;
    try {
      appVersion = await VersionUtils.getAppVersionString(environment);
    } catch (e) {
      appVersion = "Unknown";
    }
    return "${environment == Environment.prod ? "Prod" : "Dev"} - $appVersion";
  }
}
