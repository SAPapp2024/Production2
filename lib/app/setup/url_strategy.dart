import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void removeHashtagFromUrls() {
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
}