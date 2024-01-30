import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/database/d_alarm_dao.dart';
import 'package:inha_Carpool/common/models/m_alarm.dart';
import 'package:inha_Carpool/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'common/data/preference/app_preferences.dart';

/// 0829 한승완 - FCM 기본 연결 및 알림 설정

/// 백그라운드 메시지 수신 호출 콜백 함수
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  var nowTime = DateTime.now().millisecondsSinceEpoch; // 알림 도착 시각

  if (message.notification != null) {
    /// 백그라운드 상태에서 알림을 수신하면 로컬 알림에 저장
    AlarmDao().insert(AlarmMessage(
      aid: "${notification?.title}${notification?.body}${nowTime.toString()}",
      carId: message.data['groupId'] as String,
      type: message.data['id'] as String,
      title: notification?.title as String,
      body: notification?.body as String,
      time: nowTime,
    ));
  }

  return;
}

/// 앱 실행 시 초기화 - 알림 설정
void initializeNotification() async {

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false, // 포그라운드에서 알림 팝업 표시 여부 (false이면 팝업 미표시) -> 로직에 맞게 수정
    badge: true, // 뱃지 표시 여부 (true이면 뱃지 표시)
    sound: false, // 소리 효과 표시 여부 (false이면 소리 효과 미표시)
  );

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  } else {
    print("알림 권한 허용됨");
  }

// 알림 권한 요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    // 알림 메시지 수신 허용 여부
    announcement: true,
    // 음성 알림 메시지 수신 허용 여부
    badge: true,
    // 뱃지 알림 허용 여부
    carPlay: true,
    // CarPlay 알림 허용 여부
    criticalAlert: true,
    // 중요 알림 허용 여부 (사용자의 주의를 요하는 알림)
    provisional: true,
    // 임시 알림 허용 여부 (사용자가 앱을 열 때까지 임시로 알림 보류)
    sound: true, // 소리 효과 표시 여부
  );
}



void main() async {
  //상태 변화와 렌더링을 관리하는 바인딩 초기화 => 추 후 백그라운드 및 포어그라운드 상태관리에 따라 기능 리팩토링
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 네이버 지도 SDK 초기화
  await NaverMapSdk.instance.initialize(clientId: '88driux0cg');

  //다국어 지원을 위해 필요한 초기화 과정
  await EasyLocalization.ensureInitialized();

  //애플리케이션의 환경설정을 초기화 과정
  await AppPreferences.init();
  await dotenv.load(fileName: 'assets/config/.env');

  //파이어베이스 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //네이버지도 초기화
  // await NaverMapSdk.instance.initialize(clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!);

  // 백그라운드 메시지 수신 호출 콜백 함수
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ko')],
        //지원하지 않는 언어인 경우 한국어로 설정
        fallbackLocale: const Locale('ko'),
        //번역 파일들이 위치하는 경로를 설정
        path: 'assets/translations',
        //언어 코드만 사용하여 번역 파일 설 ex)en_US 대신 en만 사용
        useOnlyLangCode: true,
        child: const ProviderScope(child: App())),
  );
}
