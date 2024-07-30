import 'package:agro_k/models/document_serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'invited_users_model.g.dart';

@JsonSerializable()
@DocumentSerializer()
class InvitedUsersModel {
  String invitedEmail;
  DocumentReference invitesReference;

  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: firestoreTimestampToJson)
  DateTime created;

  InvitedUsersModel({required this.invitedEmail, required this.invitesReference, required this.created});

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  factory InvitedUsersModel.fromJson(Map<String, dynamic> json) => _$InvitedUsersModelFromJson(json);
  Map<String, dynamic> toJson() => _$InvitedUsersModelToJson(this);
}
