import 'dart:math';

import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/components/clear_icon_widget.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/Dashboard/companies_management_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/file_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/sample_sorting.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManageUsersScreenArguments {
  final String? highlightedUserId;

  const ManageUsersScreenArguments({this.highlightedUserId});
}

class ManageUsersScreen extends StatefulWidget {
  static const String id = '/user_management';
  final String? highlightedUserId;

  const ManageUsersScreen({Key? key, this.highlightedUserId}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  ScrollController companiesScrollController = ScrollController();
  ScrollController tableScrollController = ScrollController();
  ScrollController screenScrollController = ScrollController();
  List<UserModel> users = [];
  bool isLoading = false;
  AuthService authService = getIt.get();
  UserModel? user;
  int topListNum = 0;
  int endListNum = 0;
  int entriesSelected = 25;
  int dashboardPageNum = 1;
  int totalEntries = 25;
  List<String> userStatusList = ["Active", "Inactive"];
  bool _showOnlyEnabled = true;

  final TextEditingController _searchFirstName = TextEditingController();
  final TextEditingController _searchLastName = TextEditingController();
  final TextEditingController _searchEmail = TextEditingController();
  final TextEditingController _searchPhone = TextEditingController();
  final TextEditingController _searchCompany = TextEditingController();

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
      await getUsers();
      user = await authService.getUserInDB();
    } catch (e, stackTrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(
            e,
            stackTrace,
          );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getUsers() async {
    List<UserModel> users = await authService.searchUsers(
        _showOnlyEnabled,
        _searchFirstName.text,
        _searchLastName.text,
        _searchEmail.text,
        _searchPhone.text,
        _searchCompany.text,
        sortFilter);
    if (mounted) {
      this.users = users;
      setHighlightedUserInFirstPlace();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
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
          title: const Text("Manage Users"),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: screenScrollController,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: max(1200, MediaQuery.of(context).size.width),
                        child: Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                side: BorderSide(
                                    color: AppColors.cardBorder, width: 1.0)),
                            child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: createUserTable(context))),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
                visible: isLoading,
                child: const Center(child: CircularProgressIndicator()))
          ],
        ),
      ),
    );
  }

  void setHighlightedUserInFirstPlace() {
    if (widget.highlightedUserId != null) {
      var highlightedUserPosition = users.indexWhere(
          (element) => element.id == widget.highlightedUserId!);
      if (highlightedUserPosition != -1) {
        UserModel user = users[highlightedUserPosition];
        users.removeAt(highlightedUserPosition);
        users.insert(0, user);
      }
    }
  }

  Widget createUserTable(BuildContext context) {
    var items = [
      const DropdownMenuItem(value: 25, child: Text("25")),
      const DropdownMenuItem(value: 50, child: Text("50")),
      const DropdownMenuItem(value: 100, child: Text("100"))
    ];
    topListNum = (dashboardPageNum * entriesSelected) - entriesSelected;
    if (topListNum < 1) {
      topListNum = 0;
    }
    endListNum = dashboardPageNum * entriesSelected;
    totalEntries = users.length;
    if (endListNum > users.length) {
      endListNum = users.length;
    }
    var data = users.sublist(topListNum, endListNum);
    return Column(
      children: [
        Row(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "USERS",
                style: TextStyle(
                    color: Colors.black,
                    
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () {
                  searchUsers();
                },
                child: const Text("Apply")),
            const SizedBox(
              width: 15,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () {
                  _searchFirstName.text = "";
                  _searchLastName.text = "";
                  _searchEmail.text = "";
                  _searchPhone.text = "";
                  _searchCompany.text = "";
                  setState(() {
                    sortFilter = UserSortFilterWrapper.empty();
                  });
                  searchUsers();
                },
                child: const Text("Clear Filters")),
            const SizedBox(
              width: 35,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty
                        .all(AppColors
                        .appPrimaryGreen)),
                onPressed: () async {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    await generateUsersExcelFile(
                        users);
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                child: const Text(
                    "Download Report")),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          children: [
            const Text(
              "Show",
              style: TextStyle(
                  color: AppColors.black1,
                  
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              width: 4,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: const BorderRadius.all(
                  Radius.circular(4.0),
                ),
              ),
              height: 33,
              width: 58,
              padding: const EdgeInsets.all(4.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    value: entriesSelected,
                    iconSize: 20,
                    items: items,
                    focusColor: Colors.transparent,
                    style: const TextStyle(
                        color: AppColors.black1,
                        
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                    onChanged: (val) {
                      setState(() {
                        entriesSelected = val as int;
                        dashboardPageNum = 1;
                      });
                    }),
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            const Text(
              "entries",
              style: TextStyle(
                  color: AppColors.black1,
                  
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Scrollbar(
            controller: tableScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: tableScrollController,
              scrollDirection: Axis.horizontal,
              primary: false,
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: AppColors.hintTextColor),
                child: DataTable(
                    dataRowMinHeight: 50,
                    dataRowMaxHeight: 50,
                    headingRowHeight: 100,
                    showBottomBorder: true,
                    columns: [
                      DataColumn(
                        label: Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow(
                                      "First Name", UserSortFields.firstName)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchUsers(),
                                  decoration: InputDecoration(
                                      hintText: "Search First Name",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon:
                                          ClearIcon(_searchFirstName, () {
                                        searchUsers();
                                      })),
                                  controller: _searchFirstName,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow(
                                      "Last Name", UserSortFields.lastName)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchUsers(),
                                  decoration: InputDecoration(
                                      hintText: "Search Last Name",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon:
                                          ClearIcon(_searchLastName, () {
                                        searchUsers();
                                      })),
                                  controller: _searchLastName,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow(
                                      "Email", UserSortFields.email)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchUsers(),
                                  decoration: InputDecoration(
                                      hintText: "Search Email",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(_searchEmail, () {
                                        searchUsers();
                                      })),
                                  controller: _searchEmail,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow(
                                      "Phone", UserSortFields.phone)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchUsers(),
                                  decoration: InputDecoration(
                                      hintText: "Search Phone",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(_searchPhone, () {
                                        searchUsers();
                                      })),
                                  controller: _searchPhone,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow(
                                      "Company", UserSortFields.farmName)),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 200,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: TextFormField(
                                      onFieldSubmitted: (_) => searchUsers(),
                                      decoration: InputDecoration(
                                        hintText: "Search Company",
                                        hintStyle: const TextStyle(
                                            color: AppColors.hintTextColor),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.hintTextColor)),
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        suffixIcon: ClearIcon(_searchCompany, () {
                                          searchUsers();
                                        })
                                      ),
                                      controller: _searchCompany,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: 200,
                                  child: Text(
                                    "Enabled",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  "Show only enabled",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                value: _showOnlyEnabled,
                                checkColor: Colors.white,
                                activeColor: AppColors.appPrimaryGreen,
                                onChanged: (value) {
                                  setState(() {
                                    _showOnlyEnabled = value!;
                                  });
                                  searchUsers();
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    rows: data
                        .mapIndexed(
                          (index, e) => DataRow.byIndex(
                              index: index,
                              color: WidgetStateColor.resolveWith(
                                (states) {
                                  if (e.id == widget.highlightedUserId) {
                                    return Colors.yellowAccent;
                                  } else {
                                    if (index % 2 == 0) {
                                      return AppColors.tableRowBackground;
                                    } else {
                                      return Colors.white;
                                    }
                                  }
                                },
                              ),
                              cells: [
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.firstName ?? "-"),
                                    ), onTap: () {
                                  editFirstName(e);
                                }),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(capitalizeLastWord(
                                          e.lastName ?? "-")),
                                    ), onTap: () {
                                  editLastName(e);
                                }),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.email),
                                    ), onTap: () {
                                  editEmail(e);
                                }),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.phone == null
                                          ? "-"
                                          : e.phone?.phoneCountryISOName ==
                                                  "US"
                                              ? formatUSNumber(
                                                  e.phone!.phone)
                                              : e.phone!.phone),
                                    ), onTap: () {
                                  editPhone(e);
                                }),
                                DataCell(
                                  e.companyReferences.isNotEmpty
                                      ? SingleChildScrollView(
                                          controller: companiesScrollController,
                                          primary: false,
                                          scrollDirection: Axis.vertical,
                                          child: Row(
                                              children: e.companyReferences
                                                  .mapIndexed((index,
                                                          userCompany) =>
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              context.go(
                                                                "${CompaniesManagementScreen
                                                                    .id}?highlightedCompanyId=${userCompany
                                                                    .companyReference.id}",
                                                              );
                                                            },
                                                            style: TextButton.styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                minimumSize:
                                                                    const Size(
                                                                        50,
                                                                        30),
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                                alignment:
                                                                    Alignment
                                                                        .centerLeft),
                                                            child: Text(
                                                              "${userCompany
                                                                  .companyName}: ${userCompany.isAdmin ? "Admin" : "Member"}",
                                                              style: const TextStyle(
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                          if (index !=
                                                              e.companyReferences.length -
                                                                  1) ...[
                                                            const Text(
                                                              ", ",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black, fontSize: 14),
                                                            ),
                                                            const SizedBox(width: 4)
                                                          ]
                                                        ],
                                                      ))
                                                  .toList()),
                                        )
                                      : Text(
                                          e.isSuperAdmin
                                              ? "Super Admin"
                                              : "Guest",
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Checkbox(
                                      value: e.enabled,
                                      onChanged: (bool? newValue) {
                                        editEnabled(e, newValue ?? false);
                                      },
                                      checkColor: Colors.white,
                                      activeColor: AppColors.appPrimaryGreen,
                                    ),
                                  ),
                                ),
                              ]),
                        )
                        .toList()),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const SizedBox(
              width: 3,
            ),
            Text(
              "Showing ${topListNum + 1} to $endListNum of $totalEntries entries",
              style: const TextStyle(
                  color: AppColors.grayTextColor,
                  
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const Expanded(child: SizedBox()),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: AppColors.cardBorder,
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5)),
              ),
              child: TextButton(
                onPressed: dashboardPageNum > 1
                    ? () {
                        setState(() {
                          dashboardPageNum = dashboardPageNum - 1;
                        });
                      }
                    : null,
                child: const Text(
                  "Previous",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.pageBlue,
                border: Border(
                  top: BorderSide(width: 1.0, color: Colors.grey),
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: TextButton(
                onPressed: null,
                child: Text(
                  dashboardPageNum.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: AppColors.cardBorder),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5)),
              ),
              child: TextButton(
                onPressed: dashboardPageNum * entriesSelected < users.length
                    ? () {
                        setState(() {
                          dashboardPageNum = dashboardPageNum + 1;
                        });
                      }
                    : null,
                child: const Text(
                  "Next",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            const SizedBox(
              width: 50,
            )
          ],
        ),
      ],
    );
  }

  Future searchUsers() async {
    try {
      setState(() {
        isLoading = true;
      });
      users = await authService.searchUsers(
          _showOnlyEnabled,
          _searchFirstName.text,
          _searchLastName.text,
          _searchEmail.text,
          _searchPhone.text,
          _searchCompany.text,
          sortFilter);
      setHighlightedUserInFirstPlace();
      setState(() {});
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            searchUsers();
          },
          "Cancel",
          () {
            Navigator.pop(context);
          },
          "Error",
          exception.message ?? "Unknown error.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget createTitleRow(String title, UserSortFields field) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          InkWell(
            onTap: () => onSortButtonPressed(field),
            child: getSortIcon(field),
          ),
        ],
      ),
    );
  }

  void onSortButtonPressed(UserSortFields field) {
    if (sortFilter.field != field) {
      sortFilter = sortFilter.copyWith(field: field, sortType: SortType.asc);
    } else {
      if (sortFilter.sortType == SortType.asc) {
        sortFilter = sortFilter.copyWith(sortType: SortType.desc);
      } else if (sortFilter.sortType == SortType.desc) {
        sortFilter = UserSortFilterWrapper.empty();
      }
    }
    authService.sortUserList(sortFilter, users);
    setState(() {});
  }

  UserSortFilterWrapper sortFilter = UserSortFilterWrapper.empty();

  Image getSortIcon(UserSortFields field) {
    String imagePath;
    if (sortFilter.field != field || sortFilter.sortType == SortType.none) {
      imagePath = "images/imgSortArrowsBothDisabled.png";
    } else {
      if (sortFilter.sortType == SortType.asc) {
        imagePath = "images/imgSortArrowsUpEnabled.png";
      } else {
        imagePath = "images/imgSortArrowsDownEnabled.png";
      }
    }
    return Image(
      image: AssetImage(imagePath),
      width: 24,
      height: 24,
    );
  }

  void editFirstName(UserModel userModel) async {
    TextEditingController controller = TextEditingController();
    controller.text = userModel.firstName ?? "";
    bool success = await showEditTextFieldDialog(controller, "First Name");
    if (success) {
      setState(() {
        isLoading = true;
      });
      await authService.editUserFirstName(userModel, controller.text);
      userModel.firstName = controller.text;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editLastName(UserModel userModel) async {
    TextEditingController controller = TextEditingController();
    controller.text = capitalizeLastWord(userModel.lastName ?? "");
    bool success = await showEditTextFieldDialog(controller, "Last Name");
    if (success) {
      setState(() {
        isLoading = true;
      });
      controller.text = capitalizeLastWord(controller.text);
      await authService.editUserLastName(userModel, controller.text);
      userModel.lastName = controller.text;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editEmail(UserModel userModel) async {
    TextEditingController controller = TextEditingController();
    controller.text = userModel.email;
    bool success = await showEditTextFieldDialog(controller, "Email");
    if (success && controller.text != userModel.email) {
      setState(() {
        isLoading = true;
      });
      try {
        await authService.editUserEmail(userModel, controller.text);
        userModel.email = controller.text;
      } on EmailAlreadyInUseException {
        if (!mounted) return;
        showOneButtonAlertDialog(
            context,
            "Ok",
                () {
              Navigator.pop(context);
            },
            "Error",
            "This email is already in use.");
      } catch (exception, stacktrace) {
        getIt
            .get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
        if (!mounted) return;
        showOneButtonAlertDialog(
            context,
            "Ok",
            () {
              Navigator.pop(context);
            },
            "Error",
            exception.toString());
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void editPhone(UserModel userModel) async {
    TextEditingController phoneNumberController = TextEditingController();
    phoneNumberController.text = userModel.phone?.phone ?? "";
    String farmPhoneCountryISOName =
        userModel.phone?.phoneCountryISOName ?? "US";
    String farmPhoneAreaCode =
        userModel.phone?.phoneAreaCode ?? "1";
    PhoneModel? newPhone = await showEditPhoneDialog(
        phoneNumberController, farmPhoneCountryISOName, farmPhoneAreaCode, "Phone");
    if (newPhone != null) {
      setState(() {
        isLoading = true;
      });
      await authService.editUserPhone(userModel, newPhone);
      userModel.phone = newPhone;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editEnabled(UserModel userModel, bool enabled) async {
    setState(() {
      isLoading = true;
    });
    await authService.editUserEnabled(userModel, enabled);
    userModel.enabled = enabled;
    setState(() {
      isLoading = false;
    });
  }

  void addNewUser() async {
    //show sign up or something like that
  }
}
