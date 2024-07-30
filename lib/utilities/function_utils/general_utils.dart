import 'dart:io';

import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:collection/collection.dart';

bool areListsEqual(List list1, List list2) {
  // check if both are lists
  if (list1.length != list2.length) {
    return false;
  }
  // check if elements are equal
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }
  return true;
}

Future<String> getAppVersion(Environment environment) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return "${packageInfo.version} (${packageInfo.buildNumber})";
}

final restrictedInputFormatterForFirestoreKeys =
    FilteringTextInputFormatter.allow(RegExp(r"[^./\\\[\]*]"));

class RestrictedInputFormatter extends TextInputFormatter {
  final List<String> restrictedCharacters;

  RestrictedInputFormatter(this.restrictedCharacters);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String filteredText = newValue.text;

    for (String restrictedChar in restrictedCharacters) {
      filteredText = filteredText.replaceAll(restrictedChar, '');
    }

    return newValue.copyWith(text: filteredText);
  }
}

class UrlUtils {
  static Future<void> launchUrl(String url) async {
    if (!Platform.isIOS || await _canLaunchUrl(iosTestFlightUrl)) {
      final Uri uri = Uri.parse(url);
      await url_launcher.launchUrl(uri,
          mode: url_launcher.LaunchMode.externalApplication);
    }
  }

  static Future<bool> _canLaunchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    return url_launcher.canLaunchUrl(uri);
  }

  static const String androidFirebaseAppDistributionUrl =
      'https://appdistribution.firebase.google.com/u/1/testerapps/1:777747429758:android:bb3dc2de18f3bbc05fdb2f';
  static const String iosTestFlightUrl = 'itms-beta://';
}

class ConversionUtils {
  static Map<String, T> mapMapSafely<T>(
      dynamic data, T Function(dynamic) convert, String label) {
    if (data is! Map<String, dynamic>) return {};
    Map<String, T> res;
    try {
      res = (data.map<String?, T?>(
        (k, e) {
          try {
            return MapEntry(k, convert(e));
          } catch (e) {
            debugPrint(e.toString());
            return const MapEntry(null, null);
          }
        },
      )..removeWhere((key, value) => key == null || value == null))
          .map((key, value) => MapEntry(key!, value as T));
    } catch (e) {
      debugPrint("error on label $label = $e");
      res = {};
    }
    return res;
  }

  static Map<String, List<T>> mapMapWithListSafely<T extends Object>(
      Map<String, dynamic> data, T Function(dynamic) convert, String label) {
    Map<String, List<T>> res;
    try {
      res = (data.map<String?, List<T>>(
        (k, e) {
          try {
            List<dynamic> list = e;
            List<T> mappedList = list
                .map((item) {
                  try {
                    return convert(item);
                  } catch (e) {
                    debugPrint("Error on label $label = $e");
                    return null;
                  }
                })
                .whereNotNull()
                .toList();
            return MapEntry(k, mappedList);
          } catch (e) {
            debugPrint("Error on label $label = $e");
            return const MapEntry(null, []);
          }
        },
      )..removeWhere((key, value) => key == null))
          .map((key, value) => MapEntry(key!, value));
    } catch (e) {
      debugPrint("Error on label $label = $e");
      res = {};
    }
    return res;
  }

  static castWithDefault<T>(dynamic fieldToCast, T Function(dynamic) converter, String label, {required T defaultValue}) {
    try {
      return converter(fieldToCast);
    } catch (e) {
      debugPrint("Error on label $label = $e");
      return defaultValue;
    }
  }

  static castWithDefaultNullable<T>(dynamic fieldToCast, T Function(dynamic) converter, String label, {required T defaultValue}) {
    try {
      if (fieldToCast == null) return null;
      return converter(fieldToCast);
    } catch (e) {
      debugPrint("Error on label $label = $e");
      return defaultValue;
    }
  }
}
