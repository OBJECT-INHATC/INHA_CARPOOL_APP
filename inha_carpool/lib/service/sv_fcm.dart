import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inha_Carpool/common/models/m_chat.dart';

/// 0829 한승완 - FCM 서비스 클래스
class FcmService {

  final String _serverKey =
      "AAAA-NGypFk:APA91bGFNzWfZi-A_81lR4-TFxXvhCdombcWIMZyfk7GNBKd9NYrOtsL8iQUa5ghtB3UtGFCRIG0ciplrJXw9sgyHQ2gI-gkkggZbCFIDHz4rK9-S_y4_tgTPB9Qdi8OS0DhjOuL2Igb";

  /// FCM 서버 키 -> .env 파일에 저장 해야 하지만 테스트 과정에는 하드 코딩
  // final String _serverKey = dotenv.env['FCM_SERVER_KEY'] ?? "";

  /// 알림 전송 메서드
  Future<void> sendMessage({
    required List tokenList,
    required String title,
    required String body,
    required ChatMessage chatMessage,
  }) async {

    http.Response response;

    /// 알림 권한 요청
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false,
    );

    /// 알림 권한 상태 확인
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    try {
      /// FCM 서버에 알림 전송
      response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$_serverKey'
          },
          body: jsonEncode({
            'notification': {'title': title, 'body': body, 'sound': 'false'},
            'ttl': '60s',
            "content_available": true,
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              "action": '테스트',
              'groupId': chatMessage.carId,
              'message': chatMessage.message,
              'sender': chatMessage.sender,
              'time': chatMessage.time.toString() ,
            },
            // 상대방 토큰 값, to -> 단일, registration_ids -> 여러명
            //'to': userToken
            'registration_ids': tokenList
          }));
    } catch (e) {
      print('error $e');
    }
  }
}