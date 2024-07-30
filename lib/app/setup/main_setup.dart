import 'dart:async';
import 'dart:math';

import 'package:agro_k/app/app.dart';
import 'package:agro_k/app/setup/fake_mobile_imports.dart'
    if (dart.library.html) 'package:agro_k/app/setup/url_strategy.dart';
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/min_version_bloc.dart';
import 'package:agro_k/app/setup/user_state.dart';
import 'package:agro_k/services/auth_service.dart';
import 'package:agro_k/utilities/enums/environment_enum.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> mainSetup(FirebaseOptions options, Environment environment) async {
  runZonedGuarded<Future<void>>(() async {
    debugPrint("STARTED SETUP!!");
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: options,
    );
    if (kIsWeb) {
      GoRouter.optionURLReflectsImperativeAPIs = true;
    }
    configureDependencies(environment.toEnvironmentClass());
    UserState userState = getIt.get();
    RemoteErrorLoggingService firebaseCrashlyticsService = getIt.get();
    firebaseCrashlyticsService.init(environment);
    await userState.getUserDataFirstTime();
    await setup();
    _setupNotifications();
    removeHashtagFromUrls();
    debugPrint("ENDED SETUP!!");
    runApp(RepositoryProvider.value(
      value: environment,
      child: MultiBlocProvider(providers: [
        BlocProvider<MinVersionBloc>(
          create: (context) => getIt.get()..listenAppVersion(),
        ),
      ], child: AgroKApp(router: getIt.get())),
    ));
  }, (error, stack) {
    debugPrint("errrorr.. $error / $stack");
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
  });
}

Future<void> _setupNotifications() async {
  if (!kIsWeb) {
    await _getNotificationPermission();
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelKey: 'sample_channel',
              channelName: 'Sample notifications',
              channelDescription: 'Notification channel for samples',
              defaultColor: const Color(0xFF9D50DD),
              ledColor: Colors.white)
        ]);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _messageListener();
  }
}

Future<void> _getNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  debugPrint('User granted permission: ${settings.authorizationStatus}');
}

void _messageListener() {
  FirebaseMessaging.onMessage.listen(_processNotitfication);
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
}

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  _processNotitfication(message);
}

void _processNotitfication(RemoteMessage message) {
  debugPrint('Message data: ${message.data}');
  if (message.notification != null) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: Random.secure().nextInt(10000),
            channelKey: 'sample_channel',
            title: message.notification!.title,
            body: message.notification!.body));
  }
}

Future<bool> setup() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool isFirstTimeRunningApp =
      sharedPreferences.getBool("isFirstTimeRunningApp") ?? true;
  if (isFirstTimeRunningApp) {
    if (FirebaseAuth.instance.currentUser != null) {
      await AuthService().deleteNotificationToken();
      await FirebaseAuth.instance.signOut();
    }
    sharedPreferences.setBool("isFirstTimeRunningApp", false);
    return false;
  }
  var isVerified = false;
  User? currentUser;
  if (!kIsWeb) {
    currentUser = FirebaseAuth.instance.currentUser;
    debugPrint("user is $currentUser");
  } else {
    currentUser = await FirebaseAuth.instance.authStateChanges().first;
  }
  if (currentUser != null) {
    await currentUser.reload();
    isVerified = currentUser.emailVerified;
    if (!kIsWeb) {
      AuthService().updateNotificationToken(currentUser.uid);
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        AuthService().updateNotificationToken(currentUser!.uid);
      });
    }
  }

  if (isVerified == false && currentUser != null) {
    FirebaseAuth.instance.signOut();
  }

  return isVerified;
}
