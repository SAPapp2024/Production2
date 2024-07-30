import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/models/company/sample_change_model.dart';
import 'package:agro_k/models/company/sample_location_model.dart';
import 'package:agro_k/models/company/sample_with_user_model.dart';
import 'package:agro_k/models/document_serializer_nullable.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sample_model.g.dart';

@JsonSerializable()
@DocumentSerializerNullable()
//ignore: must_be_immutable
class SampleModel extends Equatable {
  String id;
  @JsonKey(
      fromJson: dateTimeFromTimestampNullable, toJson: firestoreTimestampToJson)
  DateTime? sampleDate;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: firestoreTimestampToJson)
  DateTime createdDate;
  String farm;
  String field;
  String? treatment;
  String crop;
  String? variety;
  String notes;
  String? grower;
  String? youngSampleBarcode;
  String? oldSampleBarcode;
  String status;
  String? companyName;
  SampleLocationModel? location;
  DocumentReference? userReference;
  DocumentReference? assignedTo;
  DocumentReference? companyReference;
  List<SampleChangeModel> changes;
  List<dynamic> prints;
  bool get hasBeenPrinted => prints.isNotEmpty;
  Map<String, dynamic>? youngSampleMinerals;
  Map<String, dynamic>? oldSampleMinerals;
  bool deleted;
  DateTime? deletedAt;

  SampleModel(
      {required this.id,
      this.sampleDate,
      required this.createdDate,
      required this.farm,
      required this.field,
      required this.treatment,
      required this.crop,
      required this.variety,
      required this.notes,
      required this.grower,
      this.youngSampleBarcode,
      this.oldSampleBarcode,
      required this.status,
      this.companyName,
      required this.location,
      required this.userReference,
      required this.assignedTo,
      required this.companyReference,
      this.changes = const [],
      this.youngSampleMinerals,
      this.oldSampleMinerals, required this.prints, required this.deleted, this.deletedAt});

  Future<SampleWithUserModel> toSampleWithUserModel() async {
    UserModel? user;
    if (userReference != null) {
      DocumentSnapshot userSnapshot = await userReference!.get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? data =
            userSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          user = UserModel.fromJson(data);
        }
      }
    }
    UserModel? assignedToUserModel;
    if (assignedTo != null) {
      DocumentSnapshot userSnapshot = await assignedTo!.get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? data =
            userSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          assignedToUserModel = UserModel.fromJson(data);
        }
      }
    }
    return SampleWithUserModel(
        sample: this, user: user, assignedTo: assignedToUserModel);
  }

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static DateTime? dateTimeFromTimestampNullable(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  static DateTime? dateTimeFromInt(int? date) {
    return date != null
        ? DateTime.fromMillisecondsSinceEpoch(date * 1000)
        : null;
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  factory SampleModel.fromJson(Map<String, dynamic> json) {
    List<SampleChangeModel> changes = [];
    try {
      if (json['changes'] != null) {
        changes = (json['changes'] as List<dynamic>? ?? [])
            .map((e) {
          try {
            return SampleChangeModel.fromJson(
                e as Map<String, dynamic>);
          } catch (exception, stacktrace) {
            getIt
                .get<RemoteErrorLoggingService>()
                .recordError(exception, stacktrace);
            return null;
          }
        }).whereNotNull().toList();
      }
    } catch (e, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(e, stacktrace);
    }
    return SampleModel(
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
      changes: changes,
      youngSampleMinerals: json['youngSampleMinerals'] as Map<String, dynamic>?,
      oldSampleMinerals: json['oldSampleMinerals'] as Map<String, dynamic>?,
      prints: json['prints'] as List<dynamic>? ?? [],
      deleted: json['deleted'] as bool? ?? false,
      deletedAt: SampleModel.dateTimeFromTimestampNullable(
          json['deletedAt'] as Timestamp?),
    );
  }

  factory SampleModel.fromTypesenseJson(Map<String, dynamic> json) {
    return SampleModel(
      id: json['id'] as String,
      sampleDate: SampleModel.dateTimeFromInt(json['sampleDate'] as int?),
      createdDate: SampleModel.dateTimeFromInt(json['createdDate'] as int)!,
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
      companyName: json['companyName'] as String,
      location: json['location.latitude'] == null ||
              json['location.longitude'] == null
          ? null
          : SampleLocationModel.fromJson({
              "latitude": json['location.latitude'],
              "longitude": json['location.longitude'],
            }),
      userReference: const DocumentSerializerNullable()
          .fromJson(getDocumentNullable(json['userReference.path'])),
      assignedTo: const DocumentSerializerNullable()
          .fromJson(getDocumentNullable(json['assignedTo.path'])),
      companyReference: const DocumentSerializerNullable()
          .fromJson(getDocumentNullable(json['companyReference.path'])),
      changes: (json['changes'] as List<dynamic>?)
              ?.map(
                  (e) => SampleChangeModel.fromTypesenseJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      youngSampleMinerals: json['youngSampleMinerals'] as Map<String, dynamic>?,
      oldSampleMinerals: json['oldSampleMinerals'] as Map<String, dynamic>?,
      prints: json['prints'] as List<dynamic>? ?? [],
      deleted: json['deleted'] as bool? ?? false,
      deletedAt: SampleModel.dateTimeFromInt(json['deletedAt'] as int?),
    );
  }

  static DocumentReference<Object?>? getDocumentNullable(String? path) {
    try {
      if (path == null) {
        return null;
      }
      return FirebaseFirestore.instance.doc(path);
    } catch (exception, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(exception, stacktrace);
      return null;
    }
  }

  Map<String, dynamic> toJson() => _$SampleModelToJson(this);

  @override
  List<Object?> get props => [id];
}
