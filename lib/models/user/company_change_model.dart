import 'package:agro_k/models/document_serializer.dart';
import 'package:agro_k/models/company/company_admin_user_info.dart';
import 'package:agro_k/models/company/company_change_with_user_model.dart';
import 'package:agro_k/models/user/company_change_state_model.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'company_change_model.g.dart';

@JsonSerializable(explicitToJson: true)
@DocumentSerializer()
class CompanyChangeModel {
  String id;
  @JsonKey()
  CompanyChangeStateModel oldState;
  @JsonKey()
  CompanyChangeStateModel newState;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: firestoreTimestampToJson)
  DateTime changeDate;
  DocumentReference? changedBy;

  CompanyChangeModel(
      {required this.id,
      required this.oldState,
      required this.newState,
      required this.changeDate,
      required this.changedBy});

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  static CompanyChangeModel? fromJsonAndCopy({required String id, required DateTime changeDate,
      required DocumentReference? changedBy, required Map<String, dynamic> companyDocData,
      PhoneModel? phone,
      PhoneModel? alternatePhone,
      String? address,
      String? city,
      String? name,
      String? state,
      String? province,
      String? zipcode,
    String? country,
      CompanyAdminUserInfo? companyAdminUserInfo, String? type}) {
    var oldState = CompanyChangeStateModel.fromJsonAndCopy(companyDocData);
    var newState = CompanyChangeStateModel.fromJsonAndCopy(companyDocData,
        name: name,
        address: address,
        phone: phone,
        alternatePhone: alternatePhone,
        city: city,
        state: state,
        province: province,
        zipcode: zipcode,
        country: country,
        companyAdminUserInfo: companyAdminUserInfo, type: type);
    if (oldState == newState) return null;
    return CompanyChangeModel(
      id: id,
      changeDate: changeDate,
      changedBy: changedBy,
      oldState: oldState,
      newState: newState,
    );
  }

  factory CompanyChangeModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyChangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyChangeModelToJson(this);

  Future<CompanyChangeWithUserModel> toCompanyWithUserModel() async {
    UserModel? user;
    if (changedBy != null) {
      DocumentSnapshot userSnapshot = await changedBy!.get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? data =
            userSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          user = UserModel.fromJson(data);
        }
      }
    }
    return CompanyChangeWithUserModel(companyChangeModel: this, user: user);
  }
}
