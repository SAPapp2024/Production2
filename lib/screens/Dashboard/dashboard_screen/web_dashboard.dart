import 'dart:math';

import 'package:agro_k/app/routes.dart';
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/admin_customer_usage_block_small_widget.dart';
import 'package:agro_k/components/app_bar.dart';
import 'package:agro_k/components/clear_icon_widget.dart';
import 'package:agro_k/components/location_widget.dart';
import 'package:agro_k/models/company/admin_info_model.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/invite_wrapper.dart';
import 'package:agro_k/models/company/sample_change_with_user_model.dart';
import 'package:agro_k/models/company/sample_location_model.dart';
import 'package:agro_k/models/company/sample_model.dart';
import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/models/min_max_table_item_model.dart';
import 'package:agro_k/models/user/user_with_companies_model.dart';
import 'package:agro_k/models/user_usage_model.dart';
import 'package:agro_k/screens/Auth/create_company_screen/view/create_company_screen.dart';
import 'package:agro_k/screens/Auth/log_in/view/log_in_screen.dart';
import 'package:agro_k/screens/Dashboard/companies_management_screen.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/screens/Dashboard/manage_barcodes_screen.dart';
import 'package:agro_k/screens/Dashboard/manage_crops_screen.dart';
import 'package:agro_k/screens/Dashboard/see_report_screen.dart';
import 'package:agro_k/screens/Dashboard/see_sample_changes_screen.dart';
import 'package:agro_k/screens/Dashboard/user_management_screen.dart';
import 'package:agro_k/screens/NewSample/company_samples_screen.dart';
import 'package:agro_k/screens/NewSample/new_sample_screen.dart';
import 'package:agro_k/screens/NewSample/sample_submitted_screen.dart';
import 'package:agro_k/screens/Profile/members_screen.dart';
import 'package:agro_k/screens/Profile/user_profile_screen.dart';
import 'package:agro_k/screens/Reports/report_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/enums/dashboard_templates_enum.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:agro_k/utilities/function_utils/file_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/sample_sorting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:typesense/typesense.dart';
import 'package:universal_html/html.dart' as html;

class WebDashboard extends StatefulWidget {
  const WebDashboard({Key? key}) : super(key: key);

  @override
  State<WebDashboard> createState() => WebDashboardState();
}

class WebDashboardState extends State<WebDashboard> {
  final downloadTemplateDropdownKey = GlobalKey<DropdownButton2State>();

  Client typesenseClient = getIt.get();
  ProfileService profileService = getIt.get();
  AuthService authService = getIt.get();
  SampleService sampleService = getIt.get();
  UserState userState = getIt.get();
  bool isLoading = false;
  late UserWithCompaniesModel userWithCompaniesModel;
  CompanyModel? currentCompany;
  Map<SampleWithUserModel, bool> samplesCheckedToPrint = {};

  final TextEditingController _searchIdController = TextEditingController();
  final TextEditingController _searchSampleCollectedDate =
      TextEditingController();
  final TextEditingController _searchCreatedDate = TextEditingController();
  DateTimeRange? _sampleCollectedDateRange;
  DateTimeRange? _sampleCreatedDateRange;
  final TextEditingController _searchLocationPlot = TextEditingController();
  final TextEditingController _searchCrop = TextEditingController();
  final TextEditingController _searchVariety = TextEditingController();
  final TextEditingController _searchCompany = TextEditingController();
  final TextEditingController _searchGrower = TextEditingController();
  final TextEditingController _searchNotes = TextEditingController();
  final TextEditingController _searchSampleBarcodes = TextEditingController();
  final TextEditingController _searchUser = TextEditingController();
  final TextEditingController _searchCultivation = TextEditingController();
  final TextEditingController _searchStatus = TextEditingController();
  final TextEditingController _searchSampleStatus = TextEditingController();

  List<SampleWithUserModel> dashboardData = [];

  int _pageIndex = 0;
  var entriesSelected = 25;
  var dashboardPageNum = 1;
  var totalEntries = 25; // we need to update count

  var topListNum = 0;
  var endListNum = 0;

  ScrollController tableScrollController = ScrollController();
  ScrollController screenHorizontalScrollController = ScrollController();
  ScrollController screenVerticalScrollController = ScrollController();
  SampleSortFilterWrapper sortFilter = SampleSortFilterWrapper.empty();
  UserUsageModel? userUsageModel;
  AdminInfoModel? adminInfoModel;
  int? userCount;
  List<InvitesWrapperWithCompany>? invites;

