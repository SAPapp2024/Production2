import 'package:agro_k/models/document_serializer.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';

part 'grower_with_user_emails_to_notify_model.g.dart';

@JsonSerializable()
@DocumentSerializer()
class GrowerWithUserEmailsToNotifyModel {
  final String grower;
  final List<String> userEmails;

  GrowerWithUserEmailsToNotifyModel(this.grower, this.userEmails);

  factory GrowerWithUserEmailsToNotifyModel.fromJson(Map<String, dynamic> json) => _$GrowerWithUserEmailsToNotifyModelFromJson(json);
  Map<String, dynamic> toJson() => _$GrowerWithUserEmailsToNotifyModelToJson(this);

}