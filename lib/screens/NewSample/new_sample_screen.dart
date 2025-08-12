import 'dart:async';

import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/components/app_text_form_field.dart';
import 'package:agro_k/components/choose_sample_young_old_buttons.dart';
import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/components/location_widget.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/components/reclaim_barcodes_dialog.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/sample_model.dart';
import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/models/sample_creation_wrapper.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/screens/CompanyTab/purchase_barcodes_screen.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/screens/NewSample/sample_submitted_screen.dart';
import 'package:agro_k/services/Database/app_database.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/services/location_service.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/function_utils/general_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:agro_k/utilities/function_utils/string_utils.dart';
import 'package:agro_k/utilities/function_utils/view_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

enum EditSampleResult { editedSuccessfully, cancelled, reclaimedBarcodes }

class NewSampleScreen extends StatefulWidget {
  static const String id = '/new_sample';
  final SampleWithUserModel? existingSampleToEdit;
  final String? changeId;
  final UserModel user;
  final CompanyModel farm;
  final bool populateFields;

  NewSampleScreen(
      {Key? key,
      this.existingSampleToEdit,
      required this.user,
      required this.farm, this.populateFields = true})
      : changeId =
            existingSampleToEdit != null ? const Uuid().v4().toString() : null,
        super(key: key);

  @override
  NewSampleScreenState createState() => NewSampleScreenState();
}

class NewSampleScreenState extends State<NewSampleScreen> {
  UserState userState = getIt.get();
  ProfileService profileService = getIt.get();
  AuthService authService = getIt.get();
  SampleService sampleService = getIt.get();
  LocationService locationService = getIt.get();
  final TextEditingController _newSampleDate = TextEditingController();
  final TextEditingController _newLocationTitle = TextEditingController();
  final SuggestionsBoxController _newCultivationBoxController =
      SuggestionsBoxController();
  final SuggestionsBoxController _newTreatmentBoxController =
      SuggestionsBoxController();
  final SuggestionsBoxController _newCropBoxController =
      SuggestionsBoxController();
  final SuggestionsBoxController _newVarietyBoxController =
      SuggestionsBoxController();
  final SuggestionsBoxController _newGrowerBoxController =
      SuggestionsBoxController();
  final SuggestionsBoxController _newLocationBoxController =
      SuggestionsBoxController();
  final TextEditingController _newCultivation = TextEditingController();
  final TextEditingController _newTreatment = TextEditingController();
  final TextEditingController _newCrop = TextEditingController();
  final TextEditingController _newVariety = TextEditingController();
  final TextEditingController _newGrower = TextEditingController();
  final TextEditingController _newNotes = TextEditingController();
  var _newYoungSamplesProvided = true;
  var _newOldSamplesProvided = true;
  double? latitude;
  double? longitude;

  List<String> locations = [];
  List<String> cultivationList = [];
  List<String> growerList = [];
  List<String> popUpMenuList = [];
  List<String> treatmentList = [];
  List<String> cropList = [];
  List<String> varietyList = [];

  LatLng? userLocation;

  final FocusNode _growerFocusNode = FocusNode();
  final FocusNode _farmFocusNode = FocusNode();
  final FocusNode _fieldFocusNode = FocusNode();
  final FocusNode _treatmentFocusNode = FocusNode();
  final FocusNode _cropFocusNode = FocusNode();
  final FocusNode _varietyFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _firstRequiredRowKey = GlobalKey();
  final GlobalKey _secondRequiredRowKey = GlobalKey();
  final GlobalKey _secondOptionalRowKey = GlobalKey();
  final GlobalKey _notesKey = GlobalKey();

