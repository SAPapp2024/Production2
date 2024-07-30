import 'dart:math';

import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/clear_icon_widget.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/screens/Dashboard/manage_barcodes_screen.dart';
import 'package:agro_k/screens/Dashboard/manage_growers_screen.dart';
import 'package:agro_k/screens/Dashboard/see_company_changes_screen.dart';
import 'package:agro_k/screens/Dashboard/see_company_users_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/function_utils/file_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/sample_sorting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompaniesManagementScreen extends StatefulWidget {
  static const String id = '/companies_management';
  final String? highlightedCompanyId;

  const CompaniesManagementScreen({Key? key, this.highlightedCompanyId})
      : super(key: key);

  @override
  State<CompaniesManagementScreen> createState() =>
      _CompaniesManagementScreenState();
}

class _CompaniesManagementScreenState extends State<CompaniesManagementScreen> {
  ScrollController tableScrollController = ScrollController();
  List<CompanyModel> farms = [];
  bool isLoading = false;
  UserState userState = getIt.get();
  AuthService authService = getIt.get();
  int topListNum = 0;
  int endListNum = 0;
  int entriesSelected = 25;
  int dashboardPageNum = 1;
  int totalEntries = 25;

  final TextEditingController _searchAddress = TextEditingController();
  final TextEditingController _searchPhone = TextEditingController();
  final TextEditingController _searchAlternativePhone = TextEditingController();
  final TextEditingController _searchCity = TextEditingController();
  final TextEditingController _searchState = TextEditingController();
  final TextEditingController _searchZipcode = TextEditingController();
  final TextEditingController _searchCountry = TextEditingController();
  final TextEditingController _searchName = TextEditingController();
  final TextEditingController _searchCompanyAdminEmail = TextEditingController();

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    await getCompanies();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getCompanies() async {
    List<CompanyModel> farms = await authService.searchCompanies(
        _searchAddress.text,
        _searchPhone.text,
        _searchAlternativePhone.text,
        _searchCity.text,
        _searchState.text,
        _searchCountry.text,
        _searchZipcode.text,
        _searchName.text,
        _searchCompanyAdminEmail.text,
        sortFilter);
    this.farms = farms;
    setHighlightedCompanyInFirstPlace();
    setState(() {});
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
          title: const Text("Manage Companies"),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
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
    totalEntries = farms.length;
    if (endListNum > farms.length) {
      endListNum = farms.length;
    }
    var data = farms.sublist(topListNum, endListNum);
    return Column(
      children: [
        Row(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "COMPANIES",
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
                        MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () {
                  searchCompanies();
                },
                child: const Text("Apply")),
            const SizedBox(
              width: 15,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () {
                  _searchAddress.text = "";
                  _searchPhone.text = "";
                  _searchAlternativePhone.text = "";
                  _searchCity.text = "";
                  _searchState.text = "";
                  _searchZipcode.text = "";
                  _searchName.text = "";
                  setState(() {
                    sortFilter = CompanySortFilterWrapper.empty();
                  });
                  searchCompanies();
                },
                child: const Text("Clear Filters")),
            const SizedBox(
              width: 35,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty
                        .all(AppColors
                        .appPrimaryGreen)),
                onPressed: () async {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    await generateCompaniesExcelFile(
                        farms);
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
                                      "Name", CompanySortFields.name)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCompanies(),
                                  decoration: InputDecoration(
                                      hintText: "Search Name",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(_searchName, () {
                                        searchCompanies();
                                      })),
                                  controller: _searchName,
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
                                  child: createTitleRow("Company Admin Email",
                                      CompanySortFields.companyAdminEmail)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCompanies(),
                                  decoration: InputDecoration(
                                      hintText: "Search Company Admin Email",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(_searchCompanyAdminEmail, () {
                                        searchCompanies();
                                      })),
                                  controller: _searchCompanyAdminEmail,
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
                                      "Phone", CompanySortFields.phone)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCompanies(),
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
                                        searchCompanies();
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
                                  child: createTitleRow("Alternative Phone",
                                      CompanySortFields.alternativePhone)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCompanies(),
                                  decoration: InputDecoration(
                                      hintText: "Search Alternative Phone",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(
                                          _searchAlternativePhone, () {
                                        searchCompanies();
                                      })),
                                  controller: _searchAlternativePhone,
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
                                      "Address", CompanySortFields.address)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCompanies(),
                                  decoration: InputDecoration(
                                      hintText: "Search Address",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(_searchAddress, () {
                                        searchCompanies();
                                      })),
                                  controller: _searchAddress,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow(
                                      "City", CompanySortFields.city)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCompanies(),
                                  decoration: InputDecoration(
                                      hintText: "Search City",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(_searchCity, () {
                                        searchCompanies();
                                      })),
                                  controller: _searchCity,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 150,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow(
                                      "State/Province", CompanySortFields.state)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCompanies(),
                                  decoration: InputDecoration(
                                      hintText: "Search State",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(_searchState, () {
                                        searchCompanies();
                                      })),
                                  controller: _searchState,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow(
                                      "Country", CompanySortFields.country)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCompanies(),
                                  decoration: InputDecoration(
                                      hintText: "Search Country",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(_searchCountry, () {
                                        searchCompanies();
                                      })),
                                  controller: _searchCountry,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow(
                                      "Zipcode", CompanySortFields.zipcode)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCompanies(),
                                  decoration: InputDecoration(
                                      hintText: "Search Zipcode",
                                      hintStyle: const TextStyle(
                                          color: AppColors.hintTextColor),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.hintTextColor)),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                      suffixIcon: ClearIcon(_searchZipcode, () {
                                        searchCompanies();
                                      })),
                                  controller: _searchZipcode,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const DataColumn(
                          label: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Type",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ))),
                      const DataColumn(
                          label: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Users",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ))),
                      const DataColumn(
                          label: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Available Barcodes",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ))),
                      const DataColumn(
                          label: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Used Barcodes",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ))),
                      const DataColumn(
                          label: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Growers",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ))),
                      const DataColumn(
                          label: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "See Changes",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ))),
                    ],
                    rows: data
                        .mapIndexed(
                          (index, e) => DataRow.byIndex(
                              index: index,
                              color: MaterialStateColor.resolveWith(
                                (states) {
                                  if (e.id == widget.highlightedCompanyId) {
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
                                      child: Text(e.name),
                                    ), onTap: () {
                                  editCompanyName(e);
                                }),
                                DataCell(Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(e.companyAdminUserInfo == null
                                        ? "-"
                                        : e.companyAdminUserInfo!.email))),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.phone == null
                                          ? "-"
                                          : e.phone?.phoneCountryISOName == "US"
                                              ? formatUSNumber(e.phone!.phone)
                                              : e.phone!.phone),
                                    ), onTap: () {
                                  editCompanyPhone(e);
                                }),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.alternatePhone == null
                                          ? "-"
                                          : e.alternatePhone
                                                      ?.phoneCountryISOName ==
                                                  "US"
                                              ? formatUSNumber(
                                                  e.alternatePhone!.phone)
                                              : e.alternatePhone!.phone),
                                    ), onTap: () {
                                  editCompanyAlternativePhone(e);
                                }),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.address),
                                    ), onTap: () {
                                  editCompanyAddress(e);
                                }),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.city),
                                    ), onTap: () {
                                  editCompanyCity(e);
                                }),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.state),
                                    ), onTap: () {
                                  editCompanyState(e);
                                }),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.country),
                                    ), onTap: () {
                                  editCompanyCountry(e);
                                }),
                                DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.zipcode),
                                    ), onTap: () {
                                  editCompanyZipcode(e);
                                }),
                                DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: FormField<String>(
                                      builder: (FormFieldState<String> state) {
                                        return DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: CompanyTypeConstants
                                                .companyTypeList.contains(e.type) ? e.type : CompanyTypeConstants
                                                .ccc,
                                            isDense: true,
                                            onChanged: (newValue) async {
                                              String? newStatus = newValue;
                                              if (newStatus != null) {
                                                try {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  authService.editCompanyType(
                                                      e, newStatus);
                                                  setState(() {
                                                    e.type = newStatus;
                                                  });
                                                } catch (exception, stacktrace) {
                                                  getIt
                                                      .get<
                                                      RemoteErrorLoggingService>()
                                                      .recordError(
                                                      exception, stacktrace);
                                                } finally {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                }
                                              }
                                            },
                                            items: CompanyTypeConstants
                                                .companyTypeList
                                                .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () async {
                                        context.pushNamed(
                                            SeeCompanyUsersScreen.id,
                                            extra:
                                                SeeCompanyUsersScreenArguments(
                                              user: userState.userData!.user,
                                              farm: e,
                                            ));
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors
                                            .appPrimaryGreen,
                                      ),
                                      child: Text(
                                        e.users.length.toString(),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () async {
                                        context.pushNamed(
                                            ManageBarcodesScreen.id,
                                            extra: ManageBarcodesScreenArguments(
                                                farm: e,
                                                initialSort:
                                                    BarcodeSortFilterWrapper(
                                                        field: BarcodeSortFields
                                                            .sample,
                                                        sortType:
                                                            SortType.asc)));
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors
                                            .appPrimaryGreen, // This is a custom color variable
                                      ),
                                      child: Text(
                                        e.availableBarcodesCount.toString(),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () async {
                                        context.pushNamed(
                                            ManageBarcodesScreen.id,
                                            extra: ManageBarcodesScreenArguments(
                                                farm: e,
                                                initialSort:
                                                    BarcodeSortFilterWrapper(
                                                        field: BarcodeSortFields
                                                            .sample,
                                                        sortType:
                                                            SortType.desc)));
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors
                                            .appPrimaryGreen, // This is a custom color variable
                                      ),
                                      child: Text(
                                        e.usedBarcodesCount.toString(),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () async {
                                        context.pushNamed(
                                            ManageGrowersScreen.id,
                                            extra: ManageGrowersScreenArguments(
                                              farm: e,
                                            ));
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors
                                            .appPrimaryGreen, // This is a custom color variable
                                      ),
                                      child: Text(
                                        e.growers.length.toString(),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () async {
                                        try {
                                          var companyChanges = await authService.getCompanyChanges(e);
                                          if (!mounted) { return; }
                                          context.pushNamed(
                                              SeeCompanyChangesScreen.id,
                                              extra: SeeCompanyChangesScreenArguments(
                                                companyChanges: companyChanges,
                                              ));
                                        } on Exception catch (e) {
                                          showOneButtonAlertDialog(
                                              context,
                                              "Ok",
                                                  () {
                                                Navigator.pop(context);
                                              },
                                              "Error",
                                              e.toString());
                                        } finally {
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors
                                            .appPrimaryGreen, // This is a custom color variable
                                      ),
                                      child: const Text(
                                        "See changes",
                                        textAlign: TextAlign.left,
                                      ),
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
                onPressed: dashboardPageNum * entriesSelected < farms.length
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

  void setHighlightedCompanyInFirstPlace() {
    if (widget.highlightedCompanyId != null) {
      var highlightedCompanyPosition = farms
          .indexWhere((element) => element.id == widget.highlightedCompanyId!);
      if (highlightedCompanyPosition != -1) {
        CompanyModel farm = farms[highlightedCompanyPosition];
        farms.removeAt(highlightedCompanyPosition);
        farms.insert(0, farm);
      }
    }
  }

  Future searchCompanies() async {
    try {
      farms = await authService.searchCompanies(
          _searchAddress.text,
          _searchPhone.text,
          _searchAlternativePhone.text,
          _searchCity.text,
          _searchState.text,
          _searchCountry.text,
          _searchZipcode.text,
          _searchName.text,
          _searchCompanyAdminEmail.text,
          sortFilter);
      setHighlightedCompanyInFirstPlace();
      setState(() {
        farms;
      });
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      if (!mounted) return;
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            searchCompanies();
          },
          "Cancel",
          () {
            Navigator.pop(context);
          },
          "Error",
          exception.message ?? "Unknown error.");
    }
  }

  Widget createTitleRow(String title, CompanySortFields field) {
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

  void onSortButtonPressed(CompanySortFields field) {
    if (sortFilter.field != field) {
      sortFilter = sortFilter.copyWith(field: field, sortType: SortType.asc);
    } else {
      if (sortFilter.sortType == SortType.asc) {
        sortFilter = sortFilter.copyWith(sortType: SortType.desc);
      } else if (sortFilter.sortType == SortType.desc) {
        sortFilter = CompanySortFilterWrapper.empty();
      }
    }
    authService.sortCompaniesList(sortFilter, farms);
    setState(() {});
  }

  CompanySortFilterWrapper sortFilter = CompanySortFilterWrapper.empty();

  Image getSortIcon(CompanySortFields field) {
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

  void editCompanyName(CompanyModel farmModel) async {
    TextEditingController controller = TextEditingController();
    controller.text = farmModel.name;
    bool success = await showEditTextFieldDialog(controller, "Name");
    if (success) {
      setState(() {
        isLoading = true;
      });
      await authService.editCompanyName(farmModel, controller.text);
      farmModel.name = controller.text;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editCompanyAddress(CompanyModel farmModel) async {
    TextEditingController controller = TextEditingController();
    controller.text = farmModel.address;
    bool success = await showEditTextFieldDialog(controller, "Address");
    if (success) {
      setState(() {
        isLoading = true;
      });
      await authService.editCompanyAddress(farmModel, controller.text);
      farmModel.address = controller.text;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editCompanyCity(CompanyModel farmModel) async {
    TextEditingController controller = TextEditingController();
    controller.text = farmModel.city;
    bool success = await showEditTextFieldDialog(controller, "City");
    if (success) {
      setState(() {
        isLoading = true;
      });
      await authService.editCompanyCity(farmModel, controller.text);
      farmModel.city = controller.text;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editCompanyState(CompanyModel farmModel) async {
    TextEditingController controller = TextEditingController();
    controller.text = farmModel.state;
    bool success = await showEditTextFieldDialog(controller, "State");
    if (success) {
      setState(() {
        isLoading = true;
      });
      await authService.editCompanyState(farmModel, controller.text);
      farmModel.state = controller.text;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editCompanyCountry(CompanyModel farmModel) async {
    TextEditingController controller = TextEditingController();
    controller.text = farmModel.country;
    bool success = await showEditCountryDialog(controller);
    if (success) {
      setState(() {
        isLoading = true;
      });
      await authService.editCompanyCountry(farmModel, controller.text);
      farmModel.country = controller.text;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editCompanyZipcode(CompanyModel farmModel) async {
    TextEditingController controller = TextEditingController();
    controller.text = farmModel.zipcode;
    bool success = await showEditZipcodeDialog(controller, farmModel.country);
    if (success) {
      setState(() {
        isLoading = true;
      });
      await authService.editCompanyZipcode(farmModel, controller.text);
      farmModel.zipcode = controller.text;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editCompanyPhone(CompanyModel farmModel) async {
    TextEditingController phoneNumberController = TextEditingController();
    phoneNumberController.text = farmModel.phone?.phone ?? "";
    String farmPhoneCountryISOName =
        farmModel.phone?.phoneCountryISOName ?? "US";
    String farmPhoneAreaCode = farmModel.phone?.phoneAreaCode ?? "1";
    PhoneModel? newPhone = await showEditPhoneDialog(
        phoneNumberController, farmPhoneCountryISOName, farmPhoneAreaCode, "Phone");
    if (newPhone != null) {
      setState(() {
        isLoading = true;
      });
      await authService.editCompanyPhone(farmModel, newPhone);
      farmModel.phone = newPhone;
      setState(() {
        isLoading = false;
      });
    }
  }

  void editCompanyAlternativePhone(CompanyModel farmModel) async {
    TextEditingController phoneNumberController = TextEditingController();
    phoneNumberController.text = farmModel.alternatePhone?.phone ?? "";
    String farmPhoneCountryISOName =
        farmModel.alternatePhone?.phoneCountryISOName ?? "US";
    String farmPhoneAreaCode = farmModel.alternatePhone?.phoneAreaCode ?? "1";
    PhoneModel? newPhone = await showEditPhoneDialog(
        phoneNumberController, farmPhoneCountryISOName, farmPhoneAreaCode, "Alternative Phone");
    if (newPhone != null) {
      setState(() {
        isLoading = true;
      });
      await authService.editCompanyAlternativePhone(farmModel, newPhone);
      farmModel.alternatePhone = newPhone;
      setState(() {
        isLoading = false;
      });
    }
  }

  void addNewUser() async {
    //show sign up or something like that
  }
}
