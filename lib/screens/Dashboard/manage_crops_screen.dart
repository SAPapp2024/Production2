import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/components/add_new_crop_widget.dart';
import 'package:agro_k/models/crop_model.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/file_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/sample_sorting.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../components/clear_icon_widget.dart';

class ManageCropsScreen extends StatefulWidget {
  static const String id = '/manage_crops';
  const ManageCropsScreen({Key? key}) : super(key: key);

  @override
  State<ManageCropsScreen> createState() => _ManageCropsScreenState();
}

class _ManageCropsScreenState extends State<ManageCropsScreen> {
  List<CropModel> crops = [];
  bool isLoading = false;
  SampleService sampleService = getIt.get();
  int topListNum = 0;
  int endListNum = 0;
  int entriesSelected = 25;
  int dashboardPageNum = 1;
  int totalEntries = 25; // we need to update count
  List<String> cropStatusList = ["Active", "Inactive"];

  final TextEditingController _searchCropId =
  TextEditingController();
  final TextEditingController _searchCropName =
  TextEditingController();
  final TextEditingController _searchCropStatus =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    getCrops();
  }

  Future<void> getCrops() async {
    List<CropModel> crops = await sampleService.getCrops();
    setState(() {
      this.crops = crops;
    });
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
          title: const Text("Manage Crops"),
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
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                                onPressed: () {
                                  uploadAndProcessCrops();
                                },
                                child: const Text("Upload crops")),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                                onPressed: () {
                                  addNewCrop();
                                },
                                child: const Text("Add new crop")),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 1200,
                        child: Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                side: BorderSide(
                                    color: AppColors.cardBorder, width: 1.0)),
                            child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: createCropTable(context))),
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

  void uploadAndProcessCrops() async {
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
          var rows = table.rows
              .skip(1)
              .map((row) {
                if (row.length == 3) {
                  String id = const Uuid().v4();
                  String name = row[1]!.value.toString();
                  bool isActive =
                      row[2]!.value.toString() == "-1" ? true : false;
                  return CropModel(id: id, name: name, isActive: isActive);
                } else {
                  return null;
                }
              })
              .where((element) => element != null)
              .map((e) => e!)
              .toList();
          await sampleService.uploadCrops(rows);
          await getCrops();
          if (mounted) {
            showOneButtonAlertDialog(context, "Ok", () {
              Navigator.pop(context);
            }, "Success", "Crops uploaded successfully");
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
    totalEntries = crops.length;
    if (endListNum > crops.length) {
      endListNum = crops.length;
    }
    var data = crops.sublist(topListNum, endListNum);
    return Column(
      children: [
        Row(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "CROP DASHBOARD",
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
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () {
                  searchCrops();
                },
                child: const Text("Apply")),
            const SizedBox(
              width: 15,
            ),
            ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () {
                  _searchCropId.text = "";
                  _searchCropName.text = "";
                  _searchCropStatus.text = "";
                  setState(() {
                    sortFilter =
                        CropSortFilterWrapper
                            .empty();
                  });
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
                    await generateCropsExcelFile(
                        crops);
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
        Theme(
            data: Theme.of(context)
                .copyWith(dividerColor: AppColors.hintTextColor),
            child: Align(
              alignment: Alignment.centerLeft,
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
                                  child: createTitleRow("ID",
                                      CropSortFields.id)),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  onFieldSubmitted: (_) => searchCrops(),
                                  decoration: InputDecoration(
                                    hintText: "Search Crop ID",
                                    hintStyle: const TextStyle(color: AppColors.hintTextColor),
                                    border: const OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: AppColors.hintTextColor)),
                                    isDense: true,
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    suffixIcon: ClearIcon(_searchCropId, () {
                                            searchCrops();
                                           })
                                  ),
                                  controller: _searchCropId,
                                ),
                              )
                            ],
                          ),
                        ),),
                    DataColumn(
                      label: Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: createTitleRow("Name (click to edit)",
                                    CropSortFields.name)),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: TextFormField(
                                onFieldSubmitted: (_) => searchCrops(),
                                decoration: InputDecoration(
                                  hintText: "Search Crop Name",
                                  hintStyle: const TextStyle(color: AppColors.hintTextColor),
                                  border: const OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: AppColors.hintTextColor)),
                                  isDense: true,
                                  contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  suffixIcon: ClearIcon(_searchCropName, () {
                                            searchCrops();
                                           })
                                ),
                                controller: _searchCropName,
                              ),
                            )
                          ],
                        ),
                      ),),
                    DataColumn(
                      label: Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: createTitleRow("Status",
                                    CropSortFields.status)),
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
                                          value: !["Active", "Inactive"]
                                              .contains(_searchCropStatus.text)
                                              ? null
                                              : _searchCropStatus.text,
                                          isDense: true,
                                          onChanged: (newValue) async {
                                            String? newStatus = newValue;
                                            if (newStatus != null) {
                                              setState(() {
                                                _searchCropStatus.text = newStatus;
                                              });
                                            }
                                          },
                                          items: [
                                            "",
                                            ...["Active", "Inactive"]
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
                      ),),
                  ],
                  rows: data
                      .mapIndexed(
                        (index, e) => DataRow.byIndex(
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
                              DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(e.id),
                                  ),),
                              DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(e.name),
                                  ), onTap: () {
                                showEditCropNameDialog(e);
                              }),
                              DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: FormField<String>(
                                      builder: (FormFieldState<String> state) {
                                        return DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: e.isActive
                                                ? "Active"
                                                : "Inactive",
                                            isDense: true,
                                            onChanged: (newValue) async {
                                              bool newIsActive =
                                                  newValue == "Active"
                                                      ? true
                                                      : false;
                                              try {
                                                setState(() {
                                                  e.isActive = newIsActive;
                                                });
                                                await sampleService
                                                    .editCrop(e.id, e.name,
                                                        newIsActive);
                                              } catch (exception, stacktrace) {
                                                getIt.get<RemoteErrorLoggingService>()
                                                    .recordError(exception, stacktrace);
                                              }
                                            },
                                            items: cropStatusList
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
                                  ),),
                            ]),
                      )
                      .toList()),
            )),
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
                onPressed: dashboardPageNum * entriesSelected < crops.length
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

  Future searchCrops() async {
    try {
      crops = await sampleService.searchCrops(
          _searchCropId.text,
          _searchCropName.text,
          _searchCropStatus.text == "Active" ? true : _searchCropStatus.text == "Inactive" ? false : null,
          sortFilter);
      setState(() {
        crops;
      });
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>()
          .recordError(exception, stacktrace);
      showTwoButtonAlertDialog(
          context,
          "Try again",
              () {
            Navigator.pop(context);
            searchCrops();
          },
          "Cancel",
              () {
            Navigator.pop(context);
          },
          "Error",
          exception.message ?? "Unknown error.");
    }
  }

  Widget createTitleRow(String title, CropSortFields field) {
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

  void onSortButtonPressed(CropSortFields field) {
    if (sortFilter.field != field) {
      sortFilter = sortFilter.copyWith(field: field, sortType: SortType.asc);
    } else {
      if (sortFilter.sortType == SortType.asc) {
        sortFilter = sortFilter.copyWith(sortType: SortType.desc);
      } else if (sortFilter.sortType == SortType.desc) {
        sortFilter = CropSortFilterWrapper.empty();
      }
    }
    sampleService.sortCropList(sortFilter, crops);
    setState(() {});
  }

  CropSortFilterWrapper sortFilter = CropSortFilterWrapper.empty();

  Image getSortIcon(CropSortFields field) {
    String imagePath;
    if (sortFilter.field != field ||
        sortFilter.sortType == SortType.none) {
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

  void showEditCropNameDialog(CropModel crop) {
    final GlobalKey<FormState> formKey = GlobalKey();
    TextEditingController controller = TextEditingController();
    controller.text = crop.name;
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
                            const Text("Enter new crop name",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
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
                                  if (formKey.currentState != null &&
                                  formKey.currentState!.validate()) {
                                    setState(() {
                                      crop.name = controller.text;
                                    });
                                    sampleService.editCrop(
                                        crop.id, crop.name, crop.isActive);
                                    Navigator.pop(context);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: AppColors.appPrimaryGreen,
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

  void addNewCrop() async {
    bool? createdCrop = await showDialog(
        context: context,
        builder: (context) {
          return const AddNewCropWidget();
        });
    if (createdCrop ?? false) {
      await getCrops();
    }
  }
}
