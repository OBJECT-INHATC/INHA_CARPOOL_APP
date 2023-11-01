
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/database/d_alarm_dao.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
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
  final tabs = [TabItem.carpool, TabItem.home, TabItem.myPage];

  //각 화면별 네비게이터 키 리스트
  final List<GlobalKey<NavigatorState>> navigatorKeys = [];

  int get _currentIndex => tabs.indexOf(_currentTab);

  GlobalKey<NavigatorState> get _currentTabNavigationKey =>
      navigatorKeys[_currentIndex];

  bool get extendBody => true;

  static double get bottomNavigationBarBorderRadius => 30.0;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // 각 텝의 네비게이터 초기화
    // Firebase 초기화
    Firebase.initializeApp().then((_) {
      // 로그인 상태 확인
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          // 로그인이 되어있지 않은 경우 로그아웃 처리
          FirebaseAuth.instance.signOut();
        }
      });
    }).catchError((error) {
      // Firebase 초기화 실패 시 로그아웃 처리
      FirebaseAuth.instance.signOut();
    });
    initNavigatorKeys();
    removeSplash();
  }

  void removeSplash() async{
    // 1.5초 후에 스플래시 제거
    await Future.delayed(const Duration(milliseconds: 1500));
    print("removeSplash");
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope : 뒤로가기 버튼을 눌렀을 때의 동작을 정의
    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 45,
          // 해당 선을 내릴때만 나오게 해줘
          elevation: 0,
          shape: const Border(
            bottom: BorderSide(
              color: //Colors.grey.shade200,
              Colors.white,
              width: 1,
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: Colors.white,
          shadowColor: Colors.white,
          // title:GestureDetector(
          //   onTap: () {
          //     // TODO: 이미지가 클릭되었을 때 수행할 동작
          //     // 여기에 클릭 시 수행할 작업을 추가하세요.
          //   },
          //   Padding(
          //             padding: const EdgeInsets.all(5.0),
          //             child: Image.asset(
          //               'assets/image/splash/banner.png',
          //               width: 400,  // 원하는 이미지 너비로 설정
          //               height: 60,   // 원하는 이미지 높이로 설정
          //               fit: BoxFit.contain,  // 이미지를 너비와 높이에 맞게 유지
          //             ),
          //           ),
          // ),

          leading:
          GestureDetector(
              onTap: () {
                
              },
            child:
              Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Image.asset(
                          'assets/image/splash/banner.png',
                          width: 400,  // 원하는 이미지 너비로 설정
                          height: 60,   // 원하는 이미지 높이로 설정
                          fit: BoxFit.contain,  // 이미지를 너비와 높이에 맞게 유지
                        ),
                      ),
            ),
          leadingWidth: 170,
          actions: [
            FutureBuilder<bool>(
              future: AlarmDao().checkAlarms(),
              builder: (context, snapshot) {
                bool hasLocalNotification = snapshot.data ?? false;

                return IconButton(
                  icon: Stack(
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        size: 30,
                        color: Colors.black,
                      ),
                      if (hasLocalNotification)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationList()),
                    );
                  },
                );
              },
            ),

          ],
        ),
        //바디를 하단 네비게이션 바 아래까지 확장
        extendBody: extendBody,
        //bottomNavigationBar 아래 영역 까지 그림
        // drawer: const MenuDrawer(),
        body: Padding(
          padding: EdgeInsets.only(
              bottom: extendBody ? 30 - bottomNavigationBarBorderRadius : 0),
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
      } else {
        // 뒤로가기 버튼을 눌렀을 때 로그인으로 이동 여부
        return false;
      }
    }
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
    if (oldTab == targetTab) {
      // 같은 탭인 경우
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