  Widget createSuperAdminCustomerUsage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(12.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 4,
                    blurRadius: 6,
                    offset: Offset(4, 6),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("BARCODES",
                    style: TextStyle(
                        color: AppColors.darkGrayTextColor,
                        
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                const SizedBox(
                  height: 18,
                ),
                Row(children: [
                  AdminCustomerUsageBlockSmallWidget(
                    titleText: "Available Barcodes",
                    number: adminInfoModel!.availableBarcodes,
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  AdminCustomerUsageBlockSmallWidget(
                    titleText: "Assigned Barcodes",
                    number: adminInfoModel!.assignedAndNotUsedBarcodesAmount,
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  AdminCustomerUsageBlockSmallWidget(
                    titleText: "Used Barcodes",
                    number: adminInfoModel!.usedBarcodesAmount,
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(12.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 4,
                    blurRadius: 6,
                    offset: Offset(4, 6),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("CUSTOMER USAGE",
                    style: TextStyle(
                        color: AppColors.darkGrayTextColor,
                        
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                const SizedBox(
                  height: 18,
                ),
                Row(
                  children: [
                    AdminCustomerUsageBlockSmallWidget(
                      titleText: "Total Users",
                      number: userCount!,
                    ),
                    ...(userUsageModel != null
                        ? [
                            const SizedBox(
                              width: 24,
                            ),
                            AdminCustomerUsageBlockSmallWidget(
                              titleText: "Daily Users",
                              number: userUsageModel!.dailyUsers,
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            AdminCustomerUsageBlockSmallWidget(
                              titleText: "Monthly Users",
                              number: userUsageModel!.monthlyUsers,
                            ),
                          ]
                        : [])
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _signOut() async {
    await authService.signOut();
    if (mounted) {
      context.goNamed(LogInScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserWithCompaniesModel? userWithCompaniesModel = userState.userData;
    if (userWithCompaniesModel == null) {
      context.goNamed(LogInScreen.id);
      return Container(
        color: Colors.white,
      );
    }
    CompanyModel? currentCompany = userState.currentCompanyData;
    if ((userState.currentCompanyData == null || !userState.isCompanyAdmin()) &&
        !userState.userData!.user.isSuperAdmin &&
        _pageIndex == 2) {
      _pageIndex = 0;
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: createWebAppBar(
            toolbarHeight,
            _pageIndex,
            (pageIndex) {
              setState(() {
                _pageIndex = pageIndex;
              });
            },
            (pageIndex) {
              setState(() {
                _pageIndex = pageIndex;
              });
            },
            (pageIndex) {
              setState(() {
                _pageIndex = pageIndex;
              });
            },
            (pageIndex) {
              setState(() {
                _pageIndex = pageIndex;
              });
            },
            userState.currentCompanyData != null &&
                userState.userData!.user
                    .isCompanyAdmin(userState.currentCompanyData!.id),
            () {
              showTwoButtonAlertDialog(
                  context,
                  "Cancel",
                  () {
                    Navigator.pop(context);
                  },
                  "Logout",
                  () {
                    _signOut();
                  },
                  "Logout?",
                  "Are you sure you want to logout?");
            },
            userWithCompaniesModel,
            currentCompany,
            (companySelected) async {
              await userState.updateCurrentCompany(companySelected.id);
              await _getData();
            },
            () {
              context.goNamed(CreateCompanyScreen.id,
                  extra: const CreateCompanyScreenArguments(
                      prevScreen: DashboardScreen.id));
            },
            invites?.length ?? 0),
        body: SafeArea(
          child: Stack(
            children: [
              (_pageIndex == 0
                  ? createWebDashboardView(
                      context, userWithCompaniesModel, currentCompany)
                  : _pageIndex == 1
                      ? Center(child: createReportsView(context))
                      : _pageIndex == 2
                          ? MembersScreen(
                              user: userState.userData!.user,
                              company: userState.currentCompanyData!,
                            )
                          : UserProfileScreen(
                              user: userState.userData!.user,
                              company: userState.currentCompanyData,
                              invites: invites ?? [],
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
          ),
        ),
      ),
    );
  }

  Widget createWebDashboardView(BuildContext context,
      UserWithCompaniesModel userWithCompaniesModel, CompanyModel? farm) {
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
    totalEntries = dashboardData.length;

    var isSuperAdmin = userWithCompaniesModel.user.isSuperAdmin;

    return SizedBox(
      width: double.infinity,
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: screenVerticalScrollController,
        child: SingleChildScrollView(
          controller: screenVerticalScrollController,
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            controller: screenHorizontalScrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: screenHorizontalScrollController,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        farm != null
                            ? Container()
                            : isSuperAdmin
                                ? Container()
                                : const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Guest Account",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24)),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Flexible(
                                          flex: 0,
                                          child: SizedBox(
                                            width: 800,
                                            child: Text(
                                                """In order to submit samples on your account you will need to 
                
1. Create a Company - you can create a company by selecting ‘Create Company’ in the drop down in the top right corner.

2. Wait to be invited to a Company - share your email with the company owner you are waiting to be associated with. You can join from your profile section once you are invited.""",
                                                style: TextStyle(
                                                    color: AppColors.black1,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 18)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        isSuperAdmin &&
                                adminInfoModel != null &&
                                userCount != null
                            ? createSuperAdminCustomerUsage()
                            : Container(),
                        //Filter view
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            children: [
                              Visibility(
                                visible:
                                    userWithCompaniesModel.user.isSuperAdmin,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  AppColors.appPrimaryGreen)),
                                      onPressed: () {
                                        uploadAndProcessSampleTests();
                                      },
                                      child: const Text("Upload Sample Tests")),
                                ),
                              ),
                              Visibility(
                                visible:
                                    userWithCompaniesModel.user.isSuperAdmin,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  AppColors.appPrimaryGreen)),
                                      onPressed: () {
                                        context.pushNamed(ManageUsersScreen.id);
                                      },
                                      child: const Text("Manage Users")),
                                ),
                              ),
                              Visibility(
                                visible:
                                    userWithCompaniesModel.user.isSuperAdmin,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  AppColors.appPrimaryGreen)),
                                      onPressed: () {
                                        context.pushNamed(
                                            CompaniesManagementScreen.id);
                                      },
                                      child: const Text("Manage Companies")),
                                ),
                              ),
                              Visibility(
                                visible:
                                    userWithCompaniesModel.user.isSuperAdmin,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  AppColors.appPrimaryGreen)),
                                      onPressed: () {
                                        context.pushNamed(ManageCropsScreen.id);
                                      },
                                      child: const Text("Manage Crops")),
                                ),
                              ),
                              Visibility(
                                visible: userWithCompaniesModel
                                        .user.isSuperAdmin ||
                                    (currentCompany != null &&
                                        userWithCompaniesModel.companies.any(
                                            (element) =>
                                                element.farm.id ==
                                                    currentCompany!.id &&
                                                element.isAdmin)),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  AppColors.appPrimaryGreen)),
                                      onPressed: () {
                                        context
                                            .pushNamed(ManageBarcodesScreen.id);
                                      },
                                      child: const Text("Manage Barcodes")),
                                ),
                              ),
                              Visibility(
                                  visible:
                                      userWithCompaniesModel.user.isSuperAdmin,
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 32),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2(
                                          key: downloadTemplateDropdownKey,
                                          customButton: ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStateProperty.all(
                                                        AppColors
                                                            .appPrimaryGreen),
                                                foregroundColor:
                                                    WidgetStateProperty.all(
                                                        Colors.white)),
                                            onPressed: () {
                                              downloadTemplateDropdownKey
                                                  .currentState
                                                  ?.callTap();
                                            },
                                            child: const Text(
                                                "Download Templates"),
                                          ),
                                          items: DashboardTemplates.values
                                              .map((e) => DropdownMenuItem<
                                                      DashboardTemplates>(
                                                    value: e,
                                                    child: Text(
                                                        e.toPresentation()),
                                                  ))
                                              .toList(),
                                          onChanged: (DashboardTemplates?
                                              value) async {
                                            if (value != null) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              try {
                                                await downloadDashboardTemplate(
                                                    value.getDownloadPath());
                                              } catch (_) {
                                                showOneButtonAlertDialog(
                                                    context, "Ok", () {
                                                  Navigator.pop(context);
                                                }, "Error",
                                                    "There was an error downloading the file");
                                              }
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                          },
                                          dropdownStyleData: DropdownStyleData(
                                              maxHeight: 48,
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16),
                                              width: 200,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              elevation: 8,
                                              offset: const Offset(0, 8)),
                                        ),
                                      ))),
                            ],
                          ),
                        ),
                        userWithCompaniesModel.user.isSuperAdmin || farm != null
                            ? SizedBox(
                                width: max(1200,
                                    MediaQuery.of(context).size.width - 100),
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      side: BorderSide(
                                          color: AppColors.cardBorder,
                                          width: 1.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "MAIN DASHBOARD",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStateProperty
                                                            .all(AppColors
                                                                .appPrimaryGreen)),
                                                onPressed: () {
                                                  searchSamples();
                                                },
                                                child: const Text("Apply")),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStateProperty
                                                            .all(AppColors
                                                                .appPrimaryGreen)),
                                                onPressed: () {
                                                  _searchIdController.text = "";
                                                  _searchSampleCollectedDate
                                                      .text = "";
                                                  _searchCreatedDate.text = "";
                                                  _searchLocationPlot.text = "";
                                                  _searchStatus.text = "";
                                                  _searchSampleStatus.text = "";
                                                  _searchCultivation.text = "";
                                                  _searchCrop.text = "";
                                                  _searchVariety.text = "";
                                                  _searchGrower.text = "";
                                                  _searchNotes.text = "";
                                                  _searchSampleBarcodes.text =
                                                      "";
                                                  _searchUser.text = "";
                                                  _sampleCollectedDateRange =
                                                      null;
                                                  _sampleCreatedDateRange =
                                                      null;
                                                  setState(() {
                                                    _sampleCollectedDateRange =
                                                        null;
                                                    sortFilter =
                                                        SampleSortFilterWrapper
                                                            .empty();
                                                  });
                                                  searchSamples();
                                                },
                                                child: const Text(
                                                    "Clear Filters")),
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
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  try {
                                                    await generateSamplesExcelFile(
                                                        dashboardData);
                                                  } catch (exception, stacktrace) {
                                                    getIt
                                                        .get<
                                                            RemoteErrorLoggingService>()
                                                        .recordError(exception,
                                                            stacktrace);
                                                    showOneButtonAlertDialog(
                                                        context, "Ok", () {
                                                      Navigator.pop(context);
                                                    }, "Error",
                                                        "There was an error downloading the file $exception");
                                                  }
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                },
                                                child: const Text(
                                                    "Download Report")),
                                            if (samplesCheckedToPrint
                                                .isNotEmpty) ...[
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
                                                  final box =
                                                      context.findRenderObject()
                                                          as RenderBox;
                                                  var result = await showDialog<
                                                          MergeSamplesOptions>(
                                                      context: context,
                                                      builder: (_) {
                                                        return const MergeSamplesOptionsDialog();
                                                      });
                                                  if (result != null) {
                                                    try {
                                                      var samplesCheckedToPrintKeys =
                                                          samplesCheckedToPrint
                                                              .keys
                                                              .toList();
                                                      sampleService
                                                          .updateSamplePrinted(
                                                              samplesCheckedToPrintKeys);
                                                      await createMergedPdf(
                                                          result,
                                                          box,
                                                          samplesCheckedToPrintKeys);
                                                    } catch (exception, stacktrace) {
                                                      getIt
                                                          .get<
                                                              RemoteErrorLoggingService>()
                                                          .recordError(
                                                              exception,
                                                              stacktrace);
                                                    } finally {
                                                      setState(() {
                                                        samplesCheckedToPrint
                                                            .clear();
                                                      });
                                                    }
                                                  }
                                                },
                                                child: Text(
                                                    "Print ${samplesCheckedToPrint.length} samples"),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    samplesCheckedToPrint
                                                        .clear();
                                                  });
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.appPrimaryGreen,
                                                ),
                                                child: const Text(
                                                    "Unselect all samples"),
                                              )
                                            ]
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
                                                border: Border.all(
                                                    color:
                                                        AppColors.cardBorder),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(4.0),
                                                ),
                                              ),
                                              height: 33,
                                              width: 58,
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                    value: entriesSelected,
                                                    iconSize: 20,
                                                    items: items,
                                                    focusColor:
                                                        Colors.transparent,
                                                    style: const TextStyle(
                                                        color: AppColors.black1,
                                                        
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        entriesSelected =
                                                            val as int;
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
                                        Scrollbar(
                                          controller: tableScrollController,
                                          thumbVisibility: true,
                                          trackVisibility: true,
                                          child: SingleChildScrollView(
                                            controller: tableScrollController,
                                            scrollDirection: Axis.horizontal,
                                            child: createGrid(
                                                userWithCompaniesModel),
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
                                                  color:
                                                      AppColors.grayTextColor,
                                                  
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
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(5),
                                                        bottomLeft:
                                                            Radius.circular(5)),
                                              ),
                                              child: TextButton(
                                                onPressed: dashboardPageNum > 1
                                                    ? () {
                                                        setState(() {
                                                          dashboardPageNum =
                                                              dashboardPageNum -
                                                                  1;
                                                        });
                                                      }
                                                    : null,
                                                child: const Text(
                                                  "Previous",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: AppColors.pageBlue,
                                                border: Border(
                                                  top: BorderSide(
                                                      width: 1.0,
                                                      color: Colors.grey),
                                                  bottom: BorderSide(
                                                      width: 1.0,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              child: TextButton(
                                                onPressed: null,
                                                child: Text(
                                                  dashboardPageNum.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color:
                                                        AppColors.cardBorder),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(5),
                                                        bottomRight:
                                                            Radius.circular(5)),
                                              ),
                                              child: TextButton(
                                                onPressed: dashboardPageNum *
                                                            entriesSelected <
                                                        dashboardData.length
                                                    ? () {
                                                        setState(() {
                                                          dashboardPageNum =
                                                              dashboardPageNum +
                                                                  1;
                                                        });
                                                      }
                                                    : null,
                                                child: const Text(
                                                  "Next",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 50,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createTitleRow(String title, SampleSortFields field) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        InkWell(
          onTap: () => onSortButtonPressed(field),
          child: getSortIcon(field),
        ),
      ],
    );
  }

  Image getSortIcon(SampleSortFields field) {
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

  void onSortButtonPressed(SampleSortFields field) {
    if (sortFilter.field != field) {
      sortFilter = sortFilter.copyWith(field: field, sortType: SortType.asc);
    } else {
      if (sortFilter.sortType == SortType.asc) {
        sortFilter = sortFilter.copyWith(sortType: SortType.desc);
      } else if (sortFilter.sortType == SortType.desc) {
        sortFilter = SampleSortFilterWrapper.empty();
      }
    }
    sampleService.sortSampleList(sortFilter, dashboardData);
    setState(() {});
  }

  void uploadAndProcessSampleTests() async {
    setState(() {
      isLoading = true;
    });
    try {
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (pickedFile != null) {
        var bytes = pickedFile.files.single.bytes!.toList();
        var excel = Excel.decodeBytes(bytes);
        var table = excel.tables["Sheet 1"];
        if (table != null) {
          var rows = table.rows
              .map((row) {
                debugPrint("mapping row with length ${row.length}");
                if (row.length >= 14) {
                  return row.map((cell) {
                    return cell?.props[0];
                  }).toList();
                }
              })
              .where((element) => element != null)
              .map((e) => e!)
              .toList();
          debugPrint("aoub to call uploadsampletests");
          await sampleService.uploadSampleTests(rows);
          if (mounted) {
            showOneButtonAlertDialog(context, "Ok", () {
              Navigator.pop(context);
            }, "Success", "Sample tests uploaded successfully");
          }
        } else {
          if (mounted) {
            showOneButtonAlertDialog(context, "Ok", () {
              Navigator.pop(context);
            }, "Error", "Invalid file");
          }
        }
      }
    } on FirebaseException {
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error uploading the data");
    } on Error catch (e) {
      debugPrint("Error processing sample tests - $e");
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error processing the file");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void uploadAndProcessMinMaxTable() async {
    setState(() {
      isLoading = true;
    });
    try {
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (pickedFile != null) {
        var bytes = pickedFile.files.single.bytes!.toList();
        var excel = Excel.decodeBytes(bytes);
        var table = excel.tables["Sheet 1"];
        if (table != null) {
          var rows = table.rows
              .skip(2)
              .map((row) {
                if (row.length == 4) {
                  if (row[0]?.props[0] == null ||
                      row[1]?.props[0] == null ||
                      row[2]?.props[0] == null ||
                      row[3]?.props[0] == null) {
                    return null;
                  }
                  String crop = row[0]!.props[0] as String;
                  String mineral = row[1]!.props[0] as String;
                  double? optimumMin =
                      double.tryParse(row[2]!.props[0].toString());
                  double? optimumMax =
                      double.tryParse(row[3]!.props[0].toString());
                  if (optimumMin == null || optimumMax == null) return null;
                  double rangeMax =
                      (optimumMin + (optimumMax - optimumMin) / 2) * 2;
                  return MinMaxTableItemModel(
                      crop: crop,
                      mineral: mineral,
                      optimumMin: optimumMin,
                      optimumMax: optimumMax,
                      rangeMax: rangeMax);
                }
              })
              .where((element) => element != null)
              .map((e) => e!)
              .toList();
          await sampleService.uploadMinMaxTable(rows);
          if (mounted) {
            showOneButtonAlertDialog(context, "Ok", () {
              Navigator.pop(context);
            }, "Success", "Min-Max table uploaded successfully");
          }
        } else {
          if (mounted) {
            showOneButtonAlertDialog(context, "Ok", () {
              Navigator.pop(context);
            }, "Error", "Invalid file");
          }
        }
      }
    } on FirebaseException {
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error uploading the data");
    } on Error catch (e) {
      debugPrint("Error parsing file - $e");
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error processing the file");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget createSearchField(
      String defaultText, TextEditingController controller) {
    return SizedBox(
      height: 40,
      width: 170,
      child: TextFormField(
        decoration: InputDecoration(
            hintText: defaultText,
            labelStyle: const TextStyle(fontSize: 8),
            border: const OutlineInputBorder()),
        controller: controller,
      ),
    );
  }

  Widget createGrid(UserWithCompaniesModel userWithCompaniesModel) {
    if (endListNum > dashboardData.length) {
      endListNum = dashboardData.length;
    }

    // var itemCount = dashboardData.getRange(topListNum, endListNum).length;
    var data = dashboardData.sublist(topListNum, endListNum);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: AppColors.hintTextColor),
      child: DataTable(
          dataRowMinHeight: 50,
          dataRowMaxHeight: 50,
          headingRowHeight: 100,
          showBottomBorder: true,
          columns: <DataColumn?>[
            const DataColumn(
                label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Print",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ))),
            userWithCompaniesModel.user.isSuperAdmin
                ? const DataColumn(
                    label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Edit Sample",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )))
                : null,
            const DataColumn(
                label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Download Label",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ))),
            const DataColumn(
                label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Location",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ))),
            DataColumn(
              label: Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: createTitleRow("Sample collected date",
                            SampleSortFields.collectedDate)),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        onFieldSubmitted: (_) => searchSamples(),
                        onTap: () async {
                          DateTimeRange? dateTimeRange =
                              await showDateRangePicker(
                                  context: context,
                                  initialEntryMode:
                                      DatePickerEntryMode.calendarOnly,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 1000)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 1000)),
                                  builder: (context, child) {
                                    return Column(
                                      children: [
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 400.0,
                                              maxHeight: 800.0),
                                          child: child,
                                        ),
                                      ],
                                    );
                                  });
                          if (dateTimeRange != null) {
                            _sampleCollectedDateRange = dateTimeRange;
                            var startDate = DateFormat.yMd()
                                .format(_sampleCollectedDateRange!.start);
                            var endDate = DateFormat.yMd()
                                .format(_sampleCollectedDateRange!.end);
                            if (_sampleCollectedDateRange != null) {
                              _searchSampleCollectedDate.text =
                                  "$startDate-$endDate";
                            }
                            searchSamples();
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Search collected date',
                            hintStyle:
                                const TextStyle(color: AppColors.hintTextColor),
                            border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.hintTextColor)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            suffixIcon:
                                ClearIcon(_searchSampleCollectedDate, () {
                              _sampleCollectedDateRange = null;
                              searchSamples();
                            })),
                        controller: _searchSampleCollectedDate,
                      ),
                    ),
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
                        child: createTitleRow("Sample Barcodes",
                            SampleSortFields.sampleBarcodes)),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        onFieldSubmitted: (_) => searchSamples(),
                        decoration: InputDecoration(
                            hintText: "Search Sample Barcodes",
                            hintStyle:
                                const TextStyle(color: AppColors.hintTextColor),
                            border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.hintTextColor)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            suffixIcon: ClearIcon(_searchSampleBarcodes, () {
                              searchSamples();
                            })),
                        controller: _searchSampleBarcodes,
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (userState.isSuperAdmin())
              DataColumn(
                label: Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width >= 1600
                            ? 170
                            : 100),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: createTitleRow(
                                "Company", SampleSortFields.company)),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: TextFormField(
                            onFieldSubmitted: (_) => searchSamples(),
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
                                  searchSamples();
                                })),
                            controller: _searchCompany,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            DataColumn(
              label: Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width >= 1600
                          ? 170
                          : 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: createTitleRow(
                              "Grower", SampleSortFields.grower)),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          onFieldSubmitted: (_) => searchSamples(),
                          decoration: InputDecoration(
                              hintText: "Search Grower",
                              hintStyle: const TextStyle(
                                  color: AppColors.hintTextColor),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.hintTextColor)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              suffixIcon: ClearIcon(_searchGrower, () {
                                searchSamples();
                              })),
                          controller: _searchGrower,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width >= 1600
                          ? 170
                          : 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: createTitleRow("Farm", SampleSortFields.farm)),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          onFieldSubmitted: (_) => searchSamples(),
                          decoration: InputDecoration(
                              hintText: "Search Farm",
                              hintStyle: const TextStyle(
                                  color: AppColors.hintTextColor),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.hintTextColor)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              suffixIcon: ClearIcon(_searchLocationPlot, () {
                                searchSamples();
                              })),
                          controller: _searchLocationPlot,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width >= 1600
                          ? 170
                          : 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child:
                              createTitleRow("Field", SampleSortFields.field)),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          onFieldSubmitted: (_) => searchSamples(),
                          decoration: InputDecoration(
                              hintText: "Search Field",
                              hintStyle: const TextStyle(
                                  color: AppColors.hintTextColor),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.hintTextColor)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              suffixIcon: ClearIcon(_searchCultivation, () {
                                searchSamples();
                              })),
                          controller: _searchCultivation,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width >= 1600
                          ? 170
                          : 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: createTitleRow("Crop", SampleSortFields.crop)),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          onFieldSubmitted: (_) => searchSamples(),
                          decoration: InputDecoration(
                              hintText: "Search Crop",
                              hintStyle: const TextStyle(
                                  color: AppColors.hintTextColor),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.hintTextColor)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              suffixIcon: ClearIcon(_searchCrop, () {
                                searchSamples();
                              })),
                          controller: _searchCrop,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width >= 1600
                          ? 170
                          : 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: createTitleRow(
                              "Variety", SampleSortFields.variety)),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          onFieldSubmitted: (_) => searchSamples(),
                          decoration: InputDecoration(
                              hintText: "Search Variety",
                              hintStyle: const TextStyle(
                                  color: AppColors.hintTextColor),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.hintTextColor)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              suffixIcon: ClearIcon(_searchVariety, () {
                                searchSamples();
                              })),
                          controller: _searchVariety,
                        ),
                      )
                    ],
                  ),
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
                            "Submitted by", SampleSortFields.user)),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        onFieldSubmitted: (_) => searchSamples(),
                        decoration: InputDecoration(
                            hintText: "Search user",
                            hintStyle:
                                const TextStyle(color: AppColors.hintTextColor),
                            border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.hintTextColor)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            suffixIcon: ClearIcon(_searchUser, () {
                              searchSamples();
                            })),
                        controller: _searchUser,
                      ),
                    )
                  ],
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width >= 1600
                          ? 170
                          : 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child:
                              createTitleRow("Notes", SampleSortFields.notes)),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: TextFormField(
                          onFieldSubmitted: (_) => searchSamples(),
                          decoration: InputDecoration(
                              hintText: "Search Notes",
                              hintStyle: const TextStyle(
                                  color: AppColors.hintTextColor),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.hintTextColor)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              suffixIcon: ClearIcon(_searchNotes, () {
                                searchSamples();
                              })),
                          controller: _searchNotes,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            userWithCompaniesModel.user.isSuperAdmin
                ? DataColumn(
                    label: Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: createTitleRow(
                                  "Status", SampleSortFields.status)),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 2.0,
                                    bottom: 2.0,
                                    left: 6.0,
                                    right: 6.0),
                                child: FormField<String>(
                                  builder: (FormFieldState<String> state) {
                                    return DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        hint: const Text("Search Status",
                                            style: TextStyle(
                                                color:
                                                    AppColors.hintTextColor)),
                                        value: !SampleStatusConstants
                                                .sampleStatusList
                                                .contains(_searchStatus.text)
                                            ? null
                                            : _searchStatus.text,
                                        isDense: true,
                                        onChanged: (newValue) async {
                                          String? newStatus = newValue;
                                          if (newStatus != null) {
                                            setState(() {
                                              _searchStatus.text = newStatus;
                                            });
                                          }
                                        },
                                        items: [
                                          "",
                                          ...SampleStatusConstants
                                              .sampleStatusList
                                        ].map((String value) {
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
                          )
                        ],
                      ),
                    ),
                  )
                : null,
            DataColumn(
              label: Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: createTitleRow("Sample created date",
                            SampleSortFields.createdDate)),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        onFieldSubmitted: (_) => searchSamples(),
                        onTap: () async {
                          DateTimeRange? dateTimeRange =
                              await showDateRangePicker(
                                  context: context,
                                  initialEntryMode:
                                      DatePickerEntryMode.calendarOnly,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 1000)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 1000)),
                                  builder: (context, child) {
                                    return Column(
                                      children: [
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 400.0,
                                              maxHeight: 800.0),
                                          child: child,
                                        ),
                                      ],
                                    );
                                  });
                          if (dateTimeRange != null) {
                            _sampleCreatedDateRange = dateTimeRange;
                            var startDate = DateFormat.yMd()
                                .format(_sampleCreatedDateRange!.start);
                            var endDate = DateFormat.yMd()
                                .format(_sampleCreatedDateRange!.end);
                            if (_sampleCreatedDateRange != null) {
                              _searchCreatedDate.text = "$startDate-$endDate";
                            }
                            searchSamples();
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Search created date',
                            hintStyle:
                                const TextStyle(color: AppColors.hintTextColor),
                            border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.hintTextColor)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            suffixIcon: ClearIcon(_searchCreatedDate, () {
                              _sampleCreatedDateRange = null;
                              searchSamples();
                            })),
                        controller: _searchCreatedDate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const DataColumn(
                label: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                        width: 200,
                        child: Text(
                          "See Changes",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )))),
            const DataColumn(
                label: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                        width: 200,
                        child: Text(
                          "See Report",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )))),
          ].where((element) => element != null).map((e) => e!).toList(),
          rows: data
              .mapIndexed((index, e) => DataRow.byIndex(
                  index: index,
                  color: WidgetStateColor.resolveWith(
                    (states) {
                      if (index % 2 == 0) {
                        return AppColors.tableRowBackground;
                      } else {
                        return Colors.white;
                      }
                    },
                  ),
                  cells: <DataCell?>[
                    DataCell(Checkbox(
                        value: samplesCheckedToPrint[e] ?? false,
                        onChanged: (value) {
                          setState(() {
                            if (value ?? false) {
                              samplesCheckedToPrint[e] = true;
                            } else {
                              samplesCheckedToPrint.remove(e);
                            }
                          });
                        })),
                    if (userWithCompaniesModel.user.isSuperAdmin)
                      DataCell(
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () async {
                              getCompanyAndEditSample(e);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors
                                  .appPrimaryGreen, // This is a custom color variable
                            ),
                            child: const Text(
                              "Edit sample",
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      )
                    else
                      null,
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: e.sample.youngSampleBarcode != null ||
                                  e.sample.oldSampleBarcode != null
                              ? () {
                                  generateAndDownloadLabel(e);
                                }
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors
                                .appPrimaryGreen, // This is a custom color variable
                          ),
                          child: Text(
                            e.sample.youngSampleBarcode != null ||
                                    e.sample.oldSampleBarcode != null
                                ? "Download label"
                                : "Not available",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LocationWidget(
                                          onLocationConfirmed: (latLng) {
                                            onLocationConfirmed(latLng, e);
                                          },
                                          initialLocation: e.sample.location !=
                                                  null
                                              ? LatLng(
                                                  e.sample.location!.latitude,
                                                  e.sample.location!.longitude)
                                              : null,
                                          isPinned: true,
                                        )));
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                AppColors.appPrimaryGreen),
                            foregroundColor:
                                WidgetStateProperty.all(Colors.white),
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.all(4)),
                          ),
                          child: Text(
                            e.sample.location != null
                                ? "See Map"
                                : "Set Location",
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          )),
                    )),
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.sample.sampleDate != null
                              ? DateFormat.yMd().format(e.sample.sampleDate!)
                              : "-",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: e.sample.youngSampleBarcode != null ||
                                e.sample.oldSampleBarcode != null
                            ? () {
                                getCompanyAndSeeDetails(e);
                              }
                            : null,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Young Sample Barcode: ${e.sample.youngSampleBarcode ?? "-"}\nOld Sample Barcode: ${e.sample.oldSampleBarcode ?? "-"}",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                    if (userState.isSuperAdmin())
                      DataCell(
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            e.sample.companyName ?? "-",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.sample.grower?.setEllipsisOnOverflow(25) ?? "-",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        e.sample.farm.setEllipsisOnOverflow(25),
                        textAlign: TextAlign.left,
                      ),
                    )),
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.sample.field.setEllipsisOnOverflow(25),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.sample.crop.setEllipsisOnOverflow(25),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.sample.variety?.setEllipsisOnOverflow(25) ?? "-",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.user?.getFullName() != null
                              ? e.user!.getFullName()!
                              : "-",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.sample.notes.isNotEmpty
                              ? e.sample.notes.setEllipsisOnOverflow(25)
                              : "-",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    userWithCompaniesModel.user.isSuperAdmin
                        ? DataCell(
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: e.sample.status,
                                      isDense: true,
                                      onChanged: (newValue) async {
                                        String? newStatus = newValue;
                                        if (newStatus != null) {
                                          try {
                                            setState(() {
                                              e.sample.status = newStatus;
                                            });
                                            await sampleService
                                                .updateSampleStatus(
                                                    e.sample.id,
                                                    newStatus,
                                                    RepositoryProvider.of<
                                                            Environment>(
                                                        context,
                                                        listen: false));
                                          } catch (exception, stacktrace) {
                                            getIt
                                                .get<
                                                    RemoteErrorLoggingService>()
                                                .recordError(
                                                    exception, stacktrace);
                                          }
                                        }
                                      },
                                      items: SampleStatusConstants
                                          .sampleStatusList
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
                          )
                        : null,
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat.yMd().format(e.sample.createdDate),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: e.sample.changes.isNotEmpty
                              ? () async {
                                  List<SampleChangeWithUserModel>
                                      sampleChanges = await Future.wait(e
                                          .sample.changes
                                          .map((e) => e.toSampleWithUserModel())
                                          .toList());
                                  if (mounted) {
                                    context.pushNamed(SeeSampleChangesScreen.id,
                                        extra: SeeSampleChangesScreenArguments(
                                          sampleChanges: sampleChanges,
                                        ));
                                  }
                                }
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors
                                .appPrimaryGreen, // This is a custom color variable
                          ),
                          child: Text(
                            e.sample.changes.isNotEmpty == true
                                ? "See changes"
                                : "No changes",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: userWithCompaniesModel.user.isSuperAdmin &&
                                      adminInfoModel != null &&
                                      e.sample.youngSampleMinerals != null ||
                                  e.sample.oldSampleMinerals != null
                              ? () async {
                                  context.pushNamed(SeeReportScreen.id,
                                      extra: SeeReportScreenArguments(
                                        sampleWithUser: e,
                                        adminInfo: adminInfoModel!,
                                      ));
                                }
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors
                                .appPrimaryGreen, // This is a custom color variable
                          ),
                          child: Text(
                            userWithCompaniesModel.user.isSuperAdmin &&
                                    adminInfoModel != null &&
                                    (e.sample.youngSampleMinerals != null ||
                                        e.sample.oldSampleMinerals != null)
                                ? "See report"
                                : "No report available",
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  ]
                      .where((element) => element != null)
                      .map((e) => e!)
                      .toList()))
              .toList()),
    );
  }

  void onLocationConfirmed(
      LatLng latLng, SampleWithUserModel sampleWithUser) async {
    try {
      setState(() {
        isLoading = true;
      });
      await sampleService.updateSampleLocation(
          sampleWithUser.sample.id, latLng.latitude, latLng.longitude);
      sampleWithUser.sample.location = SampleLocationModel(
          latitude: latLng.latitude, longitude: latLng.longitude);
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getCompanyAndSeeDetails(SampleWithUserModel sampleWithUserModel) async {
    try {
      setState(() {
        isLoading = true;
      });
      if (sampleWithUserModel.sample.companyReference
          is DocumentReference<Map<String, dynamic>>) {
        var farm = await sampleService.getCompanyFromReference(
            sampleWithUserModel.sample.companyReference
                as DocumentReference<Map<String, dynamic>>);
        if (mounted) {
          final sample = await context.pushNamed(SampleSubmittedScreen.id,
              extra: SampleSubmittedScreenArguments(
                  uuid: sampleWithUserModel.sample.id,
                  farm: farm,
                  showNewLabelButton: false, fromWebDashboard: true));
          if (sample is SampleModel) {
            sampleWithUserModel.sample = sample;
            setState(() {});
          }
        }
      }
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void generateAndDownloadLabel(SampleWithUserModel sample) async {
    DocumentReference? companyReference = sample.sample.companyReference;
    String farmName = "";
    if (companyReference != null) {
      CompanyModel? farm =
          await profileService.getCompanyInDB(companyReference);
      farmName = farm?.name ?? "";
    }
    var pdf = await createPdf(sample, farmName);
    Uint8List bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'sample_report.pdf';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Widget createDashboardView(BuildContext context) {
    String sampleTitle = "Sample Title";
    String sampleDate = "11/01/2021";
    String location = "Farm 016";

    return Column(
      children: [
        Text(
          sampleTitle,
          style: const TextStyle(color: AppColors.black1, fontSize: 20.0),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 10,
          width: 150,
          color: AppColors.appPrimaryGreen,
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 40,
          child: Row(
            children: [
              Text(
                "Sampling \n Date",
                style: TextStyle(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Text(
                  sampleDate,
                  style: TextStyle(color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 2,
          width: 150,
          color: Colors.black,
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 40,
          child: Row(
            children: [
              Text(
                "Farm",
                style: TextStyle(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 2,
          width: 150,
          color: Colors.black,
        ),
        const SizedBox(
          height: 5,
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: AppColors.appPrimaryGreen,
          ),
          child: const Text("See More"),
        )
      ],
    );
  }

  Widget createReportsView(BuildContext context) {
    String reportTitle = "WHEAT AGRO-K";
    String reportId1 = "VF-0095";
    String reportId2 = "202111031201";

    String date = "11-01-2021";
    String locationPlot = "Farm 016";
    String cultivation = "AK FRI";
    String crop = "Tree C";
    String plantPart = "Leaf (young)";
    String sampleType = "Sap";

    int count = 0;

    return count == 0
        ? const Column(
            children: [
              Text(
                "Feature Coming Soon!",
                style: TextStyle(color: Colors.black, fontSize: 50),
              ),
            ],
          )
        : Column(
            children: [
              Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 360,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 95,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(Icons.timer),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "Date: ",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              date,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(Icons.timer),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "Farm: ",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              locationPlot,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(Icons.timer),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "Field: ",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              cultivation,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(Icons.timer),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "Crop: ",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              crop,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(Icons.timer),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "Plant Part: ",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              plantPart,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(Icons.timer),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "Sample Type: ",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              sampleType,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, ReportScreen.id,
                                      arguments: ReportScreenArguments(
                                          productName: reportTitle));
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.appPrimaryGreen),
                                child: const Text("See Report")),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(alignment: AlignmentDirectional.topCenter, children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 75,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.15),
                          border: Border.all(width: 1, color: Colors.grey)),
                    ),
                    Positioned(
                      top: 5,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                reportTitle,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                reportId1,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            reportId2,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ],
          );
  }

  Widget createWorkOrdersView(BuildContext context) {
    String sampleTitle = "Sample Title 3";
    String sampleDate = "11/01/2021";
    String location = "Farm 016";

    return Column(
      children: [
        Text(
          sampleTitle,
          style: const TextStyle(color: AppColors.black1, fontSize: 20.0),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 10,
          width: 150,
          color: AppColors.appPrimaryGreen,
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 40,
          child: Row(
            children: [
              Text(
                "Sampling \n Date",
                style: TextStyle(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Text(
                  sampleDate,
                  style: TextStyle(color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 2,
          width: 150,
          color: Colors.black,
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 40,
          child: Row(
            children: [
              Text(
                "Farm",
                style: TextStyle(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 2,
          width: 150,
          color: Colors.black,
        ),
        const SizedBox(
          height: 5,
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: AppColors.appPrimaryGreen,
          ),
          child: const Text("See More"),
        )
      ],
    );
  }

  void getCompanyAndEditSample(SampleWithUserModel sampleWithUserModel) async {
    try {
      setState(() {
        isLoading = true;
      });
      if (sampleWithUserModel.sample.companyReference
          is DocumentReference<Map<String, dynamic>>) {
        var farm = await sampleService.getCompanyFromReference(
            sampleWithUserModel.sample.companyReference
                as DocumentReference<Map<String, dynamic>>);
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          var result = await context.pushNamed(NewSampleScreen.id, extra: {
            "existingSampleToEdit": sampleWithUserModel,
            "sampleCompany": farm
          });
          if (result is SampleModel) {
            setState(() {
              sampleWithUserModel.sample = result;
            }); //es aca
            await Future.delayed(const Duration(seconds: 2));
            if (!mounted) return;
            setState(() {
              isLoading = true;
            });
            adminInfoModel = await profileService.getSuperAdminInfo();
            setState(() {
              isLoading = false;
            });
          } else if (result == EditSampleResult.reclaimedBarcodes) {
            setState(() {
              dashboardData.remove(sampleWithUserModel);
            });
            await Future.delayed(const Duration(seconds: 2));
            if (!mounted) return;
            setState(() {
              isLoading = true;
            });
            adminInfoModel = await profileService.getSuperAdminInfo();
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error");
    }
  }

  @override
  void initState() {
    super.initState();

    _getData();
    authService.updateLastConnection();
  }

  Future _getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      userWithCompaniesModel = userState.userData!;
      currentCompany = userState.currentCompanyData;
      authService
          .getUserCompanyInvites(userState.userData!.user.email)
          .listen((event) async {
        var invites = await event;
        if (mounted) {
          setState(() {
            this.invites = invites;
          });
        }
      });
      userUsageModel = await profileService.getUserUsage();
      dashboardData = await sampleService.searchSamples(
          _sampleCollectedDateRange,
          _sampleCreatedDateRange,
          _searchCultivation.text,
          _searchLocationPlot.text,
          _searchStatus.text,
          _searchCrop.text,
          _searchVariety.text,
          _searchGrower.text,
          _searchNotes.text,
          _searchSampleBarcodes.text,
          _searchUser.text,
          _searchIdController.text.isNotEmpty ? _searchIdController.text : null,
          _searchCompany.text,
          userWithCompaniesModel.user,
          currentCompany,
          sortFilter,
          typesenseClient);
      if (userWithCompaniesModel.user.isSuperAdmin) {
        adminInfoModel = await profileService.getSuperAdminInfo();
        userCount = await profileService.getUserCount();
        setState(() {
          adminInfoModel;
          userCount;
          dashboardData;
          userUsageModel;
        });
      } else {
        setState(() {
          dashboardData;
        });
      }
    } on FirebaseException catch (e) {
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            _getData();
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

  Future searchSamples() async {
    try {
      setState(() {
        isLoading = true;
        dashboardPageNum = 1;
        samplesCheckedToPrint.clear();
      });
      dashboardData = await sampleService.searchSamples(
          _sampleCollectedDateRange,
          _sampleCreatedDateRange,
          _searchCultivation.text,
          _searchLocationPlot.text,
          _searchStatus.text,
          _searchCrop.text,
          _searchVariety.text,
          _searchGrower.text,
          _searchNotes.text,
          _searchSampleBarcodes.text,
          _searchUser.text,
          _searchIdController.text.isNotEmpty ? _searchIdController.text : null,
          _searchCompany.text,
          userWithCompaniesModel.user,
          currentCompany,
          sortFilter,
          typesenseClient);
      setState(() {
        dashboardData;
      });
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            searchSamples();
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
}
