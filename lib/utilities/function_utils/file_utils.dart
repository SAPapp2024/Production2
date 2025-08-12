import 'dart:io';

import 'package:agro_k/models/crop_model.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/grower_with_user_emails_to_notify_model.dart';
import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/models/global_barcode_list_item_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/NewSample/company_samples_screen.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/function_utils/pdf_widget.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

pw.Page createPdfPage(
    SampleWithUserModel sample,
    String companyName,
    bool youngSample,
    Uint8List firstImage,
    Uint8List secondImage,
    Uint8List checkedImage,
    Uint8List uncheckedImage) {
  return pw.Page(
      pageFormat: PdfPageFormat.a3,
      build: (pw.Context context) {
        return pw.Container(
            width: double.infinity,
            child: pw.Column(children: [
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(pw.MemoryImage(firstImage),
                        width: 560 / 1.5,
                        height: 86 / 1.5,
                        fit: pw.BoxFit.fill),
                    pw.Image(pw.MemoryImage(secondImage),
                        width: 366 / 1.5,
                        height: 148 / 1.5,
                        fit: pw.BoxFit.fill)
                  ]),
              youngSample && sample.sample.youngSampleBarcode != null ||
                  !youngSample && sample.sample.oldSampleBarcode != null
                  ? pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 32),
                  child: pw.BarcodeWidget(
                      data: youngSample &&
                          sample.sample.youngSampleBarcode != null
                          ? sample.sample.youngSampleBarcode!
                          : sample.sample.oldSampleBarcode!,
                      barcode: pw.Barcode.code128(),
                      textStyle: const pw.TextStyle(fontSize: 16),
                      drawText: true,
                      width: (barcodeHeight * 3 * 2),
                      height: (barcodeHeight * 2) + 16))
                  : Container(),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 32, right: 16),
                    child: pw.Text("Sample date:",
                        style: const pw.TextStyle(
                          fontSize: 16,
                        ))),
              ),
              pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Padding(
                      padding: const pw.EdgeInsets.only(
                          bottom: 32, top: 16, right: 16),
                      child:
                      pw.Stack(alignment: Alignment.bottomRight, children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.only(bottom: 8),
                          width: 200,
                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom: pw.BorderSide(
                                      style: pw.BorderStyle.dashed))),
                        ),
                        sample.sample.sampleDate != null
                            ? pw.Text(
                            DateFormat.yMd()
                                .format(sample.sample.sampleDate!),
                            style: const pw.TextStyle(
                              fontSize: 22,
                            ))
                            : pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 32),
                            child: pw.Container(
                              height: 1,
                              width: double.infinity,
                            ))
                      ]))),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                width: double.infinity,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Company:",
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.Expanded(
                        child: pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 8),
                            child: pw.Container(
                                padding:
                                const pw.EdgeInsets.only(top: 8, left: 54),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                            style: pw.BorderStyle.dashed))),
                                child: pw.Text(
                                  "Company",
                                  style: const pw.TextStyle(
                                    fontSize: 22,
                                  ),
                                ))))
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                // color: const PdfColor(0.2, 0.1, 0.4),
                width: double.infinity,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Grower:", style: const pw.TextStyle(fontSize: 16)),
                    pw.Expanded(
                        child: pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 8),
                            child: pw.Container(
                                padding:
                                const pw.EdgeInsets.only(top: 8, left: 75),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                            style: pw.BorderStyle.dashed))),
                                child: pw.Text(
                                  sample.sample.grower ?? "-",
                                  style: const pw.TextStyle(
                                    fontSize: 22,
                                  ),
                                ))))
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                // color: const PdfColor(0.2, 0.1, 0.4),
                width: double.infinity,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Farm (location):",
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.Expanded(
                        child: pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 8),
                            child: pw.Container(
                                padding:
                                const pw.EdgeInsets.only(top: 8, left: 32),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                            style: pw.BorderStyle.dashed))),
                                child: pw.Text(
                                  sample.sample.farm,
                                  style: const pw.TextStyle(
                                    fontSize: 22,
                                  ),
                                ))))
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                // color: const PdfColor(0.2, 0.1, 0.4),
                width: double.infinity,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Field (cultivation):",
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.Expanded(
                        child: pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 8),
                            child: pw.Container(
                                padding:
                                const pw.EdgeInsets.only(top: 8, left: 50),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                            style: pw.BorderStyle.dashed))),
                                child: pw.Text(
                                  sample.sample.field,
                                  style: const pw.TextStyle(
                                    fontSize: 22,
                                  ),
                                ))))
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                // color: const PdfColor(0.2, 0.1, 0.4),
                width: double.infinity,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Crop:", style: const pw.TextStyle(fontSize: 16)),
                    pw.Expanded(
                        child: pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 8),
                            child: pw.Container(
                                padding:
                                const pw.EdgeInsets.only(top: 8, left: 35),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                            style: pw.BorderStyle.dashed))),
                                child: pw.Text(
                                  sample.sample.crop,
                                  style: const pw.TextStyle(
                                    fontSize: 22,
                                  ),
                                ))))
                  ],
                ),
              ),
              pw.Container(
                padding: pw.EdgeInsets.only(
                    top: (sample.sample.variety?.isEmpty ?? true) ? 32 : 16),
                // color: const PdfColor(0.2, 0.1, 0.4),
                width: double.infinity,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Variety:",
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.Expanded(
                        child: pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 8),
                            child: pw.Container(
                                padding:
                                const pw.EdgeInsets.only(top: 8, left: 35),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                            style: pw.BorderStyle.dashed))),
                                child: pw.Text(
                                  sample.sample.variety ?? "",
                                  style: const pw.TextStyle(
                                    fontSize: 22,
                                  ),
                                ))))
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 32),
                width: double.infinity,
                child: pw.Row(
                  children: [
                    pw.Text("Analysis:",
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(width: 22),
                    pw.Flexible(
                        flex: 1,
                        child: pw.Row(children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 16),
                            child: pw.Image(pw.MemoryImage(checkedImage),
                                width: 124 / 4.0,
                                height: 124 / 4.0,
                                fit: pw.BoxFit.fill),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 2),
                            child: pw.Text("Plant sap",
                                style: const pw.TextStyle(fontSize: 16)),
                          ),
                        ])),
                    pw.Flexible(
                        flex: 1,
                        child: pw.Row(children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 16),
                            child: pw.Image(pw.MemoryImage(uncheckedImage),
                                width: 124 / 4.0,
                                height: 124 / 4.0,
                                fit: pw.BoxFit.fill),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 2),
                            child: pw.Text("Drain water",
                                style: const pw.TextStyle(fontSize: 16)),
                          ),
                        ])),
                    pw.Flexible(
                        flex: 1,
                        child: pw.Row(children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 16),
                            child: pw.Image(pw.MemoryImage(uncheckedImage),
                                width: 124 / 4.0,
                                height: 124 / 4.0,
                                fit: pw.BoxFit.fill),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 2),
                            child: pw.Text("Irrigation water",
                                style: const pw.TextStyle(fontSize: 16)),
                          ),
                        ])),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                // color: const PdfColor(0.2, 0.1, 0.4),
                width: double.infinity,
                child: pw.Row(
                  children: [
                    pw.Text("Leaf type:",
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(width: 16),
                    pw.Flexible(
                      flex: 1,
                      child: pw.Row(children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 16),
                          child: pw.Image(
                              pw.MemoryImage(
                                  youngSample ? checkedImage : uncheckedImage),
                              width: 124 / 4.0,
                              height: 124 / 4.0,
                              fit: pw.BoxFit.fill),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 2),
                          child: pw.Text("Leaf (young)",
                              style: const pw.TextStyle(fontSize: 16)),
                        ),
                      ]),
                    ),
                    pw.Flexible(
                        flex: 1,
                        child: pw.Row(children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 16),
                            child: pw.Image(
                                pw.MemoryImage(youngSample
                                    ? uncheckedImage
                                    : checkedImage),
                                width: 124 / 4.0,
                                height: 124 / 4.0,
                                fit: pw.BoxFit.fill),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 2),
                            child: pw.Text("Leaf (old)",
                                style: const pw.TextStyle(fontSize: 16)),
                          ),
                        ])),
                    pw.Flexible(flex: 1, child: pw.Spacer())
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                // color: const PdfColor(0.2, 0.1, 0.4),
                width: double.infinity,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Treatment:",
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.Expanded(
                        child: pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 8),
                            child: pw.Container(
                                padding:
                                const pw.EdgeInsets.only(top: 8, left: 35),
                                decoration: const pw.BoxDecoration(
                                    border: pw.Border(
                                        bottom: pw.BorderSide(
                                            style: pw.BorderStyle.dashed))),
                                child: pw.Text(
                                  sample.sample.treatment ?? "",
                                  style: const pw.TextStyle(
                                    fontSize: 22,
                                  ),
                                ))))
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                // color: const PdfColor(0.2, 0.1, 0.4),
                width: double.infinity,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 12),
                        child: pw.Text("Notes:",
                            style: const pw.TextStyle(fontSize: 16))),
                    pw.Expanded(
                        child: pw.Container(
                            padding: const pw.EdgeInsets.only(left: 8),
                            child: pw.Stack(children: [
                              pw.Container(
                                padding:
                                const pw.EdgeInsets.only(top: 3, bottom: 1),
                                child: pw.Text(
                                  sample.sample.notes,
                                  style: const pw.TextStyle(fontSize: 22),
                                ),
                              ),
                              pw.Column(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  ...List.generate(
                                    4,
                                        (index) => pw.Column(
                                      mainAxisSize: pw.MainAxisSize.min,
                                      children: [
                                        pw.SizedBox(height: 24),
                                        pw.Container(
                                            height: 1,
                                            width: double.infinity,
                                            decoration: const pw.BoxDecoration(
                                                border: pw.Border(
                                                    bottom: pw.BorderSide(
                                                        style: pw.BorderStyle
                                                            .dashed))))
                                      ],
                                    ),
                                  ),
                                  pw.SizedBox(height: 1)
                                  //Without this, the last notes line dash looks weird
                                ],
                              ),
                            ])))
                  ],
                ),
              ),
              pw.Expanded(
                  child: pw.Align(
                      alignment: pw.Alignment.bottomLeft,
                      child: pw.Text(
                          "Created: ${DateFormat.yMd().format(sample.sample.createdDate)}",
                          style:
                          const pw.TextStyle(fontSize: 16, height: 1.4))))
            ]) // Center
        );
      });
}

