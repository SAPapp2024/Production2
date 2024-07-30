import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/models/company/grower_with_user_emails_to_notify_model.dart';
import 'package:agro_k/services/sample_service.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:flutter/material.dart';

class UserNotificationsForGrowerDialog extends StatefulWidget {
  final GrowerWithUserEmailsToNotifyModel growerWithUserEmailsToNotifyModel;

  const UserNotificationsForGrowerDialog(
      {Key? key, required this.growerWithUserEmailsToNotifyModel})
      : super(key: key);

  @override
  State<UserNotificationsForGrowerDialog> createState() =>
      _UserNotificationsForGrowerDialogState();
}

class _UserNotificationsForGrowerDialogState
    extends State<UserNotificationsForGrowerDialog> {
  final userEmailController = TextEditingController();
  var shouldUpdateParent = false;
  final sampleService = getIt<SampleService>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              side: BorderSide(color: AppColors.cardBorder, width: 1.0)),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 20),
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context, shouldUpdateParent);
                          },
                          icon: const Icon(Icons.close)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, top: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: 500, minHeight: 200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: userEmailController,
                              onFieldSubmitted: (_) =>
                                  inviteUserForGrowerNotifications(
                                      userEmailController.text),
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () =>
                                        inviteUserForGrowerNotifications(
                                            userEmailController.text),
                                    icon: const Icon(
                                      Icons.add,
                                      color: AppColors.appPrimaryGreen,
                                    )),
                                labelText: "Invite Email",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            widget.growerWithUserEmailsToNotifyModel.userEmails
                                    .isNotEmpty
                                ? Flexible(
                                    child: ListView.builder(
                                        itemCount: widget
                                            .growerWithUserEmailsToNotifyModel
                                            .userEmails
                                            .length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Text(widget
                                                    .growerWithUserEmailsToNotifyModel
                                                    .userEmails[index]),
                                              ),
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              IconButton(
                                                  splashRadius: 4,
                                                  onPressed: () {
                                                    deleteUserFromGrowerNotifications(
                                                        widget
                                                            .growerWithUserEmailsToNotifyModel
                                                            .userEmails[index]);
                                                  },
                                                  icon:
                                                      const Icon(Icons.delete))
                                            ],
                                          );
                                        }))
                                : Container(
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(top: 16),
                                    child: const Text("No users to notify"),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }

  Future<void> inviteUserForGrowerNotifications(String email) async {
    try {
      await sampleService.addUserToGrowerNotificationList(
          widget.growerWithUserEmailsToNotifyModel.grower, email);
      widget.growerWithUserEmailsToNotifyModel.userEmails.add(email);
      setState(() {
        shouldUpdateParent = true;
      });
    } catch (e, stackTrace) {
      await getIt<RemoteErrorLoggingService>().recordError(e, stackTrace);
    }
  }

  Future<void> deleteUserFromGrowerNotifications(String email) async {
    try {
      await sampleService.deleteUserFromGrowerNotificationList(
          widget.growerWithUserEmailsToNotifyModel.grower, email);
      widget.growerWithUserEmailsToNotifyModel.userEmails.remove(email);
      setState(() {
        shouldUpdateParent = true;
      });
    } catch (e, stackTrace) {
      await getIt<RemoteErrorLoggingService>().recordError(e, stackTrace);
    }
  }
}
