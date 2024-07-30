import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/sample_model.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../user/user_model.dart';

class SampleWithUserModel {
  SampleModel sample;
  UserModel? user;
  UserModel? assignedTo;

  SampleWithUserModel({
    required this.sample,
    required this.user,
    required this.assignedTo,
  });
}

Future<List<List<dynamic>>> mapSampleToJsonWithCompany(
    List<SampleWithUserModel> samples) async {
  Map<String, CompanyModel?> companyMap = {};
  List<List<dynamic>> mapList = [];
  for (var sampleWithUserModel in samples) {
    SampleModel sample = sampleWithUserModel.sample;
    UserModel? user = sampleWithUserModel.user;
    UserModel? assignedTo = sampleWithUserModel.assignedTo;
    CompanyModel? companyModel;
    if (sample.companyReference != null) {
      if (!companyMap.containsKey(sample.companyReference!.id)) {
        try {
          companyModel = CompanyModel.fromJson((await sample.companyReference!.get())
              .data() as Map<String, dynamic>);
          companyMap[sample.companyReference!.id] = companyModel;
        } catch (e) {
          debugPrint("$e");
          companyMap[sample.companyReference!.id] = null;
        }
      } else {
        companyModel = companyMap[sample.companyReference!.id];
      }
    }
    String? sampleDate;
    try {
      if (sample.sampleDate != null) {
        sampleDate = DateFormat.yMd().format(sample.sampleDate!);
      }
    } catch (_) {}
    String? createdDate;
    try {
      createdDate = DateFormat.yMd().format(sample.createdDate);
    } catch (_) {}
    mapList.add([
      sample.youngSampleBarcode,
      sample.oldSampleBarcode,
      sample.companyName,
      sample.grower,
      sample.farm,
      sample.field,
      sample.crop,
      sample.treatment,
      sample.variety,
      sample.notes,
      sampleDate,
      createdDate,
      sample.status,
      user?.getFullName(),
      user?.email,
      assignedTo?.getFullName(),
      assignedTo?.email,
      companyModel?.companyAdminUserInfo?.fullName,
      companyModel?.companyAdminUserInfo?.email,
     ]);
  }
  return mapList;
}
