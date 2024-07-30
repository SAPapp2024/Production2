import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:flutter/material.dart';

class AddNewCropWidget extends StatefulWidget {
  const AddNewCropWidget({Key? key}) : super(key: key);

  @override
  State<AddNewCropWidget> createState() => _AddNewCropWidgetState();
}

class _AddNewCropWidgetState extends State<AddNewCropWidget> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<FormFieldState<bool>> checkboxKey = GlobalKey();
  final GlobalKey<State<TextFormField>> cropNameKey = GlobalKey();
  TextEditingController controller = TextEditingController();
  String cropErrorMessage = "";
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
                      const Text("Enter new crop name",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              errorText: cropErrorMessage.isEmpty ? null : cropErrorMessage
                          ),
                          key: cropNameKey,
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
                          child: FormField<bool>(
                            key: checkboxKey,
                            builder:
                                (FormFieldState<bool> state) {
                              return CheckboxListTile(title: const Text("Active"), value: state.value, onChanged: (newValue) {
                                state.didChange(newValue);
                              } );
                            },
                            initialValue: true,
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: TextButton(
                          onPressed: () async {
                            if (formKey.currentState != null &&
                                formKey.currentState!.validate()) {
                              String cropName = controller.text;
                              bool isActive = checkboxKey.currentState?.value ?? false;
                              try {
                                await sampleService.createCrop(
                                    cropName, isActive);
                                if (mounted) {
                                  context.tryPop(true);
                                }
                              } on CropNameAlreadyExistsException catch (e) {
                                setState(() {
                                  cropErrorMessage = e.toString();
                                });
                              } catch (exception, stacktrace) {
                                getIt.get<RemoteErrorLoggingService>()
                                    .recordError(exception, stacktrace);
                                showOneButtonAlertDialog(context, "Ok", () {
                                  context.tryPop();
                                }, "Error", "There was an error");
                              }
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
  }
}
