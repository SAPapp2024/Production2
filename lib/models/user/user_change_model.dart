import 'package:agro_k/models/document_serializer.dart';
import 'package:agro_k/models/company/user_change_with_user_model.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/models/user/user_change_state_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_change_model.g.dart';

@JsonSerializable(explicitToJson: true)
@DocumentSerializer()
class UserChangeModel {
  String id;
  @JsonKey()
  UserChangeStateModel oldState;
  @JsonKey()
  UserChangeStateModel newState;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: firestoreTimestampToJson)
  DateTime changeDate;
  DocumentReference? changedBy;

  UserChangeModel(
      {required this.id,
      required this.oldState,
      required this.newState,
      required this.changeDate,
      required this.changedBy});

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  static UserChangeModel? fromJsonAndCopy({required String id, required DateTime changeDate,
      DocumentReference? changedBy, required Map<String, dynamic> userDocJson,
      PhoneModel? phone,
      String? email,
      String? firstName,
      String? lastName,
      String? profileImagePath,
      bool? enabled}) {
    var oldState = UserChangeStateModel.fromJsonAndCopy(userDocJson);
    var newState = UserChangeStateModel.fromJsonAndCopy(userDocJson,
        phone: phone,
        email: email,
        firstName: firstName,
        lastName: lastName,
        profileImagePath: profileImagePath,
        enabled: enabled);
    if (oldState == newState) return null;
    return UserChangeModel(
      id: id,
      changeDate: changeDate,
      changedBy: changedBy,
      oldState: oldState,
      newState: newState,
    );
  }

  factory UserChangeModel.fromJson(Map<String, dynamic> json) =>
      _$UserChangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserChangeModelToJson(this);

  Future<UserChangeWithUserModel> toUserWithUserModel() async {
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
    return UserChangeWithUserModel(userChangeModel: this, user: user);
  }
}
