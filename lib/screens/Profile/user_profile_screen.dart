import 'package:agro_k/app/routes.dart';
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/card_with_info_rows.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/invite_wrapper.dart';
import 'package:agro_k/models/user/notification_settings_model.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/Auth/confirm_account/view/confirm_account_screen.dart';
import 'package:agro_k/screens/Auth/log_in/view/log_in_screen.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/web_dashboard.dart';
import 'package:agro_k/screens/Dashboard/manage_barcodes_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/function_utils/date_utils.dart';
import 'package:agro_k/utilities/function_utils/general_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/utility_models/info_row.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:universal_html/html.dart' as html;

class UserProfileScreen extends StatefulWidget {
  static const String id = '/user_profile';
  final UserModel user;
  final CompanyModel? company;
  final List<InvitesWrapperWithCompany> invites;

  const UserProfileScreen(
      {Key? key,
      required this.user,
      required this.company,
      required this.invites})
      : super(key: key);

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();

  final TextEditingController _lastName = TextEditingController();

  final TextEditingController _email = TextEditingController();

  final TextEditingController _userPhone = TextEditingController();
  String _userPhoneAreaCode = "";
  String _userPhoneCountryISOName = "";

//Company Profile
  final TextEditingController _farmName = TextEditingController();

  final TextEditingController _farmAddress = TextEditingController();

  final TextEditingController _farmCity = TextEditingController();

  final TextEditingController _farmState = TextEditingController();

  final TextEditingController _farmZip = TextEditingController();

  final TextEditingController _farmCountry = TextEditingController();

  final TextEditingController _farmPhone = TextEditingController();
  String _farmPhoneAreaCode = "";
  String _farmPhoneCountryISOName = "";

  final TextEditingController _farmAltPhone = TextEditingController();
  String _farmAltPhoneAreaCode = "";
  String _farmAltPhoneCountryISOName = "";

  List<String> listOfStates = Provinces.usaStates;

  Country? selectedCountry =
      countries.where((element) => element.name == "United States").firstOrNull;

//Billing
  final TextEditingController _paymentMethod = TextEditingController();

  final TextEditingController _billingAddress = TextEditingController();

  //Security
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool wasUpdated = false;
  final ProfileService profileService = getIt.get();
  final AuthService authService = getIt.get();
  bool isLoading = false;

  //Notifications
  bool sampleStartedEmail = false;
  bool sampleStarted = false;

  bool sampleCompleteEmail = false;
  bool sampleComplete = false;

  bool sampleCancelledEmail = false;
  bool sampleCancelled = false;

