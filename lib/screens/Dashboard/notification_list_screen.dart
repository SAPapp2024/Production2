import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/components/primary_button.dart';
import 'package:agro_k/models/company/user_notification_model.dart';
import 'package:agro_k/services/profile_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/function_utils/date_utils.dart';
import 'package:agro_k/utilities/function_utils/navigation_utils.dart';
import 'package:flutter/material.dart';

class NotificationListScreen extends StatefulWidget {
  static const id = "/notification_list_id";

  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class UserNotificationWithReadPropertyModel {
  final UserNotificationModel notification;
  bool isRead;

  UserNotificationWithReadPropertyModel(
      {required this.notification, required this.isRead});
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<UserNotificationWithReadPropertyModel>? notifications;
  ProfileService profileService = getIt.get();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    final user = await profileService.getUser();
    setState(() {
      notifications = user?.notifications.map((e) {
        debugPrint("createdAt = ${e.createdAt}");
        return UserNotificationWithReadPropertyModel(
            notification: e, isRead: false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              context.goBackWeb();
            },
          ),
          backgroundColor: AppColors.appPrimaryGreen,
          centerTitle: true,
          title: const Text("Notifications"),
        ),
        backgroundColor: AppColors.pageBackground,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: notifications != null && notifications!.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PrimaryButton(
                          title: "Mark as read",
                          type: PrimaryButtonType.text,
                          actionType: PrimaryButtonActionType.positive,
                          onPressed: () async {
                            try {
                              await profileService.clearNotifications();
                              setState(() {
                                notifications = notifications!
                                    .map((e) => UserNotificationWithReadPropertyModel(
                                        notification: e.notification,
                                        isRead: true))
                                    .toList();
                              });
                            } catch (e) {
                              debugPrint("error = $e");
                            }
                          },
                          padding: const EdgeInsets.fromLTRB(20, 14.5, 0, 14.5),
                        ),
                      ],
                    ),
                    const Divider(
                      color: AppColors.appGray,
                      thickness: 1,
                      height: 0,
                    ),
                    Expanded(
                      child: ListView.separated(
                          itemCount: notifications!.length,
                          separatorBuilder: (context, index) {
                            return const Divider(
                              color: AppColors.appGray,
                              thickness: 1,
                              height: 0,
                            );
                          },
                          itemBuilder: (BuildContext context, int index) =>
                              _NotificationCard(
                                  key: ValueKey(
                                      notifications![index].notification),
                                  notificationWithReadProperty:
                                      notifications![index])),
                    ),
                  ],
                )
              : const Center(
                  child: Text(
                    "No notifications",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
        ));
  }
}

class _NotificationCard extends StatefulWidget {
  final UserNotificationWithReadPropertyModel notificationWithReadProperty;

  const _NotificationCard(
      {Key? key, required this.notificationWithReadProperty})
      : super(key: key);

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PrimaryButton(
                title: widget.notificationWithReadProperty.isRead
                    ? "Cleared"
                    : "Clear",
                type: PrimaryButtonType.text,
                actionType: PrimaryButtonActionType.positive,
                onPressed: widget.notificationWithReadProperty.isRead ? null : () async {
                  await getIt.get<ProfileService>().clearSingleNotification(
                      widget.notificationWithReadProperty.notification);
                  setState(() {
                    widget.notificationWithReadProperty.isRead = true;
                  });
                },
                padding: const EdgeInsets.fromLTRB(0, 14.5, 20, 14.5),
              ),
              if (widget.notificationWithReadProperty.notification.createdAt !=
                  null)
                Text(
                  formatDateWithTime(widget
                      .notificationWithReadProperty.notification.createdAt!),
                  style: const TextStyle(
                      color: AppColors.subtitleGray,
                      fontSize: 10,
                      fontWeight: FontWeight.w400),
                )
            ],
          ),
          Text(
            widget.notificationWithReadProperty.notification.title,
            style: const TextStyle(color: AppColors.black1, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
