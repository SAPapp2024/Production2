import 'dart:io';

import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/UserNotificationSettings.dart';
import 'package:agro_k/components/card_with_info_rows.dart';
import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/components/select_user_dialog_widget.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/invite_wrapper.dart';
import 'package:agro_k/models/user/notification_settings_model.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/Auth/log_in/view/log_in_screen.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/mobile_dashboard.dart';
import 'package:agro_k/screens/edit_user_password_screen.dart';
import 'package:agro_k/screens/edit_user_profile_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:agro_k/utilities/function_utils/date_utils.dart';
import 'package:agro_k/utilities/function_utils/file_utils.dart';
import 'package:agro_k/utilities/function_utils/general_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/function_utils/version_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/utility_models/info_row.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MobileUserProfileScreen extends StatefulWidget {
  final UserModel user;
  final CompanyModel? company;
  final List<InvitesWrapperWithCompany> invites;

  const MobileUserProfileScreen(
      {Key? key,
      required this.user,
      required this.company,
      required this.invites})
      : super(key: key);

  @override
  State<MobileUserProfileScreen> createState() =>
      _MobileUserProfileScreenState();
}

class _MobileUserProfileScreenState extends State<MobileUserProfileScreen> {
  //Profile
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  String _phoneAreaCode = "";
  String _phoneCountryISOName = "";
  final ProfileService profileService = getIt.get();
  final AuthService authService = getIt.get();
  final UserState userState = getIt.get();

  WebViewController webViewController = WebViewController();

  bool _readOnly = true;
  String? _companyName;
  String? _companyAddress;
  bool isLoading = false;
  String appVersion = "";

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  bool wasUpdated = false;

  //Notifications
  bool sampleStartedEmail = false;
  bool sampleStarted = false;

  bool sampleCompleteEmail = false;
  bool sampleComplete = false;

  bool sampleCancelledEmail = false;
  bool sampleCancelled = false;

