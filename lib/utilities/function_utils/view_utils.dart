import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

void showPicker(
    BuildContext context, List<String> list, Function selectedItemChanged) {
  showCupertinoModalPopup(
      context: context,
      builder: (_) => SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 30,
              scrollController: FixedExtentScrollController(initialItem: 1),
              children: list.map((item) => Text(item.toString())).toList(),
              onSelectedItemChanged: (value) {
                selectedItemChanged(value);
              },
            ),
          ));
}

showOneButtonAlertDialog(BuildContext context, String buttonTitle,
    Function buttonAction, String title, String descriptionTitle) {
  // set up the buttons
  Widget button1 = TextButton(
    child: Text(
      buttonTitle,
      style: const TextStyle(color: Colors.black),
    ),
    onPressed: () {
      buttonAction();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      title,
      style: const TextStyle(color: Colors.black),
    ),
    content: Text(
      descriptionTitle,
      style: const TextStyle(color: Colors.black),
    ),
    actions: [
      button1,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showTwoButtonAlertDialog(
    BuildContext context,
    String button1Title,
    Function button1Action,
    String button2Title,
    Function button2Action,
    String title,
    String descriptionTitle) {
  // set up the buttons
  Widget button1 = TextButton(
    child: Text(
      button1Title,
      style: const TextStyle(color: Colors.black),
    ),
    onPressed: () {
      button1Action();
    },
  );

  Widget button2 = TextButton(
    child: Text(
      button2Title,
      style: const TextStyle(color: Colors.black),
    ),
    onPressed: () {
      button2Action();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      title,
      style: const TextStyle(color: Colors.black),
    ),
    content: Text(
      descriptionTitle,
      style: const TextStyle(color: Colors.black),
    ),
    actions: [button1, button2],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class EditZipcodeDialog extends StatefulWidget {
  final TextEditingController controller;
  final String country;

  const EditZipcodeDialog(
      {Key? key, required this.controller, required this.country})
      : super(key: key);

  @override
  State<EditZipcodeDialog> createState() => _EditZipcodeDialogState();
}

class _EditZipcodeDialogState extends State<EditZipcodeDialog> {
  final GlobalKey<FormState> formKey = GlobalKey();
  bool confirm = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              side: BorderSide(color: AppColors.cardBorder, width: 1.0)),
          child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: SizedBox(
                width: 300,
                child: confirm
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'Save "${widget.controller.text}" to '),
                          const TextSpan(
                              text: "Zipcode",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const TextSpan(text: '?')
                        ])),
                    const SizedBox(
                      height: 32,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              context.tryPop(true);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.appPrimaryGreen,
                            ),
                            child: const Text("Yes")),
                        const SizedBox(
                          width: 16,
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                confirm = false;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.appPrimaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                side: const BorderSide(
                                    color: AppColors.appPrimaryGreen,
                                    width: 2.0),
                              ),
                            ),
                            child: const Text("Cancel")),
                      ],
                    ),
                  ],
                )
                    : Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                          text: TextSpan(children: [
                            const TextSpan(
                                text: 'Edit value for ',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal)),
                            TextSpan(
                                text: widget.country,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ])),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: TextFormField(
                          controller: widget.controller,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            return validateZipcode(widget.country, widget.controller.text);
                          },
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  widget.controller.clear();
                                },
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () async {
                                if (formKey.currentState != null &&
                                    formKey.currentState!.validate()) {
                                  setState(() {
                                    confirm = true;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                AppColors.appPrimaryGreen,
                              ),
                              child: const Text(
                                "Submit",
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            TextButton(
                                onPressed: () {
                                  context.tryPop();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                  AppColors.appPrimaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(4.0),
                                    side: const BorderSide(
                                        color: AppColors.appPrimaryGreen,
                                        width: 2.0),
                                  ),
                                ),
                                child: const Text("Cancel")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }
}

String? validateZipcode(String country, String zipcode) {
  final trimmedValue = zipcode.trim();
  if (trimmedValue.isEmpty) return "Zipcode is empty";
  switch (country) {
    case 'United States':
      if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(trimmedValue)) {
        return 'Enter a 5-digit ZIP code or the ZIP+4 format (e.g., 90210 or 90210-1234).';
      }
    case 'Canada':
      if (!RegExp(r'^[A-Z][0-9][A-Z] ?[0-9][A-Z][0-9]$').hasMatch(trimmedValue)) {
        return 'Enter in the format ANA NAN, using letters and numbers (e.g., M5V 3H5). Spaces are optional.';
      }
    case 'Australia':
      if (!RegExp(r'^\d{4}$').hasMatch(trimmedValue)) {
        return 'Enter a 4-digit postal code (e.g., 2000).';
      }
    case 'South Africa':
      if (!RegExp(r'^\d{4}$').hasMatch(trimmedValue)) {
        return 'Enter a 4-digit postal code (e.g., 8001).';
      }
    case 'Mexico':
      if (!RegExp(r'^\d{5}$').hasMatch(trimmedValue)) {
        return 'Enter a 5-digit postal code (e.g., 01000).';
      }
    default:
      return null;
  }
  return null;
}

class EditTextFieldDialog extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const EditTextFieldDialog(
      {Key? key, required this.controller, required this.label})
      : super(key: key);

  @override
  State<EditTextFieldDialog> createState() => _EditTextFieldDialogState();
}

