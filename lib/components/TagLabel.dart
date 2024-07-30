import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

enum TagLabelType {
  enabled, disabled
}

class TagLabel extends StatelessWidget {
  final TagLabelType type;
  final String text;
  const TagLabel({super.key, required this.type, required this.text});

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    final Color backgroundColor;
    switch (type) {
      case TagLabelType.enabled:
        textColor = AppColors.appPrimaryGreen;
        backgroundColor = const Color(0xFFD6FFE9);
        break;
      case TagLabelType.disabled:
        textColor = AppColors.appPrimaryGreen.withOpacity(0.5);
        backgroundColor = AppColors.appPrimaryGreen.withOpacity(0.1);
        break;
    }
    return Container(
        decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
        Radius.circular(8)),
    color: backgroundColor),
    padding: const EdgeInsets.all(4),
    child: Text(text,
    style: TextStyle(
    color: textColor)));
  }
}
