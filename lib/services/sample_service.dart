import 'dart:async';

import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/models/company/admin_info_model.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/grower_with_user_emails_to_notify_model.dart';
import 'package:agro_k/models/company/sample_change_model.dart';
import 'package:agro_k/models/company/sample_change_state_model.dart';
import 'package:agro_k/models/company/sample_location_model.dart';
import 'package:agro_k/models/company/sample_model.dart';
import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/models/crop_model.dart';
import 'package:agro_k/models/global_barcode_list_item_model.dart';
import 'package:agro_k/models/min_max_table_item_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/services/Database/app_database.dart';
import 'package:agro_k/utilities/assigned_barcodes.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart' as prefix;
import 'package:agro_k/utilities/exceptions.dart';
import 'package:agro_k/utilities/function_utils/date_utils.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/sample_sorting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:typesense/typesense.dart';
import 'package:uuid/uuid.dart';

import '../utilities/constants.dart';

@injectable
class SampleService {
  Future createSample(
      String? changeId,
      String uuid,
      DateTime? newSampleDate,
      String newLocationPlot,
      String newCultivation,
      String newTreatment,
      String newCrop,
      String? newVariety,
      String newGrower,
      bool youngSample,
      bool oldSample,
      String notes,
      double? latitude,
      double? longitude,
      UserModel user,
      CompanyModel farm) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var farmRef = farm.getReference();
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);
      DocumentReference<Map<String, dynamic>> sampleRef = FirebaseFirestore.instance.collection('samples').doc(uuid);
      var newSampleData = <String, dynamic>{
        'id': uuid,
        'sampleDate': newSampleDate,
        'farm': newLocationPlot,
        'field': newCultivation,
        'treatment': newTreatment,
        'crop': newCrop,
        'variety': newVariety,
        'grower': newGrower,
        'notes': notes,
      };
      if (latitude != null && longitude != null) {
        newSampleData['location'] = SampleLocationModel(latitude: latitude, longitude: longitude).toJson();
      }
      AssignedBarcodes? newBarcodes;
      if (changeId == null) {
        var farmDoc = await transaction.get(farmRef);
        var data = farmDoc.data() as Map<String, dynamic>?;
        if (data == null) {
          throw Exception("Farm not found");
        }
        List<String> assignableBarcodes =
            (data["assignableBarcodes"] as List<dynamic>).map((e) => e as String).toList();
        var amountNeeded = youngSample && oldSample ? 2 : 1;
        if (assignableBarcodes.length < amountNeeded) {
          throw NoBarcodesException();
        }
        var barcodesToAssign = assignableBarcodes.take(amountNeeded).toList();
        transaction.update(farmRef, {"assignableBarcodes": FieldValue.arrayRemove(barcodesToAssign)});
        String? youngSampleBarcode;
        String? oldSampleBarcode;
        if (youngSample) {
          youngSampleBarcode = barcodesToAssign.first;
          barcodesToAssign.removeAt(0);
        }
        if (oldSample) {
          oldSampleBarcode = barcodesToAssign.first;
          barcodesToAssign.removeAt(0);
        }
        newSampleData['youngSampleBarcode'] = youngSampleBarcode;
        newSampleData['oldSampleBarcode'] = oldSampleBarcode;
        newBarcodes = AssignedBarcodes(youngSampleBarcode: youngSampleBarcode, oldSampleBarcode: oldSampleBarcode);
        var companyReference = FirebaseFirestore.instance.collection("companies").doc(farm.id);
        newSampleData['companyReference'] = companyReference;      // DocumentReference
        newSampleData['companyName'] = farm.name;                  // String
        newSampleData['userReference'] = userRef;                  // DocumentReference
        newSampleData['userUid'] = FirebaseAuth.instance.currentUser!.uid; // 👈 add string mirror
        newSampleData['status'] = SampleStatusConstants.userSubmitted;
        newSampleData['createdDate'] = FieldValue.serverTimestamp();        // 👈 true timestamp
        newSampleData['createdDateDMY'] = onlyDMY(DateTime.now());          // (optional) keep date-only for grouping
        newSampleData['printed'] = false;                                    // (optional) explicit default
        newSampleData['prints'] = [];
        newSampleData['userUid'] = FirebaseAuth.instance.currentUser!.uid; // add this
        newSampleData['createdDate'] = FieldValue.serverTimestamp();       // switch to server time
        // (keep createdDateDMY if you still use day-only grouping)

      }

      if (changeId != null) {
        DocumentSnapshot<Map<String, dynamic>> sampleSnapshot = await transaction.get(sampleRef);
        Map<String, dynamic>? sampleData = sampleSnapshot.data();
        if (sampleData != null) {
          SampleModel sample = SampleModel.fromJson(sampleData);
          SampleChangeStateModel oldSampleState = SampleChangeStateModel(
              sampleDate: sample.sampleDate,
              locationPlot: sample.farm,
              cultivation: sample.field,
              crop: sample.crop,
              variety: sample.variety,
              grower: sample.grower,
              notes: sample.notes,
              status: sample.status,
              youngSampleBarcode: sample.youngSampleBarcode,
              oldSampleBarcode: sample.oldSampleBarcode);
          SampleChangeStateModel newSampleState = SampleChangeStateModel(
              sampleDate: newSampleDate,
              locationPlot: newLocationPlot,
              cultivation: newCultivation,
              crop: newCrop,
              variety: newVariety,
              grower: newGrower,
              notes: notes,
              status: sample.status,
              youngSampleBarcode: newBarcodes?.youngSampleBarcode ?? sample.youngSampleBarcode,
              oldSampleBarcode: newBarcodes?.oldSampleBarcode ?? sample.oldSampleBarcode);
          SampleChangeModel change = SampleChangeModel(
              id: changeId,
              oldSampleState: oldSampleState,
              newSampleState: newSampleState,
              changeDate: DateTime.now(),
              changedBy: userRef);
          newSampleData["changes"] = FieldValue.arrayUnion([change.toJson()]);
          transaction.update(sampleRef, newSampleData);
        }
      } else {
        int usedBarcodesCountIncrease = 0;
        transaction.set(sampleRef, newSampleData);
        if (newBarcodes?.youngSampleBarcode != null) {
          transaction
              .update(FirebaseFirestore.instance.collection("global_barcodes").doc(newBarcodes!.youngSampleBarcode), {
            "barcode": newBarcodes.youngSampleBarcode,
            "companyReference": farm.getReference(),
            "companyName": farm.name,
            "sampleReference": sampleRef
          });
          usedBarcodesCountIncrease++;
        }
        if (newBarcodes?.oldSampleBarcode != null) {
          transaction
              .update(FirebaseFirestore.instance.collection("global_barcodes").doc(newBarcodes!.oldSampleBarcode), {
            "barcode": newBarcodes.oldSampleBarcode,
            "companyReference": farm.getReference(),
            "companyName": farm.name,
            "sampleReference": sampleRef
          });
          usedBarcodesCountIncrease++;
        }
        transaction.update(farmRef, {"usedBarcodesCount": FieldValue.increment(usedBarcodesCountIncrease)});
      }
    });
  }

  //update sample sample date, also add changes
  Future<void> updateSampleSampleDate(String id, DateTime newSampleDate, UserModel user) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);
      DocumentReference<Map<String, dynamic>> sampleRef = FirebaseFirestore.instance.collection('samples').doc(id);
      DocumentSnapshot<Map<String, dynamic>> sampleSnapshot = await transaction.get(sampleRef);
      Map<String, dynamic>? sampleData = sampleSnapshot.data();
      if (sampleData != null) {
        SampleModel sample = SampleModel.fromJson(sampleData);
        SampleChangeStateModel oldSampleState = SampleChangeStateModel(
            sampleDate: sample.sampleDate,
            locationPlot: sample.farm,
            cultivation: sample.field,
            crop: sample.crop,
            variety: sample.variety,
            grower: sample.grower,
            notes: sample.notes,
            status: sample.status,
            youngSampleBarcode: sample.youngSampleBarcode,
            oldSampleBarcode: sample.oldSampleBarcode);
        SampleChangeStateModel newSampleState = SampleChangeStateModel(
            sampleDate: newSampleDate,
            locationPlot: sample.farm,
            cultivation: sample.field,
            crop: sample.crop,
            variety: sample.variety,
            grower: sample.grower,
            notes: sample.notes,
            status: sample.status,
            youngSampleBarcode: sample.youngSampleBarcode,
            oldSampleBarcode: sample.oldSampleBarcode);
        SampleChangeModel change = SampleChangeModel(
            id: const Uuid().v4().toString(),
            oldSampleState: oldSampleState,
            newSampleState: newSampleState,
            changeDate: DateTime.now(),
            changedBy: userRef);
        transaction.update(sampleRef, {
          "sampleDate": newSampleDate,
          "changes": FieldValue.arrayUnion([change.toJson()])
        });
      }
    });
  }

  Future<void> saveSampleFieldsData(String newLocationPlot, String newCultivation, String newTreatment, String newCrop,
      String newVariety, String newGrower, UserModel user, CompanyModel farm) async {
    var companyReference = FirebaseFirestore.instance.collection("companies").doc(farm.id);
    await saveFarmLocation(
            locationsField: newLocationPlot, cultivationField: newCultivation, companyReference: companyReference)
        .timeout(Constants.timeoutDuration);
    await createCultivationField(user, companyReference, newCultivation, newTreatment)
        .timeout(Constants.timeoutDuration);
    await createGrowerField(user, companyReference, newGrower, newLocationPlot).timeout(Constants.timeoutDuration);
    await createCropAndVarietyFields(user, companyReference, newCrop, newVariety).timeout(Constants.timeoutDuration);
  }

  Future updateSamplePrinted(List<SampleWithUserModel> samples) async {
    var currentDate = DateTime.now();
    var userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    return Future.wait(samples.map((sampleWithUser) async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var sampleRef = FirebaseFirestore.instance.collection('samples').doc(sampleWithUser.sample.id);
        DocumentSnapshot<Map<String, dynamic>> sampleSnapshot = await transaction.get(sampleRef);
        Map<String, dynamic>? sampleData = sampleSnapshot.data();
        if (sampleData != null) {
          var samplePrint = {"date": currentDate, "userReference": userRef};
          transaction.update(sampleRef, {
            'prints': FieldValue.arrayUnion([samplePrint]),
          });
          sampleWithUser.sample.prints.add(samplePrint);
        }
      });
    }));
  }

  Future saveFarmLocation(
      {required String locationsField,
      required String cultivationField,
      required DocumentReference companyReference}) async {
    companyReference.set({
      'locations': {
        locationsField: FieldValue.arrayUnion(cultivationField.isNotEmpty ? [cultivationField] : [])
      }
    }, SetOptions(merge: true));
  }

  Future<void> saveSampleFirstStepData(
      String uuid,
      DateTime? newSampleDate,
      String newLocationPlot,
      String newCultivation,
      String newTreatment,
      String newCrop,
      String? newVariety,
      String newGrower,
      String notes,
      double? latitude,
      double? longitude,
      bool newYoungSamplesProvided,
      bool newOldSamplesProvided) async {
    if (!kIsWeb) {
      await AppDatabase().saveSample(DBSampleModelData(
        privateId: 1,
        id: uuid,
        sampleDate: newSampleDate,
        locationPlot: newLocationPlot,
        cultivation: newCultivation,
        treatment: newTreatment,
        crop: newCrop,
        variety: newVariety,
        grower: newGrower,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
        youngSamplesProvided: newYoungSamplesProvided,
        oldSamplesProvided: newOldSamplesProvided,
      ));
    }
  }

  Future<CompanyModel> getCompanyFromReference(DocumentReference<Map<String, dynamic>> companyReference) async {
    var doc = await companyReference.get();
    var data = doc.data();
    return CompanyModel.fromJson(data!);
  }

  Future<void> updateSampleLocation(
    String sampleId,
    double latitude,
    double longitude,
  ) async {
    await FirebaseFirestore.instance
        .collection("samples")
        .doc(sampleId)
        .update({'location': SampleLocationModel(latitude: latitude, longitude: longitude).toJson()});
  }

  Future<void> createSampleAndSaveData(
      String? changeId,
      String uuid,
      DateTime? newSampleDate,
      String newLocationPlot,
      String newCultivation,
      String newTreatment,
      String newCrop,
      String? newVariety,
      String newGrower,
      bool youngSampleBarcode,
      bool oldSampleBarcode,
      String notes,
      double? latitude,
      double? longitude,
      UserModel user,
      CompanyModel farm) async {
    await createSample(changeId, uuid, newSampleDate, newLocationPlot, newCultivation, newTreatment, newCrop,
            newVariety, newGrower, youngSampleBarcode, oldSampleBarcode, notes, latitude, longitude, user, farm)
        .timeout(Constants.timeoutDuration);
  }

  Future<DBSampleModelData?> getUnfinishedSample() async {
    if (!kIsWeb) {
      return AppDatabase().getSamples();
    } else {
      return null;
    }
  }

  Future<List<SampleModel>> getCompanySamples(UserModel user, CompanyModel farm) async {
    debugPrint("about to search...");
    var companyReference = FirebaseFirestore.instance.collection("companies").doc(farm.id);
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('samples')
        .where("id", isNull: false)
        .where("companyReference", isEqualTo: companyReference)
        .where("userUid", isEqualTo: FirebaseAuth.instance.currentUser!.uid) // ← 2B goes here
        .orderBy("createdDate", descending: true);                             // ← strongly recommended

    var samples = await query.get();
    debugPrint("samples.docs ${samples.docs}");
    List<SampleModel> sampleList = [];
    for (var sampleDoc in samples.docs) {
      var data = sampleDoc.data();
      debugPrint("data: $data");
      SampleModel sample = SampleModel.fromJson(data);
      sampleList.add(sample);
    }
    return sampleList;
  }

  Future<SampleModel?> getSample(String id) async {
    try {
      var sampleRef = await FirebaseFirestore.instance.collection('samples').doc(id).get();
      var data = sampleRef.data();
      if (data != null) {
        try {
          SampleModel farm = SampleModel.fromJson(data);
          return farm;
        } on Error catch (e) {
          debugPrint("$e");
          return null;
        }
      }
      return null;
    } on FirebaseException catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      rethrow;
    }
  }

  Future updateSampleStatus(String id, String status, prefix.Environment environment) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);
    SampleModel? sample = await getSample(id);
    FieldValue? changesFieldValue;
    if (sample != null) {
      SampleChangeStateModel oldSampleState = SampleChangeStateModel(
          sampleDate: sample.sampleDate,
          locationPlot: sample.farm,
          cultivation: sample.field,
          crop: sample.crop,
          variety: sample.variety,
          grower: sample.grower,
          notes: sample.notes,
          status: sample.status,
          youngSampleBarcode: sample.youngSampleBarcode,
          oldSampleBarcode: sample.oldSampleBarcode);
      SampleChangeStateModel newSampleState = SampleChangeStateModel(
          sampleDate: sample.sampleDate,
          locationPlot: sample.farm,
          cultivation: sample.field,
          crop: sample.crop,
          variety: sample.variety,
          grower: sample.grower,
          notes: sample.notes,
          status: status,
          youngSampleBarcode: sample.youngSampleBarcode,
          oldSampleBarcode: sample.oldSampleBarcode);
      SampleChangeModel change = SampleChangeModel(
          id: const Uuid().v4().toString(),
          oldSampleState: oldSampleState,
          newSampleState: newSampleState,
          changeDate: DateTime.now(),
          changedBy: userRef);
      changesFieldValue = FieldValue.arrayUnion([change.toJson()]);
    }
    DocumentReference<Map<String, dynamic>> sampleDoc = FirebaseFirestore.instance.collection('samples').doc(id);
    await sampleDoc.update({"status": status, "changes": changesFieldValue ?? []});
  }

  Future<void> uploadMinMaxTable(List<MinMaxTableItemModel> data) async {
    await FirebaseFirestore.instance.collection('admin').doc("info").update({
      "mineralMinMaxTable": data.map((e) => e.toJson()),
    });
  }

  Future uploadSampleTests(List<List<dynamic>> data) async {
    var indexPlantPart = 7;
    var indexBarcode = 9;
    var indexStartMinerals = 10;
    var headers = data[1];
    debugPrint("$headers");
    debugPrint("length of data is ${data.length}");
    await Future.wait(data.skip(2).map((row) async {
      var plantPart = row[indexPlantPart].toString().trim();
      var barcode = row[indexBarcode].toString().trim();
      String barcodeQuery;
      String mineralsField;
      if (plantPart == "Leaf (young)") {
        barcodeQuery = "youngSampleBarcode";
        mineralsField = "youngSampleMinerals";
      } else if (plantPart == "Leaf (old)") {
        barcodeQuery = "oldSampleBarcode";
        mineralsField = "oldSampleMinerals";
      } else {
        return Future.value();
      }
      debugPrint("barcode = $barcode");
      if (barcode == "AGX0001") {
        debugPrint("Yes it exists");
      }
      var sampleToUpdateSnapshot = await FirebaseFirestore.instance
          .collection('samples')
          .where("id", isNull: false)
          .where(barcodeQuery, isEqualTo: barcode)
          .get();
      if (sampleToUpdateSnapshot.size > 0) {
        var sampleToUpdate = sampleToUpdateSnapshot.docs[0];
        var minerals = <String, dynamic>{};
        for (var i = indexStartMinerals; i < headers.length; i++) {
          minerals[headers[i]] = row[i];
        }
        await sampleToUpdate.reference.update({mineralsField: minerals});
      }
    }));
  }

  String encodeToFirestore(String text) {
    return text.replaceAll("~", "").replaceAll("*", "").replaceAll("/", "").replaceAll("[", "").replaceAll("]", "");
  }

  Future<List<CropModel>> searchCrops(String id, String name, bool? isActive, CropSortFilterWrapper sortFilter) async {
    List<CropModel> cropList = [];
    var adminInfoRef = await FirebaseFirestore.instance.collection('admin').doc("info").get();
    var data = adminInfoRef.data();
    if (data != null) {
      List<CropModel> crops = (data["crops"] as List<dynamic>)
          .map((e) {
            try {
              return CropModel.fromJson(e);
            } catch (e) {
              return null;
            }
          })
          .where((e) => e != null)
          .map((e) => e!)
          .toList();
      for (var crop in crops) {
        try {
          var passesIdFilter = id.isEmpty || crop.id == id;
          var passesNameFilter = name.isEmpty || crop.name.toLowerCase().contains(name.toLowerCase());
          var passesStatusFilter = isActive == null || crop.isActive == isActive;
          if (passesIdFilter && passesNameFilter && passesStatusFilter) {
            cropList.add(crop);
          }
        } catch (exception, stacktrace) {
          getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
        }
      }
      if (!sortFilter.isEmpty()) {
        sortCropList(sortFilter, cropList);
      }
    }
    return cropList;
  }

  Future<void> addUserToGrowerNotificationList(String grower, String email) async {
    return FirebaseFirestore.instance.collection('grower_notifications').doc(grower).set({
      "grower": grower,
      "userEmails": FieldValue.arrayUnion([email]),
    }, SetOptions(merge: true));
  }

  Future<void> deleteUserFromGrowerNotificationList(String grower, String email) async {
    return FirebaseFirestore.instance.collection('grower_notifications').doc(grower).set({
      "grower": grower,
      "userEmails": FieldValue.arrayRemove([email]),
    }, SetOptions(merge: true));
  }

  Future<List<GrowerWithUserEmailsToNotifyModel>> searchGrowers(
      String title, SortType sortType, CompanyModel farm) async {
    dynamic farmData = (await farm.getReference().get()).data();
    if (farmData == null) throw Exception("Farm doesn't exist");
    farm = CompanyModel.fromJson(farmData);
    var res = farm.growers.keys.where((grower) => grower.toLowerCase().contains(title.toLowerCase())).toList();
    var growerNotifications = ((await farm.getReference().collection("grower_notifications").get()).docs)
        .where((element) => res.contains(element.id));
    var growerList = (await Future.wait(res.map((growerItem) async {
      try {
        Map<String, dynamic>? growerItemNotificationsDoc =
            growerNotifications.firstWhereOrNull((element) => element.id == growerItem) as Map<String, dynamic>?;
        if (growerItemNotificationsDoc != null) {
          return GrowerWithUserEmailsToNotifyModel.fromJson(growerItemNotificationsDoc);
        } else {
          return GrowerWithUserEmailsToNotifyModel(growerItem, []);
        }
      } catch (exception, stacktrace) {
        getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
        return GrowerWithUserEmailsToNotifyModel(growerItem, []);
      }
    })))
        .whereNotNull()
        .toList();

    switch (sortType) {
      case SortType.none:
        break;
      case SortType.asc:
        growerList.sort((a, b) => a.grower.toLowerCase().compareTo(b.grower.toLowerCase()));
        break;
      case SortType.desc:
        growerList.sort((b, a) => a.grower.toLowerCase().compareTo(b.grower.toLowerCase()));
        break;
    }
    return growerList;
  }

  Future<UploadItemsResultInfo> uploadGrowers(List<String> growers, CompanyModel farm) async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      var farmDoc = await transaction.get(farm.getReference());
      var data = farmDoc.data() as Map<String, dynamic>?;
      if (data != null) {
        var farmData = CompanyModel.fromJson(data);
        var farmGrowers = farmData.growers.keys;
        var duplicatedItems = <String>[];
        var newItems = <String>[];
        var globalItems = [...farmGrowers];
        for (var grower in growers) {
          if (globalItems.contains(grower)) {
            duplicatedItems.add(grower);
          } else {
            globalItems.add(grower);
            newItems.add(grower);
          }
        }

        for (var newItem in newItems) {
          farmData.growers[newItem] = [];
        }
        transaction.update(farm.getReference(), {"growers": farmData.growers});
        return UploadItemsResultInfo(duplicatedItems.length, newItems.length);
      }
      throw Exception("Farm doesn't exist");
    });
  }

  Future<void> addGrower(String grower, CompanyModel farm) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var farmDoc = await transaction.get(farm.getReference());
      var data = farmDoc.data() as Map<String, dynamic>?;
      if (data != null) {
        var growers = CompanyModel.fromJson(data).growers;
        if (growers[grower] != null) {
          throw GrowerAlreadyExistsException();
        }
        growers[grower] = [];
        transaction.update(farm.getReference(), {"growers": growers});
      }
    });
  }

  Future<void> deleteGrower(String grower, CompanyModel farm) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var farmDoc = await transaction.get(farm.getReference());
      var data = farmDoc.data() as Map<String, dynamic>?;
      if (data != null) {
        var growers = CompanyModel.fromJson(data).growers;
        growers.remove(grower);
        transaction.update(farm.getReference(), {"growers": growers});
      }
    });
  }

  Future<void> editGrower(String growerOldTitle, String growerNewTitle, CompanyModel farm) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var farmDoc = await transaction.get(farm.getReference());
      var data = farmDoc.data() as Map<String, dynamic>?;
      if (data != null) {
        var growers = CompanyModel.fromJson(data).growers;
        if (growers[growerNewTitle] != null) {
          throw GrowerAlreadyExistsException();
        }
        growers[growerNewTitle] = growers[growerOldTitle] ?? [];
        growers.remove(growerOldTitle);
        transaction.update(farm.getReference(), {"growers": growers});
      }
    });
  }

  Future<List<BarcodeWrapper>> searchBarcodesGlobalTable(
      String barcode, String barcodeType, BarcodeSortFilterWrapper sortFilter) async {
    List<BarcodeWrapper> barcodeList = [];
    var adminInfoRef = await FirebaseFirestore.instance.collection('admin').doc("info").get();
    var data = adminInfoRef.data();
    if (data != null) {
      List<BarcodeWrapper> requestableBarcodes = (data["assignableBarcodes"] as List<dynamic>)
          .map((barcode) => BarcodeWrapper(barcode as String, "Requestable"))
          .toList();
      List<BarcodeWrapper> barcodes = [
        ...requestableBarcodes,
      ];
      for (var item in barcodes) {
        try {
          var passesBarcodeFilter = barcode.isEmpty || item.barcode.toLowerCase().contains(barcode.toLowerCase());
          var passesBarcodeTypeFilter = barcodeType.isEmpty || item.barcodeType == barcodeType;
          if (passesBarcodeFilter && passesBarcodeTypeFilter) {
            barcodeList.add(item);
          }
        } catch (exception, stacktrace) {
          getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
        }
      }
      if (!sortFilter.isEmpty()) {
        sortBarcodeList(sortFilter, barcodeList);
      }
    }
    return barcodeList;
  }

  Future<int> getFarmBarcodeCount(CompanyModel farm) async {
    return FirebaseFirestore.instance
        .collection("global_barcodes")
        .where("companyReference", isEqualTo: farm.getReference())
        .count()
        .get()
        .then((value) => value.count ?? 0);
  }

  Future<List<GlobalBarcodeListItemModel>> searchBarcodes(
      DateTimeRange? createdDateRange,
      DateTimeRange? addedToFarmDateRange,
      String barcode,
      String barcodeType,
      String companyName,
      BarcodeSortFilterWrapper sortFilter,
      CompanyModel? farm) async {
    List<GlobalBarcodeListItemModel> barcodeList = [];
    QuerySnapshot<Map<String, dynamic>> docs;
    if (farm != null) {
      docs = await FirebaseFirestore.instance
          .collection("global_barcodes")
          .where("companyReference", isEqualTo: farm.getReference())
          .get();
    } else {
      docs = await FirebaseFirestore.instance.collection("global_barcodes").get();
    }
    var barcodes = (await Future.wait(docs.docs.map((e) async {
      try {
        return GlobalBarcodeListItemModel.fromJson(e.data());
      } catch (exception, stacktrace) {
        debugPrint("Error parsing barcode $exception");
        getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
        return null;
      }
    })))
        .whereNotNull()
        .toList();
    for (var item in barcodes) {
      try {
        var passesCreatedDateRangeFilter = createdDateRange == null ||
            item.createdDate != null &&
                isDateWithinDateRangeDMY(item.createdDate!, createdDateRange.start, createdDateRange.end);
        var passesAddedToFarmDateRangeFilter = addedToFarmDateRange == null ||
            item.dateAddedToCompany != null &&
                isDateWithinDateRangeDMY(
                    item.dateAddedToCompany!, addedToFarmDateRange.start, addedToFarmDateRange.end);
        var passesBarcodeFilter = barcode.isEmpty || item.barcode.toLowerCase().contains(barcode.toLowerCase());
        var passesCompanyFilter =
            companyName.isEmpty || (item.companyName ?? "").toLowerCase().contains(companyName.toLowerCase());
        if (passesCreatedDateRangeFilter &&
            passesAddedToFarmDateRangeFilter &&
            passesBarcodeFilter &&
            passesCompanyFilter) {
          barcodeList.add(item);
        }
      } catch (exception, stacktrace) {
        getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      }
    }
    if (!sortFilter.isEmpty()) {
      sortGlobalBarcodeList(sortFilter, barcodeList);
    }
    return barcodeList;
  }

  Future<List<SampleWithUserModel>> searchSamples(
      DateTimeRange? collectedDateRange,
      DateTimeRange? createdDateRange,
      String cultivation,
      String locationPlot,
      String status,
      String crop,
      String variety,
      String grower,
      String notes,
      String sampleBarcode,
      String userName,
      String? id,
      String farmName,
      UserModel user,
      CompanyModel? farm,
      SampleSortFilterWrapper sortFilter,
      Client typesenseClient) async {
    try {
      var currentPage = 1;
      const resultsPerPage = 250;
      var searchParams = [];
      if (cultivation.isNotEmpty) {
        searchParams.add({
          "query_by": "field",
          'q': cultivation,
        });
      }
      if (crop.isNotEmpty) {
        searchParams.add({
          "query_by": "crop",
          'q': crop,
        });
      }
      if (status.isNotEmpty) {
        searchParams.add({
          "query_by": "status",
          'q': status,
        });
      }
      if (variety.isNotEmpty) {
        searchParams.add({
          "query_by": "variety",
          'q': variety,
        });
      }
      if (grower.isNotEmpty) {
        searchParams.add({
          "query_by": "grower",
          'q': grower,
        });
      }
      if (notes.isNotEmpty) {
        searchParams.add({
          "query_by": "notes",
          'q': notes,
        });
      }
      if (user.isSuperAdmin && farmName.isNotEmpty) {
        searchParams.add({
          "query_by": "companyName",
          'q': farmName,
        });
      }
      List<SampleModel> hits = [];
      while (true) {
        Map<String, String> searchMap = {};
        if (!user.isSuperAdmin && farm != null) {
          searchMap["filter_by"] =
              "companyReference.path:'companies/${farm.id}'${user.isCompanyAdmin(farm.id) ? "" : " && userReference.path:'users/${user.id}"}";
        }
        if (searchParams.isEmpty) {
          searchMap.addAll({
            'q': '*',
            'per_page': resultsPerPage.toString(),
            'page': currentPage.toString(),
          });
          var results = await typesenseClient.collection("samples").documents.search(searchMap);
          var currentHits = results["hits"] as List<dynamic>;
          // debugPrint("currentHits: $currentHits");
          if (currentHits.isEmpty) {
            break;
          }
          hits.addAll(currentHits
              .map((e) {
                try {
                  return SampleModel.fromTypesenseJson(e["document"]);
                } catch (exception, stacktrace) {
                  getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
                  return null;
                }
              })
              .whereNotNull()
              .toList());
        } else {
          searchMap.addAll({
            'collection': 'samples',
            'per_page': resultsPerPage.toString(),
            'page': currentPage.toString(),
          });
          var results = await typesenseClient.multiSearch.perform({
            'searches': searchParams,
          }, queryParams: searchMap);
          var hitListUnflattened = ((results["results"] as List<dynamic>?) ?? [])
              .map((e) => (e["hits"] as List<dynamic>)
                  .map((e) {
                    try {
                      var data = e["document"];
                      return SampleModel.fromTypesenseJson(data);
                    } catch (exception, stacktrace) {
                      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
                      return null;
                    }
                  })
                  .whereNotNull()
                  .toList())
              .where((element) => element.isNotEmpty)
              .toList();
          var hitList = hitListUnflattened.flattened.toList();
          if (hitList.isEmpty) {
            break;
          }
          hits.addAll(hitList);
        }
        currentPage++;
      }
      hits = hits.toSet().toList();
      var sampleWithUsers = (await Future.wait(hits.map((e) async {
        try {
          return e.toSampleWithUserModel();
        } catch (exception, stacktrace) {
          getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
          return null;
        }
      })))
          .whereNotNull()
          .toList();
      List<SampleWithUserModel> sampleList = [];
      for (var sample in sampleWithUsers) {
        try {
          var passesCollectedDateRangeFilter = collectedDateRange == null ||
              sample.sample.sampleDate != null &&
                  isDateWithinDateRangeDMY(sample.sample.sampleDate!, collectedDateRange.start, collectedDateRange.end);
          var passesCreatedDateRangeFilter = createdDateRange == null ||
              isDateWithinDateRangeDMY(sample.sample.createdDate, createdDateRange.start, createdDateRange.end);
          var passesIdFilter = id == null || sample.sample.id.contains(id);
          var passesLocationPlotFilter =
              locationPlot.isEmpty || sample.sample.farm.toLowerCase().contains(locationPlot.toLowerCase());
          var passesStatusFilter = status.isEmpty || sample.sample.status.toLowerCase().contains(status.toLowerCase());
          var passesCropFilter = crop.isEmpty || sample.sample.crop.toLowerCase().contains(crop.toLowerCase());
          var passesCultivationFilter =
              cultivation.isEmpty || sample.sample.field.toLowerCase().contains(cultivation.toLowerCase());
          var passesVarietyFilter =
              variety.isEmpty || (sample.sample.variety?.toLowerCase().contains(variety.toLowerCase()) ?? false);
          var passesGrowerFilter =
              grower.isEmpty || sample.sample.grower?.toLowerCase().contains(grower.toLowerCase()) == true;
          var passesNotesFilter = notes.isEmpty || sample.sample.notes.toLowerCase().contains(notes.toLowerCase());
          var passesSampleBarcodeFilter = sampleBarcode.isEmpty ||
              sample.sample.youngSampleBarcode?.toLowerCase().contains(sampleBarcode.toLowerCase()) == true ||
              sample.sample.oldSampleBarcode?.toLowerCase().contains(sampleBarcode.toLowerCase()) == true;
          var passesUserNameFilter =
              userName.isEmpty || sample.user?.getFullName()!.toLowerCase().contains(userName.toLowerCase()) == true;
          var companyReference = FirebaseFirestore.instance.collection("companies").doc(farm?.id);
          var passesCompanyReferenceFilter =
              user.isSuperAdmin ? true : sample.sample.companyReference == companyReference;
          var passesCompanyNameFilter =
              farmName.isEmpty || sample.sample.companyName?.toLowerCase().contains(farmName.toLowerCase()) == true;
          if (passesCollectedDateRangeFilter &&
              passesCreatedDateRangeFilter &&
              passesIdFilter &&
              passesLocationPlotFilter &&
              passesStatusFilter &&
              passesCropFilter &&
              passesCultivationFilter &&
              passesVarietyFilter &&
              passesGrowerFilter &&
              passesNotesFilter &&
              passesSampleBarcodeFilter &&
              passesCompanyReferenceFilter &&
              passesUserNameFilter &&
              passesCompanyNameFilter &&
              !sample.sample.deleted) {
            sampleList.add(sample);
          }
        } catch (exception, stacktrace) {
          getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
        }
      }
      if (!sortFilter.isEmpty()) {
        sortSampleList(sortFilter, sampleList);
      }
      return sampleList;
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  void sortCropList(CropSortFilterWrapper sortFilter, List<CropModel> cropList) {
    if (sortFilter.field == CropSortFields.id) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          int? crop1ID = int.tryParse(s1.id);
          int? crop2ID = int.tryParse(s2.id);
          if (crop1ID == null && crop2ID == null) {
            return s1.id.compareTo(s2.id);
          } else if (crop1ID == null) {
            return -1;
          } else if (crop2ID == null) {
            return 1;
          }
          return crop1ID.compareTo(crop2ID);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          int? crop1ID = int.tryParse(s1.id);
          int? crop2ID = int.tryParse(s2.id);
          if (crop1ID == null && crop2ID == null) {
            return -s1.id.compareTo(s2.id);
          } else if (crop1ID == null) {
            return 1;
          } else if (crop2ID == null) {
            return -1;
          }
          return -crop1ID.compareTo(crop2ID);
        });
      }
    } else if (sortFilter.field == CropSortFields.name) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          return s1.name.compareTo(s2.name);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          return -s1.name.compareTo(s2.name);
        });
      }
    } else if (sortFilter.field == CropSortFields.status) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          if (s1.isActive == s2.isActive) {
            return 0;
          } else if (s1.isActive) {
            return 1;
          } else {
            return -1;
          }
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          if (s1.isActive == s2.isActive) {
            return 0;
          } else if (s1.isActive) {
            return -1;
          } else {
            return 1;
          }
        });
      }
    }
  }

  void sortGlobalBarcodeList(BarcodeSortFilterWrapper sortFilter, List<GlobalBarcodeListItemModel> cropList) {
    if (sortFilter.field == BarcodeSortFields.barcode) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          return s1.barcode.compareTo(s2.barcode);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          return -s1.barcode.compareTo(s2.barcode);
        });
      }
    } else if (sortFilter.field == BarcodeSortFields.company) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          return (s1.companyName ?? "").compareTo(s2.companyName ?? "");
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          return -(s1.companyName ?? "").compareTo(s2.companyName ?? "");
        });
      }
    } else if (sortFilter.field == BarcodeSortFields.createdDate) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          if (s1.createdDate == s2.createdDate) {
            return 0;
          } else if (s1.createdDate == null) {
            return -1;
          } else if (s2.createdDate == null) {
            return 1;
          } else {
            return s1.createdDate!.compareTo(s2.createdDate!);
          }
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          if (s1.createdDate == s2.createdDate) {
            return 0;
          } else if (s1.createdDate == null) {
            return 1;
          } else if (s2.createdDate == null) {
            return -1;
          } else {
            return -s1.createdDate!.compareTo(s2.createdDate!);
          }
        });
      }
    } else if (sortFilter.field == BarcodeSortFields.addedToFarmDate) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          if (s1.dateAddedToCompany == s2.dateAddedToCompany) {
            return 0;
          } else if (s1.dateAddedToCompany == null) {
            return -1;
          } else if (s2.dateAddedToCompany == null) {
            return 1;
          } else {
            return s1.dateAddedToCompany!.compareTo(s2.dateAddedToCompany!);
          }
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          if (s1.dateAddedToCompany == s2.dateAddedToCompany) {
            return 0;
          } else if (s1.dateAddedToCompany == null) {
            return 1;
          } else if (s2.dateAddedToCompany == null) {
            return -1;
          } else {
            return -s1.dateAddedToCompany!.compareTo(s2.dateAddedToCompany!);
          }
        });
      }
    } else if (sortFilter.field == BarcodeSortFields.sample) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          if (s1.sampleReference?.id == s2.sampleReference?.id) {
            return 0;
          } else if (s1.sampleReference?.id == null) {
            return -1;
          } else if (s2.sampleReference?.id == null) {
            return 1;
          } else {
            return s1.sampleReference!.id.compareTo(s2.sampleReference!.id);
          }
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          if (s1.sampleReference?.id == s2.sampleReference?.id) {
            return 0;
          } else if (s1.sampleReference?.id == null) {
            return 1;
          } else if (s2.sampleReference?.id == null) {
            return -1;
          } else {
            return -s1.sampleReference!.id.compareTo(s2.sampleReference!.id);
          }
        });
      }
    } else if (sortFilter.field == BarcodeSortFields.shipping) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          if (s1.shipping == s2.shipping) {
            return 0;
          } else {
            return s1.shipping == true ? 1 : -1;
          }
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          if (s1.shipping == s2.shipping) {
            return 0;
          } else {
            return s1.shipping == true ? -1 : 1;
          }
        });
      }
    }
  }

  void sortBarcodeList(BarcodeSortFilterWrapper sortFilter, List<BarcodeWrapper> cropList) {
    if (sortFilter.field == BarcodeSortFields.barcode) {
      if (sortFilter.sortType == SortType.asc) {
        cropList.sort((s1, s2) {
          return s1.barcode.compareTo(s2.barcode);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        cropList.sort((s1, s2) {
          return -s1.barcode.compareTo(s2.barcode);
        });
      }
    }
  }

  void sortSampleList(SampleSortFilterWrapper sortFilter, List<SampleWithUserModel> sampleList) {
    if (sortFilter.field == SampleSortFields.collectedDate) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.sampleDate == null) {
            return 1;
          } else if (s2.sample.sampleDate == null) {
            return -1;
          } else {
            return s1.sample.sampleDate!.compareTo(s2.sample.sampleDate!);
          }
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.sampleDate == null) {
            return 1;
          } else if (s2.sample.sampleDate == null) {
            return -1;
          } else {
            return -s1.sample.sampleDate!.compareTo(s2.sample.sampleDate!);
          }
        });
      }
    } else if (sortFilter.field == SampleSortFields.createdDate) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          return s1.sample.createdDate.compareTo(s2.sample.createdDate);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          return -s1.sample.createdDate.compareTo(s2.sample.createdDate);
        });
      }
    } else if (sortFilter.field == SampleSortFields.farm) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          return s1.sample.farm.compareTo(s2.sample.farm);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          return -s1.sample.farm.compareTo(s2.sample.farm);
        });
      }
    } else if (sortFilter.field == SampleSortFields.status) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          return s1.sample.status.compareTo(s2.sample.status);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          return -s1.sample.status.compareTo(s2.sample.status);
        });
      }
    } else if (sortFilter.field == SampleSortFields.field) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          return s1.sample.field.compareTo(s2.sample.field);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          return -s1.sample.field.compareTo(s2.sample.field);
        });
      }
    } else if (sortFilter.field == SampleSortFields.crop) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          return s1.sample.crop.compareTo(s2.sample.crop);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          return -s1.sample.crop.compareTo(s2.sample.crop);
        });
      }
    } else if (sortFilter.field == SampleSortFields.variety) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.variety == null) {
            return 1;
          } else if (s2.sample.variety == null) {
            return -1;
          } else {
            return s1.sample.variety!.compareTo(s2.sample.variety!);
          }
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.variety == null) {
            return 1;
          } else if (s2.sample.variety == null) {
            return -1;
          } else {
            return -s1.sample.variety!.compareTo(s2.sample.variety!);
          }
        });
      }
    } else if (sortFilter.field == SampleSortFields.grower) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.grower == null) {
            return 1;
          } else if (s2.sample.grower == null) {
            return -1;
          }
          return s1.sample.grower!.compareTo(s2.sample.grower!);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.grower == null) {
            return 1;
          } else if (s2.sample.grower == null) {
            return -1;
          }
          return -s1.sample.grower!.compareTo(s2.sample.grower!);
        });
      }
    } else if (sortFilter.field == SampleSortFields.notes) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.notes.isEmpty) {
            return 1;
          }
          if (s2.sample.notes.isEmpty) {
            return -1;
          }
          return s1.sample.notes.compareTo(s2.sample.notes);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.notes.isEmpty) {
            return 1;
          }
          if (s2.sample.notes.isEmpty) {
            return -1;
          }
          return -s1.sample.notes.compareTo(s2.sample.notes);
        });
      }
    } else if (sortFilter.field == SampleSortFields.sampleBarcodes) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.youngSampleBarcode != null || s2.sample.youngSampleBarcode != null) {
            if (s1.sample.youngSampleBarcode != null && s2.sample.youngSampleBarcode != null) {
              return s1.sample.youngSampleBarcode!.compareTo(s2.sample.youngSampleBarcode!);
            } else if (s1.sample.youngSampleBarcode != null) {
              return -1;
            } else {
              return 1;
            }
          } else if (s1.sample.oldSampleBarcode != null || s2.sample.oldSampleBarcode != null) {
            if (s1.sample.oldSampleBarcode != null && s2.sample.oldSampleBarcode != null) {
              return s1.sample.oldSampleBarcode!.compareTo(s2.sample.oldSampleBarcode!);
            } else if (s1.sample.oldSampleBarcode != null) {
              return -1;
            } else {
              return 1;
            }
          } else {
            return 0;
          }
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.oldSampleBarcode == null) {
            return 1;
          }
          if (s2.sample.oldSampleBarcode == null) {
            return -1;
          }
          return -s1.sample.oldSampleBarcode!.compareTo(s2.sample.oldSampleBarcode!);
        });
      }
    } else if (sortFilter.field == SampleSortFields.user) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          if (s1.user == null) {
            return 1;
          }
          if (s2.user == null) {
            return -1;
          }
          return s1.user!.getFullName()!.compareTo(s2.user!.getFullName()!);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          if (s1.user == null) {
            return 1;
          }
          if (s2.user == null) {
            return -1;
          }
          return -s1.user!.getFullName()!.compareTo(s2.user!.getFullName()!);
        });
      }
    } else if (sortFilter.field == SampleSortFields.company) {
      if (sortFilter.sortType == SortType.asc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.companyName == null) {
            return 1;
          }
          if (s2.sample.companyName == null) {
            return -1;
          }
          return s1.sample.companyName!.compareTo(s2.sample.companyName!);
        });
      } else if (sortFilter.sortType == SortType.desc) {
        sampleList.sort((s1, s2) {
          if (s1.sample.companyName == null) {
            return 1;
          }
          if (s2.sample.companyName == null) {
            return -1;
          }
          return -s1.sample.companyName!.compareTo(s2.sample.companyName!);
        });
      }
    }
  }

  String filterLabelToTypesenseFilter(String filterName) {
    switch (filterName) {
      case "Grower":
        return "grower";
      case "Crop":
        return "crop";
      case "Farm":
        return "farm";
      case "Field":
        return "field";
      case "Sample Date":
        return "sampleDate";
      case "Created Date":
        return "createdDate";
      default:
        return "";
    }
  }

  Future<List<SampleWithUserModel>> searchCompanySamples(
      String filterName, String searchText, UserModel user, CompanyModel farm, Client typesenseClient) async {
    var companyReference = FirebaseFirestore.instance.collection("companies").doc(farm.id);
    Map<String, dynamic> searchBody = {};
    var filter = filterLabelToTypesenseFilter(filterName);
    var currentPage = 1;
    if (searchText.isEmpty || filter == "sampleDate" || filter == "createdDate") {
      searchBody["q"] = "*";
    } else {
      searchBody["q"] = searchText;
    }
    const resultsPerPage = 250;
    searchBody["per_page"] = resultsPerPage.toString();
    if (filter != "sampleDate" && filter != "createdDate") {
      searchBody["query_by"] = filter;
    }
    searchBody["filter_by"] =
        "companyReference.path:'companies/${farm.id}'${user.isCompanyAdmin(farm.id) ? "" : " && userReference.path:'users/${user.id}"}";
    List<SampleWithUserModel> hits = [];
    while (true) {
      searchBody["page"] = currentPage.toString();
      var results = await typesenseClient.collection("samples").documents.search(searchBody);
      var currentHits = results["hits"] as List<dynamic>;
      if (currentHits.isEmpty) {
        break;
      }
      hits.addAll((await Future.wait(currentHits.map((e) async {
        try {
          var sample = SampleModel.fromTypesenseJson(e["document"]);
          return sample.toSampleWithUserModel();
        } catch (exception, stacktrace) {
          getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
          return null;
        }
      })))
          .whereNotNull()
          .toList());
      if (currentHits.length < resultsPerPage) {
        break;
      }
      currentPage++;
    }
    bool userIsAdmin = user.companyReferences
            .where((companyReferenceItem) => companyReferenceItem.companyReference == companyReference)
            .firstOrNull
            ?.isAdmin ??
        false || user.isSuperAdmin;
    List<SampleWithUserModel> sampleList = [];
    for (var sample in hits) {
      if (!sample.sample.deleted && (userIsAdmin || sample.user?.id == user.id || sample.assignedTo?.id == user.id)) {
        if (filter == "grower") {
          if ((sample.sample.grower?.toLowerCase().contains(searchText.toLowerCase()) ?? false)) {
            sampleList.add(sample);
          }
        } else if (filter == "crop") {
          if (sample.sample.crop.toLowerCase().contains(searchText.toLowerCase())) {
            sampleList.add(sample);
          }
        } else if (filter == "locationPlot") {
          if (sample.sample.farm.toLowerCase().contains(searchText.toLowerCase())) {
            sampleList.add(sample);
          }
        } else if (filter == "field") {
          if (sample.sample.field.toLowerCase().contains(searchText.toLowerCase())) {
            sampleList.add(sample);
          }
        } else if (filter == "sampleDate") {
          try {
            final dateRangeSplitted = searchText.split(" - ");
            final sampleDate = sample.sample.sampleDate != null ? onlyDMY(sample.sample.sampleDate!) : null;
            final startDate = onlyDMY(DateFormat.yMd().parse(dateRangeSplitted[0]));
            final endDate = onlyDMY(DateFormat.yMd().parse(dateRangeSplitted[1]));
            if (sampleDate?.millisecondsSinceEpoch != null &&
                sampleDate!.millisecondsSinceEpoch >= startDate.millisecondsSinceEpoch &&
                sampleDate.millisecondsSinceEpoch <= endDate.millisecondsSinceEpoch) {
              sampleList.add(sample);
            }
          } catch (_) {
            sampleList.add(sample);
          }
        } else if (filter == "createdDate") {
          try {
            final createdDate = onlyDMY(sample.sample.createdDate);
            final dateRangeSplitted = searchText.split(" - ");
            final startDate = onlyDMY(DateFormat.yMd().parse(dateRangeSplitted[0]));
            final endDate = onlyDMY(DateFormat.yMd().parse(dateRangeSplitted[1]));
            if (createdDate.millisecondsSinceEpoch >= startDate.millisecondsSinceEpoch &&
                createdDate.millisecondsSinceEpoch <= endDate.millisecondsSinceEpoch) {
              sampleList.add(sample);
            }
          } catch (_) {
            sampleList.add(sample);
          }
        } else {
          sampleList.add(sample);
        }
      }
    }
    sampleList.sort((s1, s2) {
      if (s1.sample.sampleDate == null) {
        return 1;
      }
      if (s2.sample.sampleDate == null) {
        return -1;
      }
      return -s1.sample.sampleDate!.millisecondsSinceEpoch.compareTo(s2.sample.sampleDate!.millisecondsSinceEpoch);
    });
    return sampleList;
  }

  Future<AssignedBarcodes?> getAvailableBarcodes(CompanyModel farm, bool youngSample, bool oldSample) async {
    try {
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        var farmRef = farm.getReference();
        var farmDoc = await transaction.get(farmRef);
        var data = farmDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          List<String> assignableBarcodes =
              (data["assignableBarcodes"] as List<dynamic>).map((e) => e as String).toList();
          var amountNeeded = youngSample && oldSample ? 2 : 1;
          if (assignableBarcodes.length < amountNeeded) {
            throw NoBarcodesException();
          } else {
            var barcodesToAssign = assignableBarcodes.take(amountNeeded).toList();
            transaction.update(farmRef, {"assignableBarcodes": FieldValue.arrayRemove(barcodesToAssign)});
            String? youngSampleBarcode;
            String? oldSampleBarcode;
            if (youngSample) {
              youngSampleBarcode = barcodesToAssign.first;
              barcodesToAssign.removeAt(0);
            }
            if (oldSample) {
              oldSampleBarcode = barcodesToAssign.first;
              barcodesToAssign.removeAt(0);
            }
            var res = AssignedBarcodes(youngSampleBarcode: youngSampleBarcode, oldSampleBarcode: oldSampleBarcode);
            return res;
          }
        }
        return null;
      });
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<void> addBarcodesToCompany(CompanyModel farm, int amount, bool isPurchase) async {
    DateTime currentDate = DateTime.now();
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var adminInfoDoc = await transaction.get(FirebaseFirestore.instance.collection('admin').doc("info"));
      var data = adminInfoDoc.data();
      if (data != null) {
        var adminInfo = AdminInfoModel.fromJson(data);
        if (amount > adminInfo.assignableBarcodes.length) {
          throw NotEnoughBarcodesToBuyException();
        }
        var newBarcodes = adminInfo.assignableBarcodes.take(amount).toList();
        transaction.update(adminInfoDoc.reference, {
          "assignableBarcodes": FieldValue.arrayRemove(newBarcodes),
        });
        transaction.update(farm.getReference(), {
          "assignableBarcodes": FieldValue.arrayUnion(newBarcodes),
          isPurchase ? "barcodesPurchased" : "barcodesAssigned": FieldValue.increment(amount),
        });
        for (var barcode in newBarcodes) {
          transaction.update(FirebaseFirestore.instance.collection("global_barcodes").doc(barcode), {
            "companyReference": farm.getReference(),
            "companyName": farm.name,
            "dateAddedToFarm": currentDate,
            "wasPurchased": isPurchase,
          });
        }
      }
    });
  }

  Future<BarcodeUploadResultInfo> uploadBarcodes(List<GlobalBarcodeListItemModel> barcodes) async {
    try {
      var adminBarcodesDocs = (await Future.wait(
              (await ((FirebaseFirestore.instance.collection('global_barcodes').get()).then((value) => value.docs)))
                  .map((e) async {
        try {
          return GlobalBarcodeListItemModel.fromJson(e.data());
        } catch (exception, stacktrace) {
          getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
          return null;
        }
      })))
          .whereNotNull()
          .toList();
      var requestableList = <String>[];
      var usedBarcodes = adminBarcodesDocs.map((e) => e.barcode).toList();
      var newBarcodes = <GlobalBarcodeListItemModel>[];
      var duplicatedBarcodes = <String>[];
      for (var barcode in barcodes) {
        if (!usedBarcodes.contains(barcode.barcode)) {
          var globalBarcodeItem =
              GlobalBarcodeListItemModel(barcode.barcode, null, null, null, DateTime.now(), null, null, [], false);
          usedBarcodes.add(barcode.barcode);
          newBarcodes.add(globalBarcodeItem);
          requestableList.add(barcode.barcode);
        } else {
          duplicatedBarcodes.add(barcode.barcode);
        }
      }
      WriteBatch firestoreBatch;
      var requestableListSlices = requestableList.slices(500);
      for (var slice in requestableListSlices) {
        firestoreBatch = FirebaseFirestore.instance.batch();
        firestoreBatch.update(FirebaseFirestore.instance.collection('admin').doc("info"), {
          "assignableBarcodes": FieldValue.arrayUnion(slice),
        });
        await firestoreBatch.commit();
      }
      var newBarcodesSlices = newBarcodes.slices(500);
      for (var slice in newBarcodesSlices) {
        firestoreBatch = FirebaseFirestore.instance.batch();
        for (var barcode in slice) {
          firestoreBatch.set(
            FirebaseFirestore.instance.collection("global_barcodes").doc(barcode.barcode),
            barcode.toJson(),
            SetOptions(merge: true),
          );
        }
        await firestoreBatch.commit();
      }
      return BarcodeUploadResultInfo(
          duplicatedBarcodesCount: duplicatedBarcodes.length, newBarcodesCount: newBarcodes.length);
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<void> uploadCrops(List<CropModel> newCrops) async {
    var adminInfoRef = await FirebaseFirestore.instance.collection('admin').doc("info").get();
    var data = adminInfoRef.data();
    if (data != null) {
      List<CropModel> crops = (data["crops"] as List<dynamic>)
          .map((e) {
            try {
              return CropModel.fromJson(e);
            } catch (e) {
              return null;
            }
          })
          .where((e) => e != null)
          .map((e) => e!)
          .toList();
      List<CropModel> cropsWithNoRepeatedNames = crops
          .where((crop) => !newCrops.any((newCrop) => newCrop.name.toLowerCase() == crop.name.toLowerCase()))
          .toList(); //remove crops from Firestore that have the same name as any crop inside newCrops
      List<Map<String, dynamic>> joinedCrops = [
        ...cropsWithNoRepeatedNames.map((e) => e.toJson()),
        ...newCrops.map((e) => e.toJson())
      ];
      await FirebaseFirestore.instance.collection('admin').doc("info").update({
        "crops": joinedCrops,
      });
    }
  }

  Future<void> createCrop(String cropName, bool isActive) async {
    var adminInfoRef = await FirebaseFirestore.instance.collection('admin').doc("info").get();
    var data = adminInfoRef.data();
    if (data != null) {
      List<CropModel> crops = (data["crops"] as List<dynamic>)
          .map((e) {
            try {
              return CropModel.fromJson(e);
            } catch (e) {
              return null;
            }
          })
          .where((e) => e != null)
          .map((e) => e!)
          .toList();
      if (crops.any((newCrop) => newCrop.name.toLowerCase() == cropName.toLowerCase())) {
        throw CropNameAlreadyExistsException();
      }
      int id = 0;
      if (crops.isNotEmpty) {
        for (var crop in crops) {
          int? cropId = int.tryParse(crop.id);
          if (cropId != null && cropId > id) {
            id = cropId;
          }
        }
      }
      id++;
      await FirebaseFirestore.instance.collection('admin').doc("info").update({
        "crops": FieldValue.arrayUnion([CropModel(id: id.toString(), name: cropName, isActive: isActive).toJson()]),
      });
    }
  }

  Future<void> createBarcode(String barcode) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var adminInfoRef = await transaction.get(FirebaseFirestore.instance.collection('admin').doc("info"));
      var globalBarcodeItem =
          await transaction.get(FirebaseFirestore.instance.collection("global_barcodes").doc(barcode));
      if (globalBarcodeItem.data() != null) {
        throw BarcodeAlreadyExistsException();
      }
      if (adminInfoRef.data() != null) {
        var adminInfoData = adminInfoRef.data()!;
        List<String> requestableBarcodes =
            (adminInfoData["assignableBarcodes"] as List<dynamic>).map((e) => e as String).toList();
        if (requestableBarcodes.contains(barcode)) {
          throw BarcodeAlreadyExistsException();
        }
        transaction.update(FirebaseFirestore.instance.collection('admin').doc("info"), {
          "assignableBarcodes": FieldValue.arrayUnion([barcode]),
        });
        transaction.set(FirebaseFirestore.instance.collection('global_barcodes').doc(barcode),
            GlobalBarcodeListItemModel(barcode, null, null, null, DateTime.now(), null, null, [], false).toJson());
      }
    });
  }

  bool verifyBarcodeFormat(String barcode) {
    var barcodeRegex = RegExp("(?=.{7}\$)[A-Z]{3}[0-9]{4}");
    return barcodeRegex.hasMatch(barcode);
  }

  Future<void> sendUnavailableBarcodeEmail(String barcode, CompanyModel farmModel, UserModel userModel) async {
    var mailData = {
      'to': "sean.jacobs@agro-k.rovensa.com",
      'message': {
        "subject": "Unavailable barcode alert",
        "html": """<p>Company ${farmModel.name} tried to scan barcode $barcode which is not available.</p>"""
      },
    };

    await FirebaseFirestore.instance.collection("mail").doc().set(mailData);
  }

  //create cultivation field on the farm profile
  Future<void> createCultivationField(
      UserModel user, DocumentReference companyReference, String cultivationField, String treatmentField) async {
    await companyReference.set({
      'fields': {
        cultivationField: FieldValue.arrayUnion(treatmentField.isNotEmpty ? [treatmentField] : [])
      }
    }, SetOptions(merge: true));
  }

  Future<void> createGrowerField(
      UserModel user, DocumentReference companyReference, String growerField, String locationField) async {
    await companyReference.set({
      'growers': {
        growerField: FieldValue.arrayUnion(locationField.isNotEmpty ? [locationField] : [])
      }
    }, SetOptions(merge: true));
  }

  Future<void> createCropAndVarietyFields(
      UserModel user, DocumentReference companyReference, String cropField, String varietyField) async {
    await companyReference.set({
      'crops': {
        cropField: FieldValue.arrayUnion(varietyField.isNotEmpty ? [varietyField] : [])
      }
    }, SetOptions(merge: true));
  }

  Future<List<CropModel>> getActiveCrops() async {
    try {
      var adminInfoRef = await FirebaseFirestore.instance.collection('admin').doc("info").get();
      var data = adminInfoRef.data();
      if (data != null) {
        return (data["crops"] as List<dynamic>)
            .map((e) {
              try {
                return CropModel.fromJson(e);
              } catch (e) {
                return null;
              }
            })
            .where((e) => e != null && e.isActive)
            .map((e) => e!)
            .toList();
      } else {
        return [];
      }
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<List<CropModel>> getCrops() async {
    try {
      var adminInfoRef = await FirebaseFirestore.instance.collection('admin').doc("info").get();
      var data = adminInfoRef.data();
      if (data != null) {
        return (data["crops"] as List<dynamic>)
            .map((e) {
              try {
                return CropModel.fromJson(e);
              } catch (e) {
                return null;
              }
            })
            .where((e) => e != null)
            .map((e) => e!)
            .toList();
      } else {
        return [];
      }
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<void> editCrop(String id, String name, bool isActive) async {
    var adminInfoRef = await FirebaseFirestore.instance.collection('admin').doc("info").get();
    var data = adminInfoRef.data();
    if (data == null) return;
    List<CropModel> crops = (data["crops"] as List<dynamic>)
        .map((e) {
          try {
            return CropModel.fromJson(e);
          } catch (e) {
            return null;
          }
        })
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
    CropModel? cropById = crops.where((element) => element.id == id).toList().firstOrNull;
    if (cropById != null) {
      cropById.name = name;
      cropById.isActive = isActive;
      await FirebaseFirestore.instance.collection('admin').doc("info").update({"crops": crops.map((e) => e.toJson())});
    }
  }

  Future<void> reclaimSampleBarcodesToCompany(String sampleId, String companyId) async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      var sampleRef = FirebaseFirestore.instance.collection("samples").doc(sampleId);
      var sampleData = (await transaction.get(sampleRef)).data();
      if (sampleData == null) throw Exception("Sample doesn't exist");
      var companyRef = FirebaseFirestore.instance.collection("companies").doc(companyId);
      var companyData = (await transaction.get(companyRef)).data();
      if (companyData == null) throw Exception("Company doesn't exist");
      var sample = SampleModel.fromJson(sampleData);
      if (sample.deleted || sample.deletedAt != null) {
        throw Exception("Sample is already deleted");
      }
      if (sample.youngSampleBarcode == null && sample.oldSampleBarcode == null) {
        throw Exception("Sample doesn't have any barcodes");
      }
      var youngSampleBarcode = sample.youngSampleBarcode;
      var oldSampleBarcode = sample.oldSampleBarcode;
      var barcodesToUpdate = <String>[];
      if (youngSampleBarcode != null) {
        barcodesToUpdate.add(youngSampleBarcode);
      }
      if (oldSampleBarcode != null) {
        barcodesToUpdate.add(oldSampleBarcode);
      }
      var sampleUpdateMap = {
        "deleted": true,
        "deletedAt": DateTime.now(),
        "youngSampleBarcode": FieldValue.delete(),
        "oldSampleBarcode": FieldValue.delete()
      };
      if (barcodesToUpdate.isNotEmpty) {
        Map<String, dynamic> companyUpdateMap = {};
        companyUpdateMap["usedBarcodesCount"] = FieldValue.increment(barcodesToUpdate.length * -1);
        companyUpdateMap["assignableBarcodes"] = FieldValue.arrayUnion(barcodesToUpdate);
        var userReference = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid);
        for (var barcode in barcodesToUpdate) {
          transaction.update(FirebaseFirestore.instance.collection('global_barcodes').doc(barcode), {
            "sampleReference": FieldValue.delete(),
            "reclaimedTimestamps": FieldValue.arrayUnion([
              {"date": DateTime.now(), "userReference": userReference}
            ])
          });
        }
        transaction.update(companyRef, companyUpdateMap);
      }
      transaction.update(sampleRef, sampleUpdateMap);
    });
  }

  Future<void> reclaimOneSampleBarcodeToCompany(String sampleId, String companyId, bool youngBarcode) async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      var sampleRef = FirebaseFirestore.instance.collection("samples").doc(sampleId);
      var sampleData = (await transaction.get(sampleRef)).data();
      if (sampleData == null) throw Exception("Sample doesn't exist");
      var companyRef = FirebaseFirestore.instance.collection("companies").doc(companyId);
      var companyData = (await transaction.get(companyRef)).data();
      if (companyData == null) throw Exception("Company doesn't exist");
      var sample = SampleModel.fromJson(sampleData);
      if (sample.youngSampleBarcode == null && youngBarcode || sample.oldSampleBarcode == null && !youngBarcode) {
        throw Exception("Sample doesn't have any barcodes");
      }
      var barcodeFieldToUpdate = youngBarcode ? "youngSampleBarcode" : "oldSampleBarcode";
      var barcodeReclaimed = youngBarcode ? sample.youngSampleBarcode : sample.oldSampleBarcode;
      var sampleUpdateMap = {
        barcodeFieldToUpdate: FieldValue.delete(),
      };
      Map<String, dynamic> companyUpdateMap = {};
      companyUpdateMap["usedBarcodesCount"] = FieldValue.increment(-1);
      companyUpdateMap["assignableBarcodes"] = FieldValue.arrayUnion([barcodeReclaimed]);
      var userReference = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid);
      transaction.update(FirebaseFirestore.instance.collection('global_barcodes').doc(barcodeReclaimed), {
        "sampleReference": FieldValue.delete(),
        "reclaimedTimestamps": FieldValue.arrayUnion([
          {"date": DateTime.now(), "userReference": userReference}
        ])
      });
      transaction.update(companyRef, companyUpdateMap);
      transaction.update(sampleRef, sampleUpdateMap);
    });
  }

  Future<void> reclaimBarcodes(List<GlobalBarcodeListItemModel> barcodes) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var userReference = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid);
      var barcodeDocsUpToDate = await Future.wait(barcodes.map((e) async {
        try {
          var barcodeDoc =
              await transaction.get(FirebaseFirestore.instance.collection("global_barcodes").doc(e.barcode));
          var barcodeItem = GlobalBarcodeListItemModel.fromJson(barcodeDoc.data()!);
          if (barcodeItem.companyReference == null) {
            throw Exception("Barcode ${barcodeItem.barcode} isn't assigned to a company");
          }
          if (barcodeItem.sampleReference != null) {
            throw Exception("Barcode ${barcodeItem.barcode} is assigned to a sample");
          }
          return barcodeItem;
        } on FirebaseException {
          rethrow;
        } catch (e) {
          throw Exception("Barcode data malformed");
        }
      }));
      for (var barcode in barcodeDocsUpToDate) {
        transaction.update(FirebaseFirestore.instance.collection('global_barcodes').doc(barcode.barcode), {
          "companyReference": FieldValue.delete(),
          "dateAddedToCompany": FieldValue.delete(),
          "companyName": FieldValue.delete(),
          "reclaimedTimestamps": FieldValue.arrayUnion([
            {"date": DateTime.now(), "userReference": userReference}
          ])
        });
      }
      transaction.update(FirebaseFirestore.instance.collection("admin").doc("info"),
          {"assignableBarcodes": FieldValue.arrayUnion(barcodeDocsUpToDate.map((e) => e.barcode).toList())});
      var barcodesGroupedByCompany =
          barcodeDocsUpToDate.groupSetsBy((globalBarcodeItem) => globalBarcodeItem.companyReference);
      for (var company in barcodesGroupedByCompany.keys) {
        transaction.update(FirebaseFirestore.instance.collection("companies").doc(company!.id), {
          "barcodesPurchased": FieldValue.increment(
              barcodesGroupedByCompany[company]!.where((element) => element.wasPurchased == true).length * -1),
          "barcodesAssigned": FieldValue.increment(
              barcodesGroupedByCompany[company]!.where((element) => element.wasPurchased == false).length * -1),
          "assignableBarcodes":
              FieldValue.arrayRemove(barcodesGroupedByCompany[company]!.map((e) => e.barcode).toList())
        });
      }
    });
  }
}

class NoBarcodesException implements Exception {
  NoBarcodesException();

  @override
  String toString() {
    return "No barcodes available";
  }
}

class CropNameAlreadyExistsException implements Exception {
  CropNameAlreadyExistsException();

  @override
  String toString() {
    return "A crop with this name already exists";
  }
}

class BarcodeAlreadyExistsException implements Exception {
  @override
  String toString() {
    return "This barcode already exists";
  }
}

class GrowerAlreadyExistsException implements Exception {
  @override
  String toString() {
    return "This grower already exists";
  }
}

class EmailAlreadyInUseException implements Exception {
  @override
  String toString() {
    return "This email is already in use";
  }
}

class BarcodeWrapper {
  final String barcode;
  final String barcodeType;

  BarcodeWrapper(this.barcode, this.barcodeType);
}

class BarcodeUploadResultInfo {
  final int duplicatedBarcodesCount;
  final int newBarcodesCount;

  BarcodeUploadResultInfo({required this.duplicatedBarcodesCount, required this.newBarcodesCount});
}

class UploadItemsResultInfo {
  final int duplicatedItems;
  final int newItems;

  UploadItemsResultInfo(this.duplicatedItems, this.newItems);
}
