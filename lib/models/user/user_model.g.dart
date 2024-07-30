// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      phone: json['phone'] == null
          ? null
          : PhoneModel.fromJson(json['phone'] as Map<String, dynamic>),
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      created: UserModel.dateTimeFromTimestamp(json['created'] as Timestamp),
      lastConnection:
          UserModel.dateTimeFromTimestamp(json['lastConnection'] as Timestamp),
      notificationSettings: NotificationSettingsModel.fromJson(
          json['notificationSettings'] as Map<String, dynamic>),
      isSuperAdmin: json['isSuperAdmin'] as bool,
      companyReferences: (json['companyReferences'] as List<dynamic>)
          .map((e) =>
              UserCompanyReferencesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isConfirmed: json['isConfirmed'] as bool,
      profileImagePath: json['profileImagePath'] as String?,
      deviceTokens: (json['deviceTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => UserNotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      enabled: json['enabled'] as bool,
      deleted: json['deleted'] as bool? ?? false,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'created': UserModel.firestoreTimestampToJson(instance.created),
      'lastConnection':
          UserModel.firestoreTimestampToJson(instance.lastConnection),
      'notificationSettings': instance.notificationSettings,
      'isSuperAdmin': instance.isSuperAdmin,
      'companyReferences': instance.companyReferences,
      'isConfirmed': instance.isConfirmed,
      'profileImagePath': instance.profileImagePath,
      'deviceTokens': instance.deviceTokens,
      'notifications': instance.notifications,
      'enabled': instance.enabled,
      'deleted': instance.deleted,
    };
