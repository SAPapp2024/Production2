import 'dart:convert';

import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';

Future sendPushNotification(String receiverToken, String title,
    String description, Environment environment) async {
  debugPrint("About to send to $receiverToken");
  String authorizationKey;
  if (environment == Environment.qa) {
    authorizationKey =
    'key=AAAAKSyWK9w:APA91bEKfywg4JV9V67xZ4fVzPX0oiONjNtKvE1aopiw0nkLk5CKf2lHrjoC6KL7AeUJRk6lNMQJjIm1vfBcWFBNNiD8COv6Qgwlkg73uZDNE_Yh5sWv3mVMW4xT5cP2MtFYVAg8cYIN';
  } else {
    authorizationKey =
    'key=AAAAtRVb-X4:APA91bFj9iTJ5y0cgeQ2f8Lf3ejVfq9CkXqY6y5DG2uLN4rH8gZtpnKGZxzPnpk_VvizYdZ12Fm-antKbpUKDOXZP-GF1XEprjvDRB7xSNPcQiJ944EJvpu2fDMxDfFk-bJ5nhGPZrOq';
  }
  try {
    http.Response res = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': authorizationKey
      },
      body: json.encode({
        'to': receiverToken,
        "notification": {"title": title, "body": description}
      }),
    );
    debugPrint("sc = ${res.statusCode} / message = ${res.body}");
  } catch (exception, stacktrace) {
    getIt.get<RemoteErrorLoggingService>()
        .recordError(exception, stacktrace);
  }
}