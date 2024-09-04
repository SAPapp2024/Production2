import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/add_new_barcode_widget.dart';
import 'package:agro_k/components/assign_barcodes_widget.dart';
import 'package:agro_k/components/clear_icon_widget.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/crop_model.dart';
import 'package:agro_k/models/global_barcode_list_item_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/CompanyTab/purchase_barcodes_screen.dart';
import 'package:agro_k/screens/Dashboard/companies_management_screen.dart';
import 'package:agro_k/screens/NewSample/sample_submitted_screen.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/file_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/sample_sorting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ManageBarcodesScreenArguments {
  final CompanyModel farm;
  final BarcodeSortFilterWrapper? initialSort;

  const ManageBarcodesScreenArguments({Key? key, required this.farm, this.initialSort});
}

class ManageBarcodesScreen extends StatefulWidget {
  static const String id = '/manage_barcodes';
  final UserModel user;
  final CompanyModel? farm;
  final BarcodeSortFilterWrapper? initialSort;

  const ManageBarcodesScreen({Key? key, required this.user, required this.farm, this.initialSort}) : super(key: key);

  @override
  State<ManageBarcodesScreen> createState() => _ManageBarcodesScreenState();
}

class _ManageBarcodesScreenState extends State<ManageBarcodesScreen> {
  ScrollController tableScrollController = ScrollController();
  List<GlobalBarcodeListItemModel> barcodes = [];
  bool isLoading = false;
  SampleService sampleService = getIt.get();
  UserState userState = getIt.get();
  int topListNum = 0;
  int endListNum = 0;
  int entriesSelected = 25;
  int dashboardPageNum = 1;
  int totalEntries = 25; // we need to update count
  List<String> barcodeStatusList = ["Active", "Inactive"];
  final TextEditingController _searchCreatedDate = TextEditingController();
  final TextEditingController _searchAddedToFarmDate = TextEditingController();
  DateTimeRange? _createdDateRange;
  DateTimeRange? _addedToFarmDateRange;
  BarcodeSortFilterWrapper sortFilter = BarcodeSortFilterWrapper.empty();
  Map<GlobalBarcodeListItemModel, bool> barcodesCheckedToReclaim = {};

