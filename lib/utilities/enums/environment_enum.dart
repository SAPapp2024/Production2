import 'package:injectable/injectable.dart' as prefix;

enum Environment { prod, qa }

extension Env on Environment {
  prefix.Environment toEnvironmentClass() {
    switch (this) {
      case Environment.prod:
        return prefix.prod;
      case Environment.qa:
        return prefix.dev;
    }
  }
}