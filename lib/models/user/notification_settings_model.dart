import 'package:json_annotation/json_annotation.dart';
part 'notification_settings_model.g.dart';

@JsonSerializable()
class NotificationSettingsModel {
  bool sampleStarted;
  bool sampleStartedEmail;
  bool sampleComplete;
  bool sampleCompleteEmail;
  bool daysSinceSampleStart;
  bool daysSinceSampleStartEmail;
  bool sampleCancelled;
  bool sampleCancelledEmail;

  NotificationSettingsModel({
    required this.sampleStarted,
    required this.sampleStartedEmail,
    required this.sampleComplete,
    required this.sampleCompleteEmail,
    required this.daysSinceSampleStart,
    required this.daysSinceSampleStartEmail,
    required this.sampleCancelled,
    required this.sampleCancelledEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      "sampleStarted": sampleStarted,
      "sampleStartedEmail": sampleStartedEmail,
      "sampleComplete": sampleComplete,
      "sampleCompleteEmail": sampleCompleteEmail,
      "daysSinceSampleStart": daysSinceSampleStart,
      "daysSinceSampleStartEmail": daysSinceSampleStartEmail,
      "sampleCancelled": sampleCancelled,
      "sampleCancelledEmail": sampleCancelledEmail
    };
  }

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) => _$NotificationSettingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSettingsModelToJson(this);
}
