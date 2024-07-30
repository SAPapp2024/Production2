// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_changes_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyChangesModel _$CompanyChangesModelFromJson(Map<String, dynamic> json) =>
    CompanyChangesModel(
      changes: (json['changes'] as List<dynamic>)
          .map((e) => CompanyChangeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CompanyChangesModelToJson(
        CompanyChangesModel instance) =>
    <String, dynamic>{
      'changes': instance.changes.map((e) => e.toJson()).toList(),
    };
