import 'package:agro_k/screens/Dashboard/dashboard_screen/mobile_dashboard.dart';
import 'package:agro_k/screens/Dashboard/dashboard_screen/web_dashboard.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  static const String id = '/dashboard';

  const DashboardScreen(
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? const SelectionArea(child: WebDashboard()) : const MobileDashboard();
  }
}