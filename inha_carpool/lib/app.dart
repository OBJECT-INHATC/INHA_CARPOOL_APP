import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/data/preference/prefs.dart';
import 'package:inha_Carpool/common/database/d_alarm_dao.dart';
import 'package:inha_Carpool/common/models/m_alarm.dart';
import 'package:inha_Carpool/provider/stateProvider/notification_provider.dart';
import 'package:inha_Carpool/screen/login/s_login.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/theme/custom_theme_app.dart';

class App extends ConsumerStatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  static bool isForeground = true;

  const App({super.key});

  @override
  ConsumerState<App> createState() => AppState();
}

class AppState extends ConsumerState<App> with Nav, WidgetsBindingObserver {
  @override
  GlobalKey<NavigatorState> get navigatorKey => App.navigatorKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// 알림 수신 시 호출되는 콜백 함수
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      var nowTime = DateTime.now().millisecondsSinceEpoch;

      print("message.data['groupId'] : ${message.data['groupId']}");

      const secureStorage = FlutterSecureStorage();
      String? nickName = await secureStorage.read(key: 'nickName');

      if (notification != null && message.data['sender'] != nickName) {
        /// 알림 상태관리 업데이트
        ref.read(isPushOnAlarm.notifier).state = true;

        if (notification.title == "새로운 채팅이 도착했습니다." &&
            !Prefs.chatRoomOnRx.get() &&
            Prefs.chatRoomCarIdRx.get() == message.data['groupId']) {

          // 로컬 알림 저장 - 알림이 수신되면 로컬 알림에 저장
          alarmInsert(notification, nowTime, message);

          // 카풀 완료 알람일 시 FCM에서 해당 carId의 토픽 구독 취소, 로컬 DB에서 해당 카풀 정보 삭제
          deleteTopic(message);
          return;
        }
        final flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
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
          payload: message.data['groupId'],
        );

        /// 로컬 알림 저장 - 알림이 수신되면 로컬 알림에 저장
        alarmInsert(notification, nowTime, message);

        // 카풀 완료 알람일 시 FCM에서 해당 carId의 토픽 구독 취소, 로컬 DB에서 해당 카풀 정보 삭제
        deleteTopic(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomThemeApp(
      child: Builder(builder: (context) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          /// 텍스트의 전체적인 크기를 고정
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          //네비게이터 관리
          navigatorKey: App.navigatorKey,
          title: 'Image Finder',
          theme: context.themeType.themeData,
          home: const LoginPage(),
        );
      }),
    );
  }

  void deleteTopic(RemoteMessage message) async {
    if (message.data['id'] == 'carpoolDone') {
      // 카풀 완료 알람일 시 FCM에서 해당 carId의 토픽 구독 취소, 로컬 DB에서 해당 카풀 정보 삭제
      String carId = message.data['groupId'];
      await FireStoreService().handleEndCarpoolSignal(carId);
    }
  }

  /// 로컬 알림 저장 - 알림이 수신되면 로컬 알림에 저장
  void alarmInsert(
      RemoteNotification notification, int nowTime, RemoteMessage message) {
    AlarmDao().insert(AlarmMessage(
      aid: "${notification.title}${notification.body}${nowTime.toString()}",
      carId: message.data['groupId'] as String,
      type: message.data['id'] as String,
      title: notification.title as String,
      body: notification.body as String,
      time: nowTime,
    ));
  }



// 클래스가 삭제될 때 옵저버 등록을 해제
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

// 백그라운드 알림 표시 여부 상태관리 연결
  void setAlarmBackgroundState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool('isCheckAlarm');

    if (prefs.getBool('isCheckAlarm') == true) {
      ref.read(isPushOnAlarm.notifier).state = true;
    }
  }

//옵저버의 함수로 상태관리 변화를 감지하면 앱의 포어그라운드 상태를 변경
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        App.isForeground = true;
        setAlarmBackgroundState();

        print("========= AppLifecycleState.resumed =========");
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        App.isForeground = false;
        print("========= AppLifecycleState.paused =========");

        break;
      case AppLifecycleState.detached:
        print("========= AppLifecycleState.detached =========");

        break;
      default:
        // Handle any other states that might be added in the future
        break;
    }
    super.didChangeAppLifecycleState(state);
  }
}
