import 'package:flutter/material.dart';

import '../theme/color/abs_theme_colors.dart';
import '../theme/custom_theme.dart';
import '../theme/custom_theme_holder.dart';


//BuildContext => 위젯 트리에서 빌드하고 있는 위치 및 환경에 대한 정보를 제공하는 객체
//UI 구축 과정에서 반복적으로 사용되는 코드를 간소화하고, 환경 및 테마와 관련된 정보에 쉽게 접근



extension ContextExtension on BuildContext {

  //widthSize 비율에 따른 화면 너비 반환.
  double width(double widthSize) {
    return MediaQuery.of(this).size.width * widthSize;
  }

  //heightSize 비율에 따른 화면 높이 반환.
  double height(double heightSize) {
    return MediaQuery.of(this).size.height * heightSize;
  }

  //현재 디바이스의 화면 너비 반환.
  double get deviceWidth {
    return MediaQuery.of(this).size.width;
  }

  //현재 디바이스의 화면 높이 반환.
  double get deviceHeight {
    return MediaQuery.of(this).size.height;
  }

  //현재 디바이스의 방향(가로 또는 세로) 반환.
  Orientation get deviceOrientation {
    return MediaQuery.of(this).orientation;
  }

  //상단 상태 표시줄의 높이 반환.
  double get statusBarHeight {
    return MediaQuery.of(this).padding.top;
  }

  //화면 하단의 패딩 높이 반환.
  double get viewPaddingBottom {
    return MediaQuery.of(this).padding.bottom;
  }

  //현재 플랫폼의 밝기 정보(라이트 또는 다크 모드) 반환.
  Brightness get platformBrightness {
    return MediaQuery.of(this).platformBrightness;
  }

  //현재 앱 테마의 색상 정보 반환.
  AbstractThemeColors get appColors => CustomThemeHolder.of(this).appColors;

  //현재 앱 테마의 그림자 정보 반환.

  //현재 사용 중인 커스텀 테마 정보 반환.
  CustomTheme get themeType => CustomThemeHolder.of(this).theme;

  //커스텀 테마를 변경하는 함수 반환.
  Function(CustomTheme) get changeTheme => CustomThemeHolder.of(this).changeTheme;
}

