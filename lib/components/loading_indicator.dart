import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: const Center(
            child: SizedBox(
                height: 60.0,
                width: 60.0,
                child:
                    //Image.asset('assets/images/loader.gif',fit: BoxFit.fill,) // use you custom loader or default loader
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                        strokeWidth: 5.0))));
  }
}
