import 'package:agro_k/models/document_serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'company_admin_user_info.g.dart';

@JsonSerializable()
@DocumentSerializer()
class CompanyAdminUserInfo {
  DocumentReference userReference;
  String email;
  String fullName;

  CompanyAdminUserInfo({required this.userReference, required this.email, required this.fullName});

  factory CompanyAdminUserInfo.fromJson(Map<String, dynamic> json) =>
      _$CompanyAdminUserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyAdminUserInfoToJson(this);
}