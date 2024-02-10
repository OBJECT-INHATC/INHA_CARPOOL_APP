import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/models/m_chat.dart';

enum NotificationType { chat, status }

/// 0829 한승완 - FCM 서비스 클래스
class FcmService {

  final String _serverKey = dotenv.env['FCM_SERVER_KEY'] ?? "";

  /// 알림 전송 메서드
  Future<void> sendMessage({
    required String title,
    required String body,
    required ChatMessage chatMessage,
    required NotificationType type,
  }) async {

    String notiStatus = "chat";
    String notiTopic = "/topics/${chatMessage.carId}";

    http.Response response;

    /// 어떤 알림 인지 구분
    if ( type == NotificationType.chat) {
      notiStatus = "chat";
      notiTopic = "/topics/${chatMessage.carId}";
    } else if ( type == NotificationType.status) {
      notiStatus = "status";
      notiTopic = "/topics/${chatMessage.carId}_info";
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
            'notification': {
              'title': title,
              'body': body,
              'sound': 'false',
              "priority": "high",
              "android_channel_id": "high_importance_channel"},
            'ttl': '60s',
            "content_available": true,
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': notiStatus,
              'status': 'done',
              "action": '테스트',
              'groupId': chatMessage.carId,
              'sender': chatMessage.sender,
              'time': chatMessage.time.toString(),
            },
            // 상대방 토큰 값, to -> 단일, registration_ids -> 여러명
            'to': notiTopic,
           // 'registration_ids': tokenList
          }));
    } catch (e) {
      print('error $e');
    }
  }
}