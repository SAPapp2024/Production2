import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/app_text_form_field.dart';
import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditUserPasswordScreenArguments {
  final UserModel user;

  const EditUserPasswordScreenArguments({required this.user});
}

class EditUserPasswordScreen extends StatefulWidget {
  static const String id = "/edit_user_password_screen";
  final UserModel user;

  const EditUserPasswordScreen({super.key, required this.user});

  @override
  State<EditUserPasswordScreen> createState() => _EditUserPasswordScreenState();
}

class _EditUserPasswordScreenState extends State<EditUserPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final UserState userState = getIt.get();
  final ProfileService profileService = getIt.get();
  bool isLoading = false;

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
        title: const Text("Change password"),
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
                              child: Text(
                                "Security",
                                style: TextStyle(
                                    color: AppColors.strongGray,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            AppTextFormField(
                              hint: "Enter current password",
                              floatingLabel: "Current password",
                              controller: _currentPassword,
                              textInputAction: TextInputAction.next,
                              obscureText: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter current password";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            AppTextFormField(
                              hint: "Enter new password",
                              floatingLabel: "New password",
                              controller: _newPassword,
                              textInputAction: TextInputAction.next,
                              obscureText: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter new password";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            AppTextFormField(
                              hint: "Re-enter new password",
                              floatingLabel: "Confirm password",
                              controller: _confirmPassword,
                              textInputAction: TextInputAction.next,
                              obscureText: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please re-enter new password";
                                }
                                if (value != _newPassword.text) {
                                  return "Password does not match";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
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
                      const SizedBox(
                        height: 16,
                      ),
                    ])),
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
      if (!_formKey.currentState!.validate()) return;
      setState(() {
        isLoading = true;
      });
      await profileService.updatePassword(
          widget.user.id, _currentPassword.text, _newPassword.text);
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
