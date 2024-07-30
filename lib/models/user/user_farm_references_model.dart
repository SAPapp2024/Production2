import 'package:agro_k/models/document_serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_farm_references_model.g.dart';

@JsonSerializable()
@DocumentSerializer()
class UserCompanyReferencesModel {
  final DocumentReference companyReference;
  final String companyName;
  bool isAdmin;

  UserCompanyReferencesModel({required this.companyReference, required this.companyName, required this.isAdmin});

  factory UserCompanyReferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserCompanyReferencesModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserCompanyReferencesModelToJson(this);
}