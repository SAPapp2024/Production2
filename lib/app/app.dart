import 'package:agro_k/app/below_minimum_app.dart';
import 'package:agro_k/app/routes.dart';
import 'package:agro_k/app/setup/injectable_setup.dart';
import 'package:agro_k/app/setup/min_version_bloc.dart';
import 'package:agro_k/screens/Auth/custom_auth/view/custom_auth_screen.dart';
import 'package:agro_k/theme/style.dart';
import 'package:agro_k/utilities/remote_error_logging_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';

class AgroKApp extends StatefulWidget {
  final GoRouter router;

  const AgroKApp({required this.router, Key? key}) : super(key: key);

  @override
  State<AgroKApp> createState() => AgroKAppState();
}

class AgroKAppState extends State<AgroKApp> {
  static Uri? newLocationUri;

  void getData() async {
    if (!kIsWeb) {
      try {
        var uri = await getInitialUri();
        if (isCustomAuthActionUri(uri)) {
          newLocationUri = uri;
        }
      } catch (exception, stacktrace) {
        getIt
            .get<RemoteErrorLoggingService>()
            .recordError(exception, stacktrace);
      }
      setState(() {});
      uriLinkStream.listen((uri) {
        if (isCustomAuthActionUri(uri)) {
          newLocationUri = uri;
        }
        setState(() {});
      }, onError: (err, StackTrace stacktrace) {
        getIt.get<RemoteErrorLoggingService>().recordError(err, stacktrace);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      if (newLocationUri != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.router.goNamed(CustomAuthActionScreen.id, queryParameters: {
            "oobCode": newLocationUri!.queryParameters["oobCode"]!,
            "mode": newLocationUri!.queryParameters["mode"]!
          });
          newLocationUri = null;
        });
      }
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    var theme = appTheme();

    final appWidget = MaterialApp.router(
      scrollBehavior: CustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Agro-K',
      theme: theme,
      routerConfig: widget.router,
      builder: (context, child) {
        return MediaQuery.withNoTextScaling(child: child!);
      },
    );

    if (kIsWeb) {
      return appWidget;
    } else {
      return BlocBuilder<MinVersionBloc, MinVersionState>(
          buildWhen: (prev, current) => prev.status != current.status,
          builder: (context, state) {
            if (state.status == AppVersionStatus.belowMinimum) {
              return const BelowMinimumApp();
            } else {
              return appWidget;
            }
          });
    }
  }
}

class NavigationService {
  GlobalKey<NavigatorState>? navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigationKey = GlobalKey<NavigatorState>();
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      kIsWeb ? {} : {PointerDeviceKind.touch};
}
