// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invites_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitesModel _$InvitesModelFromJson(Map<String, dynamic> json) => InvitesModel(
      isAdmin: json['isAdmin'] as bool,
      email: json['email'] as String,
      invitedTo: const DocumentSerializer()
          .fromJson(json['invitedTo'] as DocumentReference<Object?>),
      created: InvitesModel.dateTimeFromTimestamp(json['created'] as Timestamp),
    );

Map<String, dynamic> _$InvitesModelToJson(InvitesModel instance) =>
    <String, dynamic>{
      'isAdmin': instance.isAdmin,
      'email': instance.email,
      'invitedTo': const DocumentSerializer().toJson(instance.invitedTo),
      'created': InvitesModel.firestoreTimestampToJson(instance.created),
    };