class SampleDocumentWrapper {
  final SampleWithUserModel sample;
  final bool isYoung;

  SampleDocumentWrapper(this.sample, this.isYoung);
}

Future<pw.Document> createMergedSamplesPdf(List<SampleWithUserModel> samples,
    String companyName, MergeSamplesOptions option) async {
  debugPrint("FUNCTION STARTED");
  var arial = pw.Font.ttf(await rootBundle.load("fonts/Arial-Regular.ttf"));
  var calibri = pw.Font.ttf(await rootBundle.load("fonts/Calibri-Regular.ttf"));
  final pw.ThemeData theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(), fontFallback: [calibri, arial]);
  final pdf = pw.Document(theme: theme);
  final firstImage =
  (await rootBundle.load("images/1.png")).buffer.asUint8List();
  final secondImage =
  (await rootBundle.load("images/2.png")).buffer.asUint8List();
  final checkedImage = (await rootBundle.load("images/pdfCheckboxChecked.png"))
      .buffer
      .asUint8List();
  final uncheckedImage =
  (await rootBundle.load("images/pdfCheckboxUnchecked.png"))
      .buffer
      .asUint8List();
  double verticalMargin = 1.6 * PdfPageFormat.cm;
  double horizontalMargin = 1.1 * PdfPageFormat.cm;
  final pageWidth = PdfPageFormat.a4.width - 2 * horizontalMargin;
  List<SampleDocumentWrapper> sampleList = [];
  for (var sample in samples) {
    if (sample.sample.youngSampleBarcode != null) {
      sampleList.add(SampleDocumentWrapper(sample, true));
    }
    if (sample.sample.oldSampleBarcode != null) {
      sampleList.add(SampleDocumentWrapper(sample, false));
    }
  }
  Iterable<Page> pages;
  switch (option) {
    case MergeSamplesOptions.fullSize:
      pages = sampleList
          .map((e) => createPdfPage(e.sample, companyName, e.isYoung,
          firstImage, secondImage, checkedImage, uncheckedImage))
          .toList();
      break;
    case MergeSamplesOptions.fourPerSheet:
      final sampleSlices = sampleList.slices(4);
      pages = sampleSlices.map((e) {
        return pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.symmetric(
                vertical: verticalMargin, horizontal: horizontalMargin),
            build: (pw.Context context) {
              if (e.isEmpty) return pw.Container();
              return pw.Container(
                  width: pageWidth,
                  child:
                  pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
                    pw.Expanded(
                        child: pw.Row(
                            mainAxisAlignment:
                            pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                  width: pageWidth / 2,
                                  child: e.isNotEmpty
                                      ? pw.Padding(
                                      padding: pw.EdgeInsets.only(
                                          right: horizontalMargin / 2 + 8.0),
                                      child: newWidget(
                                          "1",
                                          e[0].sample,
                                          companyName,
                                          e[0].isYoung,
                                          firstImage,
                                          secondImage,
                                          checkedImage,
                                          uncheckedImage))
                                      : pw.Container()),
                              pw.Container(
                                  width: pageWidth / 2,
                                  child: e.length > 1
                                      ? pw.Padding(
                                      padding: pw.EdgeInsets.only(
                                          left: horizontalMargin / 2 + 8.0),
                                      child: newWidget(
                                          "2",
                                          e[1].sample,
                                          companyName,
                                          e[1].isYoung,
                                          firstImage,
                                          secondImage,
                                          checkedImage,
                                          uncheckedImage))
                                      : pw.Container())
                            ])),
                    pw.SizedBox(height: horizontalMargin),
                    pw.Expanded(
                        child: e.length > 2
                            ? pw.Row(
                            mainAxisAlignment:
                            pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Container(
                                  width: pageWidth / 2,
                                  child: e.length > 2
                                      ? pw.Padding(
                                      padding: pw.EdgeInsets.only(
                                          right:
                                          horizontalMargin / 2 +
                                              8.0),
                                      child: newWidget(
                                          "3",
                                          e[2].sample,
                                          companyName,
                                          e[2].isYoung,
                                          firstImage,
                                          secondImage,
                                          checkedImage,
                                          uncheckedImage))
                                      : pw.Container()),
                              pw.Container(
                                  width: pageWidth / 2,
                                  child: e.length > 3
                                      ? pw.Padding(
                                      padding: pw.EdgeInsets.only(
                                          left: horizontalMargin / 2 +
                                              8.0),
                                      child: newWidget(
                                          "4",
                                          e[3].sample,
                                          companyName,
                                          e[3].isYoung,
                                          firstImage,
                                          secondImage,
                                          checkedImage,
                                          uncheckedImage))
                                      : pw.Container())
                            ])
                            : pw.Container())
                  ]));
            });
      }).toList();
      debugPrint("termino fourpersheet");
      break;
  }
  debugPrint("termino switch");
  for (var page in pages) {
    debugPrint("adding new page");
    pdf.addPage(page);
  }
  return pdf;
}

