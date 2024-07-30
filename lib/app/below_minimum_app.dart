import 'dart:io';

import 'package:agro_k/theme/style.dart';
import 'package:agro_k/utilities/function_utils/general_utils.dart';
import 'package:flutter/material.dart';

class BelowMinimumApp extends StatelessWidget {
  const BelowMinimumApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        builder: (context, child) {
          return MediaQuery.withNoTextScaling(child: child!);
        },
        home: Scaffold(
            body: Center(
                child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              elevation: 8,
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0, top: 24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text(
                      "Update Required",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "Please update the app to the latest version to continue using it.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextButton(
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          UrlUtils.launchUrl(
                              UrlUtils.androidFirebaseAppDistributionUrl);
                        } else if (Platform.isIOS) {
                          UrlUtils.launchUrl(UrlUtils.iosTestFlightUrl);
                        }
                      },
                      child: const Text("Download Latest Version"),
                    ),
                  ]))),
        ))));
  }
}
