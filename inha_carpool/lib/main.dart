import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/database/d_alarm_dao.dart';
import 'package:inha_Carpool/common/models/m_alarm.dart';
import 'package:inha_Carpool/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'common/data/preference/app_preferences.dart';

/// todo : 알림을 클릭했을 때 알림 new는 잘 들어오나 알림을 받은 후 그냥 앱을 실행하면 new의 상태과 불명확함 해결 필요 0216 이상훈
/// -> 서버 연동 후 알림을 받았을 때 알림 new 상태를 서버에서 받아오는 방식으로 변경하거나 파이어베이스에 필드 추가하든가 해야됨
/// 
/// 이해 안되면 적극적으로 물어보자 0216 이상훈

/// 백그라운드 메시지 수신 호출 콜백 함수
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  var nowTime = DateTime.now().millisecondsSinceEpoch; // 알림 도착 시각

  /// 백그라운드에서 알림 클릭시 알림 new 부분 상태관리 연결하기
  /// 01.30 -> 백그라운드 알림을 클릭해서 들어오면 정상이나, 그냥 아이콘 눌러서 들어오면 상태관리 반영 x

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

    print("백그라운드에서 알림 수신 : ${message.data['groupId']}");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckAlarm', true);
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

  // 백그라운드 메시지 수신 호출 콜백 함수
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      fallbackLocale: const Locale('ko'),
      useOnlyLangCode: true,
      path: 'assets/translations',
      child: const ProviderScope(
        child: App(),
      ),
    ),
  );
}

/// 1. 사용자 정보 -> 스토리지에서 그만 처 들고오자! -> 수시로 바꾸는중  => 수시로 보일 때 리팩토링 중
/// 2. 자신이 카풀에 참가하고있는지 ! -> 로그인시 한 번만 쳐 묻자 => 체크완
/// 3. 알림 받았는지 유무 -> 상태관리 안하니까 재빌드 해야만 알림 표시 뜸
/// -> 그냥 클릭했을 땐 어떻게 초기화 할 것인가 ? 0213
