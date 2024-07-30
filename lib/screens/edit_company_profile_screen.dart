import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/app_text_form_field.dart';
import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';

class EditCompanyProfileScreenArguments {
  final CompanyModel company;

  const EditCompanyProfileScreenArguments({required this.company});
}

class EditCompanyProfileScreen extends StatefulWidget {
  static const String id = "/edit_company_profile_screen";
  final CompanyModel company;

  const EditCompanyProfileScreen({super.key, required this.company});

  @override
  State<EditCompanyProfileScreen> createState() =>
      _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserState userState = getIt.get();
  final ProfileService profileService = getIt.get();
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
  final phoneFocusNode = FocusNode();
  final alternatePhoneFocusNode = FocusNode();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getCompany();
  }

  Widget createGroupRow(
      String title, String hint, TextEditingController titleValue) {
    return AppTextFormField(
      controller: titleValue,
      textInputAction: TextInputAction.next,
      floatingLabel: title.toUpperCase(),
      hint: hint,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return "$title can't be empty";
        }
        return null;
      },
    );
  }

  void getCompany() {
    setState(() {
      _companyName.text = widget.company.name;
      _companyAddress.text = widget.company.address;
      _companyCity.text = widget.company.city;
      _companyState.text = widget.company.state;
      _companyZip.text = widget.company.zipcode;
      _companyPhone.text = widget.company.phone?.phone ?? "";
      _companyPhoneAreaCode = widget.company.phone?.phoneAreaCode ?? "1";
      _companyPhoneCountryISOName =
          widget.company.phone?.phoneCountryISOName ?? "US";
      _companyAltPhone.text = widget.company.alternatePhone?.phone ?? "";
      _companyAltPhoneAreaCode =
          widget.company.alternatePhone?.phoneAreaCode ?? "1";
      _companyAltPhoneCountryISOName =
          widget.company.alternatePhone?.phoneCountryISOName ?? "US";
      selectedCountry = widget.company.country.isNotEmpty
          ? countries
              .where((country) => country.name == widget.company.country)
              .firstOrNull
          : null;
      _companyCountry.text = selectedCountry?.name ?? "";
    });
  }

  Widget createStateGroupRow(bool canUpdate) {
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
                      onChanged: (newValue) {
                        setState(() {
                          _companyState.text = newValue ?? "";
                        });
                      },
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

  Widget createCountryGroupRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Company Country",
          style: TextStyle(
              color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
                color: Color(0xFFF6F6F6),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                    style: textStyle,
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
                                  _companyCountry.text = country.name;
                                  listOfStates =
                                      Provinces.getProvinces(country.name);
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
                                  labelStyle: TextStyle(color: Colors.black),
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

  Future<void> saveCompanyData(ProfileService service) async {
    return service.updateCompanyProfile(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            context.pop();
          },
        ),
        backgroundColor: AppColors.appPrimaryGreen,
        centerTitle: true,
        title: const Text("Edit profile"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: _formKey,
                    child: CustomCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                "Company info",
                                style: TextStyle(
                                    color: AppColors.strongGray,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            createGroupRow(
                                "Company Name", "Enter company name", _companyName),
                            createGroupRow("Company Address",
                                "Enter company address", _companyAddress),
                            createGroupRow(
                                "Company City", "Enter company city", _companyCity),
                            createCountryGroupRow(),
                            createGroupRow("Company Province/State",
                                "Enter company state/province", _companyState),
                            AppTextFormField(
                              controller: _companyZip,
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
                                    if (!RegExp(
                                            r'^[A-Z][0-9][A-Z] ?[0-9][A-Z][0-9]$')
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
                              floatingLabel: "Company Zip",
                              hint: "Enter company ZIP",
                            ),
                            _companyPhoneCountryISOName.isEmpty
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding:
                                        const EdgeInsets.only(top: 4.0),
                                    child: AppPhoneFormField(
                                      controller: _companyPhone,
                                      focusNode: phoneFocusNode,
                                      onEditingComplete: () {
                                        FocusScope.of(context)
                                            .requestFocus(alternatePhoneFocusNode);
                                      },
                                      initialCountryCode:
                                          _companyPhoneCountryISOName,
                                      textInputAction: TextInputAction.next,
                                      floatingLabel: "Phone",
                                      hint: "Enter main phone number",
                                      onCountryChanged: (Country country) {
                                        setState(() {
                                          _companyPhoneCountryISOName =
                                              country.code;
                                          _companyPhoneAreaCode = country.dialCode;
                                        });
                                      },
                                    ),
                                  ),
                            _companyAltPhoneCountryISOName.isEmpty
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding:
                                        const EdgeInsets.only(top: 4.0),
                                    child: AppPhoneFormField(
                                      controller: _companyAltPhone,
                                      focusNode: alternatePhoneFocusNode,
                                      initialCountryCode:
                                          _companyAltPhoneCountryISOName,
                                      floatingLabel: "Phone 2",
                                      hint: "Enter secondary phone number",
                                      onCountryChanged: (Country country) {
                                        setState(() {
                                          _companyAltPhoneCountryISOName =
                                              country.code; 
                                          _companyAltPhoneAreaCode =
                                              country.dialCode;
                                        });
                                      },
                                    ),
                                  )
                          ]),
                    ),
                  ),
                  const SizedBox(height: 16,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            onPressed: () {
                              context.pop();
                            },
                            title: "Cancel",
                            type: PrimaryButtonType.outlined,
                            actionType: PrimaryButtonActionType.positive,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: PrimaryButton(
                            onPressed: () {
                              saveData();
                            },
                            title: "Save",
                            type: PrimaryButtonType.filled,
                            actionType: PrimaryButtonActionType.positive,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16,),
                ],
              ),
            ),
            Visibility(
                visible: isLoading,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                  child: const Center(child: CircularProgressIndicator()),
                ))
          ],
        ),
      ),
    );
  }

  void saveData() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      setState(() {
        isLoading = true;
      });
      await saveCompanyData(profileService);
      await userState.getCurrentCompanyFirstTime(widget.company.id);
      final company = userState.currentCompanyData;
      if (company != null && mounted) {
        context.pop(company);
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            saveData();
          },
          "Cancel",
          () {
            Navigator.pop(context);
          },
          "Error",
          e.message ?? "Unknown error.");
    }
    setState(() {
      isLoading = false;
    });
  }
}
