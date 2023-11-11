import 'package:flutter/material.dart';

import '../../Colors/app_colors.dart';
/// 사용자 정의 색상
///  사용예시 => Color get appBar => const Color.fromARGB(255, 144, 202, 249); //앱바 색상 정의
///  색상적용 =>  color: context.appColors.appBar,  //앱바 색상 적용 예시

typedef ColorProvider = Color Function();

abstract class AbstractThemeColors {
  const AbstractThemeColors();

  Color get veryBrightGrey => AppColors.brightGrey;

  Color get drawerBg => const Color.fromARGB(255, 255, 255, 255);

  Color get scrollableItem => const Color.fromARGB(255, 57, 57, 57);

  Color get iconButton => const Color.fromARGB(255, 0, 0, 0);

  Color get iconButtonInactivate => const Color.fromARGB(255, 162, 162, 162);

  Color get inActivate => const Color.fromARGB(255, 200, 207, 220);

  Color get activate => const Color.fromARGB(255, 63, 72, 95);

  Color get badgeBg => AppColors.blueGreen;

  Color get textBadgeText => Colors.white;

  Color get badgeBorder => Colors.transparent;

  Color get divider => const Color.fromARGB(255, 210, 205, 205);

  Color get text => AppColors.darkGrey;

  Color get subText => AppColors.darkGrey;

  Color get cardBackground => Colors.white;

  Color get hintText => AppColors.middleGrey;

  Color get focusedBorder => AppColors.darkGrey;

  Color get confirmText => AppColors.blue;

  Color get drawerText => text;

  Color get appBar => const Color.fromARGB(255, 144, 202, 249);

  Color get logoColor => const Color.fromARGB(255, 70, 100, 192);

  Color get mainList => const Color.fromARGB(255, 121, 181, 222);


  Color get snackbarBgColor => AppColors.mediumBlue;

  Color get blueButtonBackground => AppColors.darkBlue;

  Color get blueMarker => Colors.blue;



  Color get roundedLaoutButtonBackground =>
      const Color.fromARGB(255, 24, 24, 24);
}
