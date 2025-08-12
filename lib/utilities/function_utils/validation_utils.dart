import 'dart:math';

import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:flutter/services.dart';

void validateEmail(String? email) {
  if (email == null || email == "") {
    throw AuthErrors.missingEmail;
  }

  if (isValidEmail(email)) {
    throw AuthErrors.invalidEmailFormat;
  }
}

void validatePhone(String? phone) {
  if (phone == null || phone == "") {
    throw AuthErrors.missingPhone;
  }

  //check phone format
  // if () {
  //   throw AuthErrors.invalidPhoneFormat;
  // }
}

//Validate Password
void validatePassword(String? password) {
  if (password == null || password == "") {
    throw AuthErrors.missingPassword;
  }

  //commenting out for now because firebase password reset has no minimum length
  //We can use this once we create custom password reset screen for firebase.
  // if (password.length < 8) {
  //   throw AuthErrors.passwordTooShort;
  // }

  if (password.length > 64) {
    throw AuthErrors.passwordTooLong;
  }
}

class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newValueString = newValue.text;
    String valueToReturn = '';
    var slashIter = 0;
    for (int i = 0; i < min(5, newValueString.length); i++) {
      if (newValueString[i] != '/' && int.tryParse(newValueString[i]) != null) {
        valueToReturn += newValueString[i];
        slashIter++;
      }
      final contains = valueToReturn.contains(RegExp(r'/'));
      if (slashIter == 2 &&
          slashIter != newValueString.length &&
          !(contains)) {
        valueToReturn += '/';
      }
    }
    return newValue.copyWith(
      text: valueToReturn,
      selection: TextSelection.fromPosition(
        TextPosition(offset: valueToReturn.length),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}