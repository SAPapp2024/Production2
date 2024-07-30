// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneModel _$PhoneModelFromJson(Map<String, dynamic> json) => PhoneModel(
      phone: json['phone'] as String? ?? "",
      phoneAreaCode: json['phoneAreaCode'] as String? ?? "1",
      phoneCountryISOName: json['phoneCountryISOName'] as String? ?? "US",
    );

Map<String, dynamic> _$PhoneModelToJson(PhoneModel instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'phoneAreaCode': instance.phoneAreaCode,
      'phoneCountryISOName': instance.phoneCountryISOName,
    };
