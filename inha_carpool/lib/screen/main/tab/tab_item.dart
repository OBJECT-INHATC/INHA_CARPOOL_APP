import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';

import 'Maps/f_map.dart';
import 'PopUp/f_popup.dart';
import 'carpool/f_carpool_list.dart';
import 'home/f_home.dart';

enum TabItem {
  carpool(Icons.directions_car, '카풀', CarpoolList()),
  home(Icons.home, 'Home', Home()),
  myPage(Icons.person, 'My', GoogleMapsApp());

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
              ? context.appColors.iconButton
              : context.appColors.iconButtonInactivate,
        ),
        label: tabName);
  }
}