  final GlobalKey<PopupMenuButtonState<int>> cultivationPopupKey = GlobalKey();
  DateTime? dateTime;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getData();
  }

  void setSampleToEdit(
      {DBSampleModelData? sample, SampleWithUserModel? existingSample}) {
    if (sample != null) {
      setState(() {
        if (sample.sampleDate != null) {
          _newSampleDate.text = DateFormat.yMd().format(sample.sampleDate!);
        }
        dateTime = sample.sampleDate;
        _newLocationTitle.text = sample.locationPlot;
        _newCultivation.text = sample.cultivation;
        _newCrop.text = sample.crop;
        _newGrower.text = sample.grower;
        _newTreatment.text = sample.treatment;
        _newVariety.text = sample.variety ?? "";
        _newNotes.text = sample.notes;
        _newYoungSamplesProvided = sample.youngSamplesProvided;
        _newOldSamplesProvided = sample.oldSamplesProvided;
        latitude = sample.latitude;
        longitude = sample.longitude;
      });
    } else if (existingSample != null) {
      setState(() {
        if (existingSample.sample.sampleDate != null) {
          _newSampleDate.text =
              DateFormat.yMd().format(existingSample.sample.sampleDate!);
          dateTime = existingSample.sample.sampleDate!;
        }
        _newLocationTitle.text = existingSample.sample.farm;
        _newCultivation.text = existingSample.sample.field;
        _newCrop.text = existingSample.sample.crop;
        _newVariety.text = existingSample.sample.variety ?? "";
        _newGrower.text = existingSample.sample.grower ?? "";
        _newNotes.text = existingSample.sample.notes;
        _newYoungSamplesProvided =
            existingSample.sample.youngSampleBarcode != null;
        _newOldSamplesProvided = existingSample.sample.oldSampleBarcode != null;
        latitude = existingSample.sample.location?.latitude;
        longitude = existingSample.sample.location?.longitude;
      });
    }
  }

  Future<void> getUserLocation() async {
    try {
      userLocation = await locationService
          .getSingleLocation()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (widget.existingSampleToEdit != null) {
        setSampleToEdit(existingSample: widget.existingSampleToEdit!);
      } else if (widget.changeId == null && widget.populateFields) {
        await getUnfinishedSampleIfExists();
      }
      await getCompany();
      getUserLocation();
    } on FirebaseException catch (e) {
      showTwoButtonAlertDialog(
          context,
          "Try again",
          () {
            Navigator.pop(context);
            getData();
          },
          "Go back",
          () {
            Navigator.pop(context);
            context.tryPop();
          },
          "Error",
          e.message ?? "Unknown error.");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future getUnfinishedSampleIfExists() async {
    try {
      var sample = await sampleService.getUnfinishedSample();
      if (sample != null) {
        if (sample.sampleDate != null) {
          _newSampleDate.text = DateFormat.yMd().format(sample.sampleDate!);
          dateTime = sample.sampleDate!;
        }
        _newLocationTitle.text = sample.locationPlot;
        _newCultivation.text = sample.cultivation;
        _newCrop.text = sample.crop;
        _newVariety.text = sample.variety ?? "";
        _newGrower.text = sample.grower;
        _newTreatment.text = sample.treatment;
        _newNotes.text = sample.notes;
        _newYoungSamplesProvided = sample.youngSamplesProvided;
        _newOldSamplesProvided = sample.oldSamplesProvided;
        latitude = sample.latitude;
        longitude = sample.longitude;
        setState(() {});
      }
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
    }
  }

  Future getCompany() async {
    var crops = await setupCropAndVariety();
    setState(() {
      cropList = crops;
      growerList = widget.farm.growers.keys.toList();
    });
    //get lists

    popUpMenuList = cultivationList;
  }

  Future<List<String>> setupCropAndVariety() async {
    var keys = widget.farm.crops.keys;
    var localCropList = keys.toList();
    var crops = (await sampleService.getActiveCrops()).map((e) => e.name);
    return {...localCropList, ...crops}.toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return SelectionArea(
      child: GestureDetector(
          onTap: () {
            _newCultivationBoxController.close();
            _newCropBoxController.close();
            _newVarietyBoxController.close();
            _newGrowerBoxController.close();
            _newLocationBoxController.close();
            _notesFocusNode.unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: BackButton(
                color: Colors.white,
                onPressed: () {
                  context.goNamed(DashboardScreen.id);
                },
              ),
              backgroundColor: AppColors.appPrimaryGreen,
              centerTitle: true,
              title: Text(widget.existingSampleToEdit != null
                  ? "Edit Sample"
                  : "Collect Sample"),
            ),
            backgroundColor: AppColors.pageBackground,
            body: WillPopScope(
              onWillPop: () async {
                context.go(DashboardScreen.id);
                return false;
              },
              child: SafeArea(
                child: KeyboardVisibilityProvider(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              CustomCard(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Required",
                                            style: TextStyle(
                                                color: AppColors.strongGray,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500))),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      key: _firstRequiredRowKey,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: AutoCompleteTextFormField(
                                            containerKey: _firstRequiredRowKey,
                                            scrollController: _scrollController,
                                            validator: (String? newValue) {
                                              if (newValue?.trim().isEmpty ??
                                                  false) {
                                                return "Please enter a grower";
                                              }
                                              return null;
                                            },
                                            suggestionsBoxController:
                                                _newGrowerBoxController,
                                            focusNode: _growerFocusNode,
                                            controller: _newGrower,
                                            textInputAction:
                                                TextInputAction.done,
                                            floatingLabel: "Grower",
                                            hint: "Enter grower name",
                                            suggestionsCallback:
                                                (searchString) async {
                                              locations = widget.farm
                                                      .growers[searchString]
                                                      ?.toList() ??
                                                  [];
                                              return filterList(
                                                  growerList, searchString);
                                            },
                                            itemBuilder: (context, item) {
                                              return ListTile(
                                                title: Text(item.toString()),
                                              );
                                            },
                                            onSuggestionSelected: (selected) {
                                              _newGrower.text =
                                                  selected.toString();
                                              locations = widget.farm
                                                      .growers[_newGrower.text]
                                                      ?.toList() ??
                                                  [];
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: AutoCompleteTextFormField(
                                            containerKey: _firstRequiredRowKey,
                                            scrollController: _scrollController,
                                            validator: (String? newValue) {
                                              if (newValue?.trim().isEmpty ??
                                                  false) {
                                                return "Please enter a farm";
                                              }
                                              return null;
                                            },
                                            suggestionsBoxController:
                                                _newLocationBoxController,
                                            controller: _newLocationTitle,
                                            focusNode: _farmFocusNode,
                                            textInputAction:
                                                TextInputAction.done,
                                            floatingLabel: "Farm",
                                            hint: "Enter farm name",
                                            suggestionsCallback:
                                                (searchString) async {
                                              cultivationList = widget
                                                      .farm.locations[searchString]
                                                      ?.toList() ??
                                                  [];
                                              return filterLocations(
                                                  locations, searchString);
                                            },
                                            itemBuilder:
                                                (context, String? item) {
                                              return ListTile(
                                                title: Text(item ?? ""),
                                              );
                                            },
                                            onSuggestionSelected:
                                                (String? selected) {
                                              _newLocationTitle.text =
                                                  selected ?? "";
                                              cultivationList = widget
                                                      .farm
                                                      .locations[_newLocationTitle
                                                          .text]
                                                      ?.toList() ??
                                                  [];
                                              debugPrint("cultivationList = $cultivationList");
                                              debugPrint("asdf is ${widget
                                                  .farm
                                                  .locations}");
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      key: _secondRequiredRowKey,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: AutoCompleteTextFormField(
                                            containerKey: _secondRequiredRowKey,
                                            scrollController: _scrollController,
                                            validator: (String? newValue) {
                                              if (newValue?.trim().isEmpty ??
                                                  false) {
                                                return "Please enter a field";
                                              }
                                              return null;
                                            },
                                            suggestionsBoxController:
                                                _newCultivationBoxController,
                                            controller: _newCultivation,
                                            focusNode: _fieldFocusNode,
                                            textInputAction:
                                                TextInputAction.done,
                                            floatingLabel: "Field",
                                            hint: "Enter field name",
                                            suggestionsCallback:
                                                (searchString) async {
                                              treatmentList = widget
                                                      .farm.fields[searchString]
                                                      ?.toList() ??
                                                  [];
                                              return filterList(cultivationList,
                                                  searchString);
                                            },
                                            itemBuilder: (context, item) {
                                              return ListTile(
                                                title: Text(item.toString()),
                                              );
                                            },
                                            onSuggestionSelected: (selected) {
                                              _newCultivation.text =
                                                  selected.toString();
                                              treatmentList = widget
                                                      .farm
                                                      .fields[
                                                          _newCultivation.text]
                                                      ?.toList() ??
                                                  [];
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: AutoCompleteTextFormField(
                                            containerKey: _secondRequiredRowKey,
                                            scrollController: _scrollController,
                                            validator: (String? newValue) {
                                              if (newValue?.trim().isEmpty ??
                                                  false) {
                                                return "Please enter a crop";
                                              }
                                              return null;
                                            },
                                            suggestionsBoxController:
                                                _newCropBoxController,
                                            controller: _newCrop,
                                            focusNode: _cropFocusNode,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.done,
                                            floatingLabel: "Crop",
                                            hint: "Enter crop name",
                                            suggestionsCallback:
                                                (searchString) async {
                                              varietyList = widget
                                                      .farm.crops[searchString]
                                                      ?.toList() ??
                                                  [];

                                              return filterList(
                                                  cropList, searchString);
                                            },
                                            itemBuilder: (context, item) {
                                              return ListTile(
                                                title: Text(item.toString()),
                                              );
                                            },
                                            onSuggestionSelected: (selected) {
                                              _newCrop.text =
                                                  selected.toString();
                                              varietyList = widget
                                                      .farm.crops[_newCrop.text]
                                                      ?.toList() ??
                                                  [];
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "Samples provided (Select all that apply)"
                                                .toUpperCase(),
                                            style: floatingLabelTextStyle)),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    ChooseSampleYoungAndOldButtons(
                                      onChanged: (isYoung, isOld) {
                                        setState(() {
                                          _newYoungSamplesProvided = isYoung;
                                          _newOldSamplesProvided = isOld;
                                        });
                                      },
                                      isYoung: _newYoungSamplesProvided,
                                      isOld: _newOldSamplesProvided,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              CustomCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Optional",
                                                style: TextStyle(
                                                    color: AppColors.strongGray,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500))),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: AppTextFormField(
                                                controller: _newSampleDate,
                                                floatingLabel: "Sample date",
                                                hint: "Select date",
                                                textInputAction:
                                                    TextInputAction.next,
                                                onTap: _selectYoungDate,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16.0),
                                                child: PrimaryButton(
                                                  type:
                                                      PrimaryButtonType.filled,
                                                  actionType:
                                                      PrimaryButtonActionType
                                                          .positive,
                                                  onPressed: () async {
                                                    try {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      await getUserLocation();
                                                      if (kIsWeb) {
                                                        if (mounted) {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      LocationWidget(
                                                                        initialLocation: latitude != null &&
                                                                                longitude != null
                                                                            ? LatLng(latitude!, longitude!)
                                                                            : userLocation,
                                                                        isPinned: latitude !=
                                                                                null &&
                                                                            longitude !=
                                                                                null,
                                                                        onLocationConfirmed:
                                                                            (LatLng
                                                                                location) {
                                                                          setState(
                                                                              () {
                                                                            longitude =
                                                                                location.longitude;
                                                                            latitude =
                                                                                location.latitude;
                                                                          });
                                                                        },
                                                                      )));
                                                        }
                                                      } else {
                                                        showLocationBottomSheet();
                                                      }
                                                    } catch (e) {
                                                      showOneButtonAlertDialog(
                                                          context, "Ok", () {
                                                        Navigator.pop(context);
                                                      }, "Error", e.toString());
                                                    } finally {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    }
                                                  },
                                                  title: "Set Location",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          key: _secondOptionalRowKey,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: AutoCompleteTextFormField(
                                                containerKey:
                                                    _secondOptionalRowKey,
                                                scrollController:
                                                    _scrollController,
                                                suggestionsBoxController:
                                                    _newVarietyBoxController,
                                                controller: _newVariety,
                                                focusNode: _varietyFocusNode,
                                                floatingLabel: "Variety",
                                                hint: "Enter variety name",
                                                textInputAction:
                                                    TextInputAction.done,
                                                suggestionsCallback:
                                                    (searchString) async {
                                                  return filterList(varietyList,
                                                      searchString);
                                                },
                                                itemBuilder: (context, item) {
                                                  return ListTile(
                                                    title:
                                                        Text(item.toString()),
                                                  );
                                                },
                                                onSuggestionSelected:
                                                    (selected) {
                                                  _newVariety.text =
                                                      selected.toString();
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: AutoCompleteTextFormField(
                                                containerKey:
                                                    _secondOptionalRowKey,
                                                scrollController:
                                                    _scrollController,
                                                suggestionsBoxController:
                                                    _newTreatmentBoxController,
                                                controller: _newTreatment,
                                                focusNode: _treatmentFocusNode,
                                                textInputAction:
                                                    TextInputAction.next,
                                                floatingLabel: "Treatment",
                                                hint: "Enter treatment name",
                                                suggestionsCallback:
                                                    (searchString) async {
                                                  return filterList(
                                                      treatmentList,
                                                      searchString);
                                                },
                                                itemBuilder: (context, item) {
                                                  return ListTile(
                                                    title:
                                                        Text(item.toString()),
                                                  );
                                                },
                                                onSuggestionSelected:
                                                    (selected) {
                                                  _newTreatment.text =
                                                      selected.toString();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    AppTextFormField(
                                      key: _notesKey,
                                      containerKey: _notesKey,
                                      scrollController: _scrollController,
                                      controller: _newNotes,
                                      keyboardType: TextInputType.multiline,
                                      focusNode: _notesFocusNode,
                                      minLines: 6,
                                      showClearButton: false,
                                      floatingLabel: "Notes",
                                      hint: "Add notes",
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ...(widget.existingSampleToEdit != null
                                  ? [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: TextButton(
                                            onPressed: () {
                                              saveSample(context);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor:
                                                  AppColors.appPrimaryGreen,
                                            ),
                                            child: const Text("Save"),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: TextButton(
                                            onPressed: () async {
                                              var sample = widget
                                                  .existingSampleToEdit!.sample;
                                              if (sample.youngSampleBarcode ==
                                                      null ||
                                                  sample.oldSampleBarcode ==
                                                      null) {
                                                showTwoButtonAlertDialog(
                                                  context,
                                                  "Yes",
                                                  () {
                                                    Navigator.pop(context);
                                                    reclaimBarcodes(context);
                                                  },
                                                  "No",
                                                  () {
                                                    Navigator.pop(context);
                                                  },
                                                  "Reclaim barcodes",
                                                  "Are you sure you want to reclaim the barcode?",
                                                );
                                                return;
                                              }
                                              var result = await showDialog<
                                                      Map<String, dynamic>>(
                                                  context: context,
                                                  builder: (context) {
                                                    return ReclaimBarcodesDialog(
                                                      sample: widget
                                                          .existingSampleToEdit!
                                                          .sample,
                                                    );
                                                  });
                                              if (!mounted) return;
                                              if (result == null) return;
                                              var reclaimYoungBarcode =
                                                  result["reclaimYoungBarcode"];
                                              var reclaimOldBarcode =
                                                  result["reclaimOldBarcode"];
                                              if (reclaimYoungBarcode == null &&
                                                  reclaimOldBarcode == null) {
                                                return;
                                              }
                                              var shouldReclaimAndDeleteSample = (sample
                                                              .youngSampleBarcode !=
                                                          null &&
                                                      sample.oldSampleBarcode !=
                                                          null &&
                                                      reclaimYoungBarcode &&
                                                      reclaimOldBarcode) ||
                                                  (sample.youngSampleBarcode !=
                                                          null &&
                                                      sample.oldSampleBarcode ==
                                                          null &&
                                                      reclaimYoungBarcode) ||
                                                  (sample.oldSampleBarcode !=
                                                          null &&
                                                      sample.youngSampleBarcode ==
                                                          null &&
                                                      reclaimOldBarcode);
                                              if (shouldReclaimAndDeleteSample) {
                                                reclaimBarcodes(context);
                                              } else {
                                                reclaimOneBarcode(
                                                    context,
                                                    reclaimYoungBarcode ??
                                                        reclaimOldBarcode);
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.red,
                                            ),
                                            child:
                                                const Text("Reclaim barcodes"),
                                          ),
                                        ),
                                      )
                                    ]
                                  : [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: PrimaryButton(
                                            type: PrimaryButtonType.filled,
                                            actionType: PrimaryButtonActionType
                                                .positive,
                                            onPressed: () {
                                              saveSample(context);
                                            },
                                            title: "Create New Label",
                                            icon: const Icon(
                                              Icons.add,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                              const SizedBox(height: 32),
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
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void reclaimBarcodes(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await sampleService.reclaimSampleBarcodesToCompany(
          widget.existingSampleToEdit!.sample.id, widget.farm.id);
      if (!mounted) return;
      context.pop(EditSampleResult.reclaimedBarcodes);
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showOneButtonAlertDialog(context,
          "An error occurred while reclaiming the barcodes. Please try again.",
          () {
        Navigator.pop(context);
      }, "OK", "Error");
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void reclaimOneBarcode(BuildContext context, bool youngBarcode) async {
    try {
      setState(() {
        isLoading = true;
      });
      await sampleService.reclaimOneSampleBarcodeToCompany(
          widget.existingSampleToEdit!.sample.id, widget.farm.id, youngBarcode);
      var sample =
          await sampleService.getSample(widget.existingSampleToEdit!.sample.id);
      if (!mounted) return;
      context.pop(sample);
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showOneButtonAlertDialog(context,
          "An error occurred while reclaiming the barcodes. Please try again.",
          () {
        Navigator.pop(context);
      }, "OK", "Error");
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void _selectYoungDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateTime != null ? dateTime! : DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now().subtract(const Duration(days: 90)),
        lastDate: DateTime(2101));
    if (picked != null) {
      dateTime = picked;
      _newSampleDate.text = DateFormat.yMd().format(dateTime!);
    }
  }

  Future<void> saveSample(BuildContext context) async {
    if (!(_formKey.currentState != null &&
        _formKey.currentState!.validate() &&
        (_newYoungSamplesProvided || _newOldSamplesProvided))) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    String uuid;
    if (widget.existingSampleToEdit != null) {
      uuid = widget.existingSampleToEdit!.sample.id;
    } else {
      uuid = const Uuid().v4();
    }
    if (widget.changeId == null) {
      try {
        await sampleService.saveSampleFieldsData(
            _newLocationTitle.text.trim(),
            _newCultivation.text.trim(),
            _newTreatment.text.trim(),
            _newCrop.text.trim(),
            _newVariety.text.trim(),
            _newGrower.text.trim(),
            widget.user,
            widget.farm);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (e is TimeoutException ||
            e.toString() == Constants.noConnectionExceptionMessage) {
          showOneButtonAlertDialog(context, "Ok", () {
            Navigator.pop(context);
            context.tryPop();
          }, "No Connection", "Try again later.");
        } else {
          showTwoButtonAlertDialog(
              context,
              "Try again",
              () {
                Navigator.pop(context);
                saveSample(context);
              },
              "Cancel",
              () {
                Navigator.pop(context);
              },
              "Error",
              e.toString());
        }
        return;
      }
      try {
        await sampleService.saveSampleFirstStepData(
            uuid,
            _newSampleDate.text.isNotEmpty
                ? DateFormat.yMd().parse(_newSampleDate.text.trim())
                : null,
            _newLocationTitle.text.trim(),
            _newCultivation.text.trim(),
            _newTreatment.text.trim(),
            _newCrop.text.trim(),
            _newVariety.text.isNotEmpty ? _newVariety.text.trim() : null,
            _newGrower.text.trim(),
            _newNotes.text.trim(),
            latitude,
            longitude,
            _newYoungSamplesProvided,
            _newOldSamplesProvided);
      } catch (exception, stacktrace) {
        getIt
            .get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
      }
    }
    if (!mounted) return;
    var sampleCreationWrapper = SampleCreationWrapper(
      id: uuid,
      changeId: widget.changeId,
      sampleDate: _newSampleDate.text.isNotEmpty
          ? DateFormat.yMd().parse(_newSampleDate.text.trim())
          : null,
      locationPlot: _newLocationTitle.text.trim(),
      cultivation: _newCultivation.text.trim(),
      treatment: _newTreatment.text.trim(),
      crop: _newCrop.text.trim(),
      variety: _newVariety.text.trim(),
      notes: _newNotes.text.trim(),
      grower: _newGrower.text.trim(),
      latitude: latitude,
      longitude: longitude,
      hasYoungSample: _newYoungSamplesProvided,
      hasOldSample: _newOldSamplesProvided,
      youngSampleBarcode:
          widget.existingSampleToEdit?.sample.youngSampleBarcode,
      oldSampleBarcode: widget.existingSampleToEdit?.sample.oldSampleBarcode,
    );
    try {
      await sampleService.createSampleAndSaveData(
          sampleCreationWrapper.changeId,
          sampleCreationWrapper.id,
          sampleCreationWrapper.sampleDate,
          sampleCreationWrapper.locationPlot,
          sampleCreationWrapper.cultivation,
          sampleCreationWrapper.treatment,
          capitalize(sampleCreationWrapper.crop),
          sampleCreationWrapper.variety,
          sampleCreationWrapper.grower,
          sampleCreationWrapper.hasYoungSample,
          sampleCreationWrapper.hasOldSample,
          sampleCreationWrapper.notes,
          sampleCreationWrapper.latitude,
          sampleCreationWrapper.longitude,
          widget.user,
          widget.farm);
      SampleModel? editedSample =
          await sampleService.getSample(sampleCreationWrapper.id);
      if (!kIsWeb) {
        await AppDatabase().deleteAllSamples();
      }
      isLoading = false;
      if (!mounted) return;
      if (sampleCreationWrapper.changeId != null) {
        if (context.canPop()) {
          context.pop(editedSample);
        }
      } else {
        context.pushNamed(SampleSubmittedScreen.id,
            extra: SampleSubmittedScreenArguments(
              uuid: sampleCreationWrapper.id,
              farm: widget.farm,
            ));
      }
    } on NoBarcodesException catch (_) {
      showTwoButtonAlertDialog(
          context,
          "Buy Barcodes",
          () {
            Navigator.pop(context);
            context.goNamed(PurchaseBarcodesScreen.id);
          },
          "Go Back",
          () {
            Navigator.pop(context);
            context.pop();
          },
          "Error",
          "This company doesn’t have any barcodes available. You have to buy barcodes before collecting new samples. We've saved your sample so you can come back to it later.");
    } catch (exception, stacktrace) {
      debugPrint("e -> $exception");
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      showOneButtonAlertDialog(context, "Ok", () {
        Navigator.pop(context);
      }, "Error", "There was an error");
    }
    setState(() {
      isLoading = false;
    });
  }

  List<String> filterList(List<String> inputlist, String sortText) {
    List<String> outputList = inputlist
        .where((o) =>
            o.trim().isNotEmpty &&
            o.toLowerCase().contains(sortText.toLowerCase()))
        .toList()
      ..sort((a, b) => a.compareTo(b));
    return outputList;
  }

  List<String> filterLocations(List<String> locations, String sortText) {
    List<String> locationsToFilter = [...locations];
    return locationsToFilter
        .where((element) =>
            element.trim().isNotEmpty &&
            element.toLowerCase().contains(sortText.toLowerCase()))
        .toList()
      ..sort((a, b) => a.compareTo(b));
  }

  void showLocationBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.8,
            child: LocationWidget(
              initialLocation: latitude != null && longitude != null
                  ? LatLng(latitude!, longitude!)
                  : userLocation,
              isPinned: latitude != null && longitude != null,
              onLocationConfirmed: (LatLng location) {
                setState(() {
                  longitude = location.longitude;
                  latitude = location.latitude;
                });
              },
            ),
          );
        });
  }
}

enum SampleEditType { assignBarcodes, finish }
