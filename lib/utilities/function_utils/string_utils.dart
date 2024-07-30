import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:collection/collection.dart';

extension Ellipsis on String {
  String setEllipsisOnOverflow(int maxCharacters) {
    return length > maxCharacters ? '${substring(0, maxCharacters)}...' : this;
  }
}

String capitalizeLastWord(String text) {
  try {
    String trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return trimmedText;
    }
    List<String> words = trimmedText.split(" ");
    return words.mapIndexed((index, word) {
      if (index == words.length - 1) {
        return capitalize(word);
      } else {
        return word;
      }
    }).join(" ");
  } catch (exception, stacktrace) {
    getIt.get<RemoteErrorLoggingService>()
        .recordError(exception, stacktrace);
    return text;
  }
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}

String formatUSNumber(String phoneNumber) {
  if (phoneNumber.length != 10) {
    return phoneNumber;
  }
  return "(${phoneNumber.substring(0, 3)})-${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6, phoneNumber.length)}";
}

bool isValidEmail(String email) {
  return !RegExp(
          r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(email);
}

String capitalize(String s) =>
    s.length > 1 ? s[0].toUpperCase() + s.substring(1) : s.toUpperCase();
