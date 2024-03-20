import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inha_Carpool/provider/carpool/carpool_notifier.dart';
import 'package:inha_Carpool/provider/doing_carpool/doing_carpool_provider.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/chat/s_chatroom.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/w_floating_btn.dart';
import 'package:inha_Carpool/screen/main/tab/tab_item.dart';
import 'package:inha_Carpool/screen/main/tab/tab_navigator.dart';

import '../../common/common.dart';
import '../../common/data/preference/prefs.dart';
import '../../fragment/f_notification.dart';
import '../../provider/stateProvider/notification_provider.dart';
import '../../service/sv_firestore.dart';

class MainScreen extends ConsumerStatefulWidget {
  // 마이페이지 이동 변수
  final String? temp;

  const MainScreen({Key? key, this.temp}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => MainScreenState(temp: temp);
}

class MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabItem _currentTab;

  //시작 화면 지정
  MainScreenState({String? temp}) {
    if (temp == 'MyPage') {
      _currentTab = TabItem.myPage;
    } else {
      _currentTab = TabItem.home;
    }
  }

  //사용 가능한 화면 리스트
  final tabs = [TabItem.carpool, TabItem.home, TabItem.myPage];

  //각 화면별 네비게이터 키 리스트
  final List<GlobalKey<NavigatorState>> navigatorKeys = [];

  // 현재 탭의 인덱스
  int get _currentIndex => tabs.indexOf(_currentTab);

  // 현재 탭의 네비게이터 키
  GlobalKey<NavigatorState> get _currentTabNavigationKey =>
      navigatorKeys[_currentIndex];

  bool get extendBody => false;

  static double get bottomNavigationBarBorderRadius => 30.0;

  // 피지컬 뒤로가기 활성화
  DateTime? currentBackPressTime;

  // 피지컬 뒤로가기 기능
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      const msg = "한 번 더 누르면 종료됩니다.";
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
      );
      return Future.value(false);
    } else {
      // 현재 탭이 홈이면 앱 종료
      if (_currentTab == TabItem.home) {
        SystemNavigator.pop();
      }
      return Future.value(true);
    }
  }

  /// 앱 실행 시 초기화 - 알림 설정
  void initializeNotification(BuildContext context) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android용 알림 채널 생성
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'high_importance_channel',
          'high_importance_notification',
          importance: Importance.max,
        ));

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
      requestAlertPermission: true, // 알림 권한 요청: Alert
      requestBadgePermission: true, // 알림 권한 요청: Badge
      requestSoundPermission: true, // 알림 권한 요청: Sound
    );

    // 플랫폼별 초기화 설정
    InitializationSettings initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notification) async {
        // 알림을 클릭하면 해당 알림의 페이로드를 출력
        /// 페이로드는 송신측에서 추가로 담아주는데 내가 이번에 추가함 깃 커밋 내역 보셈 24.01.30 이상훈
        final carId = notification.payload;
        if (carId == null) return;
        var carpoolStartTime =
            await FireStoreService().getCarpoolStartTime(carId);

        // 현재 시간을 밀리초 단위의 epoch time으로 변환합니다.
        var currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime > carpoolStartTime) {
          // 현재 시간이 carpoolStartTime을 넘었다면, 카풀이 이미 시작되었으므로 접근을 막습니다.
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('이미 끝난 카풀입니다.')));
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          // 특정 채팅방 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatroomPage(
                carId: carId,
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    /// 앱 알림 설정 초기화
    initializeNotification(context);

    Prefs.chatRoomOnRx.set(true);
    Prefs.chatRoomCarIdRx.set("");

    print("=========메인====================");
    initNavigatorKeys();
    removeSplash();

    // 각 텝의 네비게이터 초기화
  }

  void removeSplash() async {
    // 1.5초 후에 스플래시 제거
    await Future.delayed(const Duration(milliseconds: 1500));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    final carpool = ref.read(carpoolProvider);
    final isDoingCarpool = ref.read(doingProvider);

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
              color: Colors.white,
              width: 1,
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Image.asset(
                'assets/image/splash/banner.png',
                width: 400,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
          leadingWidth: 170,
          actions: [
            Consumer(builder: (context, ref, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      // 알림 new 표시 제거
                      ref.read(isPushOnAlarm.notifier).state = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationList(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                  if (ref.watch(isPushOnAlarm))
                    Positioned(
                      right: 3.5, // "new" 텍스트를 아이콘 오른쪽에 위치
                      top: 2, // "new" 텍스트를 아이콘 위쪽에 위치
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: context.appColors.blueButtonBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            ref.read(isPushOnAlarm.notifier).state = false;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationList(),
                              ),
                            );
                          },
                          child: Text(
                            'new',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
             floatingActionButton: _currentTab == TabItem.home &&
                 carpool.isNotEmpty &&
                 isDoingCarpool.isEmpty
                 ?
            const RecruitFloatingBtn(floatingMessage: "카풀 찾기")
            : null,
        extendBody: extendBody,
        body: Padding(
          padding: EdgeInsets.only(
            bottom: extendBody ? 30 - bottomNavigationBarBorderRadius : 0,
          ),
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
        await onWillPop();
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

//하단 네비게이션 바 스타일 지정
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(color: Colors.black26, spreadRadius: 0, blurRadius: 5),
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
