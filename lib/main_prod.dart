import 'package:agro_k/app/setup/firebase_options/firebase_options_prod.dart';
import 'package:agro_k/app/setup/main_setup.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool isVerified = false;

Future<void> main() async {
  debugPrint("Started main_prod.dart");
  await mainSetup(DefaultFirebaseOptions.currentPlatform, Environment.prod);
}