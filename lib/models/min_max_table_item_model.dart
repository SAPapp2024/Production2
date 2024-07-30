import 'package:json_annotation/json_annotation.dart';

part 'min_max_table_item_model.g.dart';

@JsonSerializable()
class MinMaxTableItemModel {
  String crop;
  String mineral;
  double optimumMin;
  double optimumMax;
  double rangeMax;

  MinMaxTableItemModel({
    required this.crop,
    required this.mineral,
    required this.optimumMin,
    required this.optimumMax,
    required this.rangeMax,
  });

  factory MinMaxTableItemModel.fromJson(Map<String, dynamic> json) => _$MinMaxTableItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$MinMaxTableItemModelToJson(this);
}
