import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/app_text_form_field.dart';
import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditUserProfileScreenArguments {
  final UserModel user;
  const EditUserProfileScreenArguments({required this.user});
}

class EditUserProfileScreen extends StatefulWidget {
  static const String id = "/edit_user_profile_screen";
  final UserModel user;
  const EditUserProfileScreen({super.key, required this.user});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  String _phoneAreaCode = "";
  String _phoneCountryISOName = "";
  final UserState userState = getIt.get();
  final ProfileService profileService = getIt.get();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getUser();
  }

  void getUser() {
    setState(() {
      _firstName.text = widget.user.firstName ?? "No first name";
      _lastName.text = widget.user.lastName != null
          ? capitalizeLastWord(widget.user.lastName!)
          : "No last name";
      _email.text = widget.user.email;
      _phone.text = widget.user.phone?.phone ?? "";
      _phoneAreaCode = widget.user.phone?.phoneAreaCode ?? "1";
      _phoneCountryISOName = widget.user.phone?.phoneCountryISOName ?? "US";
    });
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
            readOnly: !canUpdate,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border:
                  !canUpdate ? InputBorder.none : const OutlineInputBorder(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    var phoneFocusNode = FocusNode();
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
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom),
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                    const SizedBox(
                      height: 20,
                    ),
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text("Profile info", style: TextStyle(color: AppColors.strongGray, fontSize: 18, fontWeight: FontWeight.w500),),
                          ),
                          const SizedBox(height: 16,),
                          AppTextFormField(
                            hint: "Enter first name",
                            floatingLabel: "First name",
                            controller: _firstName,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter first name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8,),
                          AppTextFormField(
                            hint: "Enter last name",
                            floatingLabel: "Last name",
                            controller: _lastName,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(phoneFocusNode);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter last name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8,),
                          AppTextFormField(
                            hint: "Enter email",
                            floatingLabel: "Email",
                            controller: _email,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter email";
                              }
                              return null;
                            },
                          ),
                          _phoneCountryISOName.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: AppPhoneFormField(
                                  controller: _phone,
                                  focusNode: phoneFocusNode,
                                  initialCountryCode: _phoneCountryISOName,
                                  onCountryChanged: (Country country) {
                                    setState(() {
                                      _phoneCountryISOName = country.code;
                                      _phoneAreaCode = country.dialCode;
                                    });
                                  },
                                  hint: "Enter phone",
                                  floatingLabel: "Phone",
                                ),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16,),
                    const Spacer(),
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
                  ]),
                ),
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

  Future<void> saveProfileData(ProfileService service) async {
    await service.updateUserProfile(
        firstName: _firstName.text,
        lastName: _lastName.text,
        phone: _phone.text.isEmpty
            ? null
            : PhoneModel(
            phone: _phone.text,
            phoneAreaCode: _phoneAreaCode,
            phoneCountryISOName: _phoneCountryISOName),
        email: _email.text);
  }

  void saveData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await saveProfileData(profileService);
      await userState.getUserDataFirstTime();
      final user = userState.userData?.user;
      if (user != null && mounted) {
        context.pop(user);
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
