import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/components/location_widget.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/components/select_user_dialog_widget.dart';
import 'package:agro_k/components/text_with_result_match.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/sample_location_model.dart';
import 'package:agro_k/models/company/sample_model.dart';
import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/models/user/user_with_companies_model.dart';
import 'package:agro_k/screens/NewSample/sample_submitted_screen.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/file_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:typesense/typesense.dart';

class CompanySamplesScreen extends StatefulWidget {
  static const id = "/company_samples";
  final UserModel user;
  final CompanyModel farm;

  const CompanySamplesScreen({Key? key, required this.user, required this.farm})
      : super(key: key);

  @override
  State<CompanySamplesScreen> createState() => _CompanySamplesScreenState();
}

class TooltipSampleInfo {
  final SampleModel sample;
  final Offset offset;

  TooltipSampleInfo(this.sample, this.offset);
}

class _CompanySamplesScreenState extends State<CompanySamplesScreen>
    with TickerProviderStateMixin {
  UserState userState = getIt.get();
  SampleService sampleService = getIt.get();
  AuthService authService = getIt.get();
  ProfileService profileService = getIt.get();
  List<SampleWithUserModel> sampleList = [];
  static List<String> searchFilters = [
    "Grower",
    "Farm",
    "Field",
    "Crop",
    "Sample Date",
    "Created Date"
  ];
  FocusNode searchFieldFocusNode = FocusNode();
  String selectedSearchFilter = searchFilters[0];
  TextEditingController searchSamplesController = TextEditingController();
  List<SampleWithUserModel> selectedSamples = [];
  Client typesenseClient = getIt.get();
  bool searchMode = false;
  String? lastSearchTerm;
  String? lastSearchFilter;
  ScrollController scrollController = ScrollController();
  GlobalKey listViewKey = GlobalKey();
  var isLoading = false;
  List<GlobalKey> itemKeys = [];

  @override
  void initState() {
    super.initState();

    _getData();
  }

  void _getData() async {
    setState(() {
      isLoading = true;
    });
    var samples = await sampleService.searchCompanySamples(
        selectedSearchFilter,
        searchSamplesController.text,
        widget.user,
        widget.farm,
        typesenseClient);
    itemKeys = List.generate(samples.length, (index) => GlobalKey());
    setState(() {
      isLoading = false;
      sampleList = samples;
    });
  }

  void _pickDateFilter(String searchFilter) async {
    DateTime currentSelectedDate = DateTime.now();
    if (selectedSearchFilter == "Sample Date" ||
        selectedSearchFilter == "Created Date") {
      try {
        currentSelectedDate =
            DateFormat.yMd().parse(searchSamplesController.text);
      } catch (_) {}
    }
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          DateTimeRange(start: currentSelectedDate, end: currentSelectedDate),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime.now().subtract(const Duration(days: 1000)),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.greenAccent,
              surface: AppColors.appPrimaryGreen,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      searchSamplesController.text =
          "${DateFormat.yMd().format(picked.start)} - ${DateFormat.yMd().format(picked.end)}";
      selectedSearchFilter = searchFilter;
      setState(() {});
      onFieldSubmitted();
    }
  }

  Future<void> onRefreshSamples() async {
    var samples = await sampleService.searchCompanySamples(
        selectedSearchFilter,
        searchSamplesController.text,
        widget.user,
        widget.farm,
        typesenseClient);
    itemKeys = List.generate(samples.length, (index) => GlobalKey());
    setState(() {
      lastSearchTerm = searchSamplesController.text;
      lastSearchFilter = selectedSearchFilter;
      sampleList = samples;
    });
  }

  Widget filterButton(String filterName) {
    bool isCurrentFilter = filterName == selectedSearchFilter;
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: OutlinedButton(
          onPressed: filterName == "Sample Date" || filterName == "Created Date"
              ? () {
                  _pickDateFilter(filterName);
                }
              : isCurrentFilter
                  ? null
                  : () {
                      setState(() {
                        selectedSearchFilter = filterName;
                      });
                    },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
                isCurrentFilter ? Colors.white : AppColors.appPrimaryGreen),
            foregroundColor: WidgetStateProperty.all(
                isCurrentFilter ? AppColors.appPrimaryGreen : Colors.white),
            padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
            side: WidgetStateProperty.all(
                const BorderSide(color: Colors.white, width: 1.0)),
            shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)))),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Text(
              filterName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          )),
    );
  }

  Future<void> onFieldSubmitted() async {
    List<SampleWithUserModel> searchSampleResult =
        await sampleService.searchCompanySamples(
            selectedSearchFilter,
            searchSamplesController.text,
            widget.user,
            widget.farm,
            typesenseClient);
    itemKeys = List.generate(searchSampleResult.length, (index) => GlobalKey());
    setState(() {
      lastSearchTerm = searchSamplesController.text;
      lastSearchFilter = selectedSearchFilter;
      sampleList = searchSampleResult;
    });
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
                labelMedium: currentThemeText.labelMedium
                    ?.copyWith(fontFamily: "Mulish"),
                displayMedium: currentThemeText.displayMedium
                    ?.copyWith(fontFamily: "Mulish"),
                titleMedium: currentThemeText.titleMedium
                    ?.copyWith(fontFamily: "Mulish"),
                titleSmall:
                    currentThemeText.titleSmall?.copyWith(fontFamily: "Mulish"),
                bodyMedium: currentThemeText.bodyMedium
                    ?.copyWith(fontFamily: "Mulish"))),
        child: Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.zero,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          bottom: 20),
                      color: AppColors.appPrimaryGreen,
                      child: searchMode
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          focusNode: searchFieldFocusNode,
                                          controller: searchSamplesController,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF818186)),
                                          onFieldSubmitted: (_) =>
                                              onFieldSubmitted(),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            filled: true,
                                            fillColor: Colors.white,
                                            prefixIcon: const Icon(
                                              Icons.search,
                                              color: AppColors.subtitleGray,
                                              size: 24,
                                            ),
                                            suffixIcon: IconButton(
                                                hoverColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                onPressed: () {
                                                  if (searchSamplesController
                                                      .text.isNotEmpty) {
                                                    searchSamplesController
                                                        .text = "";
                                                    onFieldSubmitted();
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: AppColors.subtitleGray,
                                                  size: 24,
                                                )),
                                            hintText:
                                                "Enter ${selectedSearchFilter.toLowerCase()} name",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFf4f4f4),
                                                  width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFf4f4f4),
                                                  width: 1.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFFf4f4f4),
                                                  width: 1.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF818186)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          searchFieldFocusNode.unfocus();
                                          setState(() {
                                            searchMode = false;
                                          });
                                        },
                                        child: const Text("Cancel",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Row(
                                        children: searchFilters
                                            .map(
                                              (e) => filterButton(e),
                                            )
                                            .toList(),
                                      ),
                                    )),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: IconButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          icon: const Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      Image.asset(
                                        "images/agrok-logo.png",
                                        height: 48,
                                        width: 145,
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              searchMode = true;
                                            });
                                            searchFieldFocusNode.requestFocus();
                                          },
                                          icon: const Icon(Icons.search))
                                    ]),
                                const SizedBox(
                                  height: 12,
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Sample Management",
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (lastSearchTerm != null && lastSearchTerm != "")
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                  bottom: 8,
                                  top: 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("SHOWING RESULTS FOR",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF728597),
                                          fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 8),
                                  Text(lastSearchTerm!,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          Expanded(
                            child: sampleList.isNotEmpty
                                ? RefreshIndicator(
                                    onRefresh: onRefreshSamples,
                                    child: Stack(
                                      children: [
                                        ListView.builder(
                                          key: listViewKey,
                                          padding:
                                              const EdgeInsets.only(top: 16),
                                          controller: scrollController,
                                          itemCount: sampleList.length,
                                          itemBuilder: (context, position) =>
                                              showSampleCard(
                                                  sampleList[position],
                                                  position),
                                        ),
                                      ],
                                    ),
                                  )
                                : !isLoading
                                    ? showNoSamples()
                                    : Container(),
                          ),
                          Container(
                            color: const Color(0xFFF6F6F6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: PrimaryButton(
                                            onPressed: () async {
                                              final unprintedSamples =
                                                  sampleList
                                                      .where((element) =>
                                                          !element.sample
                                                              .hasBeenPrinted)
                                                      .toList();
                                              if (unprintedSamples.isEmpty) {
                                                await showDialog<bool>(
                                                        context: context,
                                                        builder: (_) {
                                                          return Center(
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        24.0),
                                                                child: Card(
                                                                    shape:
                                                                        const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(4)),
                                                                    ),
                                                                    child: Padding(
                                                                        padding: const EdgeInsets.all(16.0),
                                                                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                          const Flexible(
                                                                            flex:
                                                                                0,
                                                                            child:
                                                                                Text("There aren't any unprinted samples in your search.", style: TextStyle(color: Colors.black)),
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop(true);
                                                                                  },
                                                                                  child: const Text("Ok", style: TextStyle(color: Colors.black))),
                                                                            ],
                                                                          )
                                                                        ])))),
                                                          );
                                                        }) ??
                                                    false;
                                                return;
                                              } else if (unprintedSamples
                                                      .length >
                                                  50) {
                                                await showDialog<bool>(
                                                        context: context,
                                                        builder: (_) {
                                                          return Center(
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        24.0),
                                                                child: Card(
                                                                    shape:
                                                                        const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(4)),
                                                                    ),
                                                                    child: Padding(
                                                                        padding: const EdgeInsets.all(16.0),
                                                                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                          const Flexible(
                                                                            flex:
                                                                                0,
                                                                            child:
                                                                                Text("You have more than 50 unprinted samples, please print them on the website.", style: TextStyle(color: Colors.black)),
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop(true);
                                                                                  },
                                                                                  child: const Text("Ok", style: TextStyle(color: Colors.black))),
                                                                            ],
                                                                          )
                                                                        ])))),
                                                          );
                                                        }) ??
                                                    false;
                                                return;
                                              }
                                              if (!mounted) return;
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
                                                  sampleService
                                                      .updateSamplePrinted(
                                                          unprintedSamples);
                                                  await createMergedPdf(result,
                                                      box, unprintedSamples);
                                                } catch (exception, stacktrace) {
                                                  getIt
                                                      .get<
                                                          RemoteErrorLoggingService>()
                                                      .recordError(exception,
                                                          stacktrace);
                                                } finally {
                                                  setState(() {
                                                    selectedSamples.clear();
                                                  });
                                                }
                                              }
                                            },
                                            icon: const Icon(Icons.print_sharp,
                                                size: 20),
                                            title: "Print \nUnprinted",
                                            type: PrimaryButtonType.filled,
                                            actionType: PrimaryButtonActionType
                                                .positive,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 0))),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                        child: PrimaryButton(
                                            onPressed: selectedSamples.isEmpty
                                                ? null
                                                : () async {
                                                    if (selectedSamples.any(
                                                        (element) => element
                                                            .sample
                                                            .hasBeenPrinted)) {
                                                      bool continueSharing =
                                                          await showDialog<
                                                                      bool>(
                                                                  context:
                                                                      context,
                                                                  builder: (_) {
                                                                    return Center(
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.all(24.0),
                                                                          child: Card(
                                                                              shape: const RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                                                              ),
                                                                              child: Padding(
                                                                                  padding: const EdgeInsets.all(16.0),
                                                                                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                                    const Flexible(
                                                                                      flex: 0,
                                                                                      child: Text("Some of the selected samples have already been printed. Are you sure you want to continue?", style: TextStyle(color: Colors.black)),
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop(true);
                                                                                            },
                                                                                            child: const Text("Yes", style: TextStyle(color: Colors.black))),
                                                                                        TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop(false);
                                                                                            },
                                                                                            child: const Text("No", style: TextStyle(color: Colors.black))),
                                                                                      ],
                                                                                    )
                                                                                  ])))),
                                                                    );
                                                                  }) ??
                                                              false;
                                                      if (!continueSharing) {
                                                        return;
                                                      }
                                                    }
                                                    if (!mounted) return;
                                                    final box = context
                                                            .findRenderObject()
                                                        as RenderBox;
                                                    var result = await showDialog<
                                                            MergeSamplesOptions>(
                                                        context: context,
                                                        builder: (_) {
                                                          return const MergeSamplesOptionsDialog();
                                                        });
                                                    if (result != null) {
                                                      try {
                                                        sampleService
                                                            .updateSamplePrinted(
                                                                selectedSamples);
                                                        await createMergedPdf(
                                                            result,
                                                            box,
                                                            selectedSamples);
                                                      } catch (exception, stacktrace) {
                                                        getIt
                                                            .get<
                                                                RemoteErrorLoggingService>()
                                                            .recordError(
                                                                exception,
                                                                stacktrace);
                                                      } finally {
                                                        setState(() {
                                                          selectedSamples
                                                              .clear();
                                                        });
                                                      }
                                                    }
                                                  },
                                            icon: const Icon(Icons.print_sharp,
                                                size: 20),
                                            title: "Print \nSelected",
                                            type: PrimaryButtonType.filled,
                                            actionType: PrimaryButtonActionType
                                                .positive,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 0))),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: PrimaryButton(
                                          onPressed: () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            try {
                                              await generateSamplesExcelFile(
                                                  sampleList);
                                            } catch (exception, stacktrace) {
                                              getIt
                                                  .get<
                                                      RemoteErrorLoggingService>()
                                                  .recordError(
                                                      exception, stacktrace);
                                              showOneButtonAlertDialog(
                                                  context, "Ok", () {
                                                Navigator.pop(context);
                                              }, "Error",
                                                  "There was an error downloading the file: $exception");
                                            }
                                            setState(() {
                                              isLoading = false;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.download,
                                            size: 20,
                                          ),
                                          title: "Download \nCSV",
                                          type: PrimaryButtonType.filled,
                                          actionType:
                                              PrimaryButtonActionType.positive,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 0)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ]),
                  ),
                ],
              ),
              if (isLoading) const Center(child: CircularProgressIndicator())
            ],
          ),
        ));
  }

  Widget showNoSamples() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "No company samples",
        style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget showSampleCard(SampleWithUserModel sampleWithUser, int index) {
    var isSampleSelected = selectedSamples.contains(sampleWithUser);
    var isLastItem = index == sampleList.length - 1;
    final itemKey = itemKeys[index];
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        key: itemKey,
        padding:
            EdgeInsets.only(bottom: isLastItem ? 16 : 8.0, left: 20, right: 20),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            final changedDate =
                await context.pushNamed(SampleSubmittedScreen.id,
                    extra: SampleSubmittedScreenArguments(
                      uuid: sampleWithUser.sample.id,
                      farm: widget.farm,
                      automaticallyImplyLeading: true,
                    ));
            if (changedDate == true) {
              await onRefreshSamples();
            }
          },
          child: CustomCard(
            elevation: 6,
            borderRadius: 10,
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          OutlinedButton(
                              onPressed: () {
                                if (!isSampleSelected) {
                                  selectedSamples.add(sampleWithUser);
                                  setState(() {});
                                } else {
                                  selectedSamples.remove(sampleWithUser);
                                  setState(() {});
                                }
                              },
                              style: ButtonStyle(
                                minimumSize:
                                    WidgetStateProperty.all(Size.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: WidgetStateProperty.all(
                                    !isSampleSelected
                                        ? Colors.white
                                        : AppColors.appPrimaryGreen),
                                foregroundColor: WidgetStateProperty.all(
                                    !isSampleSelected
                                        ? AppColors.appPrimaryGreen
                                        : Colors.white),
                                padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        vertical: 6.5, horizontal: 11)),
                                side: WidgetStateProperty.all(BorderSide(
                                    color: !isSampleSelected
                                        ? AppColors.appPrimaryGreen
                                        : Colors.white,
                                    width: 1.0)),
                                shape: WidgetStateProperty.all(
                                    const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)))),
                              ),
                              child: Text(
                                "$index",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              )),
                          const Spacer()
                        ],
                      ),
                    ),
                    if (sampleWithUser.sample.prints.isEmpty)
                      Expanded(
                        child: Container(),
                      ),
                    if (sampleWithUser.sample.prints.isNotEmpty)
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors
                                      .appPrimaryGreen, // Set border color
                                  width: 1.0, // Set border width
                                ),
                                borderRadius: BorderRadius.circular(
                                    5.0), // Set border radius
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  "Printed",
                                  style: TextStyle(
                                      color: AppColors.appPrimaryGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("CREATED DATE",
                              style: TextStyle(
                                  color: Color(0xFF728597),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400)),
                          Text(
                              DateFormat("MM/dd/yyyy")
                                  .format(sampleWithUser.sample.createdDate),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: sampleWithUser.sample.sampleDate != null
                          ? Row(
                              children: [
                                const SizedBox(width: 8),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("SAMPLE DATE",
                                        style: TextStyle(
                                            color: Color(0xFF728597),
                                            fontSize: 8,
                                            fontWeight: FontWeight.w400)),
                                    Text(
                                        DateFormat("MM/dd/yyyy").format(
                                            sampleWithUser.sample.sampleDate!),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400))
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "GROWER",
                              style: sampleCardFieldLabelTextStyle,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            TextWithResultMatch(
                              text: sampleWithUser.sample.grower ?? "N/A",
                              searchQuery: lastSearchFilter == "Grower"
                                  ? lastSearchTerm
                                  : null,
                              style: sampleCardFieldValueTextStyle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "FARM",
                              style: sampleCardFieldLabelTextStyle,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            TextWithResultMatch(
                              text: sampleWithUser.sample.farm,
                              searchQuery: lastSearchFilter == "Farm"
                                  ? lastSearchTerm
                                  : null,
                              style: sampleCardFieldValueTextStyle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "FIELD",
                              style: sampleCardFieldLabelTextStyle,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            TextWithResultMatch(
                              text: sampleWithUser.sample.field,
                              searchQuery: lastSearchFilter == "Field"
                                  ? lastSearchTerm
                                  : null,
                              style: sampleCardFieldValueTextStyle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "CROP-CULTIVAR",
                              style: sampleCardFieldLabelTextStyle,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            TextWithResultMatch(
                              text: sampleWithUser.sample.crop,
                              searchQuery: lastSearchFilter == "Crop"
                                  ? lastSearchTerm
                                  : null,
                              style: sampleCardFieldValueTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ]),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget userThatSampleWasAssignedTo(SampleWithUserModel sampleWithUser) {
    if (userState.isCompanyAdmin() || userState.isSuperAdmin()) {
      return TextButton(
        onPressed: () async {
          assignSample(sampleWithUser);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          backgroundColor: const Color(0xFFF6F6F6),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                sampleWithUser.assignedTo?.getFullName() ?? "N/A",
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    color: Color(0xFF263128)),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            const Icon(Icons.edit, color: Color(0xFF818186)),
          ],
        ),
      );
    } else {
      return TextButton(
        onPressed: null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          backgroundColor: const Color(0xFFF6F6F6),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                sampleWithUser.assignedTo?.getFullName() ?? "N/A",
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    color: Color(0xFF263128)),
              ),
            ),
          ],
        ),
      );
    }
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
}

class MergeSamplesOptionsDialog extends StatefulWidget {
  const MergeSamplesOptionsDialog({Key? key}) : super(key: key);

  @override
  State<MergeSamplesOptionsDialog> createState() =>
      _MergeSamplesOptionsDialogState();
}

class _MergeSamplesOptionsDialogState extends State<MergeSamplesOptionsDialog> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("PDF Format",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18)),
                      const SizedBox(height: 10),
                      const Text(
                        "How would you like to format the PDF document?",
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text("Options:",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context, MergeSamplesOptions.fullSize);
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColors.appPrimaryGreen),
                            child: const Text("1 per sheet")),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context, MergeSamplesOptions.fourPerSheet);
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColors.appPrimaryGreen),
                            child: const Text("4 per sheet")),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                          child: const Text("Cancel")),
                    ],
                  ),
                ),
              ),
            )));
  }
}

const sampleCardFieldValueTextStyle =
    TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black);

const sampleCardFieldLabelTextStyle = TextStyle(
  fontWeight: FontWeight.w400,
  fontSize: 8,
  color: Color(0xFF818186),
);

enum MergeSamplesOptions { fullSize, fourPerSheet }
