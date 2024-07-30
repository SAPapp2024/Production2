// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_admin_user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyAdminUserInfo _$CompanyAdminUserInfoFromJson(
        Map<String, dynamic> json) =>
    CompanyAdminUserInfo(
      userReference: const DocumentSerializer()
          .fromJson(json['userReference'] as DocumentReference<Object?>),
      email: json['email'] as String,
      fullName: json['fullName'] as String,
    );

Map<String, dynamic> _$CompanyAdminUserInfoToJson(
        CompanyAdminUserInfo instance) =>
    <String, dynamic>{
      'userReference':
          const DocumentSerializer().toJson(instance.userReference),
      'email': instance.email,
      'fullName': instance.fullName,
    };
