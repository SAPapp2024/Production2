import 'package:formz/formz.dart';

enum RequiredFieldValidationError { empty }

extension RequiredFieldValidationErrorDescription on RequiredFieldValidationError {
  String? getDescription(String label) {
    switch (this) {
      case RequiredFieldValidationError.empty:
        return '$label is empty';
      default:
        return null;
    }
  }
}

class RequiredField extends FormzInput<String, RequiredFieldValidationError> {
  const RequiredField.pure() : super.pure('');

  const RequiredField.dirty([super.value = '']) : super.dirty();

  @override
  RequiredFieldValidationError? validator(String value) {
    if (value.isEmpty) return RequiredFieldValidationError.empty;
    return null;
  }
}
