import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/screens/Auth/create_company_screen/bloc/create_company_bloc.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/screens/Dashboard/user_management_screen.dart';
import 'package:agro_k/screens/common/models/required_field.dart';
import 'package:agro_k/screens/common/models/zipcode.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CreateCompanyScreenArguments {
  final String? uid;
  final String? prevScreen;

  const CreateCompanyScreenArguments({this.uid, this.prevScreen});
}

class CreateCompanyScreen extends StatelessWidget {
  static const String id = '/create_company';
  final String? prevScreen;

  CreateCompanyScreen({Key? key, this.prevScreen}) : super(key: key);

  static Widget withBloc({String? prevScreen, String? uid}) {
    return BlocProvider(
      create: (_) => CreateCompanyBloc(
        authService: getIt<AuthService>(),
        userState: getIt<UserState>(),
        uid: uid,
      ),
      child: CreateCompanyScreen(prevScreen: prevScreen),
    );
  }

  final TextEditingController country =
      TextEditingController(text: "United States");
  final TextEditingController state = TextEditingController();
  final TextEditingController zipcode = TextEditingController();

  final TextEditingController _companyPhone = TextEditingController();
  final TextEditingController _companyAltPhone = TextEditingController();

  final phoneFocusNode = FocusNode();
  final alternatePhoneFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return BlocListener<CreateCompanyBloc, CreateCompanyState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CreateCompanyStatus.goDashboard) {
          context.goNamed(DashboardScreen.id);
        } else if (state.status == CreateCompanyStatus.goManageUsers) {
          context.goNamed(ManageUsersScreen.id);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          if (prevScreen == DashboardScreen.id) {
            context.goNamed(DashboardScreen.id);
            return false;
          }
          return true;
        },
        child: SelectionArea(
          child: Scaffold(
              appBar: kIsWeb
                  ? null
                  : AppBar(
                      automaticallyImplyLeading: false,
                      leading: BackButton(
                        color: Colors.white,
                        onPressed: () {
                          if (prevScreen == DashboardScreen.id) {
                            context.goNamed(DashboardScreen.id);
                          } else {
                            context.goBackWeb();
                          }
                        },
                      ),
                      backgroundColor: AppColors.appPrimaryGreen,
                      centerTitle: true,
                      title: const Text("Company Profile"),
                    ),
              body: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: !kIsWeb
                          ? Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(
                                      top: 20, left: 20, right: 20),
                                  child: _NameTextFormField(),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(
                                      top: 20, left: 20, right: 20),
                                  child: _AddressTextFormField(),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(
                                      top: 20, left: 20, right: 20),
                                  child: _CityTextFormField(),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                _CountryField(
                                    countryTextEditingController: country,
                                    stateTextEditingController: state),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    SizedBox(
                                        width:
                                            (MediaQuery.of(context).size.width /
                                                    2) -
                                                30,
                                        child: _StateField(
                                            stateTextEditingController: state)),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width /
                                                  2) -
                                              30,
                                      child: _ZipcodeTextFormField(
                                          phoneFocusNode: phoneFocusNode,
                                          zipcodeTextEditingController:
                                              zipcode),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 20, right: 20),
                                  child: _PhoneField(companyPhone: _companyPhone),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 20, right: 20),
                                  child: _AlternatePhoneField(
                                    companyAltPhone: _companyAltPhone,
                                  ),
                                ),
                                const SizedBox(
                                  height: 100,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 40,
                                  child: TextButton(
                                      onPressed: () {
                                        context.read<CreateCompanyBloc>().add(
                                            const CreateCompanySubmitted());
                                      },
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              AppColors.appPrimaryGreen),
                                      child: const Text("Next")),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 40,
                                  child: TextButton(
                                      onPressed: () {
                                        context
                                            .read<CreateCompanyBloc>()
                                            .add(const CreateCompanySkipped());
                                      },
                                      style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppColors.appPrimaryGreen,
                                          padding: const EdgeInsets.all(15)),
                                      child: const Text("Skip")),
                                ),
                              ],
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  elevation: 8,
                                  child: Container(
                                    width: 800,
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                            alignment:
                                                AlignmentDirectional.center,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    50,
                                                height: 100,
                                                decoration: const BoxDecoration(
                                                  color:
                                                      AppColors.appPrimaryGreen,
                                                ),
                                              ),
                                              Image.asset(
                                                  "images/agrokLogo.png")
                                            ]),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const _NameTextFormField(),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const _AddressTextFormField(),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        _CountryField(
                                            countryTextEditingController:
                                                country,
                                            stateTextEditingController: state),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Expanded(
                                              child: _CityTextFormField(),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                                child: _StateField(
                                                    stateTextEditingController:
                                                        state)),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: _ZipcodeTextFormField(
                                                  phoneFocusNode:
                                                      phoneFocusNode,
                                                  zipcodeTextEditingController:
                                                      zipcode),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20, right: 10),
                                                child: _PhoneField(
                                                    companyPhone: _companyPhone),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 20,
                                                  left: 10,
                                                ),
                                                child: _AlternatePhoneField(
                                                    companyAltPhone:
                                                        _companyAltPhone),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 50,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          child: TextButton(
                                              onPressed: () {
                                                context
                                                    .read<CreateCompanyBloc>()
                                                    .add(
                                                        const CreateCompanySubmitted());
                                              },
                                              style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      AppColors.appPrimaryGreen,
                                                  padding:
                                                      const EdgeInsets.all(15)),
                                              child: const Text("Next")),
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          child: TextButton(
                                              onPressed: () {
                                                context
                                                    .read<CreateCompanyBloc>()
                                                    .add(
                                                        const CreateCompanySkipped());
                                              },
                                              style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.appPrimaryGreen,
                                                  padding:
                                                      const EdgeInsets.all(15)),
                                              child: const Text("Skip")),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const _LoadingIndicator()
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.companyPhone,
  });

  final TextEditingController companyPhone;

  @override
  Widget build(BuildContext context) {
    var phone = context.select((CreateCompanyBloc bloc) => bloc.state.phone);
    return IntlPhoneField(
      style: const TextStyle(color: Colors.black),
      initialCountryCode: "US",
      decoration: const InputDecoration(
        labelText: "Phone",
        border: OutlineInputBorder(),
        errorStyle: TextStyle(color: Colors.red),
      ),
      dropdownTextStyle: const TextStyle(
        color: AppColors.black1,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      disableLengthCheck: true,
      onCountryChanged: (Country country) {
        context.read<CreateCompanyBloc>().add(CreateCompanyPhoneChanged(
            PhoneModel(
                phone: phone.value.phone,
                phoneAreaCode: country.dialCode,
                phoneCountryISOName: country.code)));
      },
      onChanged: (phoneNumber) {
        context.read<CreateCompanyBloc>().add(CreateCompanyPhoneChanged(
            PhoneModel(
                phone: phoneNumber.number,
                phoneAreaCode: phone.value.phoneAreaCode,
                phoneCountryISOName: phone.value.phoneCountryISOName)));
      },
    );
  }
}

