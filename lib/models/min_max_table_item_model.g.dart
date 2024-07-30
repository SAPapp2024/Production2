// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'min_max_table_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinMaxTableItemModel _$MinMaxTableItemModelFromJson(
        Map<String, dynamic> json) =>
    MinMaxTableItemModel(
      crop: json['crop'] as String,
      mineral: json['mineral'] as String,
      optimumMin: (json['optimumMin'] as num).toDouble(),
      optimumMax: (json['optimumMax'] as num).toDouble(),
      rangeMax: (json['rangeMax'] as num).toDouble(),
    );

Map<String, dynamic> _$MinMaxTableItemModelToJson(
        MinMaxTableItemModel instance) =>
    <String, dynamic>{
      'crop': instance.crop,
      'mineral': instance.mineral,
      'optimumMin': instance.optimumMin,
      'optimumMax': instance.optimumMax,
      'rangeMax': instance.rangeMax,
    };
