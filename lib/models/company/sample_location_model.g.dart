// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleLocationModel _$SampleLocationModelFromJson(Map<String, dynamic> json) =>
    SampleLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$SampleLocationModelToJson(
        SampleLocationModel instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
