import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/data/preference/prefs.dart';
import 'package:inha_Carpool/common/database/d_alarm_dao.dart';
import 'package:inha_Carpool/common/models/m_alarm.dart';
import 'package:inha_Carpool/screen/login/s_login.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

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

      const secureStorage = FlutterSecureStorage();
      String? nickName = await secureStorage.read(key: 'nickName');


      if(notification != null && message.data['sender'] != nickName){
        // Prefs.chatRoomOnRx.get()이 true이고, 알람 수신 시 앱이 포어그라운드 상태이고
        if(notification.title == "새로운 채팅이 도착했습니다." && !Prefs.chatRoomOnRx.get() && Prefs.chatRoomCarIdRx.get() == message.data['groupId']){
          print("=====================알람 꺼둠");

          /// 로컬 알림 저장 - 알림이 수신되면 로컬 알림에 저장
          AlarmInsert(notification, nowTime, message);

          // 카풀 완료 알람일 시 FCM에서 해당 carId의 토픽 구독 취소, 로컬 DB에서 해당 카풀 정보 삭제
          deleteTopic(message);
          return;
        }
        print("${notification.title!} <-- 타이틀");
        print("${Prefs.chatRoomOnRx.get()} <-- Prefs.chatRoomOnRx.get()");
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
        AlarmInsert(notification, nowTime, message);

        // 카풀 완료 알람일 시 FCM에서 해당 carId의 토픽 구독 취소, 로컬 DB에서 해당 카풀 정보 삭제
         deleteTopic(message);
      }
    });
  }

  void deleteTopic(RemoteMessage message) async {
       if(message.data['id'] == 'carpoolDone'){
      // 카풀 완료 알람일 시 FCM에서 해당 carId의 토픽 구독 취소, 로컬 DB에서 해당 카풀 정보 삭제
      String carId = message.data['groupId'];
    await FireStoreService().handleEndCarpoolSignal(carId);
    }
  }

  /// 로컬 알림 저장 - 알림이 수신되면 로컬 알림에 저장
  void AlarmInsert(RemoteNotification notification, int nowTime, RemoteMessage message) {
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

  // 클래스가 삭제될 때 옵저버 등록을 해제
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
          debugShowCheckedModeBanner: false,

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
          home:  const LoginPage(),

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
