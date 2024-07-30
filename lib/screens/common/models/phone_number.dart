import 'package:agro_k/models/user/phone_model.dart';
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

class PhoneNumber extends FormzInput<PhoneModel, RequiredFieldValidationError> {
  const PhoneNumber.pure() : super.pure(const PhoneModel());

  const PhoneNumber.dirty([super.value = const PhoneModel()]) : super.dirty();

  @override
  RequiredFieldValidationError? validator(PhoneModel value) {
    return null;
  }
}
