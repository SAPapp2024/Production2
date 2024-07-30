// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_change_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyChangeModel _$CompanyChangeModelFromJson(Map<String, dynamic> json) =>
    CompanyChangeModel(
      id: json['id'] as String,
      oldState: CompanyChangeStateModel.fromJson(
          json['oldState'] as Map<String, dynamic>),
      newState: CompanyChangeStateModel.fromJson(
          json['newState'] as Map<String, dynamic>),
      changeDate: CompanyChangeModel.dateTimeFromTimestamp(
          json['changeDate'] as Timestamp),
      changedBy: _$JsonConverterFromJson<DocumentReference<Object?>,
              DocumentReference<Object?>>(
          json['changedBy'], const DocumentSerializer().fromJson),
    );

Map<String, dynamic> _$CompanyChangeModelToJson(CompanyChangeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'oldState': instance.oldState.toJson(),
      'newState': instance.newState.toJson(),
      'changeDate':
          CompanyChangeModel.firestoreTimestampToJson(instance.changeDate),
      'changedBy': _$JsonConverterToJson<DocumentReference<Object?>,
              DocumentReference<Object?>>(
          instance.changedBy, const DocumentSerializer().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
