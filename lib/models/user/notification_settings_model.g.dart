// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSettingsModel _$NotificationSettingsModelFromJson(
        Map<String, dynamic> json) =>
    NotificationSettingsModel(
      sampleStarted: json['sampleStarted'] as bool,
      sampleStartedEmail: json['sampleStartedEmail'] as bool,
      sampleComplete: json['sampleComplete'] as bool,
      sampleCompleteEmail: json['sampleCompleteEmail'] as bool,
      daysSinceSampleStart: json['daysSinceSampleStart'] as bool,
      daysSinceSampleStartEmail: json['daysSinceSampleStartEmail'] as bool,
      sampleCancelled: json['sampleCancelled'] as bool,
      sampleCancelledEmail: json['sampleCancelledEmail'] as bool,
    );

Map<String, dynamic> _$NotificationSettingsModelToJson(
        NotificationSettingsModel instance) =>
    <String, dynamic>{
      'sampleStarted': instance.sampleStarted,
      'sampleStartedEmail': instance.sampleStartedEmail,
      'sampleComplete': instance.sampleComplete,
      'sampleCompleteEmail': instance.sampleCompleteEmail,
      'daysSinceSampleStart': instance.daysSinceSampleStart,
      'daysSinceSampleStartEmail': instance.daysSinceSampleStartEmail,
      'sampleCancelled': instance.sampleCancelled,
      'sampleCancelledEmail': instance.sampleCancelledEmail,
    };
