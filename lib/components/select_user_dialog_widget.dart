import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SelectUserDialogWidget extends StatefulWidget {
  final List<UserModel> users;
  final String? selectedUserId;
  final String title;

  const SelectUserDialogWidget(
      {Key? key,
      required this.users,
      required this.selectedUserId,
      required this.title})
      : super(key: key);

  @override
  State<SelectUserDialogWidget> createState() => _SelectUserDialogWidgetState();
}

class _SelectUserDialogWidgetState extends State<SelectUserDialogWidget> {
  UserModel? _selectedUserModel;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    _selectedUserModel = widget.users
        .firstWhereOrNull((userModel) => userModel.id == widget.selectedUserId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = Theme.of(context);
    var currentThemeText = currentTheme.textTheme;
    return Theme(
      data: currentTheme.copyWith(
          textTheme: currentThemeText.copyWith(
              labelLarge:
                  currentThemeText.labelLarge?.copyWith(fontFamily: "Mulish"),
              bodyLarge:
                  currentThemeText.bodyLarge?.copyWith(fontFamily: "Mulish"),
              labelMedium:
                  currentThemeText.labelMedium?.copyWith(fontFamily: "Mulish"),
              displayMedium: currentThemeText.displayMedium
                  ?.copyWith(fontFamily: "Mulish"),
              titleMedium:
                  currentThemeText.titleMedium?.copyWith(fontFamily: "Mulish"),
              titleSmall:
                  currentThemeText.titleSmall?.copyWith(fontFamily: "Mulish"),
              bodyMedium:
                  currentThemeText.bodyMedium?.copyWith(fontFamily: "Mulish"))),
      child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: IntrinsicWidth(
                  child: Container(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 24.0, bottom: 47.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.black1),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            FormField<UserModel?>(
                                builder: (FormFieldState<UserModel?> state) {
                              return Column(
                                children: [
                                  InputDecorator(
                                      decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFD0D5DD),
                                                  width: 1.0))),
                                      isEmpty: _selectedUserModel == null,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<UserModel?>(
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Color(0xFF667085),
                                          ),
                                          value: _selectedUserModel,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedUserModel = newValue;
                                            });
                                          },
                                          selectedItemBuilder: (context) {
                                            return [null, ...widget.users]
                                                .map((UserModel? value) {
                                              return DropdownMenuItem<
                                                  UserModel?>(
                                                value: value,
                                                child: Text(
                                                  value?.getFullName() ??
                                                      "Unassigned",
                                                  style: const TextStyle(
                                                      color: Color(0xFF818186)),
                                                ),
                                              );
                                            }).toList();
                                          },
                                          items: [null, ...widget.users]
                                              .map((UserModel? value) {
                                            final isCurrentItem =
                                                _selectedUserModel != null &&
                                                    _selectedUserModel == value;
                                            return DropdownMenuItem<UserModel?>(
                                              value: value,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      value?.getFullName() ??
                                                          "Unassigned",
                                                      style: const TextStyle(
                                                          color:
                                                              AppColors.black1),
                                                    ),
                                                  ),
                                                  if (isCurrentItem)
                                                    const Icon(
                                                      Icons.check,
                                                      color:
                                                          AppColors.appbarGreen,
                                                    )
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      )),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(state.errorText!,
                                              style: const TextStyle(
                                                  color: Colors.red))),
                                    )
                                ],
                              );
                            }),
                            const SizedBox(height: 48),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  AppColors.appbarGreen),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  side: const BorderSide(
                                                      color: AppColors
                                                          .appbarGreen)))),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.0),
                                        child: Text("Cancel"),
                                      )),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context, _selectedUserModel ?? -1);
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  AppColors.appbarGreen),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  side: const BorderSide(
                                                      color: AppColors.appbarGreen)))),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.0),
                                        child: Text("Assign"),
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
          )),
    );
  }
}