class _AlternatePhoneField extends StatelessWidget {
  const _AlternatePhoneField({
    required this.companyAltPhone,
  });

  final TextEditingController companyAltPhone;

  @override
  Widget build(BuildContext context) {
    var altPhone =
        context.select((CreateCompanyBloc bloc) => bloc.state.altPhone);
    return IntlPhoneField(
      style: const TextStyle(color: Colors.black),
      initialCountryCode: "US",
      decoration: const InputDecoration(
        labelText: "Alternate Phone",
        border: OutlineInputBorder(),
        errorStyle: TextStyle(color: Colors.red),
      ),
      dropdownTextStyle: const TextStyle(
        color: AppColors.black1,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      disableLengthCheck: true,
      onCountryChanged: (Country country) {
        context.read<CreateCompanyBloc>().add(CreateCompanyAltPhoneChanged(
            PhoneModel(
                phone: altPhone.value.phone,
                phoneAreaCode: country.dialCode,
                phoneCountryISOName: country.code)));
      },
      onChanged: (phoneNumber) {
        context.read<CreateCompanyBloc>().add(CreateCompanyAltPhoneChanged(
            PhoneModel(
                phone: phoneNumber.number,
                phoneAreaCode: altPhone.value.phoneAreaCode,
                phoneCountryISOName: altPhone.value.phoneCountryISOName)));
      },
    );
  }
}

class _ZipcodeTextFormField extends StatelessWidget {
  const _ZipcodeTextFormField({
    required this.phoneFocusNode,
    required this.zipcodeTextEditingController,
  });

  final FocusNode phoneFocusNode;
  final TextEditingController zipcodeTextEditingController;

