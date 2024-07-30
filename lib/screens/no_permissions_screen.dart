import 'package:agro_k/screens/Dashboard/dashboard_screen/dashboard_screen.dart';
import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoPermissionsScreen extends StatelessWidget {
  const NoPermissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You don't have permissions to see this screen",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
            const SizedBox(
              height: 16,
            ),
            TextButton(
                onPressed: () {
                  debugPrint("go to home no permissions");
                  context.go(DashboardScreen.id);
                },
                child: const Text("Home",
                    style: TextStyle(
                        fontSize: 20, color: AppColors.appPrimaryGreen)))
          ],
        ),
      ),
    );
  }
}
