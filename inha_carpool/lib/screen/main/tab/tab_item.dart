import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/s_mypage.dart';

import 'carpool/s_carpool.dart';
import 'home/s_home.dart';

enum TabItem {
  carpool(Icons.local_taxi, '카풀', CarpoolList()),
  home(Icons.home, '홈', Home()),
  myPage(Icons.account_circle, '내 정보', MyPage());

  final IconData activeIcon;
  final IconData inActiveIcon;
  final String tabName;
  final Widget firstPage;

  const TabItem(this.activeIcon, this.tabName, this.firstPage,
      {IconData? inActiveIcon})
      : inActiveIcon = inActiveIcon ?? activeIcon;

  BottomNavigationBarItem toNavigationBarItem(BuildContext context,
      {required bool isActivated}) {
    return BottomNavigationBarItem(
        icon: Icon(
          key: ValueKey(tabName),
          isActivated ? activeIcon : inActiveIcon,
          color: isActivated
              ? context.appColors.logoColor
              : context.appColors.iconButtonInactivate,
        ),
        label: tabName);
  }
}