  @override
  Widget build(BuildContext context) {
    var status = context.select((CreateCompanyBloc bloc) => bloc.state.status);
    var error = context.select((CreateCompanyBloc bloc) =>
        bloc.state.zipcode.error?.getDescription("Company zipcode"));
    return TextFormField(
      textInputAction: TextInputAction.next,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(phoneFocusNode);
      },
      controller: zipcodeTextEditingController,
      onChanged: (value) {
        context
            .read<CreateCompanyBloc>()
            .add(CreateCompanyZipcodeChanged(value));
      },
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        errorText: status == CreateCompanyStatus.failure ? error : null,
        errorMaxLines: 8,
        labelText: "Company Zip",
        border: const OutlineInputBorder(),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _StateField extends StatelessWidget {
  const _StateField({
    required this.stateTextEditingController,
  });

  final TextEditingController stateTextEditingController;

  @override
  Widget build(BuildContext context) {
    var listOfStates =
        context.select((CreateCompanyBloc bloc) => bloc.state.listOfStates);
    var companyState = context
        .select((CreateCompanyBloc bloc) => bloc.state.companyState.value);
    var status = context.select((CreateCompanyBloc bloc) => bloc.state.status);
    var error = context.select((CreateCompanyBloc bloc) =>
        bloc.state.companyState.error?.getDescription("Company state"));
    return InputDecorator(
      decoration: InputDecoration(
          errorText: status == CreateCompanyStatus.failure ? error : null,
          errorStyle: const TextStyle(color: Colors.red),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        isDense: false,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: companyState == "" ||
                  !listOfStates.contains(stateTextEditingController.text)
              ? null
              : companyState,
          isDense: true,
          isExpanded: true,
          onChanged: (newValue) {
            context.read<CreateCompanyBloc>().add(CreateCompanyStateChanged(
                newValue ?? "", stateTextEditingController));
          },
          hint: Text(
            listOfStates.isEmpty ? 'No states' : 'Select your state',
            style: const TextStyle(
              color: AppColors.black1,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
          items: listOfStates.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CountryField extends StatelessWidget {
  const _CountryField({
    required this.stateTextEditingController,
    required this.countryTextEditingController,
  });

  final TextEditingController stateTextEditingController;
  final TextEditingController countryTextEditingController;

  @override
  Widget build(BuildContext context) {
    var country =
        context.select((CreateCompanyBloc bloc) => bloc.state.country);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayTextColor),
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/flags/${country.code.toLowerCase()}.png',
            package: 'intl_phone_field',
            width: 32,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
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
              controller: countryTextEditingController,
              readOnly: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Select a country",
                hintStyle: TextStyle(
                  color: AppColors.black1,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(
                color: AppColors.black1,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (ctx) => CountryPickerDialog(
                          searchText: "",
                          languageCode: "en",
                          countryList: countries,
                          onCountryChanged: (country) {
                            context.read<CreateCompanyBloc>().add(
                                CreateCompanyCountryChanged(
                                    country,
                                    countryTextEditingController,
                                    stateTextEditingController));
                          },
                          selectedCountry: country,
                          filteredCountries: countries,
                          showCountryCode: false,
                        ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CityTextFormField extends StatelessWidget {
  const _CityTextFormField();

  @override
  Widget build(BuildContext context) {
    CreateCompanyStatus status =
        context.select((CreateCompanyBloc bloc) => bloc.state.status);
    String? error = context.select((CreateCompanyBloc bloc) =>
        bloc.state.city.error?.getDescription("Company city"));
    return TextFormField(
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Colors.black),
      onChanged: (value) {
        context.read<CreateCompanyBloc>().add(CreateCompanyCityChanged(value));
      },
      decoration: InputDecoration(
        errorText: status == CreateCompanyStatus.failure ? error : null,
        labelText: "Company City",
        border: const OutlineInputBorder(),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _AddressTextFormField extends StatelessWidget {
  const _AddressTextFormField();

  @override
  Widget build(BuildContext context) {
    CreateCompanyStatus status =
        context.select((CreateCompanyBloc bloc) => bloc.state.status);
    String? error = context.select((CreateCompanyBloc bloc) =>
        bloc.state.address.error?.getDescription("Company address"));
    return TextFormField(
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Colors.black),
      onChanged: (value) {
        context
            .read<CreateCompanyBloc>()
            .add(CreateCompanyAddressChanged(value));
      },
      decoration: InputDecoration(
        errorText: status == CreateCompanyStatus.failure ? error : null,
        labelText: "Company Address",
        border: const OutlineInputBorder(),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _NameTextFormField extends StatelessWidget {
  const _NameTextFormField();

  @override
  Widget build(BuildContext context) {
    CreateCompanyStatus status =
        context.select((CreateCompanyBloc bloc) => bloc.state.status);
    String? error = context.select((CreateCompanyBloc bloc) =>
        bloc.state.name.error?.getDescription("Company name"));
    return TextFormField(
      autofocus: true,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Colors.black),
      onChanged: (value) {
        context.read<CreateCompanyBloc>().add(CreateCompanyNameChanged(value));
      },
      decoration: InputDecoration(
        labelText: "Company Name",
        errorText: status == CreateCompanyStatus.failure ? error : null,
        border: const OutlineInputBorder(),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    var status = context.select((CreateCompanyBloc bloc) => bloc.state.status);
    return Visibility(
        visible: status == CreateCompanyStatus.loading,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        ));
  }
}