class _EditTextFieldDialogState extends State<EditTextFieldDialog> {
  final GlobalKey<FormState> formKey = GlobalKey();
  bool confirm = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              side: BorderSide(color: AppColors.cardBorder, width: 1.0)),
          child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: SizedBox(
                width: 300,
                child: confirm
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: 'Save "${widget.controller.text}" to '),
                            TextSpan(
                                text: widget.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const TextSpan(text: '?')
                          ])),
                          const SizedBox(
                            height: 32,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    context.tryPop(true);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.appPrimaryGreen,
                                  ),
                                  child: const Text("Yes")),
                              const SizedBox(
                                width: 16,
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      confirm = false;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.appPrimaryGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      side: const BorderSide(
                                          color: AppColors.appPrimaryGreen,
                                          width: 2.0),
                                    ),
                                  ),
                                  child: const Text("Cancel")),
                            ],
                          ),
                        ],
                      )
                    : Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                                text: TextSpan(children: [
                                  const TextSpan(
                                      text: 'Edit value for ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  TextSpan(
                                      text: widget.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ])),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: TextFormField(
                                controller: widget.controller,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Field can't be empty";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    widget.controller.clear();
                                  },
                                )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      if (formKey.currentState != null &&
                                          formKey.currentState!.validate()) {
                                        setState(() {
                                          confirm = true;
                                        });
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          AppColors.appPrimaryGreen,
                                    ),
                                    child: const Text(
                                      "Submit",
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        context.tryPop();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppColors.appPrimaryGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          side: const BorderSide(
                                              color: AppColors.appPrimaryGreen,
                                              width: 2.0),
                                        ),
                                      ),
                                      child: const Text("Cancel")),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ))),
    );
  }
}

class EditCountryDialog extends StatefulWidget {
  final TextEditingController controller;

  const EditCountryDialog({Key? key, required this.controller})
      : super(key: key);

  @override
  State<EditCountryDialog> createState() => _EditCountryDialogState();
}

class _EditCountryDialogState extends State<EditCountryDialog> {
  final GlobalKey<FormState> formKey = GlobalKey();
  bool confirm = false;
  Country? selectedCountry;

  @override
  void initState() {
    super.initState();

    selectedCountry = widget.controller.text.isEmpty
        ? null
        : countries
            .where((element) => element.name == widget.controller.text)
            .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              side: BorderSide(color: AppColors.cardBorder, width: 1.0)),
          child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: SizedBox(
                width: 300,
                child: confirm
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: 'Save "${widget.controller.text}" to '),
                            const TextSpan(
                                text: "Country",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: '?')
                          ])),
                          const SizedBox(
                            height: 32,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    context.tryPop(true);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.appPrimaryGreen,
                                  ),
                                  child: const Text("Yes")),
                              const SizedBox(
                                width: 16,
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      confirm = false;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.appPrimaryGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      side: const BorderSide(
                                          color: AppColors.appPrimaryGreen,
                                          width: 2.0),
                                    ),
                                  ),
                                  child: const Text("Cancel")),
                            ],
                          ),
                        ],
                      )
                    : Form(
                        key: formKey,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              RichText(
                                  text: const TextSpan(children: [
                                    TextSpan(
                                        text: 'Edit value for ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal)),
                                    TextSpan(
                                        text: "Country",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ])),
                          Row(
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (selectedCountry != null)
                                Image.asset(
                                  'assets/flags/${selectedCountry!.code.toLowerCase()}.png',
                                  package: 'intl_phone_field',
                                  width: 32,
                                  frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) {
                                    Widget widget;
                                    if (wasSynchronouslyLoaded) {
                                      widget = child;
                                    } else {
                                      widget = AnimatedOpacity(
                                        opacity: frame == null ? 0 : 1,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                        child: child,
                                      );
                                    }
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        widget,
                                        const SizedBox(
                                          width: 8,
                                        ),
                                      ],
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox.shrink();
                                  },
                                ),
                              Expanded(
                                child: TextFormField(
                                  controller: widget.controller,
                                  readOnly: true,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Field can't be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) => CountryPickerDialog(
                                              searchText: "",
                                              languageCode: "en",
                                              countryList: countries,
                                              onCountryChanged: (country) {
                                                debugPrint(
                                                    "country selected = ${country.name}");
                                                widget.controller.text =
                                                    country.name;
                                              },
                                              selectedCountry: countries.first,
                                              filteredCountries: countries,
                                              showCountryCode: false,
                                              style: PickerDialogStyle(
                                                  searchFieldInputDecoration:
                                                      const InputDecoration(
                                                suffixIcon: Icon(Icons.search),
                                                labelText: "Search country",
                                                labelStyle: TextStyle(
                                                    color: Colors.black),
                                              )),
                                            ));
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    if (formKey.currentState != null &&
                                        formKey.currentState!.validate()) {
                                      setState(() {
                                        confirm = true;
                                      });
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.appPrimaryGreen,
                                  ),
                                  child: const Text(
                                    "Submit",
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                TextButton(
                                    onPressed: () {
                                      context.tryPop();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          AppColors.appPrimaryGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        side: const BorderSide(
                                            color: AppColors.appPrimaryGreen,
                                            width: 2.0),
                                      ),
                                    ),
                                    child: const Text("Cancel")),
                              ],
                            ),
                          ),
                        ]),
                      ),
              ))),
    );
  }
}

