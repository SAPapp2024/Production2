// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNotificationModel _$UserNotificationModelFromJson(
        Map<String, dynamic> json) =>
    UserNotificationModel(
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: UserNotificationModel.dateTimeFromTimestampNullable(
          json['createdAt'] as Timestamp?),
    );

Map<String, dynamic> _$UserNotificationModelToJson(
    UserNotificationModel instance) {
  final val = <String, dynamic>{
    'title': instance.title,
    'description': instance.description,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('createdAt',
      UserNotificationModel.firestoreTimestampToJson(instance.createdAt));
  return val;
}