Future<pw.Document> createPdf(
    SampleWithUserModel sample, String companyName) async {
  var arial = pw.Font.ttf(await rootBundle.load("fonts/Arial-Regular.ttf"));
  var calibri = pw.Font.ttf(await rootBundle.load("fonts/Calibri-Regular.ttf"));
  final pw.ThemeData theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(), fontFallback: [calibri, arial]);
  final pdf = pw.Document(theme: theme);
  final firstImage =
  (await rootBundle.load("images/1.png")).buffer.asUint8List();
  final secondImage =
  (await rootBundle.load("images/2.png")).buffer.asUint8List();
  final checkedImage = (await rootBundle.load("images/pdfCheckboxChecked.png"))
      .buffer
      .asUint8List();
  final uncheckedImage =
  (await rootBundle.load("images/pdfCheckboxUnchecked.png"))
      .buffer
      .asUint8List();
  if (sample.sample.youngSampleBarcode != null) {
    pdf.addPage(createPdfPage(sample, companyName, true, firstImage,
        secondImage, checkedImage, uncheckedImage));
  }
  if (sample.sample.oldSampleBarcode != null) {
    pdf.addPage(createPdfPage(sample, companyName, false, firstImage,
        secondImage, checkedImage, uncheckedImage));
  }
  return pdf;
}

