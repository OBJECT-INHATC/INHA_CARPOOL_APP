import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/main/tab/tab_item.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    super.key,
    required this.tabItem,
    required this.navigatorKey,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => tabItem.firstPage,
          );
        });
  }
}
