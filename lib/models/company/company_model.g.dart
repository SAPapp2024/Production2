// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyModel _$CompanyModelFromJson(Map<String, dynamic> json) => CompanyModel(
      id: json['id'] as String,
      address: json['address'] as String,
      phone: json['phone'] == null
          ? null
          : PhoneModel.fromJson(json['phone'] as Map<String, dynamic>),
      alternatePhone: json['alternatePhone'] == null
          ? null
          : PhoneModel.fromJson(json['alternatePhone'] as Map<String, dynamic>),
      country: json['country'] as String,
      city: json['city'] as String,
      created: CompanyModel.dateTimeFromTimestamp(json['created'] as Timestamp),
      name: json['name'] as String,
      state: json['state'] as String,
      zipcode: json['zipcode'] as String,
      users: (json['users'] as List<dynamic>)
          .map((e) => const DocumentSerializer()
              .fromJson(e as DocumentReference<Object?>))
          .toList(),
      locations: (json['locations'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      invitedUsers: (json['invitedUsers'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, InvitedUsersModel.fromJson(e as Map<String, dynamic>)),
      ),
      fields: (json['fields'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      growers: (json['growers'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      crops: (json['crops'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      assignableBarcodes: (json['assignableBarcodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      barcodesPurchased: json['barcodesPurchased'] as int,
      barcodesAssigned: json['barcodesAssigned'] as int,
      usedBarcodesCount: json['usedBarcodesCount'] as int? ?? 0,
      companyAdminUserInfo: json['companyAdminUserInfo'] == null
          ? null
          : CompanyAdminUserInfo.fromJson(
              json['companyAdminUserInfo'] as Map<String, dynamic>),
      type: json['type'] as String,
    );

Map<String, dynamic> _$CompanyModelToJson(CompanyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'phone': instance.phone?.toJson(),
      'alternatePhone': instance.alternatePhone?.toJson(),
      'city': instance.city,
      'created': CompanyModel.firestoreTimestampToJson(instance.created),
      'name': instance.name,
      'state': instance.state,
      'zipcode': instance.zipcode,
      'country': instance.country,
      'users': instance.users.map(const DocumentSerializer().toJson).toList(),
      'locations': instance.locations,
      'invitedUsers':
          instance.invitedUsers?.map((k, e) => MapEntry(k, e.toJson())),
      'fields': instance.fields,
      'growers': instance.growers,
      'crops': instance.crops,
      'assignableBarcodes': instance.assignableBarcodes,
      'barcodesPurchased': instance.barcodesPurchased,
      'barcodesAssigned': instance.barcodesAssigned,
      'usedBarcodesCount': instance.usedBarcodesCount,
      'type': instance.type,
      'companyAdminUserInfo': instance.companyAdminUserInfo?.toJson(),
    };
