import 'package:agro_k/models/document_serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invites_model.g.dart';

@JsonSerializable()
@DocumentSerializer()
class InvitesModel {
  bool isAdmin;
  String email;
  DocumentReference invitedTo;

  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: firestoreTimestampToJson)
  DateTime created;

  InvitesModel({required this.isAdmin, required this.email, required this.invitedTo, required this.created});

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  factory InvitesModel.fromJson(Map<String, dynamic> json) => _$InvitesModelFromJson(json);
  Map<String, dynamic> toJson() => _$InvitesModelToJson(this);
}
