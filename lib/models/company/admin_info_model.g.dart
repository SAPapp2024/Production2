// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminInfoModel _$AdminInfoModelFromJson(Map<String, dynamic> json) =>
    AdminInfoModel(
      assignableBarcodes: (json['assignableBarcodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      assignedBarcodesAmount: json['assignedBarcodesAmount'] as int,
      usedBarcodesAmount: json['usedBarcodesAmount'] as int,
      crops: (json['crops'] as List<dynamic>)
          .map((e) => CropModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mineralMinMaxTable: (json['mineralMinMaxTable'] as List<dynamic>)
          .map((e) => MinMaxTableItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AdminInfoModelToJson(AdminInfoModel instance) =>
    <String, dynamic>{
      'assignableBarcodes': instance.assignableBarcodes,
      'assignedBarcodesAmount': instance.assignedBarcodesAmount,
      'usedBarcodesAmount': instance.usedBarcodesAmount,
      'crops': instance.crops,
      'mineralMinMaxTable': instance.mineralMinMaxTable,
    };
