import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

enum PrimaryButtonType { filled, outlined, text }

enum PrimaryButtonActionType { positive, negative }

class PrimaryButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  final PrimaryButtonType type;
  final PrimaryButtonActionType actionType;
  final Widget? icon;
  final bool iconLeft;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;

  const PrimaryButton(
      {super.key,
      this.onPressed,
      required this.title,
      required this.type,
      required this.actionType,
      this.icon,
      this.iconLeft = true,
      this.backgroundColor,
      this.textColor,
      this.padding = const EdgeInsets.symmetric(vertical: 14.5, horizontal: 20)});

  @override
  Widget build(BuildContext context) {
    ButtonStyle style;
    switch (type) {
      case PrimaryButtonType.filled:
        Color backgroundColor;
        if (this.backgroundColor != null) {
          backgroundColor = this.backgroundColor!;
        } else {
          switch (actionType) {
            case PrimaryButtonActionType.positive:
              backgroundColor = AppColors.appPrimaryGreen;
              break;
            case PrimaryButtonActionType.negative:
              backgroundColor = Colors.red;
              break;
          }
        }
        style = ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          )),
          foregroundColor: WidgetStateProperty.all(textColor ?? Colors.white),
          backgroundColor: WidgetStateProperty.all(
              onPressed != null ? backgroundColor : AppColors.grayTextColor),
        );
        break;
      case PrimaryButtonType.text:
        Color foregroundColor;
        switch (actionType) {
          case PrimaryButtonActionType.positive:
            foregroundColor = AppColors.appPrimaryGreen;
            break;
          case PrimaryButtonActionType.negative:
            foregroundColor = Colors.red;
            break;
        }
        style = ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          )),
          foregroundColor: WidgetStateProperty.all(foregroundColor),
        );
        break;
      case PrimaryButtonType.outlined:
        Color foregroundColor;
        switch (actionType) {
          case PrimaryButtonActionType.positive:
            foregroundColor = AppColors.appPrimaryGreen;
            break;
          case PrimaryButtonActionType.negative:
            foregroundColor = Colors.red;
            break;
        }
        style = ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
            side: const BorderSide(color: AppColors.appGray, width: 1),
          )),
          foregroundColor: WidgetStateProperty.all(foregroundColor),
        );
        break;
    }
    return TextButton(
      onPressed: onPressed,
      style: style.copyWith(
        minimumSize: WidgetStateProperty.all(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStateProperty.all(padding),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null && iconLeft) ...[
            icon!,
            const SizedBox(
              width: 8,
            )
          ],
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
          if (icon != null && !iconLeft) ...[
            const SizedBox(
              width: 8,
            ),
            icon!
          ],
        ],
      ),
    );
  }
}
