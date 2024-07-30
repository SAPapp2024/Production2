import 'package:agro_k/utilities/typesense_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sample_change_state_model.g.dart';

@JsonSerializable()
class SampleChangeStateModel {
  @JsonKey(fromJson: dateTimeFromTimestampNullable, toJson: firestoreTimestampToJson)
  DateTime? sampleDate;
  String locationPlot;
  String cultivation;
  String crop;
  String? variety;
  String? grower;
  String notes;
  String? youngSampleBarcode;
  String? oldSampleBarcode;
  String status;

  SampleChangeStateModel(
      {required this.sampleDate,
      required this.locationPlot,
      required this.cultivation,
      required this.crop,
      required this.variety,
      required this.grower,
      required this.notes,
      this.youngSampleBarcode,
      this.oldSampleBarcode,
      required this.status});

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static DateTime? dateTimeFromTimestampNullable(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  factory SampleChangeStateModel.fromJson(Map<String, dynamic> json) =>
      _$SampleChangeStateModelFromJson(json);
  factory SampleChangeStateModel.fromTypesenseJson(Map<String, dynamic> json) =>
      SampleChangeStateModel(
        sampleDate: dateTimeFromTypesenseInt(
            json['sampleDate'] as int?),
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

  Map<String, dynamic> toJson() => _$SampleChangeStateModelToJson(this);
}
