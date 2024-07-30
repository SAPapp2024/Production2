
import 'package:agro_k/models/crop_model.dart';
import 'package:agro_k/models/min_max_table_item_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../document_serializer.dart';
import '../document_serializer_nullable.dart';
part 'admin_info_model.g.dart';

@JsonSerializable()
@DocumentSerializerNullable()
@DocumentSerializer()
class AdminInfoModel {
  List<String> assignableBarcodes;
  int get availableBarcodes => assignableBarcodes.length;
  int get assignedAndNotUsedBarcodesAmount => assignedBarcodesAmount - usedBarcodesAmount;
  int assignedBarcodesAmount;
  int usedBarcodesAmount;
  List<CropModel> crops;
  List<MinMaxTableItemModel> mineralMinMaxTable;

  AdminInfoModel({
    required this.assignableBarcodes,
    required this.assignedBarcodesAmount,
    required this.usedBarcodesAmount,
    required this.crops,
    required this.mineralMinMaxTable,
  });

  factory AdminInfoModel.fromJson(Map<String, dynamic> json) => _$AdminInfoModelFromJson(json);
  Map<String, dynamic> toJson() => _$AdminInfoModelToJson(this);

}