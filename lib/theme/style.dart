import 'dart:ui';

import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

ThemeData appTheme() {
  const style = TextStyle(fontFeatures: [FontFeature.proportionalFigures()]);
  return ThemeData.light().copyWith(
    useMaterial3: false,
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.appPrimaryGreen),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: AppColors.black1,
    hintColor: AppColors.black1,
    dividerColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    listTileTheme: const ListTileThemeData(textColor: AppColors.black1),
    textTheme: TextTheme(
      displayMedium: const TextStyle(
        fontSize: 60,
        fontFamily: 'SFProDisplay',
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelLarge: const TextStyle(
        fontSize: 17,
        fontFamily: 'SFProText',
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: ThemeData.light()
              .textTheme
              .titleMedium
              ?.copyWith(color: AppColors.black1) ??
          const TextStyle(
            fontSize: 14,
            fontFamily: 'SFProText',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
    ).merge(const TextTheme(
      displayLarge: style,
      displayMedium: style,
      displaySmall: style,
      headlineLarge: style,
      headlineMedium: style,
      headlineSmall: style,
      titleLarge: style,
      titleMedium: style,
      titleSmall: style,
      bodyLarge: style,
      bodyMedium: style,
      bodySmall: style,
      labelLarge: style,
      labelMedium: style,
      labelSmall: style,
    )),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: AppColors.black1)
        .copyWith(error: Colors.red),
  );
}

const kWelcomeTitleTextStyle = TextStyle(
  fontSize: 72,
  fontFamily: 'HKGrotesk',
  fontWeight: FontWeight.w700,
  color: AppColors.black1,
);

const kBadgeText = TextStyle(
  fontSize: 12,
  fontFamily: 'SFProText',
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

const kDialogDescription = TextStyle(
    fontSize: 18,
    fontFamily: 'SFProDisplay',
    fontWeight: FontWeight.w500,
    color: AppColors.black1,
    letterSpacing: -0.08);
