// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_change_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleChangeStateModel _$SampleChangeStateModelFromJson(
        Map<String, dynamic> json) =>
    SampleChangeStateModel(
      sampleDate: SampleChangeStateModel.dateTimeFromTimestampNullable(
          json['sampleDate'] as Timestamp?),
      locationPlot: json['locationPlot'] as String,
      cultivation: json['cultivation'] as String,
      crop: json['crop'] as String,
      variety: json['variety'] as String?,
      grower: json['grower'] as String?,
      notes: json['notes'] as String,
      youngSampleBarcode: json['youngSampleBarcode'] as String?,
      oldSampleBarcode: json['oldSampleBarcode'] as String?,
      status: json['status'] as String,
    );

Map<String, dynamic> _$SampleChangeStateModelToJson(
        SampleChangeStateModel instance) =>
    <String, dynamic>{
      'sampleDate':
          SampleChangeStateModel.firestoreTimestampToJson(instance.sampleDate),
      'locationPlot': instance.locationPlot,
      'cultivation': instance.cultivation,
      'crop': instance.crop,
      'variety': instance.variety,
      'grower': instance.grower,
      'notes': instance.notes,
      'youngSampleBarcode': instance.youngSampleBarcode,
      'oldSampleBarcode': instance.oldSampleBarcode,
      'status': instance.status,
    };
