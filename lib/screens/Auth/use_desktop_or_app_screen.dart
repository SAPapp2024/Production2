import 'package:flutter/material.dart';

class UseDesktopOrAppScreen extends StatelessWidget {
  static const String id = '/use_desktop_or_app';
  const UseDesktopOrAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Please visit this website on a desktop, or use the mobile app", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20), textAlign: TextAlign.center,),
        )
      ),
    );
  }
}
