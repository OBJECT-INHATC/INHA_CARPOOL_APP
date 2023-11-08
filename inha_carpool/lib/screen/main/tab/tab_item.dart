import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/f_mypage.dart';

import 'carpool/f_carpool_list.dart';
import 'home/f_home.dart';

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
