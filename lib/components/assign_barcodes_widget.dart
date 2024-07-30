import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/exceptions.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/sample_sorting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AssignBarcodesWidget extends StatefulWidget {
  const AssignBarcodesWidget({Key? key}) : super(key: key);

  @override
  State<AssignBarcodesWidget> createState() => _AssignBarcodesWidgetState();
}

class _AssignBarcodesWidgetState extends State<AssignBarcodesWidget> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<State<TextFormField>> barcodeKey = GlobalKey();
  CompanyModel? selectedCompany;
  TextEditingController companySearchTextController = TextEditingController();
  TextEditingController barcodeAmountTextController = TextEditingController();
  String errorMessage = "";
  SampleService sampleService = getIt.get();
  AuthService authService = getIt.get();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              side: BorderSide(color: AppColors.cardBorder, width: 1.0)),
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: 300,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Assign Barcodes",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TypeAheadFormField<CompanyModel>(
                              validator: (_) {
                                if (selectedCompany == null) {
                                  return "Please select a company";
                                }
                                return null;
                              },
                              noItemsFoundBuilder: (context) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("No results"),
                                );
                              },
                              textFieldConfiguration: TextFieldConfiguration(
                                  controller: companySearchTextController,
                                  textInputAction: TextInputAction.done,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: "Search company",
                                    labelStyle: const TextStyle(
                                        color: AppColors.grayTextColor),
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      onPressed:
                                          companySearchTextController.clear,
                                      icon: const Icon(Icons.clear),
                                    ),
                                  )),
                              suggestionsCallback: (searchString) async {
                                try {
                                  List<CompanyModel> farms =
                                      await authService.searchCompanies(
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          "",
                                          searchString,
                                          "",
                                          CompanySortFilterWrapper.empty());
                                  return farms;
                                } catch (exception, stacktrace) {
                                  getIt
                                      .get<RemoteErrorLoggingService>()
                                      .recordError(exception, stacktrace);
                                  return [];
                                }
                              },
                              itemBuilder: (context, item) {
                                return ListTile(
                                  title: Text(item.name),
                                );
                              },
                              onSuggestionSelected: (selected) {
                                companySearchTextController.text =
                                    selected.toString();
                                setState(() {
                                  selectedCompany = selected;
                                });
                              },
                            )),
                      ),
                      selectedCompany != null
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Selected company: ${selectedCompany!.name}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.black),
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextFormField(
                          validator: (String? newValue) {
                            if (newValue?.trim().isEmpty ?? true) {
                              return "This field can't be empty";
                            } else if ((int.tryParse(newValue ?? "") ?? 0) <=
                                0) {
                              return "The amount must be greater than 0";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Barcodes Amount",
                            labelStyle:
                                const TextStyle(color: AppColors.grayTextColor),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                barcodeAmountTextController.clear();
                              },
                              icon: const Icon(Icons.clear),
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                          controller: barcodeAmountTextController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 30.0),
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            if (formKey.currentState != null &&
                                formKey.currentState!.validate()) {
                              int barcodeAmount =
                                  int.parse(barcodeAmountTextController.text);
                              try {
                                await sampleService.addBarcodesToCompany(
                                    selectedCompany!, barcodeAmount, false);
                                if (mounted) {
                                  Navigator.pop(context, true);
                                }
                              } on NotEnoughBarcodesToBuyException catch (_) {
                                showOneButtonAlertDialog(context, "Ok", () {
                                  Navigator.pop(context);
                                }, "Error",
                                    "The system doesn't currently have that amount of barcodes.");
                              } catch (exception, stacktrace) {
                                getIt
                                    .get<RemoteErrorLoggingService>()
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
