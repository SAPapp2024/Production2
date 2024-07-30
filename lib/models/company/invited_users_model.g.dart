// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invited_users_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitedUsersModel _$InvitedUsersModelFromJson(Map<String, dynamic> json) =>
    InvitedUsersModel(
      invitedEmail: json['invitedEmail'] as String,
      invitesReference: const DocumentSerializer()
          .fromJson(json['invitesReference'] as DocumentReference<Object?>),
      created:
          InvitedUsersModel.dateTimeFromTimestamp(json['created'] as Timestamp),
    );

Map<String, dynamic> _$InvitedUsersModelToJson(InvitedUsersModel instance) =>
    <String, dynamic>{
      'invitedEmail': instance.invitedEmail,
      'invitesReference':
          const DocumentSerializer().toJson(instance.invitesReference),
      'created': InvitedUsersModel.firestoreTimestampToJson(instance.created),
    };
