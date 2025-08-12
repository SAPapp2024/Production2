import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/card_with_info_rows.dart';
import 'package:agro_k/components/location_widget.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/components/select_user_dialog_widget.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/sample_location_model.dart';
import 'package:agro_k/models/company/sample_model.dart';
import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/models/user/user_with_companies_model.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/screens/NewSample/company_samples_screen.dart';
import 'package:agro_k/screens/NewSample/new_sample_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/date_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/utility_models/info_row.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class SampleSubmittedScreenArguments {
  final String uuid;
  final CompanyModel farm;
  final bool automaticallyImplyLeading;
  final bool showNewLabelButton;
  final bool fromWebDashboard;

  const SampleSubmittedScreenArguments(
      {required this.uuid,
      required this.farm,
      this.automaticallyImplyLeading = false,
      this.showNewLabelButton = true, this.fromWebDashboard = false});
}

class SampleSubmittedScreen extends StatefulWidget {
  static const String id = '/sample_submitted';
  final String uuid;
  final CompanyModel farm;
  final bool automaticallyImplyLeading;
  final bool showNewLabelButton;
  final bool fromWebDashboard;

  const SampleSubmittedScreen(
      {Key? key,
      required this.uuid,
      required this.farm,
      required this.automaticallyImplyLeading,
      required this.showNewLabelButton, required this.fromWebDashboard})
      : super(key: key);

  @override
  SampleSubmittedScreenState createState() => SampleSubmittedScreenState();
}

class SampleSubmittedScreenState extends State<SampleSubmittedScreen> {
  SampleService sampleService = getIt.get();
  SampleWithUserModel? sample;

  AuthService authService = getIt.get();
  UserState userState = getIt.get();
  bool isLoading = false;
  Marker? marker;
  List<BarcodeWrapper> barcodes = [];
  bool isExpanded = false;
  bool changedDate = false;

  @override
  void initState() {
    super.initState();

    _getSample();
  }

