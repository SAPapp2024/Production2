import 'package:agro_k/models/company/company_admin_user_info.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'company_change_state_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CompanyChangeStateModel extends Equatable {
  //set fields address ,phone ,alternatePhone ,city ,name ,state ,zipcode ,companyAdminUserInfo
  PhoneModel? phone;
  PhoneModel? alternatePhone;
  String? address;
  String? city;
  String? name;
  String? country;
  String? state;
  String? province;
  String? zipcode;
  CompanyAdminUserInfo? companyAdminUserInfo;
  String? type;

  CompanyChangeStateModel(
      {this.phone,
      this.alternatePhone,
      this.address,
      this.city,
      this.name,
      this.country,
      this.state,
      this.province,
      this.zipcode,
      this.companyAdminUserInfo, this.type});

  factory CompanyChangeStateModel.fromJsonAndCopy(Map<String, dynamic> json,
      {PhoneModel? phone,
      PhoneModel? alternatePhone,
      String? address,
      String? city,
      String? name,
      String? country,
      String? state,
      String? province,
      String? zipcode,
      CompanyAdminUserInfo? companyAdminUserInfo, String? type}) {
    return CompanyChangeStateModel(
      phone: phone ??
          (json['phone'] != null ? PhoneModel.fromJson(json['phone']) : null),
      alternatePhone: alternatePhone ??
          (json['alternatePhone'] != null
              ? PhoneModel.fromJson(json['alternatePhone'])
              : null),
      address: address ?? json['address'],
      city: city ?? json['city'],
      name: name ?? json['name'],
      state: state ?? json['state'],
      province: province ?? json['province'],
      zipcode: zipcode ?? json['zipcode'],
      country: country ?? json['country'],
      companyAdminUserInfo: companyAdminUserInfo ??
          (json['companyAdminUserInfo'] != null
              ? CompanyAdminUserInfo.fromJson(json['companyAdminUserInfo'])
              : null),
      type: type ?? json['type'],
    );
  }

  factory CompanyChangeStateModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyChangeStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyChangeStateModelToJson(this);

  @override
  List<Object?> get props => [
        phone,
        alternatePhone,
        address,
        city,
        name,
        state,
        zipcode,
        companyAdminUserInfo,
        type
  ];

}
