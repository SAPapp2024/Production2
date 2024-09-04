import 'package:agro_k/models/company/company_admin_user_info.dart';
import 'package:agro_k/models/company/invited_users_model.dart';
import 'package:agro_k/models/document_serializer.dart';
import 'package:agro_k/models/document_serializer_nullable.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/utilities/constants.dart';
import 'package:agro_k/utilities/function_utils/general_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'company_model.g.dart';

@JsonSerializable(explicitToJson: true)
@DocumentSerializerNullable()
@DocumentSerializer()
class CompanyModel {
  String id;
  String address;
  PhoneModel? phone;
  PhoneModel? alternatePhone;
  String city;

  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: firestoreTimestampToJson)
  DateTime created;

  String name;
  String state;
  String zipcode;
  String country;
  List<DocumentReference> users;
  Map<String, List<String>> locations;
  Map<String, InvitedUsersModel>? invitedUsers;
  Map<String, List<String>> fields;
  Map<String, List<String>> growers;
  Map<String, List<String>> crops;
  List<String> assignableBarcodes;
  int barcodesPurchased;
  int barcodesAssigned;
  int usedBarcodesCount;
  String type;

  int get availableBarcodesCount => barcodesPurchased + barcodesAssigned - usedBarcodesCount;
  bool get isShipping => country.toLowerCase() == 'united states';
  CompanyAdminUserInfo? companyAdminUserInfo;

  CompanyModel(
      {required this.id,
      required this.address,
      required this.phone,
      required this.alternatePhone,
      required this.country,
      required this.city,
      required this.created,
      required this.name,
      required this.state,
      required this.zipcode,
      required this.users,
      required this.locations,
      required this.invitedUsers,
      required this.fields,
      required this.growers,
      required this.crops,
      required this.assignableBarcodes,
      required this.barcodesPurchased,
      required this.barcodesAssigned,
      this.usedBarcodesCount = 0,
      required this.companyAdminUserInfo,
      required this.type});

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    // debugPrint("json here is ${json['name']} ${json['barcodesPurchased']}");
    List<DocumentReference> users;
    try {
      users = (json['users'] as List<dynamic>)
          .map((e) {
            try {
              return const DocumentSerializer().fromJson(e as DocumentReference<Object?>);
            } catch (e) {
              debugPrint(e.toString());
              return null;
            }
          })
          .whereNotNull()
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      users = [];
    }

    return CompanyModel(
        id: json['id'] as String,
        address:
            ConversionUtils.castWithDefault<String>(json['address'], (e) => e as String, defaultValue: "", 'address'),
        phone: ConversionUtils.castWithDefaultNullable<PhoneModel?>(
            json['phone'], (e) => PhoneModel.fromJson(e as Map<String, dynamic>), defaultValue: null, 'phone'),
        alternatePhone: ConversionUtils.castWithDefaultNullable<PhoneModel?>(
            json['alternatePhone'],
            (e) => PhoneModel.fromJson(e as Map<String, dynamic>),
            defaultValue: null,
            'alternatePhone'),
        city: ConversionUtils.castWithDefault<String>(json['city'], (e) => e as String, defaultValue: "", 'city'),
        created: CompanyModel.dateTimeFromTimestamp(json['created'] as Timestamp),
        name: ConversionUtils.castWithDefault<String>(json['name'], (e) => e as String, defaultValue: "", 'name'),
        state: ConversionUtils.castWithDefault<String>(json['state'], (e) => e as String, defaultValue: "", 'state'),
        country:
            ConversionUtils.castWithDefault<String>(json['country'], (e) => e as String, defaultValue: "", 'country'),
        zipcode:
            ConversionUtils.castWithDefault<String>(json['zipcode'], (e) => e as String, defaultValue: "", 'zipcode'),
        users: users,
        locations: ConversionUtils.mapMapWithListSafely(json['locations'] ?? {}, (e) => e as String, 'locations'),
        invitedUsers: ConversionUtils.mapMapSafely(
            json['invitedUsers'], (e) => InvitedUsersModel.fromJson(e as Map<String, dynamic>), "invitedUsers"),
        fields: ConversionUtils.mapMapWithListSafely(json['fields'] ?? {}, (e) => e as String, 'fields'),
        growers: ConversionUtils.mapMapWithListSafely(json['growers'] ?? {}, (e) => e as String, 'growers'),
        crops: ConversionUtils.mapMapWithListSafely(json['crops'] ?? {}, (e) => e as String, 'crops'),
        assignableBarcodes: (json['assignableBarcodes'] as List<dynamic>).map((e) => e as String).toList(),
        barcodesPurchased: ConversionUtils.castWithDefault<int>(
            (json['barcodesPurchased'] is double) ? json['barcodesPurchased'].toInt() : json['barcodesPurchased'],
            (e) => e as int,
            'barcodesPurchased',
            defaultValue: 0),
        barcodesAssigned: ConversionUtils.castWithDefault<int>(
            (json['barcodesAssigned'] is double) ? json['barcodesAssigned'].toInt() : json['barcodesAssigned'], (e) => e as int, 'barcodesAssigned',
            defaultValue: 0),
        usedBarcodesCount: ConversionUtils.castWithDefault<int>(
            (json['usedBarcodesCount'] is double) ? json['usedBarcodesCount'].toInt() : json['usedBarcodesCount'],
            (e) => e as int,
            'usedBarcodesCount',
            defaultValue: 0),
        companyAdminUserInfo: json['companyAdminUserInfo'] == null ? null : CompanyAdminUserInfo.fromJson(json['companyAdminUserInfo'] as Map<String, dynamic>),
        type: ConversionUtils.castWithDefault<String>(json['type'], (e) => e as String, defaultValue: CompanyTypeConstants.ccc, 'type'));
  }

  Map<String, dynamic> toJson() => _$CompanyModelToJson(this);

  DocumentReference getReference() {
    return FirebaseFirestore.instance.collection("companies").doc(id);
  }
}