  final TextEditingController _searchBarcodeValue = TextEditingController();
  final TextEditingController _searchCompany = TextEditingController();
  final TextEditingController _searchBarcodeType = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialSort != null) {
      sortFilter = widget.initialSort!;
    }
    getBarcodes();
  }

  Future<void> getBarcodes() async {
    try {
      await searchBarcodes();
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            getBarcodes();
          },
          "Cancel",
          () {
            Navigator.pop(context);
          },
          "Error",
          exception.message ?? "Unknown error.");
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
          title: const Text("Manage Barcodes"),
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
                      widget.user.isSuperAdmin && widget.farm == null
                          ? Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                                      onPressed: () {
                                        uploadAndProcessBarcodes();
                                      },
                                      child: const Text("Upload barcodes")),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                                      onPressed: () {
                                        addNewBarcode();
                                      },
                                      child: const Text("Add new barcode")),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                                      onPressed: () {
                                        assignBarcodes();
                                      },
                                      child: const Text("Assign barcodes")),
                                ),
                              ],
                            )
                          : userState.isCompanyAdmin()
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                                      onPressed: () async {
                                        bool result = await context.pushNamed<bool>(PurchaseBarcodesScreen.id) ?? false;
                                        if (result) {
                                          await getBarcodes();
                                        }
                                      },
                                      child: const Text("Purchase barcodes")),
                                )
                              : Container(),
                      widget.farm != null && userState.isCompanyAdmin()
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Barcodes assigned: ${widget.farm!.barcodesAssigned}",
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Text("Barcodes purchased: ${widget.farm!.barcodesPurchased}",
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )
                          : Container(),
                      Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              side: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                          child: Padding(padding: const EdgeInsets.all(40.0), child: createCropTable(context)))
                    ],
                  ),
                ),
              ),
            ),
            Visibility(visible: isLoading, child: const Center(child: CircularProgressIndicator()))
          ],
        ),
      ),
    );
  }

  Widget createCropTable(BuildContext context) {
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
    totalEntries = barcodes.length;
    if (endListNum > barcodes.length) {
      endListNum = barcodes.length;
    }
    var data = barcodes.sublist(topListNum, endListNum);
    return Column(
      children: [
        Row(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "BARCODE DASHBOARD",
                style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () {
                  searchBarcodes();
                },
                child: const Text("Apply")),
            const SizedBox(
              width: 15,
            ),
            ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () {
                  _searchBarcodeValue.text = "";
                  _searchBarcodeType.text = "";
                  _searchCompany.text = "";
                  setState(() {
                    sortFilter = BarcodeSortFilterWrapper.empty();
                  });
                },
                child: const Text("Clear Filters")),
            const SizedBox(
              width: 35,
            ),
            ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () async {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    await generateBarcodesExcelFile(List.generate(
                      barcodes.length,
                      (index) => barcodes[index],
                    ));
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                child: const Text("Download Report")),
            if (barcodesCheckedToReclaim.isNotEmpty) ...[
              const SizedBox(
                width: 35,
              ),
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () async {
                  if (barcodesCheckedToReclaim.length > 499) {
                    showOneButtonAlertDialog(
                      context,
                      "Reclaim",
                      () {
                        Navigator.pop(context);
                      },
                      "Reclaim ${barcodesCheckedToReclaim.length} barcodes",
                      "You can only reclaim up to 499 barcodes at a time",
                    );
                    return;
                  }
                  showTwoButtonAlertDialog(
                    context,
                    "Reclaim",
                    () async {
                      try {
                        Navigator.pop(context);
                        setState(() {
                          isLoading = true;
                        });
                        await sampleService.reclaimBarcodes(barcodesCheckedToReclaim.keys.toList());
                        if (!mounted) return;
                        showOneButtonAlertDialog(
                          context,
                          "Ok",
                          () {
                            Navigator.pop(context);
                          },
                          "Success",
                          "Barcodes reclaimed successfully",
                        );
                        barcodes.clear();
                        await getBarcodes();
                        barcodesCheckedToReclaim.clear();
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                    "Cancel",
                    () {
                      Navigator.pop(context);
                      setState(() {
                        isLoading = false;
                      });
                    },
                    "Reclaim ${barcodesCheckedToReclaim.length} barcodes",
                    "Are you sure you want to reclaim ${barcodesCheckedToReclaim.length} barcodes?",
                  );
                },
                child: Text("Reclaim ${barcodesCheckedToReclaim.length} samples"),
              ),
              const SizedBox(
                width: 8,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    barcodesCheckedToReclaim.clear();
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.appPrimaryGreen,
                ),
                child: const Text("Unselect all samples"),
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
              style: TextStyle(color: AppColors.black1, fontSize: 14, fontWeight: FontWeight.w400),
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
                    style: const TextStyle(color: AppColors.black1, fontSize: 14, fontWeight: FontWeight.w400),
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
              style: TextStyle(color: AppColors.black1, fontSize: 14, fontWeight: FontWeight.w400),
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
                  data: Theme.of(context).copyWith(dividerColor: AppColors.hintTextColor),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DataTable(
                        dataRowMaxHeight: 50,
                        dataRowMinHeight: 50,
                        headingRowHeight: 100,
                        showBottomBorder: true,
                        columns: [
                          const DataColumn(
                              label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Reclaim",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ))),
                          DataColumn(
                            label: Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: createTitleRow("Barcode", BarcodeSortFields.barcode)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: TextFormField(
                                      onFieldSubmitted: (_) => searchBarcodes(),
                                      decoration: InputDecoration(
                                          hintText: "Search Barcode",
                                          hintStyle: const TextStyle(color: AppColors.hintTextColor),
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide(color: AppColors.hintTextColor)),
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          suffixIcon: ClearIcon(_searchBarcodeValue, () {
                                            searchBarcodes();
                                          })),
                                      controller: _searchBarcodeValue,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          widget.user.isSuperAdmin
                              ? DataColumn(
                                  label: Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: createTitleRow("Company", BarcodeSortFields.company)),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: TextFormField(
                                            onFieldSubmitted: (_) => searchBarcodes(),
                                            decoration: InputDecoration(
                                                hintText: "Search Company",
                                                hintStyle: const TextStyle(color: AppColors.hintTextColor),
                                                border: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: AppColors.hintTextColor)),
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                suffixIcon: ClearIcon(_searchCompany, () {
                                                  searchBarcodes();
                                                })),
                                            controller: _searchCompany,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : DataColumn(label: Container()),
                          DataColumn(
                            label: Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: createTitleRow("Loaded date", BarcodeSortFields.createdDate)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: TextFormField(
                                      onFieldSubmitted: (_) => searchBarcodes(),
                                      onTap: () async {
                                        DateTime currentDate = DateTime.now();
                                        DateTimeRange? dateTimeRange = await showDateRangePicker(
                                            context: context,
                                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                                            firstDate: currentDate.subtract(const Duration(days: 1000)),
                                            lastDate: currentDate.add(const Duration(days: 1000)),
                                            builder: (context, child) {
                                              return Column(
                                                children: [
                                                  ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(maxWidth: 400.0, maxHeight: 800.0),
                                                    child: child,
                                                  ),
                                                ],
                                              );
                                            });
                                        if (dateTimeRange != null) {
                                          _createdDateRange = dateTimeRange;
                                          var startDate = DateFormat.yMd().format(_createdDateRange!.start);
                                          var endDate = DateFormat.yMd().format(_createdDateRange!.end);
                                          if (_createdDateRange != null) {
                                            _searchCreatedDate.text = "$startDate-$endDate";
                                          }
                                        }
                                      },
                                      decoration: InputDecoration(
                                          hintText: 'Search loaded date',
                                          hintStyle: const TextStyle(color: AppColors.hintTextColor),
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide(color: AppColors.hintTextColor)),
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          suffixIcon: ClearIcon(_searchCreatedDate, () {
                                            _createdDateRange = null;
                                            searchBarcodes();
                                          })),
                                      controller: _searchCreatedDate,
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
                                      child:
                                          createTitleRow("Added to company date", BarcodeSortFields.addedToFarmDate)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: TextFormField(
                                      onFieldSubmitted: (_) => searchBarcodes(),
                                      onTap: () async {
                                        DateTime currentDate = DateTime.now();
                                        DateTimeRange? dateTimeRange = await showDateRangePicker(
                                            context: context,
                                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                                            firstDate: currentDate.subtract(const Duration(days: 1000)),
                                            lastDate: currentDate.add(const Duration(days: 1000)),
                                            builder: (context, child) {
                                              return Column(
                                                children: [
                                                  ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(maxWidth: 400.0, maxHeight: 800.0),
                                                    child: child,
                                                  ),
                                                ],
                                              );
                                            });
                                        if (dateTimeRange != null) {
                                          _addedToFarmDateRange = dateTimeRange;
                                          var startDate = DateFormat.yMd().format(_addedToFarmDateRange!.start);
                                          var endDate = DateFormat.yMd().format(_addedToFarmDateRange!.end);
                                          if (_addedToFarmDateRange != null) {
                                            _searchAddedToFarmDate.text = "$startDate-$endDate";
                                          }
                                        }
                                      },
                                      decoration: InputDecoration(
                                          hintText: 'Search added to company date',
                                          hintStyle: const TextStyle(color: AppColors.hintTextColor),
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide(color: AppColors.hintTextColor)),
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          suffixIcon: ClearIcon(_searchAddedToFarmDate, () {
                                            _addedToFarmDateRange = null;
                                            searchBarcodes();
                                          })),
                                      controller: _searchAddedToFarmDate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow("Sample", BarcodeSortFields.sample)),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: createTitleRow("Shipping", BarcodeSortFields.shipping)),
                            ),
                          ),
                        ],
                        rows: data.mapIndexed(
                          (index, e) {
                            return DataRow.byIndex(
                                index: index,
                                color: MaterialStateColor.resolveWith(
                                  (states) {
                                    if (index % 2 == 0) {
                                      return AppColors.tableRowBackground;
                                    } else {
                                      return Colors.white;
                                    }
                                  },
                                ),
                                cells: [
                                  DataCell(e.companyReference != null && e.sampleReference == null
                                      ? Checkbox(
                                          value: barcodesCheckedToReclaim[e] ?? false,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value ?? false) {
                                                barcodesCheckedToReclaim[e] = true;
                                              } else {
                                                barcodesCheckedToReclaim.remove(e);
                                              }
                                            });
                                          })
                                      : Container()),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(e.barcode),
                                    ),
                                  ),
                                  widget.user.isSuperAdmin
                                      ? DataCell(
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton(
                                                onPressed: e.companyReference != null
                                                    ? () {
                                                        context.go(
                                                          "${CompaniesManagementScreen.id}?highlightedCompanyId=${e.companyReference!.id}",
                                                        );
                                                      }
                                                    : null,
                                                child: Text(e.companyName ?? "-")),
                                          ),
                                        )
                                      : DataCell(Container()),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        e.createdDate != null ? DateFormat.yMd().format(e.createdDate!) : "N/A",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        e.dateAddedToCompany != null
                                            ? DateFormat.yMd().format(e.dateAddedToCompany!)
                                            : "N/A",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton(
                                          onPressed: e.companyReference != null && e.sampleReference != null
                                              ? () async {
                                                  try {
                                                    var farmModel = CompanyModel.fromJson(
                                                        (await e.companyReference!.get()).data()
                                                            as Map<String, dynamic>);
                                                    if (!mounted) return;
                                                    context.goNamed(SampleSubmittedScreen.id,
                                                        extra: SampleSubmittedScreenArguments(
                                                            uuid: e.sampleReference!.id,
                                                            farm: farmModel,
                                                            showNewLabelButton: false));
                                                  } catch (exception, stacktrace) {
                                                    getIt
                                                        .get<RemoteErrorLoggingService>()
                                                        .recordError(exception, stacktrace);
                                                    showOneButtonAlertDialog(context, "Ok", () {
                                                      Navigator.pop(context);
                                                    }, "Error", "There was an error loading the sample");
                                                  }
                                                }
                                              : null,
                                          child: Text(e.sampleReference?.id ?? "-")),
                                    ),
                                  ),
                                  DataCell(getShippingWidget(e)),
                                ]);
                          },
                        ).toList()),
                  )),
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
              style: const TextStyle(color: AppColors.grayTextColor, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const Expanded(child: SizedBox()),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: AppColors.cardBorder,
                ),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
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
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
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
                borderRadius: const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
              ),
              child: TextButton(
                onPressed: dashboardPageNum * entriesSelected < barcodes.length
                    ? () {
                        setState(() {
                          dashboardPageNum = dashboardPageNum + 1;
                        });
                      }
                    : null,
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
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

  Future searchBarcodes() async {
    try {
      setState(() {
        isLoading = true;
      });
      barcodes = await sampleService.searchBarcodes(_createdDateRange, _addedToFarmDateRange, _searchBarcodeValue.text,
          _searchBarcodeType.text, _searchCompany.text, sortFilter, widget.farm);
      setState(() {
        barcodes;
      });
    } on FirebaseException catch (e) {
      debugPrint("e -> ${e.message}");
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            searchBarcodes();
          },
          "Cancel",
          () {
            Navigator.pop(context);
          },
          "Error",
          e.message ?? "Unknown error.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget createTitleRow(String title, BarcodeSortFields field) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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

  Widget createTitleRowNoSorting(String title) {
    return SizedBox(
      width: 200,
      child: Text(
        title,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      ),
    );
  }

  void onSortButtonPressed(BarcodeSortFields field) {
    if (sortFilter.field != field) {
      sortFilter = sortFilter.copyWith(field: field, sortType: SortType.asc);
    } else {
      if (sortFilter.sortType == SortType.asc) {
        sortFilter = sortFilter.copyWith(sortType: SortType.desc);
      } else if (sortFilter.sortType == SortType.desc) {
        sortFilter = BarcodeSortFilterWrapper.empty();
      }
    }
    sampleService.sortGlobalBarcodeList(sortFilter, barcodes);
    setState(() {});
  }

  Image getSortIcon(BarcodeSortFields field) {
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

  void showEditCropNameDialog(CropModel barcode) {
    final GlobalKey<FormState> formKey = GlobalKey();
    TextEditingController controller = TextEditingController();
    controller.text = barcode.name;
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    side: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: SizedBox(
                      width: 300,
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Enter new barcode name",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: TextFormField(
                                controller: controller,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Field can't be empty";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: TextButton(
                                onPressed: () {
                                  if (formKey.currentState != null && formKey.currentState!.validate()) {
                                    setState(() {
                                      barcode.name = controller.text;
                                    });
                                    sampleService.editCrop(barcode.id, barcode.name, barcode.isActive);
                                    Navigator.pop(context);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.appPrimaryGreen,
                                ),
                                child: const Text(
                                  "Submit",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
          );
        });
  }

  void assignBarcodes() async {
    bool? createdBarcode = await showDialog(
        context: context,
        builder: (context) {
          return const AssignBarcodesWidget();
        });
    if (createdBarcode ?? false) {
      await getBarcodes();
    }
  }

  void addNewBarcode() async {
    bool? createdBarcode = await showDialog(
        context: context,
        builder: (context) {
          return const AddNewBarcodeWidget();
        });
    if (createdBarcode ?? false) {
      await getBarcodes();
    }
  }

  void uploadAndProcessBarcodes() async {
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
        if (excel.tables.isNotEmpty) {
          var table = excel.tables.entries.first.value;
          var invalidBarcodesCount = 0;
          DateTime currentDate = DateTime.now();
          var rows = table.rows
              .skip(1)
              .map((row) {
                if (row.isNotEmpty) {
                  String? barcode;
                  if (row[0]!.value is SharedString || row[0]!.value is String) {
                    barcode = row[0]!.value.toString().trim();
                  }
                  var barcodeRegex = RegExp("[A-Z]{3}[0-9]{4}");
                  if (barcode != null && barcodeRegex.hasMatch(barcode)) {
                    return GlobalBarcodeListItemModel(
                        row[0]!.value.toString(), null, null, null, currentDate, null, null, [], false);
                  } else {
                    invalidBarcodesCount++;
                    return null;
                  }
                } else {
                  invalidBarcodesCount++;
                }
              })
              .where((element) => element != null)
              .map((e) => e!)
              .toList();
          var barcodeUploadInfo = await sampleService.uploadBarcodes(rows);
          await getBarcodes();
          if (mounted) {
            showOneButtonAlertDialog(context, "Ok", () {
              Navigator.pop(context);
            }, "Success",
                "Barcodes uploaded successfully.\n${table.rows.length - 1} total rows.\n${barcodeUploadInfo.newBarcodesCount} barcodes uploaded successfully.\n${barcodeUploadInfo.duplicatedBarcodesCount} duplicated barcodes.\n$invalidBarcodesCount invalid rows.");
          }
        }
      }
    } on FirebaseException {
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error uploading the data");
    } on Exception {
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error processing the file");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget getShippingWidget(GlobalBarcodeListItemModel item) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        item.shipping == true ? 'Yes' : 'No',
        textAlign: TextAlign.left,
      ),
    );
  }
}
