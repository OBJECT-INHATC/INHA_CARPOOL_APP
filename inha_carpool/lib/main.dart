import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'common/data/preference/app_preferences.dart';

/// 0829 한승완 - FCM 기본 연결 및 알림 설정


/// 현재 접속한 플랫폼이 웹인지 확인 => 웹 true, 모바일 false
import 'package:flutter/foundation.dart'
    show kIsWeb;

/// 백그라운드 메시지 수신 호출 콜백 함수
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {

  }
  return;
}
//
// @pragma('vm:entry-point')
// void backgroundHandler(NotificationResponse response) async {
//
// }

/// 앱 실행 시 초기화 - 알림 설정
void initializeNotification() async {

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
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  // 플랫폼별 초기화 설정
   InitializationSettings initializationSettings = InitializationSettings(
    android: const AndroidInitializationSettings("@mipmap/ic_launcher"),
    iOS: iosInitializationSettings, // IOS는 추후 아이디 구매해서 연결 해야함
  );

  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onDidReceiveBackgroundNotificationResponse: backgroundHandler
  );

  // 포그라운드 상태에서 알림을 받을 수 있도록 설정
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // 알림 권한 요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

}


void main() async {
  //태 변화와 렌더링을 관리하는 바인딩 초기화 => 추 후 백그라운드 및 포어그라운드 상태관리에 따라 기능 리팩토링
  WidgetsFlutterBinding.ensureInitialized();

  //다국어 지원을 위해 필요한 초기화 과정
  await EasyLocalization.ensureInitialized();

  //애플리케이션의 환경설정을 초기화 과정
  await AppPreferences.init();
  await dotenv.load(fileName: 'assets/config/.env');

  //파이어베이스 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 백그라운드 메시지 수신 호출 콜백 함수
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 알림 설정
  initializeNotification();

  runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ko')],
        //지원하지 않는 언어인 경우 한국어로 설정
        fallbackLocale: const Locale('ko'),
        //번역 파일들이 위치하는 경로를 설정
        path: 'assets/translations',
        //언어 코드만 사용하여 번역 파일 설 ex)en_US 대신 en만 사용
        useOnlyLangCode: true,
        child: const App()),
      );
}

