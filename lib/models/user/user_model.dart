import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/models/company/company_model.dart';
import 'package:agro_k/models/company/user_notification_model.dart';
import 'package:agro_k/models/document_serializer_nullable.dart';
import 'package:agro_k/models/user/notification_settings_model.dart';
import 'package:agro_k/models/user/phone_model.dart';
import 'package:agro_k/models/user/user_company_model.dart';
import 'package:agro_k/models/user/user_farm_references_model.dart';
import 'package:agro_k/models/user/user_with_companies_model.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
@DocumentSerializerNullable()
class UserModel {
  String id;
  PhoneModel? phone;
  String email;
  String? firstName;
  String? lastName;

  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: firestoreTimestampToJson)
  DateTime created;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: firestoreTimestampToJson)
  DateTime lastConnection;

  NotificationSettingsModel notificationSettings;
  bool isSuperAdmin;
  List<UserCompanyReferencesModel> companyReferences;
  bool isConfirmed;
  String? profileImagePath;
  List<String> deviceTokens;
  List<UserNotificationModel> notifications;
  bool enabled;
  bool deleted;

  UserModel(
      {required this.id,
      required this.phone,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.created,
      required this.lastConnection,
      required this.notificationSettings,
      required this.isSuperAdmin,
      required this.companyReferences,
      required this.isConfirmed,
      required this.profileImagePath,
      required this.deviceTokens,
      required this.notifications,
      required this.enabled, this.deleted = false});

  String? getFullName() {
    if (firstName == null || lastName == null) {
      return null;
    }
    return "$firstName $lastName";
  }

  bool isCompanyAdmin(String farmId) {
    return companyReferences
            .firstWhereOrNull((farm) => farm.companyReference.id == farmId)
            ?.isAdmin ??
        false;
  }

  static DateTime dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static dynamic firestoreTimestampToJson(dynamic value) => value;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<UserCompanyReferencesModel> companyReferences = [];
    try {
      if (json['companyReferences'] != null) {
        companyReferences = (json['companyReferences'] as List<dynamic>)
            .map((e) {
              try {
                return UserCompanyReferencesModel.fromJson(
                    e as Map<String, dynamic>);
              } catch (exception, stacktrace) {
                getIt
                    .get<RemoteErrorLoggingService>()
                    .recordError(exception, stacktrace);
                return null;
              }
            })
            .whereNotNull()
            .toList();
      }
    } catch (e, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(e, stacktrace);
    }
    List<UserNotificationModel> notifications = [];
    try {
      if (json['notifications'] != null) {
        notifications = (json['notifications'] as List<dynamic>)
            .map((e) {
          try {
            return UserNotificationModel.fromJson(
                e as Map<String, dynamic>);
          } catch (exception, stacktrace) {
            getIt
                .get<RemoteErrorLoggingService>()
                .recordError(exception, stacktrace);
            return null;
          }
        })
            .whereNotNull()
            .toList();
      }
    } catch (e, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(e, stacktrace);
    }
    PhoneModel? phone;
    try {
      if (json['phone'] != null) {
        phone = PhoneModel.fromJson(json['phone'] as Map<String, dynamic>);
      }
    } catch (e, stacktrace) {
      getIt.get<RemoteErrorLoggingService>().recordError(e, stacktrace);
    }
    return UserModel(
      id: json['id'] as String,
      phone: phone,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      created: UserModel.dateTimeFromTimestamp(json['created'] as Timestamp),
      lastConnection:
          UserModel.dateTimeFromTimestamp(json['lastConnection'] as Timestamp),
      notificationSettings: NotificationSettingsModel.fromJson(
          json['notificationSettings'] as Map<String, dynamic>),
      isSuperAdmin: json['isSuperAdmin'] as bool,
      companyReferences: companyReferences,
      isConfirmed: json['isConfirmed'] as bool,
      profileImagePath: json['profileImagePath'] as String?,
      deviceTokens: (json['deviceTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notifications: notifications,
      enabled: json['enabled'] as bool,
      deleted: json['deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  Future<UserWithCompaniesModel> toUserWithCompaniesModel() async {
    List<UserCompanyModel> farms =
        (await Future.wait(companyReferences.map((companyReference) async {
      try {
        DocumentSnapshot companySnapshot = await companyReference.companyReference.get();
        if (companySnapshot.exists) {
          Map<String, dynamic>? data =
              companySnapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            return UserCompanyModel(
                farm: CompanyModel.fromJson(data), isAdmin: companyReference.isAdmin);
          }
        }
        return null;
      } catch (exception, stacktrace) {
        getIt
            .get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
        return null;
      }
    })))
            .whereNotNull()
            .toList();
    return UserWithCompaniesModel(user: this, companies: farms);
  }

  DocumentReference getReference() {
    return FirebaseFirestore.instance.collection('users').doc(id);
  }
}
