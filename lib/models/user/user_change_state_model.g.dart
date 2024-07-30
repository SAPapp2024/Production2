// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_change_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserChangeStateModel _$UserChangeStateModelFromJson(
        Map<String, dynamic> json) =>
    UserChangeStateModel(
      phone: json['phone'] == null
          ? null
          : PhoneModel.fromJson(json['phone'] as Map<String, dynamic>),
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      enabled: json['enabled'] as bool?,
    );

Map<String, dynamic> _$UserChangeStateModelToJson(
        UserChangeStateModel instance) =>
    <String, dynamic>{
      'phone': instance.phone?.toJson(),
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profileImagePath': instance.profileImagePath,
      'enabled': instance.enabled,
    };
