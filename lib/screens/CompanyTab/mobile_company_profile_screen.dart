import 'dart:core';

import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/card_with_info_rows.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/screens/CompanyTab/purchase_barcodes_screen.dart';
import 'package:agro_k/screens/edit_company_profile_screen.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/utility_models/info_row.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/theme/colors.dart';

class MobileCompanyProfileScreen extends StatefulWidget {
  final UserModel user;
  final CompanyModel company;

  const MobileCompanyProfileScreen(
      {Key? key, required this.user, required this.company})
      : super(key: key);

  @override
  State<MobileCompanyProfileScreen> createState() =>
      _MobileCompanyProfileScreenState();
}

class _MobileCompanyProfileScreenState
    extends State<MobileCompanyProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ProfileService profileService = getIt.get();
  AuthService authService = getIt.get();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _companyAddress = TextEditingController();
  final TextEditingController _companyCity = TextEditingController();
  final TextEditingController _companyState = TextEditingController();
  final TextEditingController _companyZip = TextEditingController();
  final TextEditingController _companyCountry = TextEditingController();

  final TextEditingController _companyPhone = TextEditingController();
  String _companyPhoneAreaCode = "";
  String _companyPhoneCountryISOName = "";

  final TextEditingController _companyAltPhone = TextEditingController();
  String _companyAltPhoneAreaCode = "";
  String _companyAltPhoneCountryISOName = "";
  Country? selectedCountry =
      countries.where((element) => element.name == "United States").firstOrNull;
  List<String> listOfStates = Provinces.usaStates;
  bool _readOnly = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  void didUpdateWidget(covariant MobileCompanyProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.company != oldWidget.company) {
      getData();
    }
  }

  void getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await getCompany(widget.company);
    } on FirebaseException catch (e) {
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            getData();
          },
          "Go back",
          () {
            Navigator.pop(context);
            context.tryPop();
          },
          "Error",
          e.message ?? "Unknown error.");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getCompany(CompanyModel company) async {
    setState(() {
      _companyName.text = company.name;
      _companyAddress.text = company.address;
      _companyCity.text = company.city;
      _companyState.text = company.state;
      _companyZip.text = company.zipcode;
      _companyPhone.text = company.phone?.phone ?? "";
      _companyPhoneAreaCode = company.phone?.phoneAreaCode ?? "1";
      _companyPhoneCountryISOName = company.phone?.phoneCountryISOName ?? "US";
      _companyAltPhone.text = company.alternatePhone?.phone ?? "";
      _companyAltPhoneAreaCode = company.alternatePhone?.phoneAreaCode ?? "1";
      _companyAltPhoneCountryISOName =
          company.alternatePhone?.phoneCountryISOName ?? "US";
      selectedCountry = company.country.isNotEmpty
          ? countries
              .where((country) => country.name == company.country)
              .firstOrNull
          : null;
      _companyCountry.text = selectedCountry?.name ?? "";
    });
  }

  void saveCompanyData(ProfileService service) {
    service.updateCompanyProfile(
        companyName: _companyName.text,
        address: _companyAddress.text,
        city: _companyCity.text,
        state: _companyState.text,
        country: selectedCountry?.name ?? "",
        zip: _companyZip.text,
        phone: _companyPhone.text.isEmpty
            ? null
            : PhoneModel(
                phone: _companyPhone.text,
                phoneAreaCode: _companyPhoneAreaCode,
                phoneCountryISOName: _companyPhoneCountryISOName),
        altPhone: _companyAltPhone.text.isEmpty
            ? null
            : PhoneModel(
                phone: _companyAltPhone.text,
                phoneAreaCode: _companyAltPhoneAreaCode,
                phoneCountryISOName: _companyAltPhoneCountryISOName),
        companyReference: widget.company.getReference());
  }

  Widget createCompanyProfile() {
    var isAdmin = getIt.get<UserState>().isCompanyAdmin();
    var phoneFocusNode = FocusNode();
    var alternatePhoneFocusNode = FocusNode();
    return Stack(children: [
      Form(
        key: _formKey,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: createGroupRow("Company Name", _companyName, isAdmin),
          ),
          createGroupRow("Company Address", _companyAddress, isAdmin),
          createGroupRow("Company City", _companyCity, isAdmin),
          createCountryGroupRow(isAdmin),
          Row(
            children: [
              Expanded(
                child: createGroupRow(
                    "Company State/Province", _companyState, isAdmin),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Company Zip",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                      child: TextFormField(
                        controller: _companyZip,
                        readOnly: _readOnly || !isAdmin,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(5),
                        ],
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(phoneFocusNode);
                        },
                        validator: (value) {
                          final zipcodeTrimmed = value?.trim() ?? "";
                          if (zipcodeTrimmed.isEmpty) {
                            return "Zipcode can't be empty";
                          }
                          switch (_companyCountry.text.trim()) {
                            case 'United States':
                              if (!RegExp(r'^\d{5}(-\d{4})?$')
                                  .hasMatch(zipcodeTrimmed)) {
                                return 'Enter a 5-digit ZIP code or the ZIP+4 format (e.g., 90210 or 90210-1234).';
                              }
                            case 'Canada':
                              if (!RegExp(r'^[A-Z][0-9][A-Z] ?[0-9][A-Z][0-9]$')
                                  .hasMatch(zipcodeTrimmed)) {
                                return 'Enter in the format ANA NAN, using letters and numbers (e.g., M5V 3H5). Spaces are optional.';
                              }
                            case 'Australia':
                              if (!RegExp(r'^\d{4}$')
                                  .hasMatch(zipcodeTrimmed)) {
                                return 'Enter a 4-digit postal code (e.g., 2000).';
                              }
                            case 'South Africa':
                              if (!RegExp(r'^\d{4}$')
                                  .hasMatch(zipcodeTrimmed)) {
                                return 'Enter a 4-digit postal code (e.g., 8001).';
                              }
                            case 'Mexico':
                              if (!RegExp(r'^\d{5}$')
                                  .hasMatch(zipcodeTrimmed)) {
                                return 'Enter a 5-digit postal code (e.g., 01000).';
                              }
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          border: (_readOnly || !isAdmin)
                              ? InputBorder.none
                              : const OutlineInputBorder(),
                        ),
                        style: const TextStyle(
                          color: AppColors.black1,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phone",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  _companyPhoneCountryISOName.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                          child: IntlPhoneField(
                            controller: _companyPhone,
                            readOnly: _readOnly,
                            focusNode: phoneFocusNode,
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(alternatePhoneFocusNode);
                            },
                            initialCountryCode: _companyPhoneCountryISOName,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border: (_readOnly)
                                  ? InputBorder.none
                                  : const OutlineInputBorder(),
                            ),
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
                            disableLengthCheck: true,
                            enabled: !_readOnly && isAdmin,
                            onCountryChanged: (Country country) {
                              setState(() {
                                _companyPhoneCountryISOName = country.code;
                                _companyPhoneAreaCode = country.dialCode;
                              });
                            },
                          ),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Alternate Phone",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  _companyAltPhoneCountryISOName.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                          child: IntlPhoneField(
                            controller: _companyAltPhone,
                            readOnly: _readOnly,
                            focusNode: alternatePhoneFocusNode,
                            initialCountryCode: _companyAltPhoneCountryISOName,
                            decoration: InputDecoration(
                              border: (_readOnly)
                                  ? InputBorder.none
                                  : const OutlineInputBorder(),
                            ),
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
                            disableLengthCheck: true,
                            enabled: !_readOnly && isAdmin,
                            onCountryChanged: (Country country) {
                              setState(() {
                                _companyAltPhoneCountryISOName = country.code;
                                _companyAltPhoneAreaCode = country.dialCode;
                              });
                            },
                          ),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
          ])
        ]),
      ),
      Visibility(
        visible: getIt.get<UserState>().isCompanyAdmin(),
        child: Align(
          alignment: Alignment.topRight,
          child: TextButton(
              onPressed: () {
                if (!_readOnly) {
                  phoneFocusNode.unfocus();
                  alternatePhoneFocusNode.unfocus();
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  saveData();
                  showOneButtonAlertDialog(context, "Ok", () {
                    Navigator.pop(context);
                  }, "Saved", "Profile has been saved");
                } else {
                  setState(() {
                    _readOnly = false;
                  });
                }
              },
              child: Text(
                _readOnly ? "Edit profile" : "Done",
                style: const TextStyle(color: AppColors.appPrimaryGreen),
              )),
        ),
      )
    ]);
  }

  Widget createGroupRow(
      String title, TextEditingController titleValue, bool canUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
          child: TextFormField(
            controller: titleValue,
            readOnly: _readOnly || !canUpdate,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: (_readOnly || !canUpdate)
                  ? InputBorder.none
                  : const OutlineInputBorder(),
            ),
            style: const TextStyle(
              color: AppColors.black1,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget createStateGroupRow(bool canUpdate) {
    var canEdit = !(_readOnly || !canUpdate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Company State/Province",
          style: TextStyle(
              color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
            child: FormField<String>(
              builder: (FormFieldState<String> formState) {
                return InputDecorator(
                  decoration: InputDecoration(
                      // labelStyle: textStyle,
                      // errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
                      hintText: 'Please select your state',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  isEmpty: _companyState.text == '',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _companyState.text == "" ||
                              !listOfStates.contains(_companyState.text)
                          ? null
                          : _companyState.text,
                      isDense: true,
                      onChanged: canEdit
                          ? (newValue) {
                              setState(() {
                                _companyState.text = newValue ?? "";
                              });
                            }
                          : null,
                      items: listOfStates.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            )),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget createCountryGroupRow(bool canUpdate) {
    var canEdit = !(_readOnly || !canUpdate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Company Country",
          style: TextStyle(
              color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
          child: Container(
            padding: canEdit
                ? const EdgeInsets.symmetric(horizontal: 8)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
                border: !canEdit
                    ? null
                    : Border.all(color: AppColors.grayTextColor),
                borderRadius: const BorderRadius.all(Radius.circular(4.0))),
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (selectedCountry != null)
                  Image.asset(
                    'assets/flags/${selectedCountry!.code.toLowerCase()}.png',
                    package: 'intl_phone_field',
                    width: 32,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      Widget widget;
                      if (wasSynchronouslyLoaded) {
                        widget = child;
                      } else {
                        widget = AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                    controller: _companyCountry,
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: AppColors.black1,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    onTap: !canEdit
                        ? null
                        : () {
                            showDialog(
                                context: context,
                                builder: (ctx) => CountryPickerDialog(
                                      searchText: "",
                                      languageCode: "en",
                                      countryList: countries,
                                      onCountryChanged: (country) {
                                        debugPrint(
                                            "country selected = ${country.name}");
                                        _companyCountry.text = country.name;
                                        listOfStates = Provinces.getProvinces(
                                            country.name);
                                        if (!listOfStates
                                            .contains(_companyState.text)) {
                                          _companyState.text = "";
                                        }
                                        setState(() {
                                          selectedCountry = country;
                                        });
                                      },
                                      selectedCountry: countries.first,
                                      filteredCountries: countries,
                                      showCountryCode: false,
                                      style: PickerDialogStyle(
                                          searchFieldInputDecoration:
                                              const InputDecoration(
                                        suffixIcon: Icon(Icons.search),
                                        labelText: "Search country",
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                      )),
                                    ));
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        SingleChildScrollView(
            child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryButton(
                      title: "Edit company",
                      onPressed: () async {
                        final newCompanyData =
                            await context.pushNamed<CompanyModel>(
                                EditCompanyProfileScreen.id);
                        if (newCompanyData != null) {
                          getCompany(newCompanyData);
                        }
                      },
                      actionType: PrimaryButtonActionType.positive,
                      type: PrimaryButtonType.text,
                    ),
                  ],
                ),
              ),
              Image.asset(
                "images/imgCompany.png",
                width: 120,
                height: 120,
                fit: BoxFit.fill,
              ),
              const SizedBox(
                height: 36,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: PrimaryButton(
                    onPressed: () {
                      context.pushNamed<bool>(PurchaseBarcodesScreen.id);
                    },
                    actionType: PrimaryButtonActionType.positive,
                    type: PrimaryButtonType.filled,
                    title: "Purchase Barcodes",
                  )),
              const SizedBox(
                height: 24,
              ),
              CardWithInfoRows(
                infoRows: [
                  InfoRow("Company name", _companyName.text),
                  InfoRow("Company address", _companyAddress.text),
                  InfoRow("Company city", _companyCity.text),
                  InfoRow("Company country", _companyCountry.text),
                  InfoRow("Company province/state", _companyState.text),
                  InfoRow("Company zip", _companyZip.text),
                  InfoRow("Phone", _companyPhone.text),
                  InfoRow("Phone 2", _companyAltPhone.text),
                ],
                onTap: (value) {},
              ),
            ],
          ),
        )),
        Visibility(
            visible: isLoading,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: const Center(child: CircularProgressIndicator()),
            ))
      ],
    ));
  }

  void saveData() {
    setState(() {
      _readOnly = true;
    });
    saveCompanyData(profileService);
  }
}
