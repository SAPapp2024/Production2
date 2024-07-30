import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final void Function()? onTap;
  final double elevation;
  final double borderRadius;

  const CustomCard({super.key, required this.child, this.padding = const EdgeInsets.all(20.0), this.onTap, this.elevation = 15, this.borderRadius = 20});

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        elevation: elevation,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child,)));
  }
}