import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/database/d_alarm_dao.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/models/m_alarm.dart';
import 'package:inha_Carpool/screen/login/s_login.dart';

import 'common/theme/custom_theme_app.dart';

/// 0829 한승완 - FCM 기본 연결 및 알림 설정

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  static bool isForeground = true;

  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with Nav, WidgetsBindingObserver {
  @override
  GlobalKey<NavigatorState> get navigatorKey => App.navigatorKey;

  //상태관리 옵저버 실행 + 디바이스 토큰 저장
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// 알림 수신 시 호출되는 콜백 함수
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      var nowTime = DateTime.now().millisecondsSinceEpoch; // 알림 도착 시각

      if(notification != null){
        final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // 알림 채널 ID
              'high_importance_notification', // 알림 채널 이름
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );

        /// 로컬 알림 저장 - 알림이 수신되면 로컬 알림에 저장
        AlarmDao().insert(
            AlarmMessage(
              aid: "${notification.title}${notification.body}${nowTime.toString()}",
              carId: message.data['groupId'] as String,
              type: message.data['id'] as String,
              title: notification.title as String,
              body: notification.body as String,
              time: nowTime,
            )
        );
      }
    });

  }

  //클래스가 삭제될 때 옵저버 등록을 해제
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomThemeApp(
      child: Builder(builder: (context) {
        return MaterialApp(
          /// 0916 한승완 - 텍스트의 전체적인 크기를 고정
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          //네비게이터 관리
          navigatorKey: App.navigatorKey,
          //언어 영역
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          //언어 영역 끝
          title: 'Image Finder',
          theme: context.themeType.themeData,
          home: const LoginPage(),

        );
      }),
    );
  }

  //옵저버의 함수로 상태관리 변화를 감지하면 앱의 포어그라운드 상태를 변경
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        App.isForeground = true;
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        App.isForeground = false;
        break;
      case AppLifecycleState.detached:
        break;
      default:
      // Handle any other states that might be added in the future
        break;
        // TODO: Handle this case.
    }
    super.didChangeAppLifecycleState(state);
  }
}