class EditPhoneDialog extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String initialCountryISOName;
  final String initialAreaCode;

  const EditPhoneDialog(
      {Key? key,
      required this.controller,
      required this.label,
      this.initialCountryISOName = "US",
      this.initialAreaCode = "1"})
      : super(key: key);

  @override
  State<EditPhoneDialog> createState() => _EditPhoneDialogState();
}

class _EditPhoneDialogState extends State<EditPhoneDialog> {
  final GlobalKey<FormState> formKey = GlobalKey();
  bool confirm = false;
  late String countryISOName;
  late String areaCode;

  @override
  void initState() {
    super.initState();

    countryISOName = widget.initialCountryISOName;
    areaCode = widget.initialAreaCode;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              side: BorderSide(color: AppColors.cardBorder, width: 1.0)),
          child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: SizedBox(
                width: 300,
                child: confirm
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: 'Save "+$areaCode${widget.controller.text}" to '),
                            TextSpan(
                                text: widget.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const TextSpan(text: '?')
                          ])),
                          const SizedBox(
                            height: 32,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    context.tryPop(PhoneModel(
                                        phoneCountryISOName: countryISOName,
                                        phoneAreaCode: areaCode,
                                        phone: widget.controller.text));
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.appPrimaryGreen,
                                  ),
                                  child: const Text("Yes")),
                              const SizedBox(
                                width: 16,
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      confirm = false;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.appPrimaryGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      side: const BorderSide(
                                          color: AppColors.appPrimaryGreen,
                                          width: 2.0),
                                    ),
                                  ),
                                  child: const Text("Cancel")),
                            ],
                          ),
                        ],
                      )
                    : Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                                text: TextSpan(children: [
                                  const TextSpan(
                                      text: 'Edit value for ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  TextSpan(
                                      text: widget.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ])),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: IntlPhoneField(
                                controller: widget.controller,
                                initialCountryCode: countryISOName,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: AppColors.black1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                dropdownTextStyle: const TextStyle(
                                  color: AppColors.black1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                disableLengthCheck: false,
                                autovalidateMode: AutovalidateMode.disabled,
                                invalidNumberMessage: "Invalid phone number",
                                onCountryChanged: (Country country) {
                                  setState(() {
                                    countryISOName = country.code;
                                    areaCode = country.dialCode;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      if (formKey.currentState != null &&
                                          formKey.currentState!.validate()) {
                                        setState(() {
                                          confirm = true;
                                        });
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          AppColors.appPrimaryGreen,
                                    ),
                                    child: const Text(
                                      "Submit",
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        context.tryPop();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppColors.appPrimaryGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          side: const BorderSide(
                                              color: AppColors.appPrimaryGreen,
                                              width: 2.0),
                                        ),
                                      ),
                                      child: const Text("Cancel")),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ))),
    );
  }
}

extension Dialog on State {
  Future<bool> showEditTextFieldDialog(
      TextEditingController controller, String label) async {
    return (await showDialog(
            context: context,
            builder: (context) {
              return EditTextFieldDialog(
                controller: controller,
                label: label,
              );
            })) ??
        false;
  }

  Future<bool> showEditZipcodeDialog(
      TextEditingController controller, String country) async {
    return (await showDialog(
        context: context,
        builder: (context) {
          return EditZipcodeDialog(
            controller: controller,
            country: country,
          );
        })) ??
        false;
  }

  Future<bool> showEditCountryDialog(TextEditingController controller) async {
    return (await showDialog(
            context: context,
            builder: (context) {
              return EditCountryDialog(controller: controller);
            })) ??
        false;
  }

  Future<PhoneModel?> showEditPhoneDialog(
      TextEditingController controller,
      String initialCountryISOName,
      String initialAreaCode,
      String label) async {
    return (await showDialog(
        context: context,
        builder: (context) {
          return EditPhoneDialog(
            controller: controller,
            initialCountryISOName: initialCountryISOName,
            initialAreaCode: initialAreaCode,
            label: label,
          );
        }));
  }
}
