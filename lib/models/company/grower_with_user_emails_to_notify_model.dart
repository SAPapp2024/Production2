import 'package:agro_k/models/document_serializer.dart';
import 'package:json_annotation/json_annotation.dart';

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