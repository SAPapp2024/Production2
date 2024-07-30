// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_change_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleChangeModel _$SampleChangeModelFromJson(Map<String, dynamic> json) =>
    SampleChangeModel(
      id: json['id'] as String,
      oldSampleState:
          SampleChangeModel.sampleStateFromJson(json['oldSampleState']),
      newSampleState:
          SampleChangeModel.sampleStateFromJson(json['newSampleState']),
      changeDate: SampleChangeModel.dateTimeFromTimestamp(
          json['changeDate'] as Timestamp),
      changedBy: const DocumentSerializerNullable()
          .fromJson(json['changedBy'] as DocumentReference<Object?>?),
    );

Map<String, dynamic> _$SampleChangeModelToJson(SampleChangeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'oldSampleState':
          SampleChangeModel.sampleStateToJson(instance.oldSampleState),
      'newSampleState':
          SampleChangeModel.sampleStateToJson(instance.newSampleState),
      'changeDate':
          SampleChangeModel.firestoreTimestampToJson(instance.changeDate),
      'changedBy':
          const DocumentSerializerNullable().toJson(instance.changedBy),
    };
