import 'package:flutter/material.dart';
import 'package:inha_Carpool/fragment/setting/f_setting.dart';
import 'package:inha_Carpool/screen/main/tab/tab_item.dart';
import 'package:inha_Carpool/screen/main/tab/tab_navigator.dart';

import '../../common/common.dart';
import '../../fragment/f_notification.dart';
import 'w_menu_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  //시작 화면 지정
  TabItem _currentTab = TabItem.home;

  //사용 가능한 화면 리스트
  final tabs = [TabItem.carpool, TabItem.home, TabItem.myPage,
    TabItem.popmenu, TabItem.map];

  //각 화면별 네비게이터 키 리스트
  final List<GlobalKey<NavigatorState>> navigatorKeys = [];

  int get _currentIndex => tabs.indexOf(_currentTab);

  GlobalKey<NavigatorState> get _currentTabNavigationKey =>
      navigatorKeys[_currentIndex];

  bool get extendBody => true;

  static double get bottomNavigationBarBorderRadius => 30.0;

  @override
  void initState() {
    super.initState();
    // 각 텝의 네비게이터 초기화
    initNavigatorKeys();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade200,
          title: 'titleSTR'.tr().text.make(),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                size: 35,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationList()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, size: 35),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingPage()),
                );

              },
            ),
          ],
        ),
        //바디를 하단 네비게이션 바 아래까지 확장
        extendBody: extendBody,
        //bottomNavigationBar 아래 영역 까지 그림
        drawer: const MenuDrawer(),
        body: Padding(
          padding: EdgeInsets.only(
              bottom: extendBody ? 60 - bottomNavigationBarBorderRadius : 0),
          child: SafeArea(
            bottom: !extendBody,
            child: pages,
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  IndexedStack get pages => IndexedStack(
      index: _currentIndex,
      children: tabs
          .mapIndexed((tab, index) => Offstage(
                offstage: _currentTab != tab,
                child: TabNavigator(
                  navigatorKey: navigatorKeys[index],
                  tabItem: tab,
                ),
              ))
          .toList());

  //텝 내의서 뒤로 갈 수 있으면 해당 탭의 네비게이터를 이용, 아니면 홈으로 이동
  Future<bool> _handleBackPressed() async {
    final isFirstRouteInCurrentTab =
        (await _currentTabNavigationKey.currentState?.maybePop() == false);
    if (isFirstRouteInCurrentTab) {
      if (_currentTab != TabItem.home) {
        _changeTab(tabs.indexOf(TabItem.home));
        return false;
      }
    }
    // maybePop 가능하면 나가지 않는다.
    return isFirstRouteInCurrentTab;
  }

  //하단 네비게이션 바 스타일 지정
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black26, spreadRadius: 0, blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bottomNavigationBarBorderRadius),
          topRight: Radius.circular(bottomNavigationBarBorderRadius),
        ),
        child: BottomNavigationBar(
          items: navigationBarItems(context),
          currentIndex: _currentIndex,
          selectedItemColor: context.appColors.text,
          unselectedItemColor: context.appColors.iconButtonInactivate,
          onTap: _handleOnTapNavigationBarItem,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  //하단 네비게이션 바 아이템 지정 ( 아이콘 색상 변경 )
  List<BottomNavigationBarItem> navigationBarItems(BuildContext context) {
    return tabs
        .mapIndexed(
          (tab, index) => tab.toNavigationBarItem(
            context,
            isActivated: _currentIndex == index,
          ),
        )
        .toList();
  }

  // 선택한 탭의 인덱스로 현재 텝 변경
  void _changeTab(int index) {
    setState(() {
      _currentTab = tabs[index];
    });
  }

  // 선택된 탭과 그렇지 않은 탭 아이콘 상태 변경
  BottomNavigationBarItem bottomItem(bool activate, IconData iconData,
      IconData inActivateIconData, String label) {
    return BottomNavigationBarItem(
        icon: Icon(
          key: ValueKey(label),
          activate ? iconData : inActivateIconData,
          color: activate
              ? context.appColors.iconButton
              : context.appColors.iconButtonInactivate,
        ),
        label: label);
  }

  //중요!
  //하단 네비게이션 바의 아이템이 탭됐을 때의 처리를 정의
  // 현재 탭과 타겟 탭이 같은 경우, 현재 탭의 네비게이터에서 모든 기록을 삭제
  void _handleOnTapNavigationBarItem(int index) {
    final oldTab = _currentTab;
    final targetTab = tabs[index];
    if (oldTab == targetTab) { // 같은 탭인 경우
      final navigationKey = _currentTabNavigationKey;
      popAllHistory(navigationKey);
    }
    _changeTab(index);
  }

  // 선택된 탭의 네비게이터에서 모든 기록을 삭제
  void popAllHistory(GlobalKey<NavigatorState> navigationKey) {
    //스택에 해당 텝이 있는지 확인
    final bool canPop = navigationKey.currentState?.canPop() == true;
    if (canPop) {
      //스택에서 해당 텝을 모두 제거
      while (navigationKey.currentState?.canPop() == true) {
        navigationKey.currentState!.pop();
      }
    }
  }

  void initNavigatorKeys() {
    for (final _ in tabs) {
      navigatorKeys.add(GlobalKey<NavigatorState>());
    }
  }
}
