import 'package:formz/formz.dart';

enum ConfirmPasswordValidationError {
  empty,
  mismatch,
}

extension ConfirmPasswordValidationErrorDescription on ConfirmPasswordValidationError {
  String? getDescription() {
    switch (this) {
      case ConfirmPasswordValidationError.empty:
        return 'Password is empty';
      case ConfirmPasswordValidationError.mismatch:
        return 'Passwords do not match';
      default:
        return null;
    }
  }
}

class ConfirmPassword extends FormzInput<String, ConfirmPasswordValidationError> {
  final String password;

  const ConfirmPassword.pure({
      this.password = ''
  }) : super.pure('');

  const ConfirmPassword.dirty({this.password = '', String value = ''}) : super.dirty(value);

  @override
  ConfirmPasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return ConfirmPasswordValidationError.empty;
    }
    return password == value
        ? null
        : ConfirmPasswordValidationError.mismatch;
  }
}