Future createTestBarcodeExcelFileAndDownloadOnWeb() async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['SheetName'];
  for (var i = 100; i < 600; i++) {
    if (i < 350) {
      sheetObject.insertRowIterables(["AAA3$i", "Scannable"], i);
    } else {
      sheetObject.insertRowIterables(["AAA3$i", "Requestable"], i);
    }
  }
  List<int>? excelBytes = excel.encode();
  if (excelBytes != null) {
    final blob = html.Blob([excelBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'barcodes.xlsx';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}

Future<void> downloadDashboardTemplate(String path) async {
  Uint8List? bytes = await FirebaseStorage.instance.ref(path).getData();
  if (bytes != null) {
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = path.split("/")[1];
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  } else {
    debugPrint("No bytes read");
  }
}

Future<File?> generateSamplesExcelFile(List<SampleWithUserModel> samples) async {
  if (samples.isEmpty) {
    return null;
  }
  List<List<dynamic>> excelRows = await mapSampleToJsonWithCompany(samples);
  Uint8List? bytes = await FirebaseStorage.instance
      .ref("templates/samples_report_template.xlsx")
      .getData();
  if (bytes != null) {
    final fileName = "samples-${DateTime.now().millisecondsSinceEpoch}";
    var excelFile = Excel.decodeBytes(bytes);
    for (var i = 0; i < excelRows[0].length; i++) {
      excelFile.sheets["Sheet1"]!.setColAutoFit(i);
    }
    for (var sample in excelRows) {
      excelFile.appendRow("Sheet1", sample);
    }
    final excelFileBytes = excelFile.save(fileName: "$fileName.xlsx");
    if (kIsWeb) return null;
    if (excelFileBytes == null) {
      throw Exception("Unknown");
    }
    final file = File(
        "${(await getApplicationDocumentsDirectory()).path}/$fileName.xlsx");
    file
     ..createSync(recursive: true)
     ..writeAsBytesSync(excelFileBytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Sample report",
      subject: "Sample report",
    );
  }
  return null;
}

// Future<void> generateSamplesExcelFile(List<SampleWithUserModel> samples) async {
//     List<Map<String, dynamic>> sampleJsonList = await mapSampleToJsonWithFarm(samples);
//     var result = await FirebaseFunctions.instance
//         .httpsCallable("createSamplesReport")
//         .call<String>({"samples": sampleJsonList});
//     String url = result.data;
//     html.AnchorElement anchorElement =  html.AnchorElement(href: url);
//     anchorElement.download = url;
//     anchorElement.click();
// }

Future<void> generateUsersExcelFile(List<UserModel> users) async {
  Uint8List? bytes = await FirebaseStorage.instance
      .ref("templates/users_report_template.xlsx")
      .getData();
  if (bytes != null) {
    var excelFile = Excel.decodeBytes(bytes);
    for (var user in users) {
      excelFile.appendRow("Sheet1", [
        user.firstName,
        user.lastName,
        user.email,
        user.phone?.getFullPhoneNumber() ?? "-",
        user.companyReferences.map((e) => e.companyName).join(", "),
        user.enabled ? "Enabled" : "Disabled",
      ]);
    }
    excelFile.save(fileName: "users_report.xlsx");
  }
}

Future<void> generateCompaniesExcelFile(List<CompanyModel> farms) async {
  Uint8List? bytes = await FirebaseStorage.instance
      .ref("templates/companies_report_template.xlsx")
      .getData();
  if (bytes != null) {
    var excelFile = Excel.decodeBytes(bytes);
    for (var farm in farms) {
      excelFile.appendRow("Sheet1", [
        farm.name,
        farm.companyAdminUserInfo?.email,
        farm.phone?.phoneCountryISOName == "US"
            ? formatUSNumber(farm.phone!.phone)
            : farm.phone?.phone,
        farm.alternatePhone?.phoneCountryISOName == "US"
            ? formatUSNumber(farm.alternatePhone!.phone)
            : farm.alternatePhone?.phone,
        farm.address,
        farm.city,
        farm.state,
        farm.country,
        farm.zipcode,
        farm.type,
        farm.users.length,
        farm.availableBarcodesCount,
        farm.usedBarcodesCount,
        farm.growers.length,
      ]);
    }
    excelFile.save(fileName: "companies_report.xlsx");
  }
}

Future<void> generateBarcodesExcelFile(List<GlobalBarcodeListItemModel> barcodes) async {
  Uint8List? bytes = await FirebaseStorage.instance
      .ref("templates/barcodes_report_template.xlsx")
      .getData();
  if (bytes != null) {
    var excelFile = Excel.decodeBytes(bytes);
    for (var barcode in barcodes) {
      excelFile.appendRow("Sheet1", [
        barcode.barcode,
        barcode.companyName,
        barcode.createdDate != null
            ? DateFormat.yMd()
            .format(barcode.createdDate!)
            : "",
        barcode.dateAddedToCompany != null
            ? DateFormat.yMd()
            .format(barcode.dateAddedToCompany!)
            : "",
        barcode.sampleReference?.id,
      ]);
    }
    excelFile.save(fileName: "barcodes_report.xlsx");
  }
}

Future<void> generateGrowersExcelFile(List<GrowerWithUserEmailsToNotifyModel> growers) async {
  Uint8List? bytes = await FirebaseStorage.instance
      .ref("templates/growers_report_template.xlsx")
      .getData();
  if (bytes != null) {
    var excelFile = Excel.decodeBytes(bytes);
    for (var e in growers) {
      excelFile.appendRow("Sheet1", [
        e.grower,
      ]);
    }
    excelFile.save(fileName: "growers_report.xlsx");
  }
}

Future<void> generateCropsExcelFile(List<CropModel> crops) async {
  Uint8List? bytes = await FirebaseStorage.instance
      .ref("templates/crops_report_template.xlsx")
      .getData();
  if (bytes != null) {
    var excelFile = Excel.decodeBytes(bytes);
    for (var e in crops) {
      excelFile.appendRow("Sheet1", [
        e.id,
        e.name,
        e.isActive
            ? "Active"
            : "Inactive"
      ]);
    }
    excelFile.save(fileName: "crops_report.xlsx");
  }
}

Future<void> createMergedPdf(MergeSamplesOptions option, widgets.RenderBox box, List<SampleWithUserModel> samples) async {
  var pdf =
  await createMergedSamplesPdf(samples, "", option);
  final fileBytes = await pdf.save();
  final fileName = "samples-${DateTime.now().millisecondsSinceEpoch}.pdf";
  if (kIsWeb) {
    final blob = html.Blob([fileBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  } else {
    final file = File(
        "${(await getApplicationDocumentsDirectory()).path}/$fileName");
    await file.writeAsBytes(fileBytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Sample report",
      subject: "Sample report",
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }
}

Future<File> downloadFile(String url, String filename) async {
  var httpClient = HttpClient();
  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();
  var bytes = await consolidateHttpClientResponseBytes(response);
  String dir = (await getTemporaryDirectory()).path;
  File file = File('$dir/$filename');
  await file.writeAsBytes(bytes);
  return file;
}