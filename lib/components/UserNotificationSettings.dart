import 'package:agro_k/components/custom_card.dart';
import 'package:agro_k/models/user/user_model.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

enum UserNotificationLabel {
  sampleAnalysisStarted,
  sampleCompleted,
  sampleCancelled,
  finishSampleReminder
}

extension UserNotificationLabelPresentation on UserNotificationLabel {

  String toFirebaseMap(UserNotificationType type) {
    String label;
    switch (this) {
      case UserNotificationLabel.sampleAnalysisStarted:
        label = "sampleStarted";
      case UserNotificationLabel.sampleCompleted:
        label = "sampleComplete";
      case UserNotificationLabel.sampleCancelled:
        label = "sampleCancelled";
      case UserNotificationLabel.finishSampleReminder:
        label = "daysSinceSampleStart";
    }
    return type == UserNotificationType.push ? label : "${label}Email";
  }

  String get label {
    switch (this) {
      case UserNotificationLabel.sampleAnalysisStarted:
        return "Notification when sample analysis started";
      case UserNotificationLabel.sampleCompleted:
        return "Notification when sample is completed";
      case UserNotificationLabel.sampleCancelled:
        return "Notification if sample cancelled";
      case UserNotificationLabel.finishSampleReminder:
        return "Finish sample reminder";
    }
  }

  (bool, bool) getNotificationSettings(UserModel user) {
    switch (this) {
      case UserNotificationLabel.sampleAnalysisStarted:
        return (user.notificationSettings.sampleStartedEmail, user.notificationSettings.sampleStarted);
      case UserNotificationLabel.sampleCompleted:
        return (user.notificationSettings.sampleCompleteEmail, user.notificationSettings.sampleComplete);
      case UserNotificationLabel.sampleCancelled:
        return (user.notificationSettings.sampleCancelledEmail, user.notificationSettings.sampleCancelled);
      case UserNotificationLabel.finishSampleReminder:
        return (user.notificationSettings.daysSinceSampleStartEmail, user.notificationSettings.daysSinceSampleStart);
    }
  }
}

enum UserNotificationType { email, push }

class UserNotificationSettings extends StatefulWidget {
  final UserModel user;
  final ProfileService profileService;

  const UserNotificationSettings(
      {super.key, required this.user, required this.profileService});

  @override
  State<UserNotificationSettings> createState() => _UserNotificationSettingsState();
}

class _UserNotificationSettingsState extends State<UserNotificationSettings> {
  @override
  Widget build(BuildContext context) {
    const List<UserNotificationLabel> labels = UserNotificationLabel.values;
    return CustomCard(
        padding: EdgeInsets.zero,
        child: ListView.separated(
          itemBuilder: (context, index) {
            var item = labels[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
              child: Row(
                key: ValueKey(index),
                children: [
                  Expanded(
                    child: Text(item.label,
                        style: const TextStyle(
                            color: AppColors.subtitleGray,
                            fontWeight: FontWeight.w500,
                            fontSize: 14)),
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  InkWell(
                    onTap: () async {
                      await widget.profileService.updateNotificationSettings(
                          widget.user, item.toFirebaseMap(UserNotificationType.email), !item.getNotificationSettings(widget.user).$1);
                      switch (item) {
                        case UserNotificationLabel.sampleAnalysisStarted:
                          widget.user.notificationSettings.sampleStartedEmail = !widget.user.notificationSettings.sampleStartedEmail;
                          break;
                        case UserNotificationLabel.sampleCompleted:
                          widget.user.notificationSettings.sampleCompleteEmail = !widget.user.notificationSettings.sampleCompleteEmail;
                          break;
                        case UserNotificationLabel.sampleCancelled:
                          widget.user.notificationSettings.sampleCancelledEmail = !widget.user.notificationSettings.sampleCancelledEmail;
                          break;
                        case UserNotificationLabel.finishSampleReminder:
                          widget.user.notificationSettings.daysSinceSampleStartEmail = !widget.user.notificationSettings.daysSinceSampleStartEmail;
                          break;
                      }
                      setState(() {});
                    },
                    child: Image.asset(
                        item.getNotificationSettings(widget.user).$1 ? "images/iconEmailOptionSelected.png" : "images/iconEmailOptionUnselected.png",
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  InkWell(
                    onTap: () async {
                      await widget.profileService.updateNotificationSettings(
                          widget.user, item.toFirebaseMap(UserNotificationType.push), !item.getNotificationSettings(widget.user).$2);
                      switch (item) {
                        case UserNotificationLabel.sampleAnalysisStarted:
                          widget.user.notificationSettings.sampleStarted = !widget.user.notificationSettings.sampleStarted;
                          break;
                        case UserNotificationLabel.sampleCompleted:
                          widget.user.notificationSettings.sampleComplete = !widget.user.notificationSettings.sampleComplete;
                          break;
                        case UserNotificationLabel.sampleCancelled:
                          widget.user.notificationSettings.sampleCancelled = !widget.user.notificationSettings.sampleCancelled;
                          break;
                        case UserNotificationLabel.finishSampleReminder:
                          widget.user.notificationSettings.daysSinceSampleStart = !widget.user.notificationSettings.daysSinceSampleStart;
                          break;
                      }
                      setState(() {});
                    },
                    child: Image.asset(
                      item.getNotificationSettings(widget.user).$2 ? "images/iconPhoneOptionSelected.png" : "images/iconPhoneOptionUnselected.png",
                      width: 36,
                      height: 36,
                    ),
                  ),
                ],
              ),
            );
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: labels.length,
          separatorBuilder: (context, index) {
            return const Divider(
              color: AppColors.appGray,
              thickness: 1,
              height: 0,
            );
          },
        ));
  }
}
