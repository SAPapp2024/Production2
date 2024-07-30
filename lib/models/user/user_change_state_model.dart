import 'package:agro_k/models/user/phone_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_change_state_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserChangeStateModel extends Equatable {
  PhoneModel? phone;
  String? email;
  String? firstName;
  String? lastName;
  String? profileImagePath;
  bool? enabled;

  UserChangeStateModel(
      {this.phone,
      this.email,
      this.firstName,
      this.lastName,
      this.profileImagePath,
      this.enabled});

  factory UserChangeStateModel.fromJsonAndCopy(Map<String, dynamic> json, {PhoneModel? phone,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImagePath,
    bool? enabled}) {
    return UserChangeStateModel(
      phone: phone ?? (json['phone'] != null ? PhoneModel.fromJson(json['phone']) : null),
      email: email ?? json['email'],
      firstName: firstName ?? json['firstName'],
      lastName: lastName ?? json['lastName'],
      profileImagePath: profileImagePath ?? json['profileImagePath'],
      enabled: enabled ?? json['enabled'],
    );
  }

  factory UserChangeStateModel.fromJson(Map<String, dynamic> json) => _$UserChangeStateModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserChangeStateModelToJson(this);

  @override
  // TODO: implement props
  List<Object?> get props => [phone, email, firstName, lastName, profileImagePath, enabled];
}