  void _getSample() async {
    sample = await (await sampleService.getSample(widget.uuid))
        ?.toSampleWithUserModel();
    if (sample != null && sample!.sample.location != null) {
      final location = sample!.sample.location!;
      marker = Marker(
          markerId: const MarkerId("0"),
          position: LatLng(location.latitude, location.longitude));
    }
    if (sample!.sample.youngSampleBarcode != null) {
      barcodes.add(BarcodeWrapper(sample!.sample.youngSampleBarcode!, true));
    }
    if (sample!.sample.oldSampleBarcode != null) {
      barcodes.add(BarcodeWrapper(sample!.sample.oldSampleBarcode!, false));
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = Theme.of(context);
    var currentThemeText = currentTheme.textTheme;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    if (sample == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return SelectionArea(
      child: WillPopScope(
          onWillPop: () async {
            if (widget.automaticallyImplyLeading) {
              if (kIsWeb) {
                context.goBackWeb();
              } else {
                context.pop(changedDate);
              }
            }
            return false;
          },
          child: Theme(
            data: currentTheme.copyWith(
                textTheme: currentThemeText.copyWith(
                    labelLarge: currentThemeText.labelLarge
                        ?.copyWith(fontFamily: "Mulish"),
                    bodyLarge: currentThemeText.bodyLarge
                        ?.copyWith(fontFamily: "Mulish"),
                    labelMedium: currentThemeText.labelMedium
                        ?.copyWith(fontFamily: "Mulish"),
                    displayMedium: currentThemeText.displayMedium
                        ?.copyWith(fontFamily: "Mulish"),
                    titleMedium: currentThemeText.titleMedium
                        ?.copyWith(fontFamily: "Mulish"),
                    titleSmall: currentThemeText.titleSmall
                        ?.copyWith(fontFamily: "Mulish"),
                    bodyMedium: currentThemeText.bodyMedium
                        ?.copyWith(fontFamily: "Mulish"))),
            child: Scaffold(
                backgroundColor: const Color(0xfffbfbfb),
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    child: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: AppColors.appbarGreen,
                      titleSpacing: 0,
                      leading: null,
                      centerTitle: true,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            maintainAnimation: true,
                            maintainSize: true,
                            maintainState: true,
                            visible: widget.automaticallyImplyLeading,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                    child: SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          if (kIsWeb) {
                                            context.goBackWeb();
                                          } else {
                                            context.pop(changedDate);
                                          }
                                        },
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all(
                                              EdgeInsets.zero),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.only(
                                              top: 2.0,
                                              right: 2.0,
                                              bottom: 2.0,
                                              left: 8.0),
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                          const Text("Sample Details",
                              style: TextStyle(
                                  fontFamily: "Mulish", fontSize: 18)),
                          const SizedBox(
                            width: 52,
                          ) //empty view to align title
                        ],
                      ),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Stack(
                    children: [
                      if (sample != null)
                        SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: kIsWeb
                                      ? 800
                                      : MediaQuery.of(context).size.width - 40,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16.0, bottom: 20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 24.0, bottom: 18.0),
                                          child: Row(
                                              children: barcodes.map((barcode) {
                                            return Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 700),
                                                  child: LayoutBuilder(builder:
                                                      (context, constraints) {
                                                    double barcodeTextSize;
                                                    if (barcodes.length == 1) {
                                                      barcodeTextSize = 24.0;
                                                    } else {
                                                      barcodeTextSize = 16.0;
                                                    }
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        BarcodeWidget(
                                                          data: barcode.barcode,
                                                          barcode:
                                                              Barcode.code128(),
                                                          height: constraints
                                                                  .maxWidth *
                                                              0.56,
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .black1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize:
                                                                  barcodeTextSize),
                                                        ),
                                                        if (barcodes.length > 1)
                                                          Text(
                                                            barcode.isYoung
                                                                ? "Young"
                                                                : "Old",
                                                            style: const TextStyle(
                                                                color: AppColors
                                                                    .subtitleGray,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14.0),
                                                          ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              ),
                                            );
                                          }).toList()),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Creation date",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .subtitleGray,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                  Text(
                                                      sample?.sample
                                                                  .createdDate !=
                                                              null
                                                          ? formatDateWithDaySuffix(
                                                              sample!.sample
                                                                  .createdDate)
                                                          : "N/A",
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400))
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      const Text("Sample date",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .subtitleGray,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                      Text(
                                                          sample?.sample
                                                                      .sampleDate !=
                                                                  null
                                                              ? formatDateWithDaySuffix(
                                                                  sample!.sample
                                                                      .sampleDate!)
                                                              : "N/A",
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400))
                                                    ],
                                                  ),
                                                  if (userState
                                                          .isCompanyAdmin() ||
                                                      userState
                                                          .isSuperAdmin() ||
                                                      sample
                                                              ?.sample
                                                              .userReference
                                                              ?.id ==
                                                          userState
                                                              .user?.uid) ...[
                                                    const SizedBox(width: 4),
                                                    InkWell(
                                                      onTap: () async {
                                                        //get min date between sample date and now
                                                        final dateNow = DateTime.now();
                                                        final firstDate = sample?.sample.sampleDate != null
                                                            ? sample!.sample.sampleDate!.isBefore(dateNow) ? sample!.sample.sampleDate! : dateNow
                                                            : dateNow;
                                                        final DateTime? picked = await showDatePicker(
                                                            context: context,
                                                            initialDate: sample?.sample.sampleDate != null ? sample?.sample.sampleDate! : dateNow,
                                                            initialDatePickerMode: DatePickerMode.day,
                                                            firstDate: firstDate.subtract(const Duration(days: 90)),
                                                            lastDate: DateTime(2101));
                                                        if (picked != null) {
                                                          sample?.sample.sampleDate = picked;
                                                          changedDate = true;
                                                          setState(() {});
                                                          try {
                                                            await sampleService
                                                                .updateSampleSampleDate(
                                                                sample!.sample
                                                                    .id, picked,
                                                                userState
                                                                    .userData!
                                                                    .user);
                                                          } catch (exception, stacktrace) {
                                                            getIt
                                                                .get<RemoteErrorLoggingService>()
                                                                .recordError(
                                                                exception, stacktrace);
                                                            showOneButtonAlertDialog(context, "Ok", () {
                                                              context.tryPop();
                                                            }, "Error", "There was an error");
                                                          }
                                                        }
                                                      },
                                                      child: Image.asset(
                                                        "images/iconEditSampleAssigned.png",
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                    )
                                                  ]
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Column(
                                            children: [
                                              InfoRowPresentation(
                                                  item: InfoRow(
                                                      "Grower",
                                                      sample?.sample.grower ??
                                                          ""),
                                                  id: 0),
                                              const Divider(
                                                color: AppColors.appGray,
                                                thickness: 1,
                                              ),
                                              InfoRowPresentation(
                                                  item: InfoRow(
                                                      "Farm",
                                                      sample?.sample.farm ??
                                                          ""),
                                                  id: 1),
                                              const Divider(
                                                color: AppColors.appGray,
                                                thickness: 1,
                                              ),
                                              InfoRowPresentation(
                                                  item: InfoRow(
                                                      "Field",
                                                      sample?.sample.field ??
                                                          ""),
                                                  id: 2),
                                              if (isExpanded) ...[
                                                const Divider(
                                                  color: AppColors.appGray,
                                                  thickness: 1,
                                                ),
                                                InfoRowPresentation(
                                                    item: InfoRow(
                                                        "Crop-Cultivar",
                                                        sample?.sample.crop ??
                                                            ""),
                                                    id: 3),
                                                const Divider(
                                                  color: AppColors.appGray,
                                                  thickness: 1,
                                                ),
                                                InfoRowPresentation(
                                                    item: InfoRow(
                                                        "Variety",
                                                        sample?.sample
                                                                .variety ??
                                                            ""),
                                                    id: 4),
                                                const Divider(
                                                  color: AppColors.appGray,
                                                  thickness: 1,
                                                ),
                                                InfoRowPresentation(
                                                    item: InfoRow("Analysis",
                                                        "Plant Sap"),
                                                    id: 5),
                                                const Divider(
                                                  color: AppColors.appGray,
                                                  thickness: 1,
                                                ),
                                                InfoRowPresentation(
                                                    item: InfoRow(
                                                        "Leaf Type",
                                                        sample?.sample != null
                                                            ? getLeafTypePresentation(
                                                                sample!.sample)
                                                            : ""),
                                                    id: 6),
                                                const Divider(
                                                  color: AppColors.appGray,
                                                  thickness: 1,
                                                ),
                                                InfoRowPresentation(
                                                    item: InfoRow(
                                                        "Treatment",
                                                        sample?.sample
                                                                .treatment ??
                                                            ""),
                                                    id: 7),
                                              ],
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: PrimaryButton(
                                                      title: isExpanded
                                                          ? "Show less"
                                                          : "Show more",
                                                      type: PrimaryButtonType
                                                          .outlined,
                                                      actionType:
                                                          PrimaryButtonActionType
                                                              .positive,
                                                      iconLeft: false,
                                                      onPressed: () {
                                                        setState(() {
                                                          isExpanded =
                                                              !isExpanded;
                                                        });
                                                      },
                                                      icon: isExpanded
                                                          ? const Icon(Icons
                                                              .keyboard_arrow_up)
                                                          : const Icon(Icons
                                                              .keyboard_arrow_down),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (sample?.sample.location !=
                                                  null)
                                                Container(
                                                  height: 100,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 16.0, bottom: 16),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: AbsorbPointer(
                                                      child: GoogleMap(
                                                        gestureRecognizers: <Factory<
                                                            OneSequenceGestureRecognizer>>{
                                                          Factory<
                                                              OneSequenceGestureRecognizer>(
                                                            () =>
                                                                EagerGestureRecognizer(),
                                                          ),
                                                        },
                                                        initialCameraPosition:
                                                            CameraPosition(
                                                                bearing: 0.0,
                                                                target: LatLng(
                                                                    sample!
                                                                        .sample
                                                                        .location!
                                                                        .latitude,
                                                                    sample!
                                                                        .sample
                                                                        .location!
                                                                        .longitude),
                                                                tilt: 0.0,
                                                                zoom: 13),
                                                        markers: marker != null
                                                            ? {marker!}
                                                            : {},
                                                        mapType: MapType.hybrid,
                                                        buildingsEnabled: false,
                                                        myLocationEnabled:
                                                            false,
                                                        myLocationButtonEnabled:
                                                            false,
                                                        zoomControlsEnabled:
                                                            false,
                                                        mapToolbarEnabled:
                                                            false,
                                                        scrollGesturesEnabled:
                                                            false,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (sample?.sample.location ==
                                                  null)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 24.0),
                                                  child: Row(
                                                    children: [
                                                      PrimaryButton(
                                                        type:
                                                            PrimaryButtonType.filled,
                                                        actionType:
                                                            PrimaryButtonActionType
                                                                .positive,
                                                        onPressed: () {
                                                          showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              context: context,
                                                              builder: (context) {
                                                                return FractionallySizedBox(
                                                                  heightFactor: 0.8,
                                                                  child:
                                                                      LocationWidget(
                                                                    onLocationConfirmed:
                                                                        (latLng) {
                                                                      onLocationConfirmed(
                                                                          latLng,
                                                                          sample!);
                                                                    },
                                                                    initialLocation: sample?.sample.location !=
                                                                            null
                                                                        ? LatLng(
                                                                            sample!.sample.location!.latitude,
                                                                            sample!.sample.location!.longitude)
                                                                        : null,
                                                                    isPinned:
                                                                        true,
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                        title: "Set Location",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Comments",
                                                style:
                                                    sampleFieldLabelTextStyle,
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                (sample?.sample.notes == null ||
                                                        sample!.sample.notes
                                                            .isEmpty)
                                                    ? "No comments"
                                                    : sample!.sample.notes,
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    sampleFieldValueTextStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          width: double.infinity,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Assigned to",
                                                      style:
                                                          sampleFieldLabelTextStyle,
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                      sample?.assignedTo
                                                              ?.getFullName() ??
                                                          "N/A",
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          sampleFieldValueTextStyle,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (userState.isCompanyAdmin() ||
                                                  userState.isSuperAdmin()) ...[
                                                const SizedBox(width: 16),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      assignSample(sample!);
                                                    },
                                                    icon: Image.asset(
                                                      "images/iconEditSampleAssigned.png",
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                  ),
                                                )
                                              ]
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                        type: PrimaryButtonType.outlined,
                                        actionType:
                                            PrimaryButtonActionType.positive,
                                        onPressed: () {
                                          if (widget.fromWebDashboard && changedDate && sample != null) {
                                            context.pop(sample!.sample);
                                          } else {
                                            context.goNamed(DashboardScreen.id);
                                          }
                                        },
                                        title: "Finish",
                                      ),
                                    ),
                                    if (widget.showNewLabelButton) ...[
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: PrimaryButton(
                                          type: PrimaryButtonType.filled,
                                          actionType:
                                              PrimaryButtonActionType.positive,
                                          onPressed: () async {
                                            if (sample != null) {
                                              try {
                                                await sampleService
                                                    .saveSampleFirstStepData(
                                                  const Uuid().v4(),
                                                  sample!.sample.sampleDate,
                                                  sample!.sample.farm,
                                                  sample!.sample.field,
                                                  sample!.sample.treatment ??
                                                      "",
                                                  sample!.sample.crop,
                                                  sample!.sample.variety ?? "",
                                                  sample!.sample.grower ?? "",
                                                  sample!.sample.notes,
                                                  sample!.sample.location
                                                      ?.latitude,
                                                  sample!.sample.location
                                                      ?.longitude,
                                                  sample!.sample
                                                          .youngSampleBarcode !=
                                                      null,
                                                  sample!.sample
                                                          .oldSampleBarcode !=
                                                      null,
                                                );
                                              } catch (exception, stacktrace) {
                                                getIt
                                                    .get<
                                                        RemoteErrorLoggingService>()
                                                    .recordError(
                                                        exception, stacktrace);
                                              }
                                            }
                                            if (mounted) {
                                              context
                                                  .goNamed(NewSampleScreen.id);
                                            }
                                          },
                                          title: "Create New Label",
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(
                                  height: 32,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                    ],
                  ),
                )),
          )),
    );
  }

  void assignSample(SampleWithUserModel sampleWithUser) async {
    try {
      setState(() {
        isLoading = true;
      });
      var users = await authService.getUsersFromCompany(widget.farm);
      if (mounted) {
        dynamic selectedUser = await showDialog(
            context: context,
            builder: (context) {
              return SelectUserDialogWidget(
                  users: users.map((e) => e.user).toList(),
                  selectedUserId: sampleWithUser.assignedTo?.id,
                  title: "Select a user to assign the sample");
            });
        if (selectedUser != null) {
          if (selectedUser is UserWithCompaniesModel) {
            if (selectedUser.user.id != sampleWithUser.assignedTo?.id) {
              await authService.assignSampleToUser(
                  selectedUser.user, sampleWithUser.sample);
              sampleWithUser.assignedTo = selectedUser.user;
              if (mounted) {
                setState(() {});
              }
            }
          } else if (selectedUser == -1) {
            await authService.assignSampleToUser(null, sampleWithUser.sample);
            sampleWithUser.assignedTo = null;
            if (mounted) {
              setState(() {});
            }
          }
        }
      }
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      if (!context.mounted) {
        return;
      }
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            assignSample(sampleWithUser);
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

  String getLeafTypePresentation(SampleModel sample) {
    var leafTypePresentation = "";
    if (sample.youngSampleBarcode != null) {
      leafTypePresentation += "Young";
    }
    if (sample.oldSampleBarcode != null) {
      if (leafTypePresentation.isNotEmpty) {
        leafTypePresentation += ", ";
      }
      leafTypePresentation += "Old";
    }
    return leafTypePresentation;
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
}

const sampleFieldLabelTextStyle = TextStyle(
    fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF818186));
const sampleFieldValueTextStyle = TextStyle(
    fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF263128));

class BarcodeWrapper {
  final String barcode;
  final bool isYoung;

  BarcodeWrapper(this.barcode, this.isYoung);
}
