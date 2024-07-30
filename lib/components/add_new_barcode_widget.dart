import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:flutter/material.dart';

class AddNewBarcodeWidget extends StatefulWidget {
  const AddNewBarcodeWidget({Key? key}) : super(key: key);

  @override
  State<AddNewBarcodeWidget> createState() => _AddNewBarcodeWidgetState();
}

class _AddNewBarcodeWidgetState extends State<AddNewBarcodeWidget> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<State<TextFormField>> barcodeKey = GlobalKey();
  TextEditingController controller = TextEditingController();
  String barcodeErrorMessage = "";
  SampleService sampleService = getIt.get();

  @override
  Widget build(BuildContext context) {
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
                      const Text("Enter new barcode",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              errorText: barcodeErrorMessage.isEmpty
                                  ? null
                                  : barcodeErrorMessage),
                          key: barcodeKey,
                          controller: controller,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field can't be empty";
                            } else if (!RegExp("(?=.{7}\$)[A-Z]{3}[0-9]{4}").hasMatch(value)) {
                              return "Invalid barcode";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: TextButton(
                          onPressed: () async {
                            if (formKey.currentState != null &&
                                formKey.currentState!.validate()) {
                              String barcode = controller.text;
                              try {
                                await sampleService.createBarcode(
                                    barcode);
                                if (mounted) {
                                  Navigator.pop(context, true);
                                }
                              } on BarcodeAlreadyExistsException catch (e) {
                                setState(() {
                                  barcodeErrorMessage = e.toString();
                                });
                              } catch (exception, stacktrace) {
                                getIt.get<RemoteErrorLoggingService>()
                                    .recordError(exception, stacktrace);
                                showOneButtonAlertDialog(context, "Ok", () {
                                  Navigator.pop(context);
                                }, "Error", "There was an error");
                              }
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
  }
}
