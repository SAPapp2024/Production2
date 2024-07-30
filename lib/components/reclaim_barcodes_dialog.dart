import 'package:agro_k/models/company/sample_model.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

class ReclaimBarcodesDialog extends StatefulWidget {
  final SampleModel sample;

  const ReclaimBarcodesDialog({Key? key, required this.sample})
      : super(key: key);

  @override
  State<ReclaimBarcodesDialog> createState() => _ReclaimBarcodesDialogState();
}

class _ReclaimBarcodesDialogState extends State<ReclaimBarcodesDialog> {
  bool _reclaimYoungBarcode = false;
  bool _reclaimOldBarcode = false;
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 24.0, bottom: 24.0),
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Select barcodes to reclaim",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.black1),
                        ),
                        const SizedBox(height: 16),
                        if (widget.sample.youngSampleBarcode != null)
                          SwitchListTile(
                            contentPadding: const EdgeInsets.only(left: 8),
                            value: _reclaimYoungBarcode,
                            onChanged: (bool value) {
                              setState(() => _reclaimYoungBarcode = value);
                            },
                            title: const Text("Young",
                                style: TextStyle(
                                    color: AppColors.grayTextColor, fontSize: 14)),
                          ),
                        const SizedBox(height: 8),
                        if (widget.sample.oldSampleBarcode != null)
                          SwitchListTile(
                            contentPadding: const EdgeInsets.only(left: 8),
                            value: _reclaimOldBarcode,
                            onChanged: (bool value) {
                              setState(() => _reclaimOldBarcode = value);
                            },
                            title: const Text("Old",
                                style: TextStyle(
                                    color: AppColors.grayTextColor, fontSize: 14)),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              if (_reclaimYoungBarcode || _reclaimOldBarcode) {
                                Navigator.pop(context, {
                                  "reclaimYoungBarcode": _reclaimYoungBarcode,
                                  "reclaimOldBarcode": _reclaimOldBarcode
                                });
                              } else {
                                setState(() {
                                  _errorMessage =
                                      "Please select at least one barcode";
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.appPrimaryGreen,
                            ),
                            child: const Text("Submit"),
                          ),
                        ),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                      ],
                    ),
                  ),
                ))));
  }
}
