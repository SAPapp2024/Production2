import 'package:json_annotation/json_annotation.dart';

part 'crop_model.g.dart';

@JsonSerializable()
class CropModel {
  String id;
  String name;
  bool isActive;

  CropModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) => _$CropModelFromJson(json);
  Map<String, dynamic> toJson() => _$CropModelToJson(this);
}
