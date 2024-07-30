import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionUtils {

  static Future<String> getAppVersionString(Environment environment) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "${packageInfo.version} (${packageInfo.buildNumber})";
  }

  static Future<AppVersion> getAppVersion(Environment environment) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return AppVersion(name: packageInfo.version, code: packageInfo.buildNumber);
  }
}

class AppVersion extends Equatable {
  final String name;
  final String code;

  @override
  List<Object?> get props => [name, code];

  @override
  String toString() => "$name+$code";

  const AppVersion({required this.name, required this.code});
}



class AppVersionMinimumAndLatest {
  final String minimum;
  final String latest;

  AppVersionMinimumAndLatest({required this.minimum, required this.latest});
}
