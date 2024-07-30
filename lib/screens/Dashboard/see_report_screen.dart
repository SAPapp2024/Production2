import 'dart:math';

import 'package:agro_k/models/company/admin_info_model.dart';
import 'package:agro_k/models/company/sample_model.dart';
import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/models/min_max_table_item_model.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const sampleDataRowWidth = 350.0;
const barRowWidth = 500.0;
const rowHeight = 100.0;
const labelWidth = 100.0;

class SeeReportScreenArguments {
  final SampleWithUserModel sampleWithUser;
  final AdminInfoModel adminInfo;

  const SeeReportScreenArguments({required this.sampleWithUser, required this.adminInfo});
}

class SeeReportScreen extends StatefulWidget {
  static const id = "/see_report";
  final SampleWithUserModel sampleWithUser;
  final AdminInfoModel adminInfo;

  const SeeReportScreen(
      {Key? key, required this.sampleWithUser, required this.adminInfo})
      : super(key: key);

  @override
  State<SeeReportScreen> createState() => _SeeReportScreenState();
}

class _SeeReportScreenState extends State<SeeReportScreen> {
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  Widget createRatioWidget(String title, String value1, String value2) {
    return Card(
        child: IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
            child: Column(
              children: [
                Text(value1,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(value2,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Flexible(
              child: VerticalDivider(
            color: Colors.black,
            width: 1,
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
            child: Text(title),
          )
        ],
      ),
    ));
  }

  Widget createSampleDataFieldItemWidget(
      {required String title, required String value, String? secondValue}) {
    Widget header = Container(
        color: Colors.green,
        width: 150,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.2)));
    return Container(
        child: secondValue != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  header,
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 8),
                      width: 150,
                      child: Text(value)),
                  Container(
                      alignment: Alignment.center,
                      width: 150,
                      child: Text(secondValue)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  header,
                  Container(
                      alignment: Alignment.center,
                      width: 150,
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(value))
                ],
              ));
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.sampleWithUser.sample.youngSampleMinerals == null ||
            widget.sampleWithUser.sample.youngSampleMinerals!.isEmpty) &&
        (widget.sampleWithUser.sample.oldSampleMinerals == null ||
            widget.sampleWithUser.sample.oldSampleMinerals!.isEmpty)) {
      return const Text("No sample tests");
    }
    var mineralKeys =
        widget.sampleWithUser.sample.youngSampleMinerals?.keys.toList() ??
            widget.sampleWithUser.sample.oldSampleMinerals!.keys.toList();
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
            title: const Text("Plant Sap Analysis"),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("images/agrokLogo.png"),
              )
            ],
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Scrollbar(
                controller: horizontalScrollController,
                child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: constraints.copyWith(
                          minWidth: 1200,
                          maxWidth: max(1200, constraints.maxWidth)),
                      child: Scrollbar(
                        controller: verticalScrollController,
                        child: SingleChildScrollView(
                          controller: verticalScrollController,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 1200,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Card(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(4))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            createSampleDataFieldItemWidget(
                                                title: "Sampling date",
                                                value: widget.sampleWithUser
                                                            .sample.sampleDate !=
                                                        null
                                                    ? DateFormat.yMd().format(
                                                        widget.sampleWithUser
                                                            .sample.sampleDate!)
                                                    : "-"),
                                            createSampleDataFieldItemWidget(
                                                title: "Crop",
                                                value: widget
                                                    .sampleWithUser.sample.crop),
                                            createSampleDataFieldItemWidget(
                                                title: "Location/plot",
                                                value: widget.sampleWithUser
                                                    .sample.farm),
                                            createSampleDataFieldItemWidget(
                                                title: "Cultivation",
                                                value: widget.sampleWithUser
                                                    .sample.field),
                                            createSampleDataFieldItemWidget(
                                              title: "Barcode",
                                              value: widget.sampleWithUser.sample
                                                      .youngSampleBarcode ??
                                                  "-",
                                              secondValue: widget.sampleWithUser
                                                      .sample.oldSampleBarcode ??
                                                  "-",
                                            ),
                                            createSampleDataFieldItemWidget(
                                                title: "Sample Number",
                                                value: widget
                                                    .sampleWithUser.sample.id),
                                            createSampleDataFieldItemWidget(
                                              title: "Plant Part",
                                              value: "Untreated",
                                              secondValue: "Treated",
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                                createRatioWidget("K/Ca ratio", "3.5", "5.5"),
                                createRatioWidget("Tot. N is NO3", "302%", "74%"),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 32.0, right: 32.0, bottom: 32.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Card(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4))),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 16.0),
                                          child: Column(
                                            children: [
                                              tableHeader(),
                                              ...mineralKeys.map((mineral) {
                                                MinMaxTableItemModel?
                                                    minMaxTableItem = widget
                                                        .adminInfo
                                                        .mineralMinMaxTable
                                                        .firstWhereOrNull(
                                                            (element) =>
                                                                element.crop ==
                                                                    widget
                                                                        .sampleWithUser
                                                                        .sample
                                                                        .crop &&
                                                                element.mineral ==
                                                                    mineral);
                                                if (minMaxTableItem == null) {
                                                  return Container();
                                                }
                                                return Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const SizedBox(
                                                        width:
                                                            sampleDataRowWidth +
                                                                barRowWidth +
                                                                16,
                                                        child: Divider(
                                                          color: Colors.grey,
                                                          thickness: 2,
                                                          height: 2,
                                                        )),
                                                    SampleMineralTestBarChart(
                                                        sample: widget
                                                            .sampleWithUser
                                                            .sample,
                                                        minMaxTableItem:
                                                            minMaxTableItem,
                                                        mineral: mineral),
                                                  ],
                                                );
                                              }).toList()
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
              );
            },
          )),
    );
  }

  Widget tableHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)),
      child: Container(
        width: sampleDataRowWidth + barRowWidth + 16,
        color: Colors.green,
        padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: sampleDataRowWidth,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Mineral",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.2),
                        )),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: labelWidth,
                    child: const Text(
                      "Plant part",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.2),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: labelWidth,
                    child: const Text(
                      "Result",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: barRowWidth,
              child: Row(
                children: [
                  Container(
                    width: barRowWidth / 3,
                    alignment: Alignment.center,
                    child: const Text(
                      "Deficient",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.2),
                    ),
                  ),
                  Container(
                    width: barRowWidth / 3,
                    alignment: Alignment.center,
                    child: const Text(
                      "Optimum",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.2),
                    ),
                  ),
                  Container(
                    width: barRowWidth / 3,
                    alignment: Alignment.center,
                    child: const Text(
                      "Excessive",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SampleMineralTestBarChart extends StatelessWidget {
  final SampleModel sample;
  final MinMaxTableItemModel minMaxTableItem;
  final String mineral;

  const SampleMineralTestBarChart(
      {Key? key,
      required this.sample,
      required this.minMaxTableItem,
      required this.mineral})
      : super(key: key);

  Widget createSampleMineralBarChartSingleBar({required bool isYoungSample}) {
    double sampleValue;
    if (isYoungSample && sample.youngSampleMinerals?[mineral] != null) {
      sampleValue = sample.youngSampleMinerals![mineral];
    } else if (!isYoungSample && sample.oldSampleMinerals?[mineral] != null) {
      sampleValue = sample.oldSampleMinerals![mineral];
    } else {
      return Container();
    }
    double optimumMin = minMaxTableItem.optimumMin;
    double optimumMax = minMaxTableItem.optimumMax;
    double rangeMax = minMaxTableItem.rangeMax;
    double barWidth;
    if (sampleValue < optimumMin) {
      barWidth = sampleValue * (barRowWidth / 3) / optimumMin;
    } else if (sampleValue >= optimumMin && sampleValue <= optimumMax) {
      barWidth = (barRowWidth / 3) +
          ((sampleValue - optimumMin) *
              (barRowWidth / 3) /
              (optimumMax - optimumMin));
    } else {
      barWidth = (2 * barRowWidth / 3) +
          ((sampleValue - optimumMax) *
              (barRowWidth / 3) /
              (rangeMax - optimumMax));
    }
    return Container(
      width: barWidth,
      height: rowHeight / 2,
      color: isYoungSample ? Colors.blue : Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: sampleDataRowWidth,
            height: rowHeight,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    mineral,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: labelWidth,
                  child: Column(
                    children: [
                      Container(
                          height: rowHeight / 2,
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Leaf (young)",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          )),
                      Container(
                          height: rowHeight / 2,
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Leaf (old)",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  width: labelWidth,
                  child: Column(
                    children: [
                      Container(
                          height: rowHeight / 2,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            sample.youngSampleMinerals?[mineral].toString() ??
                                "-",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          )),
                      Container(
                          height: rowHeight / 2,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            sample.oldSampleMinerals?[mineral].toString() ??
                                "-",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: barRowWidth,
            height: rowHeight,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: rowHeight / 2,
                      child: createSampleMineralBarChartSingleBar(
                          isYoungSample: true),
                    ),
                    SizedBox(
                      height: rowHeight / 2,
                      child: createSampleMineralBarChartSingleBar(
                          isYoungSample: false),
                    )
                  ],
                ),
                Positioned(
                    left: (barRowWidth / 3) - (labelWidth / 2.0),
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: labelWidth,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const VerticalDivider(
                            color: Colors.black,
                          ),
                          Card(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              elevation: 4,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                    minMaxTableItem.optimumMin.toString(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ))
                        ],
                      ),
                    )),
                Positioned(
                    left: (2 * barRowWidth / 3) - (labelWidth / 2.0),
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: labelWidth,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const VerticalDivider(
                            color: Colors.black,
                          ),
                          Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            elevation: 4,
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(4.0),
                              child: Text(minMaxTableItem.optimumMax.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          )
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
