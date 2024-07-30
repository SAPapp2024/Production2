// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_farm_references_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCompanyReferencesModel _$UserCompanyReferencesModelFromJson(
        Map<String, dynamic> json) =>
    UserCompanyReferencesModel(
      companyReference: const DocumentSerializer()
          .fromJson(json['companyReference'] as DocumentReference<Object?>),
      companyName: json['companyName'] as String,
      isAdmin: json['isAdmin'] as bool,
    );

Map<String, dynamic> _$UserCompanyReferencesModelToJson(
        UserCompanyReferencesModel instance) =>
    <String, dynamic>{
      'companyReference':
          const DocumentSerializer().toJson(instance.companyReference),
      'companyName': instance.companyName,
      'isAdmin': instance.isAdmin,
    };
