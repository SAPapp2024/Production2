// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_barcode_list_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalBarcodeListItemModel _$GlobalBarcodeListItemModelFromJson(
        Map<String, dynamic> json) =>
    GlobalBarcodeListItemModel(
      json['barcode'] as String,
      const DocumentSerializerNullable()
          .fromJson(json['companyReference'] as DocumentReference<Object?>?),
      json['companyName'] as String?,
      const DocumentSerializerNullable()
          .fromJson(json['sampleReference'] as DocumentReference<Object?>?),
      GlobalBarcodeListItemModel.dateTimeFromTimestampNullable(
          json['createdDate'] as Timestamp?),
      GlobalBarcodeListItemModel.dateTimeFromTimestampNullable(
          json['dateAddedToCompany'] as Timestamp?),
      json['wasPurchased'] as bool?,
      json['reclaimedTimestamps'] as List<dynamic>,
    );

Map<String, dynamic> _$GlobalBarcodeListItemModelToJson(
        GlobalBarcodeListItemModel instance) =>
    <String, dynamic>{
      'barcode': instance.barcode,
      'companyReference':
          const DocumentSerializerNullable().toJson(instance.companyReference),
      'companyName': instance.companyName,
      'sampleReference':
          const DocumentSerializerNullable().toJson(instance.sampleReference),
      'wasPurchased': instance.wasPurchased,
      'createdDate': GlobalBarcodeListItemModel.firestoreTimestampToJson(
          instance.createdDate),
      'dateAddedToCompany': GlobalBarcodeListItemModel.firestoreTimestampToJson(
          instance.dateAddedToCompany),
      'reclaimedTimestamps': instance.reclaimedTimestamps,
    };
