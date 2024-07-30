import 'package:agro_k/app/routes.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportScreen extends StatefulWidget {
  static const String id = '/report';

  const ReportScreen({Key? key}) : super(key: key);

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  String sampleNumber = "202111031201";
  String sampleDate = "11-01-2021";
  String locationPlot = "Farm 016";
  String cultivation = "AK FRI";
  String crop = "Tree C";
  String variety = "";
  String plantPart = "Leaf (young)";
  String sampleType = "Plant sap";
  String barcode = "VF-0095";
  String status = "Complete";

  bool sepAnalysisSelected = true;
  List<String> sepAnalysisImages = [
    "images/sap1.png",
    "images/sap1.png",
    "images/sap1.png",
    "images/sap1.png",
    "images/sap1.png",
    "images/sap1.png",
    "images/sap1.png"
  ];
  bool graphsSelected = false;
  List<String> graphsImages = [
    "images/sapReport.png",
    "images/sapReport.png",
    "images/sapReport.png"
  ];
  bool nccReportSelected = false;
  List<String> nccImages = ["images/sap1.png"];
  bool minMaxReport = false;
  List<String> minMaxImages = ["images/sapReport.png", "images/sapReport.png"];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ReportScreenArguments args =
        ModalRoute.of(context)!.settings.arguments as ReportScreenArguments;

    String productName = args.productName;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return WillPopScope(
      onWillPop: () async => false,
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
            title: Text(productName),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Sample Number",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      sampleNumber,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Sampling Date",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      sampleDate,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Farm",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      locationPlot,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Field",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      cultivation,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Crop",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      crop,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Variety",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      variety,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Plant Part",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      plantPart,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Sample Type",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      sampleType,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Barcode",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      barcode,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Status",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      status,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                sepAnalysisSelected = true;
                                graphsSelected = false;
                                nccReportSelected = false;
                                minMaxReport = false;
                              });
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: sepAnalysisSelected
                                    ? Colors.white
                                    : AppColors.appPrimaryGreen,
                                backgroundColor: sepAnalysisSelected
                                    ? AppColors.appPrimaryGreen
                                    : Colors.white),
                            child: const Text("Sep Analysis")),
                        const Expanded(child: SizedBox()),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                sepAnalysisSelected = false;
                                graphsSelected = true;
                                nccReportSelected = false;
                                minMaxReport = false;
                              });
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: graphsSelected
                                    ? Colors.white
                                    : AppColors.appPrimaryGreen,
                                backgroundColor: graphsSelected
                                    ? AppColors.appPrimaryGreen
                                    : Colors.white),
                            child: const Text("Graphs")),
                        const Expanded(child: SizedBox()),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                sepAnalysisSelected = false;
                                graphsSelected = false;
                                nccReportSelected = true;
                                minMaxReport = false;
                              });
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: nccReportSelected
                                    ? Colors.white
                                    : AppColors.appPrimaryGreen,
                                backgroundColor: nccReportSelected
                                    ? AppColors.appPrimaryGreen
                                    : Colors.white),
                            child: const Text("NCC Report")),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            sepAnalysisSelected = false;
                            graphsSelected = false;
                            nccReportSelected = false;
                            minMaxReport = true;
                          });
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: minMaxReport
                                ? Colors.white
                                : AppColors.appPrimaryGreen,
                            backgroundColor: minMaxReport
                                ? AppColors.appPrimaryGreen
                                : Colors.white),
                        child: const Text("Min / Max")),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                //pictures below
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: sepAnalysisSelected == true
                        ? sepAnalysisImages.length
                        : graphsSelected == true
                            ? graphsImages.length
                            : nccReportSelected == true
                                ? nccImages.length
                                : minMaxImages.length,
                    itemBuilder: (BuildContext ctxt, int index) =>
                        Center(child: createImageViews(context, index)))
              ],
            ),
          ))),
    );
  }

  Widget createImageViews(BuildContext context, int index) {
    List<String> images = [];

    if (sepAnalysisSelected) {
      images = sepAnalysisImages;
    } else if (graphsSelected) {
      images = graphsImages;
    } else if (nccReportSelected) {
      images = nccImages;
    } else {
      images = minMaxImages;
    }

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Image.asset(images[index])
      ],
    );
  }
}
