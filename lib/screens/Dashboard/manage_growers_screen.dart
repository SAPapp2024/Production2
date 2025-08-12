import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/add_new_grower_widget.dart';
import 'package:agro_k/components/user_notifications_for_grower_dialog.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/grower_with_user_emails_to_notify_model.dart';
import 'package:agro_k/models/crop_model.dart';
import 'package:agro_k/models/user/user_model.dart';
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

import '../../components/clear_icon_widget.dart';

class ManageGrowersScreenArguments {
  final CompanyModel farm;

  const ManageGrowersScreenArguments({Key? key, required this.farm});
}

class ManageGrowersScreen extends StatefulWidget {
  static const String id = '/manage_growers';
  final UserModel user;
  final CompanyModel farm;

  const ManageGrowersScreen({Key? key, required this.user, required this.farm})
      : super(key: key);

  @override
  State<ManageGrowersScreen> createState() => _ManageGrowersScreenState();
}

class _ManageGrowersScreenState extends State<ManageGrowersScreen> {
  List<GrowerWithUserEmailsToNotifyModel> growers = [];
  bool isLoading = false;
  SampleService sampleService = getIt.get();
  UserState userState = getIt.get();
  int topListNum = 0;
  int endListNum = 0;
  int entriesSelected = 25;
  int dashboardPageNum = 1;
  int totalEntries = 25; // we need to update count

  final TextEditingController _searchGrowerValue = TextEditingController();

  @override
  void initState() {
    super.initState();

    getGrowers();
  }

  Future<void> getGrowers() async {
    try {
      setState(() {
        isLoading = true;
      });
      await searchGrowers();
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            getGrowers();
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
          title: const Text("Manage Growers"),
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
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        AppColors.appPrimaryGreen)),
                                onPressed: () {
                                  uploadAndProcessGrowers();
                                },
                                child: const Text("Upload growers")),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        AppColors.appPrimaryGreen)),
                                onPressed: () {
                                  addOrEditNewGrower(null);
                                },
                                child: const Text("Add new grower")),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 1200,
                        child: Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
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
    totalEntries = growers.length;
    if (endListNum > growers.length) {
      endListNum = growers.length;
    }
    var data = growers.sublist(topListNum, endListNum);
    return Column(
      children: [
        Row(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "GROWER DASHBOARD",
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
                  getGrowers();
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
                  _searchGrowerValue.text = "";
                  setState(() {
                    sortType = SortType.none;
                  });
                  getGrowers();
                },
                child: const Text("Clear Filters")),
            const SizedBox(
              width: 35,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(AppColors.appPrimaryGreen)),
                onPressed: () async {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    await generateGrowersExcelFile(growers);
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                child: const Text("Download Report")),
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
                  dataRowHeight: 50,
                  headingRowHeight: 100,
                  showBottomBorder: true,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: 200,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: createTitleRow("Grower")),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: TextFormField(
                                onFieldSubmitted: (_) => getGrowers(),
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
                                    suffixIcon:
                                        ClearIcon(_searchGrowerValue, () {
                                      getGrowers();
                                    })),
                                controller: _searchGrowerValue,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: SizedBox(
                        width: 200,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 200,
                              child: Text(
                                "Notifications",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                    ),
                    const DataColumn(
                      label: SizedBox(
                        width: 200,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 200,
                              child: Text(
                                "Edit",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                    ),
                    const DataColumn(
                      label: SizedBox(
                        width: 200,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 200,
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                    ),
                  ],
                  rows: data
                      .mapIndexed(
                        (index, e) => DataRow.byIndex(
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
                            cells: [
                              DataCell(
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(e.grower),
                                ),
                              ),
                              DataCell(
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () async {
                                      var shouldRebuild = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return UserNotificationsForGrowerDialog(growerWithUserEmailsToNotifyModel: e,);
                                          }) ?? false;
                                      if (shouldRebuild) {
                                        setState(() {});
                                      }
                                    },
                                    child: const Text("See users"),
                                  ),
                                ),
                              ),
                              DataCell(
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    onPressed: () {
                                      addOrEditNewGrower(e.grower);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                ),
                              ),
                              DataCell(
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    onPressed: () {
                                      showTwoButtonAlertDialog(
                                          context,
                                          "Yes",
                                          () async {
                                            await sampleService.deleteGrower(
                                                e.grower, widget.farm);
                                            await getGrowers();
                                            if (!mounted) return;
                                            Navigator.pop(context);
                                          },
                                          "No",
                                          () {
                                            Navigator.pop(context);
                                          },
                                          "Delete grower",
                                          "Are you sure you want to delete grower \"${e.grower}\"");
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ),
                              ),
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
                onPressed: dashboardPageNum * entriesSelected < growers.length
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

  Future searchGrowers() async {
    try {
      growers = await sampleService.searchGrowers(
          _searchGrowerValue.text, sortType, widget.farm);
      setState(() {});
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            getGrowers();
          },
          "Cancel",
          () {
            Navigator.pop(context);
          },
          "Error",
          exception.message ?? "Unknown error.");
    }
  }

  Widget createTitleRow(String title) {
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
            onTap: () => onSortButtonPressed(),
            child: getSortIcon(),
          ),
        ],
      ),
    );
  }

  void onSortButtonPressed() {
    if (sortType == SortType.asc) {
      sortType = SortType.desc;
    } else if (sortType == SortType.desc) {
      sortType = SortType.none;
    } else {
      sortType = SortType.asc;
    }
    setState(() {});
    getGrowers();
  }

  SortType sortType = SortType.none;

  Image getSortIcon() {
    String imagePath;
    if (sortType == SortType.none) {
      imagePath = "images/imgSortArrowsBothDisabled.png";
    } else {
      if (sortType == SortType.asc) {
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

  void showEditCropNameDialog(CropModel grower) {
    final GlobalKey<FormState> formKey = GlobalKey();
    TextEditingController controller = TextEditingController();
    controller.text = grower.name;
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
                            const Text("Enter new grower name",
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
                                      grower.name = controller.text;
                                    });
                                    sampleService.editCrop(grower.id,
                                        grower.name, grower.isActive);
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

  void addOrEditNewGrower(String? grower) async {
    String? createdGrower = await showDialog(
        context: context,
        builder: (context) {
          return AddNewGrowerWidget(
            farm: widget.farm,
            grower: grower,
          );
        });
    if (createdGrower != null) {
      getGrowers();
    }
  }

  void uploadAndProcessGrowers() async {
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
              .map((row) {
                if (row.length == 1) {
                  String? grower;
                  if (row[0]!.value is SharedString ||
                      row[0]!.value is String) {
                    grower = row[0]!.value.toString().trim();
                  }
                  return grower;
                }
              })
              .where((element) => element != null)
              .map((e) => e!)
              .toList();
          await sampleService.uploadGrowers(rows, widget.farm);
          await getGrowers();
          if (mounted) {
            showOneButtonAlertDialog(context, "Ok", () {
              Navigator.pop(context);
            }, "Success", "Growers uploaded successfully");
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
}
