import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inha_Carpool/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'common/data/preference/app_preferences.dart';

void main() async {

  /// 0828 한승완 TODO : FCM 기본 설정 추가

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
