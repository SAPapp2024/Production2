import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/TagLabel.dart';
import 'package:agro_k/components/app_text_form_field.dart';
import 'package:agro_k/components/company_card.dart';
import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/components/menu_options_popup.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/mobile_dashboard.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/web_dashboard.dart';
import 'package:agro_k/screens/Dashboard/user_management_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/members_service.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:agro_k/utilities/function_utils/date_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/function_utils/validation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MembersScreen extends StatefulWidget {
  final UserModel user;
  final CompanyModel company;

  const MembersScreen({Key? key, required this.user, required this.company})
      : super(key: key);

  @override
  MembersScreenState createState() => MembersScreenState();
}

class MembersScreenState extends State<MembersScreen> {
  UserState userState = getIt.get<UserState>();
  final TextEditingController _emailController = TextEditingController();
  MembersService membersService = getIt.get();
  ProfileService profileService = getIt.get();
  AuthService authService = getIt.get();
  List<UserModel> activeMembers = [];
  List<String> invitedMembers = [];
  String? _farmName;
  String? _farmAddress;

  double toolbarHeight = 100;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<void> getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await getCompany();
      await getMembers();
    } on FirebaseException catch (e) {
      showOneButtonAlertDialog(context, "Try again", () {
        Navigator.pop(context);
        getData();
      }, "Error", e.message ?? "Unknown error.");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getCompany() async {
    setState(() {
      _farmName = widget.company.name;
      _farmAddress = widget.company.address;
    });
  }

  Future<void> removeUserFromCompany(
      UserModel userModel, CompanyModel farmModel) async {
    try {
      setState(() {
        isLoading = true;
      });
      await authService.removeUserFromCompany(userModel.id, farmModel);
      activeMembers.remove(userModel);
      if (mounted) {
        showOneButtonAlertDialog(context, "Ok", () {
          Navigator.pop(context);
        }, "Removed",
            "You have just removed ${userModel.getFullName()} from your company.");
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

  Future<void> removeMemberInvite(String email, CompanyModel farmModel) async {
    try {
      setState(() {
        isLoading = true;
      });
      await authService.removeMemberInvite(email, farmModel);
      invitedMembers.remove(email);
      if (mounted) {
        showOneButtonAlertDialog(context, "Ok", () {
          Navigator.pop(context);
        }, "Removed", "You have just removed the invite to $email.");
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

  Future<void> getMembers() async {
    try {
      Set<List<dynamic>> members = await membersService.getMembersOfCompany(
          user: widget.user, company: widget.company);
      setState(() {
        activeMembers = members.first as List<UserModel>;
        invitedMembers =
            (members.last as List<String>).map((e) => e.trim()).toList();
      });
    } on FirebaseException catch (e) {
      showOneButtonAlertDialog(context, "Try again", () {
        Navigator.pop(context);
        getMembers();
      }, "Error", e.message ?? "Unknown error.");
    }

    //get users for farm
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return SafeArea(
      child: Stack(
        children: [
          showMembersWidget(),
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
    );
  }

  Widget showMembersWidget() {
    return kIsWeb
        ? SingleChildScrollView(
            child: Column(children: [
            const SizedBox(
              height: 50,
            ),
            if (userState.isCompanyAdmin() || userState.isSuperAdmin()) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: TextFormField(
                    controller: _emailController,
                    onFieldSubmitted: (_) => inviteUser(),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: inviteUser,
                          icon: const Icon(
                            Icons.add,
                            color: AppColors.appPrimaryGreen,
                          )),
                      labelText: "Invite Email",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
            const Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text(
                  "Active Members",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            activeMembersCard(),
            const SizedBox(
              height: 20,
            ),
            if (userState.isCompanyAdmin() || userState.isSuperAdmin()) ...[
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Invited Members",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Container(
                        height: 250,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 2)),
                        child: ListView.builder(
                            itemCount: invitedMembers.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _invitedMemberItem(index, context);
                            })),
                  ),
                ],
              ),
            ],
            const SizedBox(
              height: 50,
            )
          ]))
        : setupMobileView();
  }

  Widget _invitedMemberItem(int index, BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                invitedMembers[index],
                style: const TextStyle(color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextButton(
                onPressed: () {
                  showTwoButtonAlertDialog(
                      context,
                      "Cancel",
                      () {
                        Navigator.pop(context);
                      },
                      "Remove",
                      () {
                        Navigator.pop(context);
                        removeMemberInvite(
                            invitedMembers[index], widget.company);
                      },
                      "Remove invite?",
                      "You are about to remove the invite to ${invitedMembers[index]} are you sure you want to continue?");
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    "Remove",
                    style: TextStyle(
                        color: AppColors.appPrimaryGreen, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget setupMobileView() {
    return SingleChildScrollView(
      child: Container(
        color: AppColors.pageBackground,
        child: Column(
          children: [
            const SizedBox(
              height: 28,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CompanyCard(
                company: widget.company,
                padding:
                    const EdgeInsets.symmetric(horizontal: 27, vertical: 20),
              ),
            ),
            const SizedBox(
              height: 36,
            ),
            activeMembersCardMobile(),
            ...(userState.isCompanyAdmin() || userState.isSuperAdmin()
                ? [
                    const SizedBox(
                      height: 16,
                    ),
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Invite members",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.strongGray),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          AppTextFormField(
                            controller: _emailController,
                            hint: "Enter email address",
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                type: PrimaryButtonType.filled,
                                onPressed: inviteUser,
                                title: "Send invite",
                                actionType: PrimaryButtonActionType.positive,
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CustomCard(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Invited members",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.strongGray),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          (invitedMembers.isNotEmpty
                              ? ListView.builder(
                                  itemCount: invitedMembers.length,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                invitedMembers[index],
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColors.subtitleGray),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: TextButton(
                                                onPressed: () {
                                                  showTwoButtonAlertDialog(
                                                      context,
                                                      "Cancel",
                                                      () {
                                                        Navigator.pop(context);
                                                      },
                                                      "Remove",
                                                      () {
                                                        Navigator.pop(context);
                                                        removeMemberInvite(
                                                            invitedMembers[
                                                                index],
                                                            widget.company);
                                                      },
                                                      "Remove invite?",
                                                      "You are about to remove the invite to ${invitedMembers[index]} are you sure you want to continue?");
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Text(
                                                    "Remove",
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .appPrimaryGreen,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  })
                              : const Text("No invited members",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black1))),
                        ],
                      )),
                    ),
                    const SizedBox(
                      height: 31,
                    ),
                  ]
                : []),
          ],
        ),
      ),
    );
  }

  Widget activeMembersCardMobile() {
    return CustomCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Active members",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.strongGray),
          ),
          const SizedBox(
            height: 16,
          ),
          ListView.separated(
              shrinkWrap: true,
              itemCount: activeMembers.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: 16,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                UserModel member = activeMembers[index];
                bool memberIsCompanyAdmin =
                    member.isCompanyAdmin(widget.company.id);
                return InkWell(
                  onTap: kIsWeb && userState.isSuperAdmin()
                      ? () {
                          context.go(
                              "${ManageUsersScreen.id}?highlightedUserId=${member.id}");
                        }
                      : null,
                  child: Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(300.0),
                          child: member.profileImagePath == null
                              ? Image.asset(
                                  "images/profilePicturePlaceholder.png",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Image(
                                  image: NetworkImage(member.profileImagePath!),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 0,
                                    child: Text(
                                      "${member.firstName} ${capitalizeLastWord(member.lastName ?? "")}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 0,
                                    child: Text(
                                      member.email,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.subtitleGray),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "Joined ${getDaysFromDateToToday(member.created)} days ago",
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.grayTextColor),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (memberIsCompanyAdmin)
                                  const TagLabel(
                                    text: "Admin",
                                    type: TagLabelType.enabled,
                                  ),
                                if (!memberIsCompanyAdmin)
                                  const TagLabel(
                                    text: "Member",
                                    type: TagLabelType.enabled,
                                  ),
                                if ((userState.isCompanyAdmin() ||
                                        userState.isSuperAdmin()) &&
                                    !memberIsCompanyAdmin &&
                                    member.email != widget.user.email)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (dialogContext) {
                                                return MenuOptionsPopup(
                                                    options:
                                                        MemberOptions.values,
                                                    presentation: (value) =>
                                                        value.toPresentation,
                                                    onSelected: (value) {
                                                      switch (value) {
                                                        case MemberOptions
                                                              .removeMember:
                                                          showTwoButtonAlertDialog(
                                                              context,
                                                              "Cancel",
                                                              () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              "Remove",
                                                              () {
                                                                Navigator.pop(
                                                                    context);
                                                                removeUserFromCompany(
                                                                    member,
                                                                    widget
                                                                        .company);
                                                              },
                                                              "Remove member?",
                                                              "You are about to remove ${member.email} are you sure you want to continue?");
                                                          break;
                                                        case MemberOptions
                                                              .makeAdmin:
                                                          showTwoButtonAlertDialog(
                                                              context,
                                                              "Cancel",
                                                              () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              "Accept",
                                                              () async {
                                                                assignNewCompanyAdmin(
                                                                    widget.user,
                                                                    member,
                                                                    widget
                                                                        .company);
                                                              },
                                                              "Assign new admin?",
                                                              "You are about to assign ${member.email} as company admin for ${widget.company.name} are you sure you want to continue?");
                                                          break;
                                                      }
                                                    });
                                              });
                                        },
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero),
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  const Size(50, 20)),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        icon: Icon(Icons.more_vert_outlined)),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget activeMembersCard() {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      elevation: 8,
      child: Container(
          constraints:
              BoxConstraints(maxHeight: activeMembers.length > 3 ? 950 : 300),
          width: MediaQuery.of(context).size.width - 40,
          padding: const EdgeInsets.all(12),
          child: ListView.separated(
              shrinkWrap: true,
              itemCount: activeMembers.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: 10,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                UserModel member = activeMembers[index];
                bool memberIsCompanyAdmin =
                    member.isCompanyAdmin(widget.company.id);
                return Card(
                  elevation: 0,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: const BorderSide(
                          color: AppColors.hintTextColor, width: 2.0)),
                  child: InkWell(
                    onTap: kIsWeb && userState.isSuperAdmin()
                        ? () {
                            context.go(
                                "${ManageUsersScreen.id}?highlightedUserId=${member.id}");
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 12, bottom: 10),
                      width: MediaQuery.of(context).size.width - 40,
                      child: Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(300.0),
                              child: member.profileImagePath == null
                                  ? Image.asset(
                                      "images/profilePicturePlaceholder.png",
                                      width: 51,
                                      height: 51,
                                    )
                                  : Image(
                                      image: NetworkImage(
                                          member.profileImagePath!),
                                      width: 51,
                                      height: 51,
                                      fit: BoxFit.cover,
                                    )),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 17.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            "${member.firstName} ${capitalizeLastWord(member.lastName ?? "")} (${member.email})",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.black1),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            "Joined ${getDaysFromDateToToday(member.created)} days ago",
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.grayTextColor),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (memberIsCompanyAdmin)
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(8)),
                                              color: Colors.white),
                                          padding: const EdgeInsets.all(4),
                                          child: const Text("Admin",
                                              style: TextStyle(
                                                  color:
                                                      AppColors.grayTextColor)),
                                        ),
                                      if ((userState.isCompanyAdmin() ||
                                              userState.isSuperAdmin()) &&
                                          !memberIsCompanyAdmin &&
                                          member.email != widget.user.email)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: IconButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (dialogContext) {
                                                      return MenuOptionsPopup(
                                                          options:
                                                          MemberOptions.values,
                                                          presentation: (value) =>
                                                          value.toPresentation,
                                                          onSelected: (value) {
                                                            switch (value) {
                                                              case MemberOptions
                                                                  .removeMember:
                                                                showTwoButtonAlertDialog(
                                                                    context,
                                                                    "Cancel",
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    "Remove",
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      removeUserFromCompany(
                                                                          member,
                                                                          widget
                                                                              .company);
                                                                    },
                                                                    "Remove member?",
                                                                    "You are about to remove ${member.email} are you sure you want to continue?");
                                                                break;
                                                              case MemberOptions
                                                                  .makeAdmin:
                                                                showTwoButtonAlertDialog(
                                                                    context,
                                                                    "Cancel",
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    "Accept",
                                                                        () async {
                                                                      assignNewCompanyAdmin(
                                                                          widget.user,
                                                                          member,
                                                                          widget
                                                                              .company);
                                                                    },
                                                                    "Assign new admin?",
                                                                    "You are about to assign ${member.email} as company admin for ${widget.company.name} are you sure you want to continue?");
                                                                break;
                                                            }
                                                          });
                                                    });
                                              },
                                              style: ButtonStyle(
                                                padding: MaterialStateProperty.all(
                                                    EdgeInsets.zero),
                                                minimumSize:
                                                MaterialStateProperty.all(
                                                    const Size(50, 20)),
                                                tapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              icon: Icon(Icons.more_vert_outlined)),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })),
    );
  }

  void assignNewCompanyAdmin(UserModel currentCompanyAdmin,
      UserModel newCompanyAdmin, CompanyModel company) async {
    setState(() {
      isLoading = true;
    });
    try {
      Navigator.pop(context);
      await authService.setUserAsCompanyAdmin(
          widget.user, newCompanyAdmin, widget.company);
      await userState.getUserDataFirstTime();
      if (!context.mounted) return;
      if (kIsWeb) {
        await userState.getCurrentCompanyFirstTime(company.id);
        if (!context.mounted) return;
        context.findAncestorStateOfType<WebDashboardState>()?.setState(() {});
      } else {
        context
            .findAncestorStateOfType<MobileDashboardState>()
            ?.setState(() {});
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

  void inviteUser() {
    var email = _emailController.text.trim();
    try {
      validateEmail(email);
    } on AuthErrors catch (_) {
      return;
    }
    if (invitedMembers.contains(email)) {
      showOneButtonAlertDialog(context, "Ok", () {
        _emailController.text = "";
        Navigator.pop(context);
      }, "Error", "This user has already been invited");
    } else if (activeMembers
            .indexWhere((element) => element.email.trim() == email) !=
        -1) {
      showOneButtonAlertDialog(context, "Ok", () {
        _emailController.text = "";
        Navigator.pop(context);
      }, "Error", "This user is already a member.");
    } else {
      showTwoButtonAlertDialog(
          context,
          "Cancel",
          () {
            Navigator.pop(context);
          },
          "Invite",
          () async {
            try {
              Navigator.pop(context);
              setState(() {
                isLoading = true;
              });
              await membersService.inviteMembersToCompany(email, widget.company,
                  RepositoryProvider.of<Environment>(context, listen: false));
              await getData();
              setState(() {
                _emailController.text = "";
              });
              if (mounted) {
                showOneButtonAlertDialog(context, "Ok", () {
                  Navigator.pop(context);
                }, "Success!", "We have invited $email to your company.");
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
          "Invite User?",
          "Are you sure you want to invite $email to your company?");
    }
  }

  Widget setupInviteMembersCard() {
    return Column(
      children: [
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: inviteUser,
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.appPrimaryGreen,
                    )),
                labelText: "Invite Email",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Text(
              "Invited Members",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Card(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            elevation: 8,
            child: Container(
              height: 250,
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(12),
              child: invitedMembers.isNotEmpty
                  ? ListView.builder(
                      itemCount: invitedMembers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 10.0,
                            ),
                            Card(
                              elevation: 0,
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: const BorderSide(
                                      color: AppColors.hintTextColor,
                                      width: 2.0)),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 12, bottom: 10),
                                width: MediaQuery.of(context).size.width - 40,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        invitedMembers[index],
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black1),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: TextButton(
                                        onPressed: () {
                                          showTwoButtonAlertDialog(
                                              context,
                                              "Cancel",
                                              () {
                                                Navigator.pop(context);
                                              },
                                              "Remove",
                                              () {
                                                Navigator.pop(context);
                                                removeMemberInvite(
                                                    invitedMembers[index],
                                                    widget.company);
                                              },
                                              "Remove invite?",
                                              "You are about to remove the invite to ${invitedMembers[index]} are you sure you want to continue?");
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Text(
                                            "Remove",
                                            style: TextStyle(
                                                color:
                                                    AppColors.appPrimaryGreen,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      })
                  : const Text("No invited members",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black1)),
            )),
        const SizedBox(
          height: 50,
        )
      ],
    );
  }
}

enum MemberOptions { removeMember, makeAdmin }

extension MemberOptionsExtension on MemberOptions {
  String get toPresentation {
    switch (this) {
      case MemberOptions.removeMember:
        return "Remove member";
      case MemberOptions.makeAdmin:
        return "Make admin";
    }
  }
}
