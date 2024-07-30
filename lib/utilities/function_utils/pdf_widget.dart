import 'dart:typed_data';

import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Widget newWidget(
    String id,
    SampleWithUserModel sample,
    String companyName,
    bool youngSample,
    Uint8List firstImage,
    Uint8List secondImage,
    Uint8List checkedImage,
    Uint8List uncheckedImage) {
  const fontSize = 7.55;
  return pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
    pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(pw.MemoryImage(firstImage),
              width: 4.5 * PdfPageFormat.cm,
              height: 4.5 * PdfPageFormat.cm * 86 / 560,
              fit: pw.BoxFit.fill),
          pw.Image(pw.MemoryImage(secondImage),
              width: 2.55 * PdfPageFormat.cm,
              height: 2.55 * PdfPageFormat.cm * 148 / 366,
              fit: pw.BoxFit.fill)
        ]),
    pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.SizedBox(
            width: 3.5 * PdfPageFormat.cm,
            height: 3.5 * PdfPageFormat.cm / 3,
            child: pw.BarcodeWidget(
                data: youngSample ? sample.sample.youngSampleBarcode! : sample.sample.oldSampleBarcode!,
                barcode: pw.Barcode.code128(),
                textStyle: pw.TextStyle(font: pw.Font.helvetica(), fontSize: fontSize),
                width: barcodeHeight * 3,
                height: barcodeHeight + fontSize))),
    pw.Align(
      alignment: pw.Alignment.topRight,
      child: pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text("Sample date:",
              style: const pw.TextStyle(
                fontSize: fontSize,
              ))),
    ),
    pw.Align(
        alignment: pw.Alignment.topRight,
        child: pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4, top: 8),
            child: pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 4),
                alignment: pw.Alignment.centerRight,
                width: 100,
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(style: pw.BorderStyle.dashed))),
                child: sample.sample.sampleDate != null
                    ? pw.Text(
                    DateFormat.yMd().format(sample.sample.sampleDate!),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: fontSize,
                    ))
                    : pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 8),
                    child: pw.Container(
                      height: 1,
                      width: double.infinity,))))),
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text("Company:", style: const pw.TextStyle(fontSize: fontSize)),
          pw.Expanded(
              flex: 1,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Container(
                      padding:
                      const pw.EdgeInsets.only(top: 8, bottom: 4, left: 54),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              bottom:
                              pw.BorderSide(style: pw.BorderStyle.dashed))),
                      child: pw.Text(companyName,
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip,
                          style: const pw.TextStyle(
                            fontSize: fontSize,
                          )))))
        ],
      ),
    ),

    pw.Container(
      padding: const pw.EdgeInsets.only(top: 2),
      // color: const PdfColor(0.2, 0.1, 0.4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text("Grower:", style: const pw.TextStyle(fontSize: fontSize)),
          pw.Expanded(
              flex: 1,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Container(
                      padding:
                      const pw.EdgeInsets.only(top: 8, bottom: 4, left: 75),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              bottom:
                              pw.BorderSide(style: pw.BorderStyle.dashed))),
                      child: pw.Text(sample.sample.grower ?? "-",
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip,
                          style: const pw.TextStyle(
                            fontSize: fontSize,
                          )))))
        ],
      ),
    ),
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 2),
      // color: const PdfColor(0.2, 0.1, 0.4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text("Farm (location):", style: const pw.TextStyle(fontSize: fontSize)),
          pw.Expanded(
              flex: 1,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Container(
                      padding:
                      const pw.EdgeInsets.only(top: 8, bottom: 4, left: 32),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              bottom:
                              pw.BorderSide(style: pw.BorderStyle.dashed))),
                      child: pw.Text(sample.sample.farm,
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip,
                          style: const pw.TextStyle(
                            fontSize: fontSize,
                          )))))
        ],
      ),
    ),
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 2),
      // color: const PdfColor(0.2, 0.1, 0.4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text("Field (cultivation):", style: const pw.TextStyle(fontSize: fontSize)),
          pw.Expanded(
              flex: 1,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Container(
                      padding:
                      const pw.EdgeInsets.only(top: 8, bottom: 4, left: 50),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              bottom:
                              pw.BorderSide(style: pw.BorderStyle.dashed))),
                      child: pw.Text(sample.sample.field,
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip,
                          style: const pw.TextStyle(
                            fontSize: fontSize,
                          )))))
        ],
      ),
    ),
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 2),
      // color: const PdfColor(0.2, 0.1, 0.4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text("Crop:", style: const pw.TextStyle(fontSize: fontSize)),
          pw.Expanded(
              flex: 1,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Container(
                      padding:
                      const pw.EdgeInsets.only(top: 8, bottom: 4, left: 35),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              bottom:
                              pw.BorderSide(style: pw.BorderStyle.dashed))),
                      child: pw.Text(sample.sample.crop,
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip,
                          style: const pw.TextStyle(
                            fontSize: fontSize,
                          )))))
        ],
      ),
    ),
    pw.Container(
      padding: pw.EdgeInsets.only(top: (sample.sample.variety?.isEmpty ?? true) ? 4 : 2),
      // color: const PdfColor(0.2, 0.1, 0.4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text("Variety:", style: const pw.TextStyle(fontSize: fontSize)),
          pw.Expanded(
              flex: 1,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Container(
                      padding:
                      const pw.EdgeInsets.only(top: 8, bottom: 4, left: 35),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              bottom:
                              pw.BorderSide(style: pw.BorderStyle.dashed))),
                      child: pw.Text(sample.sample.variety ?? "",
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip,
                          style: const pw.TextStyle(
                            fontSize: fontSize,
                          )))))
        ],
      ),
    ),
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        children: [
          pw.Text("Analysis:", style: const pw.TextStyle(fontSize: fontSize)),
          pw.SizedBox(width: 4),
          pw.Flexible(
              flex: 1,
              child: pw.Row(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 2),
                  child: pw.Image(pw.MemoryImage(checkedImage),
                      width: 124 / 8.0, height: 124 / 8.0, fit: pw.BoxFit.fill),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 2),
                  child: pw.Text("Plant sap",
                      style: const pw.TextStyle(fontSize: fontSize)),
                ),
              ])),
          pw.Flexible(
              flex: 1,
              child: pw.Row(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 2),
                  child: pw.Image(pw.MemoryImage(uncheckedImage),
                      width: 124 / 8.0, height: 124 / 8.0, fit: pw.BoxFit.fill),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 2),
                  child: pw.Text("Drain water",
                      style: const pw.TextStyle(fontSize: fontSize)),
                ),
              ])),
          pw.Flexible(
              flex: 1,
              child: pw.Row(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 2),
                  child: pw.Image(pw.MemoryImage(uncheckedImage),
                      width: 124 / 8.0, height: 124 / 8.0, fit: pw.BoxFit.fill),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 2),
                  child: pw.Text("Irrigation water",
                      style: const pw.TextStyle(fontSize: fontSize)),
                ),
              ])),
        ],
      ),
    ),
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 2),
      // color: const PdfColor(0.2, 0.1, 0.4),
      child: pw.Row(
        children: [
          pw.Text("Leaf type:", style: const pw.TextStyle(fontSize: fontSize)),
          pw.SizedBox(width: 4),
          pw.Flexible(
            flex: 1,
            child: pw.Row(children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 2),
                child: pw.Image(
                    pw.MemoryImage(youngSample ? checkedImage : uncheckedImage),
                    width: 124 / 8.0,
                    height: 124 / 8.0,
                    fit: pw.BoxFit.fill),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 2),
                child: pw.Text("Leaf (young)",
                    style: const pw.TextStyle(fontSize: fontSize)),
              ),
            ]),
          ),
          pw.Flexible(
              flex: 1,
              child: pw.Row(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 2),
                  child: pw.Image(
                      pw.MemoryImage(
                          youngSample ? uncheckedImage : checkedImage),
                      width: 124 / 8.0,
                      height: 124 / 8.0,
                      fit: pw.BoxFit.fill),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 2),
                  child: pw.Text("Leaf (old)",
                      style: const pw.TextStyle(fontSize: fontSize)),
                ),
              ])),
          pw.Flexible(flex: 1, child: pw.Spacer())
        ],
      ),
    ),
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 2),
      // color: const PdfColor(0.2, 0.1, 0.4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text("Treatment:", style: const pw.TextStyle(fontSize: fontSize)),
          pw.Expanded(
              flex: 1,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Container(
                      padding:
                      const pw.EdgeInsets.only(top: 8, bottom: 4, left: 75),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                              bottom:
                              pw.BorderSide(style: pw.BorderStyle.dashed))),
                      child: pw.Text(sample.sample.treatment ?? "-",
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip,
                          style: const pw.TextStyle(
                            fontSize: fontSize,
                          )))))
        ],
      ),
    ),
    pw.Container(
      padding: const pw.EdgeInsets.only(top: 4),
      // color: const PdfColor(0.2, 0.1, 0.4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6),
              child:
              pw.Text("Notes:", style: const pw.TextStyle(fontSize: fontSize))),
          pw.Expanded(
              flex: 1,
              child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Stack(children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.only(top: 3, bottom: 1),
                      child: pw.Text(sample.sample.notes,
                          style:
                          const pw.TextStyle(fontSize: 11, lineSpacing: 3),
                          maxLines: 2,
                          overflow: pw.TextOverflow.clip),
                    ),
                    pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        ...List.generate(
                          2,
                              (index) => pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.SizedBox(height: 15),
                              pw.Container(
                                  height: 1,
                                  width: double.infinity,
                                  decoration: const pw.BoxDecoration(
                                      border: pw.Border(
                                          bottom: pw.BorderSide(
                                              style: pw.BorderStyle.dashed))))
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
    pw.SizedBox(height: 20),
    pw.Align(
        alignment: pw.Alignment.bottomLeft,
        child: pw.Text(
            "Created: ${DateFormat.yMd().format(sample.sample.createdDate)}",
            style: const pw.TextStyle(fontSize: fontSize, height: 1.4)))
  ]);
}