import 'package:agro_k/models/user/company_change_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'company_changes_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CompanyChangesModel {
  List<CompanyChangeModel> changes;

  CompanyChangesModel({required this.changes});

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  factory CompanyChangesModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyChangesModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyChangesModelToJson(this);
}
