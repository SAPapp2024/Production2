import 'dart:io';

import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/utilities/function_utils/version_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@injectable
class MinVersionBloc extends Cubit<MinVersionState> {
  MinVersionBloc()
      : super(const MinVersionState(status: AppVersionStatus.initial));

  void listenAppVersion() async {
    if (kIsWeb) return;
    await FirebaseFirestore.instance.disableNetwork();
    await FirebaseFirestore.instance.enableNetwork();
    FirebaseFirestore.instance
        .collection("admin")
        .doc("version")
        .snapshots()
        .listen((event) async {
      try {
        if (event.exists) {
          var minVersion = event.data()!;
          String minimum;
          if (Platform.isAndroid) {
            minimum = minVersion["android_minimum"];
          } else if (Platform.isIOS) {
            minimum = minVersion["ios_minimum"];
          } else {
            return;
          }
          var status = await getAppVersionStatus(
              AppVersionMinimumAndLatest(minimum: minimum, latest: "1.0.0+1"));
          debugPrint("Status: $status");
          emit(state.copyWith(status: status));
        } else {
          emit(state.copyWith(status: AppVersionStatus.upToDate));
          debugPrint("Error en listenAppVersion: Document does not exist");
          return;
        }
      } catch (exception, stacktrace) {
        getIt
            .get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
        debugPrint("Error en listenAppVersion: $exception");
        emit(state.copyWith(status: AppVersionStatus.upToDate));
      }
    }, onError: (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      debugPrint("Error en onError: $exception");
      emit(state.copyWith(status: AppVersionStatus.upToDate));
    });
  }

  Future<AppVersionStatus> getAppVersionStatus(
      AppVersionMinimumAndLatest appVersionMinimumAndLatest) async {
    final minimumVersion = appVersionMinimumAndLatest.minimum.toString();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    List<String> versionParts = version.split('.');
    List<String> minimumVersionParts = minimumVersion.split('+')[0].split('.');

    bool isAboveMinimum = true;
    for (int i = 0; i < minimumVersionParts.length; i++) {
      try {
        if (int.parse(versionParts[i]) > int.parse(minimumVersionParts[i])) {
          break;
        } else if (int.parse(versionParts[i]) <
            int.parse(minimumVersionParts[i])) {
          isAboveMinimum = false;
          break;
        }
      } catch (e) {
        debugPrint("Error parsing version or minimum version parts: $e");
        isAboveMinimum = false;
        break;
      }
    }
    if (!isAboveMinimum) {
      return AppVersionStatus.belowMinimum;
    }
    debugPrint(
        "int.parse(minimumVersion.split('+')[1]) < int.parse(buildNumber) ${int.parse(minimumVersion.split('+')[1]) < int.parse(buildNumber)} // ${int.parse(minimumVersion.split('+')[1])} , ${int.parse(buildNumber)}");
    if (int.parse(minimumVersion.split('+')[1]) > int.parse(buildNumber)) {
      return AppVersionStatus.belowMinimum;
    }

    return AppVersionStatus.upToDate;
  }
}

class MinVersionState extends Equatable {
  const MinVersionState({required this.status});

  final AppVersionStatus? status;

  @override
  List<Object?> get props => [status];

  MinVersionState copyWith({AppVersionStatus? status}) {
    return MinVersionState(status: status ?? this.status);
  }
}

enum AppVersionStatus {
  initial,
  upToDate,
  belowMinimum,
}
