import 'package:formz/formz.dart';

enum ZipcodeValidationError { empty, invalidUSA, invalidCanada, invalidAustralia, invalidSouthAfrica, invalidMexico }

extension ZipcodeValidationErrorDescription on ZipcodeValidationError {
  String? getDescription(String label) {
    switch (this) {
      case ZipcodeValidationError.empty:
        return '$label is empty';
      case ZipcodeValidationError.invalidUSA:
        return 'Enter a 5-digit ZIP code or the ZIP+4 format (e.g., 90210 or 90210-1234).';
      case ZipcodeValidationError.invalidCanada:
        return 'Enter in the format ANA NAN, using letters and numbers (e.g., M5V 3H5). Spaces are optional.';
      case ZipcodeValidationError.invalidAustralia:
        return 'Enter a 4-digit postal code (e.g., 2000).';
      case ZipcodeValidationError.invalidSouthAfrica:
        return 'Enter a 4-digit postal code (e.g., 8001).';
      case ZipcodeValidationError.invalidMexico:
        return 'Enter a 5-digit postal code (e.g., 01000).';
    }
  }
}

class Zipcode extends FormzInput<String, ZipcodeValidationError> {
  final String country;
  const Zipcode.pure(this.country) : super.pure('');

  const Zipcode.dirty(this.country, [super.value = '']) : super.dirty();

  @override
  ZipcodeValidationError? validator(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) return ZipcodeValidationError.empty;
    switch (country) {
      case 'United States':
        if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(trimmedValue)) {
          return ZipcodeValidationError.invalidUSA;
        }
      case 'Canada':
        if (!RegExp(r'^[A-Z][0-9][A-Z] ?[0-9][A-Z][0-9]$').hasMatch(trimmedValue)) {
          return ZipcodeValidationError.invalidCanada;
        }
      case 'Australia':
        if (!RegExp(r'^\d{4}$').hasMatch(trimmedValue)) {
          return ZipcodeValidationError.invalidAustralia;
        }
      case 'South Africa':
        if (!RegExp(r'^\d{4}$').hasMatch(trimmedValue)) {
          return ZipcodeValidationError.invalidSouthAfrica;
        }
      case 'Mexico':
        if (!RegExp(r'^\d{5}$').hasMatch(trimmedValue)) {
          return ZipcodeValidationError.invalidMexico;
        }
      default:
        return null;
    }
    return null;
  }
}
