// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCompanyModel _$UserCompanyModelFromJson(Map<String, dynamic> json) =>
    UserCompanyModel(
      farm: CompanyModel.fromJson(json['farm'] as Map<String, dynamic>),
      isAdmin: json['isAdmin'] as bool,
    );

Map<String, dynamic> _$UserCompanyModelToJson(UserCompanyModel instance) =>
    <String, dynamic>{
      'farm': instance.farm,
      'isAdmin': instance.isAdmin,
    };
