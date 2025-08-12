import 'package:agro_k/models/document_serializer.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_company_model.g.dart';

@JsonSerializable()
@DocumentSerializer()
class UserCompanyModel {
  final CompanyModel farm;
  final bool isAdmin;

  UserCompanyModel({required this.farm, required this.isAdmin});

  factory UserCompanyModel.fromJson(Map<String, dynamic> json) =>
      _$UserCompanyModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserCompanyModelToJson(this);
}