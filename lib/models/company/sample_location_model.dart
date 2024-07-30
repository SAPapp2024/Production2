import 'package:json_annotation/json_annotation.dart';

part 'sample_location_model.g.dart';

@JsonSerializable()
class SampleLocationModel {
  double latitude;
  double longitude;

  SampleLocationModel({required this.latitude, required this.longitude});

  factory SampleLocationModel.fromJson(Map<String, dynamic> json) =>
      _$SampleLocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$SampleLocationModelToJson(this);
}