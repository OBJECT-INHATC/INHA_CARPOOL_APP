import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/screen/main/tab/carpool/f_carpool_list.dart';
import 'package:fast_app_base/screen/main/tab/PopUp/f_popup.dart';
import 'package:flutter/material.dart';

import 'Maps/f_map.dart';
import 'home/f_home.dart';

enum TabItem {
  carpool(Icons.directions_car, '카풀', CarpoolList()),
  home(Icons.home, 'Home', Home()),
  myPage(Icons.person, 'My', Placeholder()),
  popmenu(Icons.menu, '메뉴', PopUpFragment()),
  map(Icons.map, '지도', GoogleMaps());
import 'package:fast_app_base/screen/main/tab/home/f_home.dart';
import 'package:flutter/material.dart';

enum TabItem {
  home(Icons.home, '홈', HomeFragment()),
  ttosspay(Icons.payment, '토스페이', TtospayFragment()),
  stock(Icons.candlestick_chart, '주식', StockFragment()),
  all(Icons.menu, '전체', AllFragment());

  final IconData activeIcon;
  final IconData inActiveIcon;
  final String tabName;
  final Widget firstPage;

  const TabItem(this.activeIcon, this.tabName, this.firstPage, {IconData? inActiveIcon})
      : inActiveIcon = inActiveIcon ?? activeIcon;

  BottomNavigationBarItem toNavigationBarItem(BuildContext context, {required bool isActivated}) {
    return BottomNavigationBarItem(
        icon: Icon(
          key: ValueKey(tabName),
          isActivated ? activeIcon : inActiveIcon,
          color:
              isActivated ? context.appColors.iconButton : context.appColors.iconButtonInactivate,
          isActivated ? context.appColors.iconButton : context.appColors.iconButtonInactivate,
        ),
        label: tabName);
  }
}
