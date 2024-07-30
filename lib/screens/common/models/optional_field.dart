import 'package:formz/formz.dart';

enum OptionalFieldValidationError { none }

class OptionalField extends FormzInput<String, OptionalFieldValidationError> {
  const OptionalField.pure() : super.pure('');

  const OptionalField.dirty([super.value = '']) : super.dirty();

  @override
  OptionalFieldValidationError? validator(String value) {
    return null;
  }
}
