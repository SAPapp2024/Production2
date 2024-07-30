import 'package:agro_k/models/company/sample_change_with_user_model.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeeSampleChangesScreenArguments {
  final List<SampleChangeWithUserModel> sampleChanges;

  const SeeSampleChangesScreenArguments({required this.sampleChanges});
}

class SeeSampleChangesScreen extends StatefulWidget {
  static const id = "/see_sample_changes";
  final List<SampleChangeWithUserModel> sampleChanges;

  const SeeSampleChangesScreen({Key? key, required this.sampleChanges})
      : super(key: key);

  @override
  State<SeeSampleChangesScreen> createState() => _SeeSampleChangesScreenState();
}

class _SeeSampleChangesScreenState extends State<SeeSampleChangesScreen> {
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
          title: const Text("Sample changes"),
        ),
        backgroundColor: AppColors.pageBackground,
        body: widget.sampleChanges.isNotEmpty
            ? ListView.builder(
                itemCount: widget.sampleChanges.length,
                itemBuilder: (BuildContext context, int index) =>
                    _SampleChangesItem(
                        key: ValueKey(widget.sampleChanges[index]),
                        sampleChange: widget.sampleChanges[index]))
            : Container(),
      ),
    );
  }
}

class _SampleChangesItem extends StatelessWidget {
  final SampleChangeWithUserModel sampleChange;

  const _SampleChangesItem({Key? key, required this.sampleChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 500,
          child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text("Change made by:",
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.black1,
                                fontWeight: FontWeight.w600)),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(sampleChange.user != null
                                ? "${sampleChange.user!.firstName} ${capitalizeLastWord(sampleChange.user!.lastName ?? "")}"
                                : "User doesn't exist"),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Text("Change date:",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.black1,
                                  fontWeight: FontWeight.w600)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(DateFormat.yMd().format(
                                  sampleChange.sampleChangeModel.changeDate)),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text("Sample changes",
                          style: TextStyle(
                              fontSize: 18,
                              color: AppColors.black1,
                              fontWeight: FontWeight.w700)),
                    ),
                    _SampleChangesItemField(
                        key: const Key("sample_changes_farm_key"),
                        title: "Farm",
                        oldValue: sampleChange
                            .sampleChangeModel.oldSampleState.locationPlot,
                        newValue: sampleChange
                            .sampleChangeModel.newSampleState.locationPlot),
                    _SampleChangesItemField(
                        key: const Key("sample_changes_crop_key"),
                        title: "Crop",
                        oldValue:
                            sampleChange.sampleChangeModel.oldSampleState.crop,
                        newValue:
                            sampleChange.sampleChangeModel.newSampleState.crop),
                    _SampleChangesItemField(
                        key: const Key("sample_changes_field_key"),
                        title: "Field",
                        oldValue: sampleChange
                            .sampleChangeModel.oldSampleState.cultivation,
                        newValue: sampleChange
                            .sampleChangeModel.newSampleState.cultivation),
                    _SampleChangesItemField(
                        key: const Key("sample_changes_variety_key"),
                        title: "Variety",
                        oldValue: sampleChange
                            .sampleChangeModel.oldSampleState.variety,
                        newValue: sampleChange
                            .sampleChangeModel.newSampleState.variety),
                    _SampleChangesItemField(
                        key: const Key("sample_changes_grower_key"),
                        title: "Grower",
                        oldValue: sampleChange
                            .sampleChangeModel.oldSampleState.grower,
                        newValue: sampleChange
                            .sampleChangeModel.newSampleState.grower),
                    _SampleChangesItemField(
                        key: const Key("sample_changes_notes_key"),
                        title: "Notes",
                        oldValue:
                            sampleChange.sampleChangeModel.oldSampleState.notes,
                        newValue: sampleChange
                            .sampleChangeModel.newSampleState.notes),
                    _SampleChangesItemField(
                        key: const Key("sample_changes_young_sample_barcode_key"),
                        title: "Young sample barcode",
                        oldValue: sampleChange.sampleChangeModel.oldSampleState
                            .youngSampleBarcode,
                        newValue: sampleChange.sampleChangeModel.newSampleState
                            .youngSampleBarcode),
                    _SampleChangesItemField(
                        key: const Key("sample_changes_old_sample_barcode_key"),
                        title: "Old sample barcode",
                        oldValue: sampleChange
                            .sampleChangeModel.oldSampleState.oldSampleBarcode,
                        newValue: sampleChange
                            .sampleChangeModel.newSampleState.oldSampleBarcode),
                    _SampleChangesItemField(
                        key: const Key("sample_changes_status_key"),
                        title: "Status",
                        oldValue: sampleChange
                            .sampleChangeModel.oldSampleState.status,
                        newValue: sampleChange
                            .sampleChangeModel.newSampleState.status),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class _SampleChangesItemField extends StatelessWidget {
  final String title;
  final String? oldValue;
  final String? newValue;

  const _SampleChangesItemField(
      {Key? key,
      required this.title,
      required this.oldValue,
      required this.newValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (oldValue == newValue) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$title:",
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black1,
                    fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(
                    child: Text(
                  oldValue ?? "No value",
                  textAlign: TextAlign.center,
                )),
                const Icon(Icons.arrow_right_alt_outlined),
                Expanded(
                    child: Text(newValue ?? "No value",
                        textAlign: TextAlign.center))
              ],
            )
          ],
        ),
      );
    }
  }
}
