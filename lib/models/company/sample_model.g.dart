// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleModel _$SampleModelFromJson(Map<String, dynamic> json) => SampleModel(
      id: json['id'] as String,
      sampleDate: SampleModel.dateTimeFromTimestampNullable(
          json['sampleDate'] as Timestamp?),
      createdDate:
          SampleModel.dateTimeFromTimestamp(json['createdDate'] as Timestamp),
      farm: json['farm'] as String,
      field: json['field'] as String,
      treatment: json['treatment'] as String?,
      crop: json['crop'] as String,
      variety: json['variety'] as String?,
      notes: json['notes'] as String,
      grower: json['grower'] as String?,
      youngSampleBarcode: json['youngSampleBarcode'] as String?,
      oldSampleBarcode: json['oldSampleBarcode'] as String?,
      status: json['status'] as String,
      companyName: json['companyName'] as String?,
      location: json['location'] == null
          ? null
          : SampleLocationModel.fromJson(
              json['location'] as Map<String, dynamic>),
      userReference: const DocumentSerializerNullable()
          .fromJson(json['userReference'] as DocumentReference<Object?>?),
      assignedTo: const DocumentSerializerNullable()
          .fromJson(json['assignedTo'] as DocumentReference<Object?>?),
      companyReference: const DocumentSerializerNullable()
          .fromJson(json['companyReference'] as DocumentReference<Object?>?),
      changes: (json['changes'] as List<dynamic>?)
              ?.map(
                  (e) => SampleChangeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      youngSampleMinerals: json['youngSampleMinerals'] as Map<String, dynamic>?,
      oldSampleMinerals: json['oldSampleMinerals'] as Map<String, dynamic>?,
      prints: json['prints'] as List<dynamic>,
      deleted: json['deleted'] as bool,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SampleModelToJson(SampleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sampleDate': SampleModel.firestoreTimestampToJson(instance.sampleDate),
      'createdDate': SampleModel.firestoreTimestampToJson(instance.createdDate),
      'farm': instance.farm,
      'field': instance.field,
      'treatment': instance.treatment,
      'crop': instance.crop,
      'variety': instance.variety,
      'notes': instance.notes,
      'grower': instance.grower,
      'youngSampleBarcode': instance.youngSampleBarcode,
      'oldSampleBarcode': instance.oldSampleBarcode,
      'status': instance.status,
      'companyName': instance.companyName,
      'location': instance.location,
      'userReference':
          const DocumentSerializerNullable().toJson(instance.userReference),
      'assignedTo':
          const DocumentSerializerNullable().toJson(instance.assignedTo),
      'companyReference':
          const DocumentSerializerNullable().toJson(instance.companyReference),
      'changes': instance.changes,
      'prints': instance.prints,
      'youngSampleMinerals': instance.youngSampleMinerals,
      'oldSampleMinerals': instance.oldSampleMinerals,
      'deleted': instance.deleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
