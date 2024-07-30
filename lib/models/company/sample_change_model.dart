import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/models/document_serializer_nullable.dart';
import 'package:agro_k/models/company/sample_change_state_model.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:agro_k/utilities/typesense_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'sample_change_with_user_model.dart';

part 'sample_change_model.g.dart';

@JsonSerializable()
@DocumentSerializerNullable()
class SampleChangeModel {
  String id;
  @JsonKey(fromJson: sampleStateFromJson, toJson: sampleStateToJson)
  SampleChangeStateModel oldSampleState;
  @JsonKey(fromJson: sampleStateFromJson, toJson: sampleStateToJson)
  SampleChangeStateModel newSampleState;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: firestoreTimestampToJson)
  DateTime changeDate;
  DocumentReference? changedBy;

  SampleChangeModel({required this.id, required this.oldSampleState, required this.newSampleState, required this.changeDate, required this.changedBy});

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  static Map<String, dynamic> sampleStateToJson(SampleChangeStateModel state) => state.toJson();

  static SampleChangeStateModel sampleStateFromJson(dynamic value) => SampleChangeStateModel.fromJson(value);
  static SampleChangeStateModel sampleStateFromTypesenseJson(dynamic value) => SampleChangeStateModel.fromTypesenseJson(value);

  factory SampleChangeModel.fromJson(Map<String, dynamic> json) => _$SampleChangeModelFromJson(json);

  factory SampleChangeModel.fromTypesenseJson(Map<String, dynamic> json) {
    return SampleChangeModel(
      id: json['id'] as String,
      oldSampleState:
      SampleChangeModel.sampleStateFromTypesenseJson(json['oldSampleState']),
      newSampleState:
      SampleChangeModel.sampleStateFromTypesenseJson(json['newSampleState']),
      changeDate: dateTimeFromTypesenseInt(
          json['changeDate'] as int)!,
      changedBy: const DocumentSerializerNullable()
          .fromJson(getDocumentNullable(json['changedBy']['path'])),
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

    Map<String, dynamic> toJson() => _$SampleChangeModelToJson(this);

    Future<SampleChangeWithUserModel> toSampleWithUserModel() async {
      UserModel? user;
      debugPrint("changedBy = $changedBy");
      if (changedBy != null) {
        DocumentSnapshot userSnapshot = await changedBy!.get();
        if (userSnapshot.exists) {
          Map<String, dynamic>? data =
          userSnapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            user = UserModel.fromJson(data);
          }
        }
      }
      return SampleChangeWithUserModel(
          sampleChangeModel: this,
          user: user);
    }
}