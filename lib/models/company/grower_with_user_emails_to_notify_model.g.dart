// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grower_with_user_emails_to_notify_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowerWithUserEmailsToNotifyModel _$GrowerWithUserEmailsToNotifyModelFromJson(
        Map<String, dynamic> json) =>
    GrowerWithUserEmailsToNotifyModel(
      json['grower'] as String,
      (json['userEmails'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$GrowerWithUserEmailsToNotifyModelToJson(
        GrowerWithUserEmailsToNotifyModel instance) =>
    <String, dynamic>{
      'grower': instance.grower,
      'userEmails': instance.userEmails,
    };