  bool daysSinceSampleStartEmail = false;
  bool daysSinceSampleStart = false;

//Data
  double toolbarHeight = 100;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  void didUpdateWidget(covariant UserProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.company != oldWidget.company || widget.user != oldWidget.user) {
      getData();
    } else if (!areListsEqual(widget.invites, oldWidget.invites)) {
      setState(() {});
    }
  }

  void getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await downloadUserProfilePictureFile(widget.user);
      getUser();
      getCompany();
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
            html.window.history.back();
          },
          "Error",
          e.message ?? "Unknown error.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> downloadUserProfilePictureFile(UserModel user) async {
    try {
      var bytes = await FirebaseStorage.instance
          .ref()
          .child("users/${FirebaseAuth.instance.currentUser?.uid}")
          .getData();
      setState(() {
        _profileImage = bytes;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void getUser() {
    setState(() {
      _firstName.text = widget.user.firstName ?? "";
      _lastName.text = widget.user.lastName != null
          ? capitalizeLastWord(widget.user.lastName!)
          : "";
      _email.text = widget.user.email;

      _userPhone.text = widget.user.phone?.phone ?? "";
      _userPhoneAreaCode = widget.user.phone?.phoneAreaCode ?? "1";
      _userPhoneCountryISOName = widget.user.phone?.phoneCountryISOName ?? "US";

      sampleStarted = widget.user.notificationSettings.sampleStarted;
      sampleStartedEmail = widget.user.notificationSettings.sampleStartedEmail;

      sampleCompleteEmail =
          widget.user.notificationSettings.sampleCompleteEmail;
      sampleComplete = widget.user.notificationSettings.sampleComplete;

      sampleCancelledEmail =
          widget.user.notificationSettings.sampleCancelledEmail;
      sampleCancelled = widget.user.notificationSettings.sampleCancelled;

      daysSinceSampleStartEmail =
          widget.user.notificationSettings.daysSinceSampleStartEmail;
      daysSinceSampleStart =
          widget.user.notificationSettings.daysSinceSampleStart;
    });
  }

  void removeInvite(String inviteId) {
    widget.invites.removeWhere((element) => element.id == inviteId);
    setState(() {});
  }

  void getCompany() {
    setState(() {
      _farmName.text = widget.company?.name ?? "";
      _farmAddress.text = widget.company?.address ?? "";
      _farmCity.text = widget.company?.city ?? "";
      _farmState.text = widget.company?.state ?? "";
      _farmZip.text = widget.company?.zipcode ?? "";
      _farmPhone.text = widget.company?.phone?.phone ?? "";
      _farmPhoneAreaCode = widget.company?.phone?.phoneAreaCode ?? "1";
      _farmPhoneCountryISOName =
          widget.company?.phone?.phoneCountryISOName ?? "US";
      _farmAltPhone.text = widget.company?.alternatePhone?.phone ?? "";
      _farmAltPhoneAreaCode =
          widget.company?.alternatePhone?.phoneAreaCode ?? "1";
      _farmAltPhoneCountryISOName =
          widget.company?.alternatePhone?.phoneCountryISOName ?? "US";
      selectedCountry =
          widget.company?.country != null && widget.company!.country.isNotEmpty
              ? countries
                  .where((country) => country.name == widget.company?.country)
                  .firstOrNull
              : null;
      _farmCountry.text = selectedCountry?.name ?? "";
    });
  }

  bool checkWasUpdated() {
    if (wasUpdated) {
      showTwoButtonAlertDialog(
          context,
          "Cancel",
          () {
            Navigator.pop(context);
            return false;
          },
          "Continue",
          () {
            Navigator.pop(context);
            context.tryPop();
            return true;
          },
          "Leave without saving?",
          "Are you sure you want to leave without saving? Changes will be lost.");
    } else {
      context.tryPop();
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return WillPopScope(
        onWillPop: () async {
          return checkWasUpdated();
        },
        child: Scaffold(
            body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: createProfile(),
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
        )));
  }

  Widget createProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.invites.isNotEmpty
            ? Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      const Text(
                        "Invites",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.appPrimaryGreen,
                          borderRadius: BorderRadius.circular(90),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          child: Text(
                            widget.invites.length.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      elevation: 8,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            child: ListView.builder(
                                itemCount: widget.invites.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  InvitesWrapperWithCompany invite =
                                      widget.invites[index];
                                  return Column(
                                    key: ValueKey(invite),
                                    children: [
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Card(
                                        elevation: 0,
                                        color: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            side: const BorderSide(
                                                color: AppColors.hintTextColor,
                                                width: 2.0)),
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 12,
                                              bottom: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Flexible(
                                                      flex: 0,
                                                      child: Text(
                                                        invite.company.name,
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .black1),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4.0),
                                                      child: Text(
                                                        "Invited ${getDaysFromDateToToday(invite.created)} days ago",
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .grayTextColor),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  showTwoButtonAlertDialog(
                                                      context,
                                                      "No",
                                                      () {
                                                        Navigator.pop(context);
                                                      },
                                                      "Yes",
                                                      () {
                                                        Navigator.pop(context);
                                                        answerInvite(
                                                            invite, true);
                                                      },
                                                      "Join ${invite.company.name}?",
                                                      "Are you sure you want to join ${invite.company.name}?");
                                                },
                                                child: const Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.check_outlined,
                                                      color: AppColors
                                                          .appPrimaryGreen,
                                                    ),
                                                    Text("Join",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  showTwoButtonAlertDialog(
                                                      context,
                                                      "No",
                                                      () {
                                                        Navigator.pop(context);
                                                      },
                                                      "Yes",
                                                      () {
                                                        Navigator.pop(context);
                                                        answerInvite(
                                                            invite, false);
                                                      },
                                                      "Deny ${invite.company.name}?",
                                                      "Are you sure you want to deny the invite from ${invite.company.name}?");
                                                },
                                                child: const Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.cancel,
                                                      color: Colors.red,
                                                    ),
                                                    Text("Dismiss",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                })),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
        createUserProfile(),
        createCompanyProfile(),
        // createBillingProfile(),
        const SizedBox(
          height: 40,
        ),
        SizedBox(
          width: 600,
          child: Column(
            children: [
              const Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    "Security",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  const SizedBox(
                      width: 110,
                      child: Text(
                        "Current Password",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: SizedBox(
                      // width: 250,
                      height: 50,
                      child: TextField(
                        controller: _currentPassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Enter current password",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  const SizedBox(
                      width: 110,
                      child: Text(
                        "New Password",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: SizedBox(
                      // width: 250,
                      height: 50,
                      child: TextField(
                        controller: _newPassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Enter new password",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  const SizedBox(
                      width: 110,
                      child: Text(
                        "Confirm Password",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: SizedBox(
                      // width: 250,
                      height: 50,
                      child: TextField(
                        controller: _confirmPassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Reenter password",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        const Row(
          children: [
            SizedBox(
              width: 15,
            ),
            Text(
              "Settings",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: CardWithInfoRows(
            infoRows: [
              InfoRow(
                "Terms of Service",
                "",
              ),
              InfoRow(
                "Privacy Policy",
                "",
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                goToTermsOfService(context);
              } else if (index == 1) {
                goToPrivacyPolicy();
              }
            },
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        const Row(
          children: [
            SizedBox(
              width: 15,
            ),
            Text(
              "Notifications",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Text("Email",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              width: 15,
            ),
            Text("In-App",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Expanded(child: SizedBox()),
            Text("Option",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Flexible(child: SizedBox()),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Divider(
            thickness: 3,
            color: Colors.grey,
          ),
        ),
        Row(
          children: [
            //option 1 notifications
            const SizedBox(
              width: 20,
            ),
            Checkbox(
                value: sampleStartedEmail,
                onChanged: (bool? val) {
                  setState(() {
                    sampleStartedEmail = !sampleStartedEmail;
                  });
                }),
            const SizedBox(
              width: 22,
            ),
            Checkbox(
                value: sampleStarted,
                onChanged: (bool? val) {
                  setState(() {
                    sampleStarted = !sampleStarted;
                  });
                }),
            // const SizedBox(width: 25),
            const Expanded(child: SizedBox()),
            const Text("Notification when sample analysis started.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const Expanded(child: SizedBox()),
            // const SizedBox(
            //   width: 20,
            // ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Divider(
            color: Colors.grey,
          ),
        ),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Checkbox(
                value: sampleCompleteEmail,
                onChanged: (bool? val) {
                  setState(() {
                    sampleCompleteEmail = !sampleCompleteEmail;
                  });
                }),
            const SizedBox(
              width: 22,
            ),
            Checkbox(
                value: sampleComplete,
                onChanged: (bool? val) {
                  setState(() {
                    sampleComplete = !sampleComplete;
                  });
                }),
            // const SizedBox(width: 25),
            const Expanded(child: SizedBox()),
            const Text("Notification when sample is completed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const Expanded(child: SizedBox()),
            // const SizedBox(
            //   width: 20,
            // ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Divider(
            color: Colors.grey,
          ),
        ),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Checkbox(
                value: sampleCancelledEmail,
                onChanged: (bool? val) {
                  setState(() {
                    sampleCancelledEmail = !sampleCancelledEmail;
                  });
                }),
            const SizedBox(
              width: 22,
            ),
            Checkbox(
                value: sampleCancelled,
                onChanged: (bool? val) {
                  setState(() {
                    sampleCancelled = !sampleCancelled;
                  });
                }),
            // const SizedBox(width: 25),
            const Expanded(child: SizedBox()),
            const Text("Notification if sample cancelled.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const Expanded(child: SizedBox()),
            // const SizedBox(
            //   width: 20,
            // ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Divider(
            color: Colors.grey,
          ),
        ),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Checkbox(
                value: daysSinceSampleStartEmail,
                onChanged: (bool? val) {
                  setState(() {
                    daysSinceSampleStartEmail = !daysSinceSampleStartEmail;
                  });
                }),
            const SizedBox(
              width: 22,
            ),
            Checkbox(
                value: daysSinceSampleStart,
                onChanged: (bool? val) {
                  setState(() {
                    daysSinceSampleStart = !daysSinceSampleStart;
                  });
                }),
            // const SizedBox(width: 25),
            const Expanded(child: SizedBox()),
            const Text("Finish sample reminders.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const Expanded(child: SizedBox()),
            // const SizedBox(
            //   width: 20,
            // ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width - 40,
            child: TextButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                saveData();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.appPrimaryGreen,
              ),
              child: const Text("Save"),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  void saveData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var currentEmail = widget.user.email;
      await Future.wait([
        saveProfileData(profileService),
        saveCompanyData(profileService),
        ...(_currentPassword.text != "" &&
                _newPassword.text != "" &&
                _confirmPassword.text != "")
            ? [updatePassword(profileService)]
            : []
      ]);
      if (!mounted) return;
      if (currentEmail != _email.text) {
        showOneButtonAlertDialog(context, "Ok", () async {
          setState(() {
            isLoading = true;
          });
          await authService.signOut();
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            context.goNamed(LogInScreen.id);
          }
        }, "Saved",
            "Profile has been saved. After changing your email, you have to log in again.");
      } else {
        showOneButtonAlertDialog(context, "Ok", () {
          Navigator.pop(context);
        }, "Saved", "Profile has been saved");
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
    } on EmailAlreadyInUseException catch (e) {
      if (!mounted) return;
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "This email is already in use.");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> saveProfileData(ProfileService service) async {
    var notifSettings = NotificationSettingsModel(
        sampleStarted: sampleStarted,
        sampleStartedEmail: sampleStartedEmail,
        sampleComplete: sampleComplete,
        sampleCompleteEmail: sampleCompleteEmail,
        daysSinceSampleStart: daysSinceSampleStart,
        daysSinceSampleStartEmail: daysSinceSampleStartEmail,
        sampleCancelled: sampleCancelled,
        sampleCancelledEmail: sampleCancelledEmail);

    await service.updateUserProfileWeb(
        firstName: _firstName.text,
        lastName: _lastName.text,
        phone: _userPhone.text.isNotEmpty
            ? PhoneModel(
                phone: _userPhone.text,
                phoneAreaCode: _userPhoneAreaCode,
                phoneCountryISOName: _userPhoneCountryISOName)
            : null,
        notifSettings: notifSettings,
        email: _email.text);
  }

  Future<void> saveCompanyData(ProfileService service) async {
    var farmRef = widget.company?.getReference();

    if (farmRef != null) {
      await service.updateCompanyProfile(
          companyName: _farmName.text,
          address: _farmAddress.text,
          city: _farmCity.text,
          state: _farmState.text,
          country: selectedCountry?.name ?? "",
          zip: _farmZip.text,
          phone: _farmPhone.text.isEmpty
              ? null
              : PhoneModel(
                  phone: _farmPhone.text,
                  phoneAreaCode: _farmPhoneAreaCode,
                  phoneCountryISOName: _farmPhoneCountryISOName),
          altPhone: _farmAltPhone.text.isEmpty
              ? null
              : PhoneModel(
                  phone: _farmAltPhone.text,
                  phoneAreaCode: _farmAltPhoneAreaCode,
                  phoneCountryISOName: _farmAltPhoneCountryISOName),
          companyReference: farmRef);
    }
  }

  Future<void> answerInvite(
      InvitesWrapperWithCompany invite, bool accept) async {
    try {
      setState(() {
        isLoading = true;
      });
      await authService.respondUserCompanyInvitation(invite.company, invite.id,
          FirebaseAuth.instance.currentUser!.uid, accept);
      removeInvite(invite.id);
      if (mounted) {
        if (accept) {
          context.findAncestorStateOfType<WebDashboardState>()?.setState(() {});
          showOneButtonAlertDialog(context, "Ok", () {
            Navigator.pop(context);
          }, "Congratulations", "You have just joined ${invite.company.name}.");
        } else {
          showOneButtonAlertDialog(context, "Ok", () {
            Navigator.pop(context);
          }, "Denied",
              "You have just dismissed the invite from ${invite.company.name}.");
        }
      }
    } catch (e) {
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updatePassword(ProfileService service) async {
    if (_newPassword.text == _confirmPassword.text) {
      await service.updatePassword(
          _email.text, _currentPassword.text, _newPassword.text);
    }
  }

  Future<void> _openGalleryPicker() async {
    try {
      setState(() {
        isLoading = true;
      });
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        var bytes = await pickedImage.readAsBytes();
        await _uploadImage(bytes);
        _profileImage = bytes;
        if (mounted) {
          context.findAncestorStateOfType<WebDashboardState>()?.setState(() {});
        }
      }
    } on Exception catch (exception, stacktrace) {
      if (!mounted) return;
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error uploading the photo");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _uploadImage(Uint8List imageFile) async {
    await profileService.updateUserProfileImageWeb(imageFile);
  }

  Widget createCountryGroupRow(bool canEdit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 20,
        ),
        const SizedBox(
            width: 110,
            child: Text(
              "Company Country",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
        const SizedBox(
          width: 20,
        ),
        Expanded(
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
                    controller: _farmCountry,
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
                                        _farmCountry.text = country.name;
                                        listOfStates = Provinces.getProvinces(
                                            country.name);
                                        if (!listOfStates
                                            .contains(_farmState.text)) {
                                          _farmState.text = "";
                                        }
                                        setState(() {
                                          selectedCountry = country;
                                        });
                                      },
                                      selectedCountry: countries.first,
                                      filteredCountries: countries,
                                      showCountryCode: false,
                                    ));
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget createUserProfile() {
    return SizedBox(
      width: 600,
      child: Column(children: [
        createGroupTitle("User Profile"),
        Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 28),
              child: InkWell(
                onTap: _openGalleryPicker,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(300.0),
                    child: _profileImage == null && isLoading
                        ? const CircularProgressIndicator()
                        : _profileImage == null
                            ? Image.asset(
                                "images/profilePicturePlaceholder.png",
                                width: 256,
                                height: 197,
                              )
                            : Image.memory(
                                _profileImage!,
                                width: 197,
                                height: 197,
                                fit: BoxFit.cover,
                              )),
              ),
            )),
        const SizedBox(height: 16),
        createGroupRow("First Name", _firstName, true),
        const SizedBox(height: 8),
        createGroupRow("Last Name", _lastName, true),
        const SizedBox(height: 8),
        createGroupRow("Email", _email, true),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            const SizedBox(
                width: 110,
                child: Text(
                  "Phone",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )),
            const SizedBox(
              width: 20,
            ),
            _userPhoneCountryISOName.isEmpty
                ? const SizedBox.shrink()
                : Expanded(
                    child: IntlPhoneField(
                      controller: _userPhone,
                      initialCountryCode: _userPhoneCountryISOName,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      dropdownTextStyle: const TextStyle(
                        color: AppColors.black1,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      disableLengthCheck: true,
                      onCountryChanged: (Country country) {
                        setState(() {
                          _userPhoneCountryISOName = country.code;
                          _userPhoneAreaCode = country.dialCode;
                        });
                      },
                    ),
                  ),
            const Expanded(child: SizedBox()),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
      ]),
    );
  }

  Widget createCompanyProfile() {
    var isAdmin = getIt.get<UserState>().isCompanyAdmin();
    return SizedBox(
      width: 600,
      child: Form(
        key: _formKey,
        child: Column(children: [
          createGroupTitle("Company Profile"),
          isAdmin
              ? Container(
                  height: 74,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 15),
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      context.pushNamed(ManageBarcodesScreen.id,
                          extra: ManageBarcodesScreenArguments(
                              farm: widget.company!));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.appPrimaryGreen,
                    ),
                    child: const Text(
                      "Manage Barcodes",
                    ),
                  ))
              : Container(),
          createGroupRow("Company Name", _farmName, isAdmin),
          const SizedBox(height: 8),
          createGroupRow("Address", _farmAddress, isAdmin),
          const SizedBox(height: 8),
          createGroupRow("City", _farmCity, isAdmin),
          const SizedBox(height: 8),
          createCountryGroupRow(isAdmin),
          const SizedBox(height: 8),
          createStateGroupRow(isAdmin),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              const SizedBox(
                  width: 110,
                  child: Text(
                    "Zip",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  controller: _farmZip,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (value) {
                    final zipcodeTrimmed = value?.trim() ?? "";
                    if (zipcodeTrimmed.isEmpty) {
                      return "Zipcode can't be empty";
                    }
                    switch (_farmCountry.text.trim()) {
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
                        if (!RegExp(r'^\d{4}$').hasMatch(zipcodeTrimmed)) {
                          return 'Enter a 4-digit postal code (e.g., 2000).';
                        }
                      case 'South Africa':
                        if (!RegExp(r'^\d{4}$').hasMatch(zipcodeTrimmed)) {
                          return 'Enter a 4-digit postal code (e.g., 8001).';
                        }
                      case 'Mexico':
                        if (!RegExp(r'^\d{5}$').hasMatch(zipcodeTrimmed)) {
                          return 'Enter a 5-digit postal code (e.g., 01000).';
                        }
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              const SizedBox(
                  width: 110,
                  child: Text(
                    "Phone",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                width: 20,
              ),
              _farmPhoneCountryISOName.isEmpty
                  ? const SizedBox.shrink()
                  : Expanded(
                      child: IntlPhoneField(
                        controller: _farmPhone,
                        initialCountryCode: _farmPhoneCountryISOName,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        dropdownTextStyle: const TextStyle(
                          color: AppColors.black1,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        disableLengthCheck: true,
                        enabled: isAdmin,
                        onCountryChanged: (Country country) {
                          setState(() {
                            _farmPhoneCountryISOName = country.code;
                            _farmPhoneAreaCode = country.dialCode;
                          });
                        },
                      ),
                    ),
              const Expanded(child: SizedBox()),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              const SizedBox(
                  width: 110,
                  child: Text(
                    "Alternate Phone",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                width: 20,
              ),
              _farmAltPhoneCountryISOName.isEmpty
                  ? const SizedBox.shrink()
                  : Expanded(
                      child: IntlPhoneField(
                        controller: _farmAltPhone,
                        initialCountryCode: _farmAltPhoneCountryISOName,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        dropdownTextStyle: const TextStyle(
                          color: AppColors.black1,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        disableLengthCheck: true,
                        enabled: isAdmin,
                        onCountryChanged: (Country country) {
                          setState(() {
                            _farmAltPhoneCountryISOName = country.code;
                            _farmAltPhoneAreaCode = country.dialCode;
                          });
                        },
                      ),
                    ),
              const Expanded(child: SizedBox()),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget createStateGroupRow(bool canUpdate) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 20,
        ),
        const SizedBox(
          width: 110,
          child: Text(
            "Company State/Province",
            style: TextStyle(
                color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: FormField<String>(
            builder: (FormFieldState<String> formState) {
              return InputDecorator(
                decoration: InputDecoration(
                    // labelStyle: textStyle,
                    // errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
                    hintText: 'Please select your state',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
                isEmpty: _farmState.text == '',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _farmState.text == "" ||
                            !listOfStates.contains(_farmState.text)
                        ? null
                        : _farmState.text,
                    isDense: true,
                    onChanged: canUpdate
                        ? (newValue) {
                            setState(() {
                              _farmState.text = newValue ?? "";
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
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget createBillingProfile(bool canEdit) {
    return Column(children: [
      createGroupTitle("Billing"),
      const SizedBox(height: 8),
      createGroupRow("Payment Method", _paymentMethod, canEdit),
      const SizedBox(height: 8),
      createGroupRow("Billing Address", _billingAddress, canEdit),
    ]);
  }

  Widget createGroupTitle(String groupTitle) {
    return Column(children: [
      const SizedBox(
        height: 40,
      ),
      Row(
        children: [
          const SizedBox(
            width: 15,
          ),
          Text(
            groupTitle,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
    ]);
  }

  Widget createGroupRow(
      String title, TextEditingController titleValue, bool canEdit) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: TextFormField(
            // titleValue.text,
            controller: titleValue,
            readOnly: !canEdit,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
