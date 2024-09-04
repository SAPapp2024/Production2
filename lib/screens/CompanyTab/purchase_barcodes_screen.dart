import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/app_text_form_field.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/components/purchasing_web_view.dart';
import 'package:agro_k/components/purchasing_web_view_imports.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company_payment_method.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/services/payment_service.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/encrypt_utils.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:agro_k/utilities/exceptions.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchaseBarcodesScreen extends StatefulWidget {
  static const id = "/purchase_barcodes";
  final UserModel user;
  final CompanyModel farm;

  const PurchaseBarcodesScreen({Key? key, required this.user, required this.farm}) : super(key: key);

  @override
  State<PurchaseBarcodesScreen> createState() => _PurchaseBarcodesScreenState();
}

class _PurchaseBarcodesScreenState extends State<PurchaseBarcodesScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<FormState> billingAddressFormKey = GlobalKey();
  var isLoading = false;
  SampleService sampleService = getIt.get();
  PaymentService paymentService = getIt.get();
  UserState userState = getIt.get();
  TextEditingController barcodeAmountTextController = TextEditingController();
  CompanyPaymentMethod? companyPaymentMethod;
  var listOfStates = Provinces.usaStates;
  bool useCurrentCard = true;

// Define the first set of data
  final List<Map<String, String>> shipDataOther = [
    {'samples': '0-9', 'price': '\$40.00'},
    {'samples': '10', 'price': '\$37.50'},
    {'samples': '20', 'price': '\$35.00'},
    {'samples': '50', 'price': '\$32.50'},
    {'samples': '100', 'price': '\$30.00'},
    {'samples': '250', 'price': '\$27.50'},
    {'samples': '1000', 'price': '\$25.00'},
  ];

  // Define the second set of data
  final List<Map<String, String>> shipDataUS = [
    {'samples': '0-9', 'price': '\$52.50'},
    {'samples': '10', 'price': '\$45.00'},
    {'samples': '20', 'price': '\$40.00'},
    {'samples': '50', 'price': '\$37.50'},
    {'samples': '100', 'price': '\$35.00'},
    {'samples': '250', 'price': '\$32.50'},
    {'samples': '1000', 'price': '\$30.00'},
  ];

  bool isUSCountry = false;

  //Billing address
  var editMode = false;
  final TextEditingController address = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController zipcode = TextEditingController();

  final TextEditingController newAddress = TextEditingController();
  final TextEditingController newCity = TextEditingController();
  final TextEditingController newState = TextEditingController();
  final TextEditingController newZipcode = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (TargetPlatform.iOS == defaultTargetPlatform) {
      // listen to uriLinkStream and navigate to dashboard
      uriLinkStream.listen((event) {
        if (event != null && event.scheme == "agrokapp" && event.host == "myapp") {
          context.goNamed(DashboardScreen.id);
        }
      });
    }
    address.text = "${widget.farm.address}, ${widget.farm.city}, ${widget.farm.state}, ${widget.farm.zipcode}";
    isUSCountry = widget.farm.country == 'United States';
    getCompanyPaymentMethod();
  }

  void getCompanyPaymentMethod() async {
    setState(() {
      isLoading = true;
    });
    companyPaymentMethod = await paymentService.getPaymentMethodForCompany(widget.farm.id);
    debugPrint("companyPaymentMethod = $companyPaymentMethod");
    setState(() {
      if (companyPaymentMethod != null) {
        useCurrentCard = true;
      } else {
        useCurrentCard = false;
      }
      debugPrint("useCurrentCard = $useCurrentCard");
      isLoading = false;
    });
  }

  String formatBillingAddress() {
    return "${address.text}, ${city.text}, ${state.text}, ${zipcode.text}";
  }

  @override
  Widget build(BuildContext context) {
    print(widget.farm.country);
    return Scaffold(
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
        title: const Text("Purchase Barcodes"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AppTextFormField(
                      validator: (String? newValue) {
                        if (newValue?.trim().isEmpty ?? true) {
                          return "This field can't be empty";
                        } else if ((int.tryParse(newValue ?? "") ?? 0) <= 0) {
                          return "The amount must be greater than 0";
                        }
                        return null;
                      },
                      floatingLabel: "Amount of barcodes",
                      hint: "Enter amount of barcodes",
                      controller: barcodeAmountTextController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  buildTableView(),
                  const SizedBox(
                    height: 32,
                  ),
                  Column(
                    children: <Widget>[
                      if (companyPaymentMethod != null)
                        RadioListTile<bool>(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Card company: ${companyPaymentMethod!.cardCompanyName}'),
                              Text('Card number: ${companyPaymentMethod!.cardNumber}'),
                              Text('Card exp date: ${companyPaymentMethod!.formattedExpirationDate()}'),
                            ],
                          ),
                          value: true,
                          groupValue: useCurrentCard,
                          onChanged: (bool? value) {
                            setState(() {
                              useCurrentCard = value ?? false;
                            });
                          },
                        ),
                      RadioListTile<bool>(
                        title: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Use new card'),
                            Text(
                              '(you will be prompted to enter card info after clicking submit)',
                              style: TextStyle(color: AppColors.strongGray, fontSize: 12),
                            ),
                          ],
                        ),
                        value: false,
                        groupValue: useCurrentCard,
                        onChanged: (bool? value) {
                          setState(() {
                            useCurrentCard = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: PrimaryButton(
                      onPressed: buyAssignableBarcodes,
                      type: PrimaryButtonType.filled,
                      actionType: PrimaryButtonActionType.positive,
                      title: "Submit",
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
              visible: isLoading,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: const Center(child: CircularProgressIndicator()),
              ))
        ],
      ),
    );
  }

  Widget buildTableView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.5))),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '# of Sample\nLabels',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.strongGray),
                        ),
                      ),
                      VerticalDivider(
                        thickness: 1,
                        color: AppColors.strongGray.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text(
                            '${isUSCountry ? 'Total^' : 'Price'}\n\$ / ea.',
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.strongGray),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: AppColors.strongGray.withOpacity(0.3),
                ),
                // Generate rows for the first set of data
                ...(isUSCountry ? shipDataUS : shipDataOther).map((data) {
                  int index = (isUSCountry ? shipDataUS : shipDataOther).indexOf(data);
                  return Column(
                    children: [
                      const SizedBox(height: 0),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['samples']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, color: AppColors.strongGray),
                              ),
                            ),
                            VerticalDivider(
                              thickness: 1,
                              color: AppColors.strongGray.withOpacity(0.3),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  data['price']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16, color: AppColors.strongGray),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 0),
                      Visibility(
                        visible: index != (isUSCountry ? shipDataUS : shipDataOther).length - 1,
                        child: Divider(
                          height: 1,
                          color: AppColors.strongGray.withOpacity(0.3),
                        ),
                      )
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          Visibility(
            visible: !isUSCountry,
            child: RichText(
                text: const TextSpan(
                    text: '*Registered customers can email purchase orders to ',
                    style: TextStyle(fontSize: 14, color: AppColors.strongGray, height: 1.5),
                    children: [
                  TextSpan(
                      text: ' SAP@agro-k.com',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ))
                ])),
          ),
          Visibility(
            visible: isUSCountry,
            child: RichText(
              text: const TextSpan(
                text: '^Shipping included. US only.\n* Pre-approved customers can email purchase orders to ',
                style: TextStyle(fontSize: 14, color: AppColors.strongGray, height: 1.5),
                children: <TextSpan>[
                  TextSpan(
                    text: 'SAP@agro-k.com',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget billingAddressForm() {
    return SizedBox(
      width: 400,
      child: Form(
        key: billingAddressFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              // key: phoneEmailKey,
              controller: address,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.black),
              validator: (value) {
                if (value == "") {
                  return "Please enter a company address";
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
                errorStyle: TextStyle(color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                // key: phoneEmailKey,
                controller: newCity,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == "") {
                    return "Please enter a company city";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "City",
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: kIsWeb
                  ? FormField<String>(
                      builder: (FormFieldState<String> formState) {
                        return InputDecorator(
                          decoration: InputDecoration(
                              // labelStyle: textStyle,
                              // errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
                              labelText: 'State/Province',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                          isEmpty: newState.text == '',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: newState.text == "" ? null : newState.text,
                              isDense: true,
                              onChanged: (newValue) {
                                setState(() {
                                  newState.text = newValue ?? "";
                                });
                              },
                              items: listOfStates.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    )
                  : TextFormField(
                      // key: phoneEmailKey,
                      controller: newState,
                      readOnly: true,
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == "") {
                          return "Please select a state";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "State/Province",
                        border: OutlineInputBorder(),
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        showPicker(context, listOfStates, (value) {
                          setState(() {
                            newState.text = listOfStates[value];
                          });
                        });
                      }),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                // key: phoneEmailKey,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                controller: newZipcode,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                ],
                style: const TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == "") {
                    return "Please enter a zipcode";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Zip Code",
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> buyAssignableBarcodes() async {
    try {
      debugPrint("current card = $useCurrentCard");
      var validateBarcodeAmount = formKey.currentState != null && formKey.currentState!.validate();
      if (!validateBarcodeAmount) {
        return;
      }
      var barcodeAmount = int.tryParse(barcodeAmountTextController.text);
      if (barcodeAmount == null) return;
      final isAdmin = userState.isCompanyAdmin();
      final cardToken = useCurrentCard ? companyPaymentMethod?.token : null;
      debugPrint("isAdmin = $isAdmin");
      if (isAdmin && !useCurrentCard) {
        showTwoButtonAlertDialog(
            context,
            "Yes",
            () {
              openPurchaseUrl(barcodeAmount: barcodeAmount, isAdmin: isAdmin, cardToken: cardToken, saveCard: true);
            },
            "No",
            () {
              openPurchaseUrl(barcodeAmount: barcodeAmount, isAdmin: isAdmin, cardToken: cardToken, saveCard: false);
            },
            "Save card details",
            "Do you want to save the card details for future purchases?");
      } else {
        openPurchaseUrl(barcodeAmount: barcodeAmount, isAdmin: isAdmin, cardToken: cardToken, saveCard: false);
      }
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            buyAssignableBarcodes();
          },
          "Cancel",
          () {
            Navigator.pop(context);
          },
          "Error",
          exception.message ?? "Unknown error.");
    } on NotEnoughBarcodesToBuyException catch (_) {
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "The system doesn't currently have that amount of barcodes.");
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error");
    }
  }

  Future<void> openPurchaseUrl(
      {required int barcodeAmount, required bool isAdmin, String? cardToken, required bool saveCard}) async {
    if (kIsWeb) {
      final result = await context.pushNamed<PaymentStatus>(PurchasingWebView.id,
          extra: PurchasingWebViewArguments(
              zipcode: widget.farm.zipcode,
              address: widget.farm.address,
              amount: barcodeAmount,
              email: widget.user.email,
              companyId: widget.farm.id,
              isAdmin: isAdmin,
              cardToken: cardToken,
              saveCard: saveCard,
              shipping: isUSCountry));
      if (mounted && result != PaymentStatus.approved) {
        if (result == null || result == PaymentStatus.canceled) {
          return;
        }
        showOneButtonAlertDialog(context, "Ok", () {
          Navigator.pop(context);
        }, "There was an error", "Payment status = ${result.name}");
        return;
      }
      if (mounted) {
        context.goNamed(DashboardScreen.id);
      }
    } else {
      print(buildPaymentUrl(context,
          companyId: widget.farm.id,
          address: widget.farm.address,
          zipcode: widget.farm.zipcode,
          email: widget.user.email,
          amount: barcodeAmount,
          isAdmin: isAdmin,
          shipping: isUSCountry,
          cardToken: cardToken,
          saveCard: saveCard,
          fromMobileApp: true));
      launchUrl(
          Uri.parse(buildPaymentUrl(context,
              companyId: widget.farm.id,
              address: widget.farm.address,
              zipcode: widget.farm.zipcode,
              email: widget.user.email,
              amount: barcodeAmount,
              isAdmin: isAdmin,
              shipping: isUSCountry,
              cardToken: cardToken,
              saveCard: saveCard,
              fromMobileApp: true)),
          mode: LaunchMode.externalApplication);
    }
  }
}

String buildPaymentUrl(BuildContext context,
    {required String companyId,
    required String address,
    required String zipcode,
    required String email,
    required int amount,
    required bool isAdmin,
    required bool shipping,
    String? cardToken,
    required bool saveCard,
    required bool fromMobileApp}) {
  final map = {
    "company_id": companyId,
    "from_mobile_app": fromMobileApp ? "1" : "0",
    "amount": amount.toString(),
    "address": address,
    "zip": zipcode,
    "email": email,
    "shipping": shipping,
    "is_admin": isAdmin ? "1" : "0",
    "card_token": cardToken ?? "",
    "save_card": saveCard ? "1" : "0",
  };
  final token = encryptMap(map);
  debugPrint("token = $token");
  final paymentUrl = getPaymentUrl(RepositoryProvider.of<Environment>(context, listen: false));
  return "$paymentUrl?company_id=$companyId&from_mobile_app=${fromMobileApp ? "1" : "0"}&amount=$amount&address=$address&zip=$zipcode&email=$email&shipping=$shipping&is_admin=${isAdmin ? "1" : "0"}&save_card=${saveCard ? "1" : "0"}&verification_token=$token&card_token=${cardToken ?? ""}";
}
