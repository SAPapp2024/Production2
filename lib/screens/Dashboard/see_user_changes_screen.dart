import 'package:agro_k/models/company/user_change_with_user_model.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeeUserChangesScreenArguments {
  final List<UserChangeWithUserModel> userChanges;

  const SeeUserChangesScreenArguments({required this.userChanges});
}

class SeeUserChangesScreen extends StatefulWidget {
  static const id = "/see_user_changes";
  final List<UserChangeWithUserModel> userChanges;

  const SeeUserChangesScreen({Key? key, required this.userChanges})
      : super(key: key);

  @override
  State<SeeUserChangesScreen> createState() => _SeeUserChangesScreenState();
}

class _SeeUserChangesScreenState extends State<SeeUserChangesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            context.goBackWeb();
          },
        ),
        backgroundColor: AppColors.appPrimaryGreen,
        centerTitle: true,
        title: const Text("User changes"),
      ),
      backgroundColor: AppColors.pageBackground,
      body: widget.userChanges.isNotEmpty
          ? ListView.builder(
              itemCount: widget.userChanges.length,
              itemBuilder: (BuildContext context, int index) {
                UserChangeWithUserModel userChange = widget.userChanges[index];
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 500,
                      child: Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text("Change made by:",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.black1,
                                            fontWeight: FontWeight.w600)),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(userChange.user != null
                                            ? "${userChange.user!.firstName} ${capitalizeLastWord(userChange.user!.lastName ?? "")}"
                                            : "User doesn't exist"),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      const Text("Change date:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.black1,
                                              fontWeight: FontWeight.w600)),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(DateFormat.yMd().format(
                                              userChange
                                                  .userChangeModel.changeDate)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 12.0),
                                  child: Text("User changes",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.black1,
                                          fontWeight: FontWeight.w700)),
                                ),
                                showChangeIfExists(
                                    "Phone",
                                    userChange.userChangeModel.oldState.phone
                                        ?.getFullPhoneNumber(),
                                    userChange.userChangeModel.newState.phone
                                        ?.getFullPhoneNumber()),
                                showChangeIfExists(
                                    "Email",
                                    userChange.userChangeModel.oldState.email,
                                    userChange.userChangeModel.newState.email),
                                showChangeIfExists(
                                    "First Name",
                                    userChange
                                        .userChangeModel.oldState.firstName,
                                    userChange
                                        .userChangeModel.newState.firstName),
                                showChangeIfExists(
                                    "Last Name",
                                    capitalizeLastWord(userChange
                                            .userChangeModel
                                            .oldState
                                            .lastName ??
                                        ""),
                                    capitalizeLastWord(userChange
                                            .userChangeModel
                                            .newState
                                            .lastName ??
                                        "")),
                                showChangeIfExists(
                                    "Enabled",
                                    userChange.userChangeModel.oldState.enabled
                                        .toString(),
                                    userChange.userChangeModel.newState.enabled
                                        .toString()),
                                showPhotoChangeIfExists(
                                    "Profile Image",
                                    userChange.userChangeModel.oldState
                                        .profileImagePath,
                                    userChange.userChangeModel.newState
                                        .profileImagePath),
                              ],
                            ),
                          )),
                    ),
                  ),
                );
              })
          : Container(),
    );
  }

  Widget showChangeIfExists(String title, String? oldValue, String? newValue) {
    if (oldValue == newValue) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$title:",
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black1,
                    fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(
                    child: Text(
                  oldValue ?? "No value",
                  textAlign: TextAlign.center,
                )),
                const Icon(Icons.arrow_right_alt_outlined),
                Expanded(
                    child: Text(newValue ?? "No value",
                        textAlign: TextAlign.center))
              ],
            )
          ],
        ),
      );
    }
  }

  Widget showPhotoChangeIfExists(
      String title, String? oldValue, String? newValue) {
    if (oldValue == newValue) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$title:",
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black1,
                    fontWeight: FontWeight.w600)),
            Row(
              children: [
                oldValue != null
                    ? Image.asset(oldValue)
                    : Expanded(
                        child: Text(
                        oldValue ?? "No Photo",
                        textAlign: TextAlign.center,
                      )),
                const Icon(Icons.arrow_right_alt_outlined),
                newValue != null
                    ? Image.asset(newValue)
                    : Expanded(
                        child: Text(
                        newValue ?? "No Photo",
                        textAlign: TextAlign.center,
                      )),
              ],
            )
          ],
        ),
      );
    }
  }
}
