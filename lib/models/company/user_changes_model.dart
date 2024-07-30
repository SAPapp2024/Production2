import 'package:agro_k/models/user/user_change_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_changes_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserChangesModel {
  List<UserChangeModel> changes;

  UserChangesModel({required this.changes});

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  factory UserChangesModel.fromJson(Map<String, dynamic> json) =>
      _$UserChangesModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserChangesModelToJson(this);
}
