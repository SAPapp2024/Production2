import 'package:formz/formz.dart';

enum EmailValidationError { empty, invalidEmail }

extension EmailValidationErrorDescription on EmailValidationError {
  String? getDescription() {
    switch (this) {
      case EmailValidationError.empty:
        return 'Email is empty';
      case EmailValidationError.invalidEmail:
        return 'Email is invalid';
      default:
        return null;
    }
  }
}

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');

  const Email.dirty([super.value = '']) : super.dirty();

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!isValidEmail(value)) return EmailValidationError.invalidEmail;
    return null;
  }

}

bool isValidEmail(String value) {
  return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(value);
}
