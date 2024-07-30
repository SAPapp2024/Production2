// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_change_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyChangeStateModel _$CompanyChangeStateModelFromJson(
        Map<String, dynamic> json) =>
    CompanyChangeStateModel(
      phone: json['phone'] == null
          ? null
          : PhoneModel.fromJson(json['phone'] as Map<String, dynamic>),
      alternatePhone: json['alternatePhone'] == null
          ? null
          : PhoneModel.fromJson(json['alternatePhone'] as Map<String, dynamic>),
      address: json['address'] as String?,
      city: json['city'] as String?,
      name: json['name'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      province: json['province'] as String?,
      zipcode: json['zipcode'] as String?,
      companyAdminUserInfo: json['companyAdminUserInfo'] == null
          ? null
          : CompanyAdminUserInfo.fromJson(
              json['companyAdminUserInfo'] as Map<String, dynamic>),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$CompanyChangeStateModelToJson(
        CompanyChangeStateModel instance) =>
    <String, dynamic>{
      'phone': instance.phone?.toJson(),
      'alternatePhone': instance.alternatePhone?.toJson(),
      'address': instance.address,
      'city': instance.city,
      'name': instance.name,
      'country': instance.country,
      'state': instance.state,
      'province': instance.province,
      'zipcode': instance.zipcode,
      'companyAdminUserInfo': instance.companyAdminUserInfo?.toJson(),
      'type': instance.type,
    };
