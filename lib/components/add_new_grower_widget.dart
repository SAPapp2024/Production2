import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:flutter/material.dart';

class AddNewGrowerWidget extends StatefulWidget {
  final String? grower;
  final CompanyModel farm;
  const AddNewGrowerWidget({Key? key, this.grower, required this.farm}) : super(key: key);

  @override
  State<AddNewGrowerWidget> createState() => _AddNewGrowerWidgetState();
}

class _AddNewGrowerWidgetState extends State<AddNewGrowerWidget> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> dropdownKey = GlobalKey();
  final GlobalKey<State<TextFormField>> growerKey = GlobalKey();
  TextEditingController controller = TextEditingController();
  String growerErrorMessage = "";
  SampleService sampleService = getIt.get();

  @override
  void initState() {
    super.initState();

    controller.text = widget.grower ?? "";
  }

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
                      const Text("Enter new grower",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              errorText: growerErrorMessage.isEmpty
                                  ? null
                                  : growerErrorMessage),
                          key: growerKey,
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
                          onPressed: () async {
                            if (formKey.currentState != null &&
                                formKey.currentState!.validate()) {
                              String grower = controller.text;
                              try {
                                if (widget.grower != null) {
                                  await sampleService.editGrower(
                                      widget.grower!, grower, widget.farm);
                                } else {
                                  await sampleService.addGrower(
                                      grower, widget.farm);
                                }
                                if (mounted) {
                                  Navigator.pop(context, grower);
                                }
                              } on GrowerAlreadyExistsException catch (e) {
                                setState(() {
                                  growerErrorMessage = e.toString();
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
