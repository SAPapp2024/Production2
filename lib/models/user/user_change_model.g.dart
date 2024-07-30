// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_change_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserChangeModel _$UserChangeModelFromJson(Map<String, dynamic> json) =>
    UserChangeModel(
      id: json['id'] as String,
      oldState: UserChangeStateModel.fromJson(
          json['oldState'] as Map<String, dynamic>),
      newState: UserChangeStateModel.fromJson(
          json['newState'] as Map<String, dynamic>),
      changeDate: UserChangeModel.dateTimeFromTimestamp(
          json['changeDate'] as Timestamp),
      changedBy: _$JsonConverterFromJson<DocumentReference<Object?>,
              DocumentReference<Object?>>(
          json['changedBy'], const DocumentSerializer().fromJson),
    );

Map<String, dynamic> _$UserChangeModelToJson(UserChangeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'oldState': instance.oldState.toJson(),
      'newState': instance.newState.toJson(),
      'changeDate':
          UserChangeModel.firestoreTimestampToJson(instance.changeDate),
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
