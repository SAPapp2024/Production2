import 'package:formz/formz.dart';

enum PasswordValidationError { empty }

extension PasswordValidationErrorDescription on PasswordValidationError {
  String? getDescription() {
    switch (this) {
      case PasswordValidationError.empty:
        return 'Password is empty';
      default:
        return null;
    }
  }
}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');

  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    return null;
  }
}
