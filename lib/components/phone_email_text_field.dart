import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/function_utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

//ignore: must_be_immutable
class PhoneEmailTextField extends StatelessWidget {

  PhoneEmailTextField({
    Key? key,
    required this.controller,
    required this.isEmail,
    required this.phoneValid,
    required this.onChanged,
  }) : super(key: key);

  final TextEditingController controller;
  bool isEmail;
  bool phoneValid;
  Function onChanged;

  @override
  Widget build(BuildContext context) {
    if (isEmail) {
      return Form(
        child: TextFormField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          validator: (value) {
            try {
              validateEmail(value);
            } on AuthErrors catch (err) {
              return err.errorDescription;
            }
            return null;
          },
          decoration: const InputDecoration(
            labelText: "Phone Number or Email",
            border: OutlineInputBorder(),
            errorStyle: TextStyle(color: Colors.red),
          ),
          onChanged: (email) {
            if (email.isEmpty || isNumeric(email)) {
              onChanged(false, email);
            }
          },
        ),
      );
    } else {
      return Form(
        child: IntlPhoneField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.black),
            keyboardType: TextInputType.emailAddress,
            dropdownTextStyle: const TextStyle(color: Colors.black),
            pickerDialogStyle:
                PickerDialogStyle(countryCodeStyle: const TextStyle(color: Colors.black), countryNameStyle: const TextStyle(color: Colors.black)),
            validator: (value) {
              try {
                validateEmail(value?.number);
              } on AuthErrors catch (err) {
                return err.errorDescription;
              }
              return null;
            },
            decoration: const InputDecoration(
              prefixStyle: TextStyle(color: Colors.black),
              labelStyle: TextStyle(color: Colors.black),
              labelText: 'Phone Number or Email',
              border: OutlineInputBorder(
                borderSide: BorderSide(),
              ),
            ),
            initialCountryCode: 'US',
            onChanged: (phone) {
              Country country = countries.firstWhere((element) => "+${element.dialCode}" == phone.countryCode);
              if (phone.number.length == country.maxLength || phone.number.length > country.minLength && phone.number.length < country.maxLength) {
                phoneValid = false;
              } else {
                phoneValid = true;
              }
              if (phone.number.isNotEmpty && !isNumeric(phone.number)) {
                onChanged(true, phone.number);
              }
            }),
      );
    }
  }
}