  bool daysSinceSampleStartEmail = false;
  bool daysSinceSampleStart = false;

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  void didUpdateWidget(covariant MobileUserProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.company != oldWidget.company) {
      getData();
    } else if (!areListsEqual(widget.invites, oldWidget.invites)) {
      setState(() {});
    }
  }

  Future<void> getAppVersionLabel() async {
    var env = RepositoryProvider.of<Environment>(context, listen: false);
    appVersion =
        "Sap Analysis${env == Environment.prod ? "" : " Dev"} ${await VersionUtils.getAppVersionString(env)}";
    setState(() {});
  }

  void getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      getUser(widget.user);
      getCompany();
      getAppVersionLabel();
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getCompany() {
    setState(() {
      _companyName = widget.company?.name ?? "";
      _companyAddress = widget.company?.address ?? "";
    });
  }

  void getUser(UserModel user) {
    downloadUserProfilePictureFile(user);
    setState(() {
      _firstName.text = user.firstName ?? "No first name";
      _lastName.text = user.lastName != null
          ? capitalizeLastWord(user.lastName!)
          : "No last name";
      _email.text = user.email;
      _phone.text = user.phone?.getFullPhoneNumber() ?? "";
      _phoneAreaCode = user.phone?.phoneAreaCode ?? "1";
      _phoneCountryISOName = user.phone?.phoneCountryISOName ?? "US";
      sampleStarted = user.notificationSettings.sampleStarted;
      sampleStartedEmail = user.notificationSettings.sampleStartedEmail;

      sampleCompleteEmail = user.notificationSettings.sampleCompleteEmail;
      sampleComplete = user.notificationSettings.sampleComplete;

      sampleCancelledEmail = user.notificationSettings.sampleCancelledEmail;
      sampleCancelled = user.notificationSettings.sampleCancelled;

      daysSinceSampleStartEmail =
          user.notificationSettings.daysSinceSampleStartEmail;
      daysSinceSampleStart = user.notificationSettings.daysSinceSampleStart;
    });
  }

  void removeInvite(String inviteId) {
    widget.invites.removeWhere((element) => element.id == inviteId);
    setState(() {});
  }

  Widget createUserProfile() {
    var phoneFocusNode = FocusNode();
    return Stack(children: [
      Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: createGroupRow("First Name", _firstName, true),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Last Name",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
              child: TextFormField(
                controller: _lastName,
                readOnly: _readOnly,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(phoneFocusNode);
                },
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
        createGroupRow("Email", _email, false),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Phone",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            _phoneCountryISOName.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                    child: IntlPhoneField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      readOnly: _readOnly,
                      focusNode: phoneFocusNode,
                      initialCountryCode: _phoneCountryISOName,
                      decoration: InputDecoration(
                        border: _readOnly
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
                      enabled: !_readOnly,
                      onCountryChanged: (Country country) {
                        setState(() {
                          _phoneCountryISOName = country.code;
                          _phoneAreaCode = country.dialCode;
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
        )
      ]),
      Align(
        alignment: Alignment.topRight,
        child: TextButton(
            onPressed: () {
              if (!_readOnly) {
                _lastName.text = capitalizeLastWord(_lastName.text);
                phoneFocusNode.unfocus();
              }
              setState(() {
                _readOnly = !_readOnly;
              });
            },
            child: Text(
              _readOnly ? "Edit profile" : "Done",
              style: const TextStyle(color: AppColors.appPrimaryGreen),
            )),
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
        const SizedBox(
          width: 20,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryButton(
                      title: "Edit profile",
                      onPressed: () async {
                        final newProfile = await context
                            .pushNamed<UserModel>(EditUserProfileScreen.id);
                        if (newProfile != null) {
                          getUser(newProfile);
                        }
                      },
                      actionType: PrimaryButtonActionType.positive,
                      type: PrimaryButtonType.text,
                    ),
                    IconButton(
                      onPressed: () async {
                        showTwoButtonAlertDialog(
                            context,
                            "Cancel",
                            () {
                              Navigator.pop(context);
                            },
                            "Logout",
                            () async {
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
                            },
                            "Logout?",
                            "Are you sure you want to logout?");
                      },
                      icon: Image.asset(
                        "images/iconLogout.png",
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ),
              widget.invites.isNotEmpty
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Invites",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            const SizedBox(
                              width: 8,
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
                                      fontSize: 18),
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
                        Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          elevation: 8,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                child: ListView.builder(
                                    itemCount: widget.invites.length,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
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
                                                    color:
                                                        AppColors.hintTextColor,
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
                                                          CrossAxisAlignment
                                                              .start,
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
                                                                    FontWeight
                                                                        .w600,
                                                                color: AppColors
                                                                    .black1),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 4.0),
                                                          child: Text(
                                                            "Invited ${getDaysFromDateToToday(invite.created)} days ago",
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: AppColors
                                                                    .grayTextColor),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  TextButton(
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
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      showTwoButtonAlertDialog(
                                                          context,
                                                          "No",
                                                          () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          "Yes",
                                                          () {
                                                            Navigator.pop(
                                                                context);
                                                            answerInvite(
                                                                invite, true);
                                                          },
                                                          "Join ${invite.company.name}?",
                                                          "Are you sure you want to join ${invite.company.name}?");
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      showTwoButtonAlertDialog(
                                                          context,
                                                          "No",
                                                          () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          "Yes",
                                                          () {
                                                            Navigator.pop(
                                                                context);
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
                                                                color:
                                                                    Colors.grey,
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
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    )
                  : Container(),
              const SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    openCameraGallerySelection();
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                    child: _profileImage != null
                        ? Image.file(
                            _profileImage!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "images/profilePicturePlaceholder.png",
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 36,
              ),
              CardWithInfoRows(
                infoRows: [
                  InfoRow(
                    "First Name",
                    _firstName.text,
                  ),
                  InfoRow(
                    "Last Name",
                    _lastName.text,
                  ),
                  InfoRow(
                    "Email",
                    _email.text,
                  ),
                  InfoRow(
                    "Phone",
                    _phone.text,
                  ),
                ],
                onTap: (int value) {},
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "Security",
                  style: TextStyle(
                      color: AppColors.strongGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              CustomCard(
                  child: const Row(
                    children: [
                      Expanded(
                          child: Text(
                        "Change your password",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      )),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 24,
                        color: AppColors.subtitleGray,
                      )
                    ],
                  ),
                  onTap: () {
                    context.pushNamed(EditUserPasswordScreen.id);
                  }),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "Notifications",
                  style: TextStyle(
                      color: AppColors.strongGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              UserNotificationSettings(
                user: widget.user,
                profileService: profileService,
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "Settings",
                  style: TextStyle(
                      color: AppColors.strongGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              CardWithInfoRows(
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  title: "Delete account",
                  onPressed: _deleteAccount,
                  actionType: PrimaryButtonActionType.negative,
                  type: PrimaryButtonType.outlined,
                ),
              ),
              const SizedBox(
                height: 16,
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
          context
              .findAncestorStateOfType<MobileDashboardState>()
              ?.setState(() {});
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
        phone: _phone.text.isEmpty
            ? null
            : PhoneModel(
                phone: _phone.text,
                phoneAreaCode: _phoneAreaCode,
                phoneCountryISOName: _phoneCountryISOName),
        notifSettings: notifSettings,
        email: _email.text);
  }

  void saveData() async {
    try {
      await saveProfileData(profileService);
      await userState.getUserDataFirstTime();
      setState(() {
        _readOnly = true;
      });
    } on FirebaseException catch (e) {
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
  }

  void openCameraGallerySelection() {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 275,
              child: CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                        _openCameraPicker();
                      },
                      child: const Text("Camera")),
                  CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                        _openGalleryPicker();
                      },
                      child: const Text("Gallery")),
                ],
                cancelButton: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
              ),
            ));
  }

  Future<void> _deleteAccount() async {
    showTwoButtonAlertDialog(
        context,
        "No",
        () {
          Navigator.pop(context);
        },
        "Yes",
        () async {
          try {
            setState(() {
              isLoading = true;
            });
            final listOfCompaniesWhereUserIsAdmin = widget
                .user.companyReferences
                .where((company) => company.isAdmin);
            if (listOfCompaniesWhereUserIsAdmin.isNotEmpty) {
              showOneButtonAlertDialog(context, "Ok", () {
                Navigator.pop(context);
              }, "Error",
                  "You can't delete your account because you are an admin of these companies: ${listOfCompaniesWhereUserIsAdmin.map((e) => e.companyName).join(", ")}.");
            } else {
              await profileService.deleteUserProfile(widget.user);
              await authService.signOut();
              if (!mounted) return;
              context.goNamed(LogInScreen.id);
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
        },
        "Delete account?",
        "Are you sure you want to delete your account?");
  }

  // Implementing the image picker
  Future<void> _openGalleryPicker() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      try {
        setState(() {
          isLoading = true;
        });
        var file = File(pickedImage.path);
        var url = await _uploadImage(file);
        setState(() {
          _profileImage = file;
          widget.user.profileImagePath = url;
        });
      } catch (e, stacktrace) {
        if (!mounted) return;
        getIt.get<RemoteErrorLoggingService>().recordError(e, stacktrace);
        showOneButtonAlertDialog(context, "Ok", () {
          Navigator.pop(context);
        }, "Error", "There was an error uploading the photo.");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _openCameraPicker() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      try {
        setState(() {
          isLoading = true;
        });
        var file = File(pickedImage.path);
        var url = await _uploadImage(file);
        setState(() {
          _profileImage = file;
          widget.user.profileImagePath = url;
        });
      } catch (e, stacktrace) {
        if (!mounted) return;
        getIt.get<RemoteErrorLoggingService>().recordError(e, stacktrace);
        showOneButtonAlertDialog(context, "Ok", () {
          Navigator.pop(context);
        }, "Error", "There was an error uploading the photo.");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    return profileService.updateUserProfileImage(imageFile);
  }

  Future<void> downloadUserProfilePictureFile(UserModel user) async {
    Directory tempDir = await getTemporaryDirectory();
    File downloadToFile = File("${tempDir.path}/profile-picture.png");
    try {
      await FirebaseStorage.instance
          .ref()
          .child("users/${FirebaseAuth.instance.currentUser?.uid}")
          .writeToFile(downloadToFile);
      setState(() {
        _profileImage = downloadToFile;
      });
    } on FirebaseException catch (exception, stacktrace) {
      if (exception.code != "object-not-found") {
        getIt
            .get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
      }
    }
  }
}

class PdfWebViewScreen extends StatefulWidget {
  final String url;
  final String name;

  const PdfWebViewScreen({super.key, required this.url, required this.name});

  @override
  State<PdfWebViewScreen> createState() => _PdfWebViewScreenState();
}

class _PdfWebViewScreenState extends State<PdfWebViewScreen> {
  File? file;

  @override
  void initState() {
    super.initState();

    downloadPdf();
  }

  void downloadPdf() async {
    file = await downloadFile(widget.url, "pdf");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: AppColors.appPrimaryGreen,
        centerTitle: true,
      ),
      body: file == null
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: PdfViewer.openFile(
                file!.path,
              ),
            ),
    );
  }
}
