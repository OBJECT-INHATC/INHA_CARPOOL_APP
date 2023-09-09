import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/theme/color/dark_app_colors.dart';
import 'package:inha_Carpool/common/theme/color/light_app_colors.dart';
import 'package:inha_Carpool/common/theme/shadows/dart_app_shadows.dart';
import 'package:inha_Carpool/common/theme/shadows/light_app_shadows.dart';
import 'package:flutter/material.dart';

import '../Colors/app_colors.dart';

enum CustomTheme {
  dark(
    DarkAppColors(),
    DarkAppShadows(),
  ),
  light(
    LightAppColors(),
    LightAppShadows(),
  );

  const CustomTheme(this.appColors, this.appShadows);

  final AbstractThemeColors appColors;
  final AbsThemeShadows appShadows;

  ThemeData get themeData {
    switch (this) {
      case CustomTheme.dark:
        return darkTheme;
      case CustomTheme.light:
        return lightTheme;
    }
  }
}

MaterialColor primarySwatchColor = Colors.lightBlue;

ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: primarySwatchColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,

    // textTheme: GoogleFonts.singleDayTextTheme(
    //   ThemeData(brightness: Brightness.light).textTheme,
    // ),
    colorScheme: ColorScheme.light().copyWith(
      primary: Colors.black, // 이 부분이 primary color에 해당합니다.
      secondary: Colors.transparent, // 이 부분이 tint color에 해당합니다.
    )
    // colorScheme: const ColorScheme.light(background: Colors.white)
);

ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: primarySwatchColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.veryDarkGrey,
    // textTheme: GoogleFonts.nanumMyeongjoTextTheme(
    //   ThemeData(brightness: Brightness.dark).textTheme,
    // ),
    colorScheme: const ColorScheme.dark(background: AppColors.veryDarkGrey));
