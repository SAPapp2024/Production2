import 'package:agro_k/models/document_serializer_nullable.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'phone_model.g.dart';

@JsonSerializable()
@DocumentSerializerNullable()
class PhoneModel extends Equatable {
  final String phone;
  final String phoneAreaCode;
  final String phoneCountryISOName;

  const PhoneModel({
    this.phone = "",
    this.phoneAreaCode = "1",
    this.phoneCountryISOName = "US",
  });

  factory PhoneModel.fromJson(Map<String, dynamic> json) =>
      _$PhoneModelFromJson(json);
  Map<String, dynamic>? toJson() => _$PhoneModelToJson(this);

  String getFullPhoneNumber() => "+$phoneAreaCode$phone";

  @override
  List<Object?> get props => [phone, phoneAreaCode, phoneCountryISOName];
}
