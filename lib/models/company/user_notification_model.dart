
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../document_serializer.dart';
import '../document_serializer_nullable.dart';

part 'user_notification_model.g.dart';

@JsonSerializable()
@DocumentSerializerNullable()
@DocumentSerializer()
class UserNotificationModel {
  String title;
  String description;
  @JsonKey(fromJson: dateTimeFromTimestampNullable, toJson: firestoreTimestampToJson, includeIfNull: false)
  DateTime? createdAt;

  UserNotificationModel({
    required this.title,
    required this.description,
    this.createdAt,
  });

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  static DateTime? dateTimeFromTimestampNullable(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  factory UserNotificationModel.fromJson(Map<String, dynamic> json) => _$UserNotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserNotificationModelToJson(this);

}