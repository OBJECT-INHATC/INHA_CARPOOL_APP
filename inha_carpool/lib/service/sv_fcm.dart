import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/models/m_chat.dart';
import 'package:inha_Carpool/service/api/Api_topic.dart';

import '../common/data/preference/prefs.dart';
import '../dto/topic_dto.dart';

enum NotificationType { chat, status }

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
    if (type == NotificationType.chat) {
      notiStatus = "chat";
      notiTopic = "/topics/${chatMessage.carId}";
    } else if (type == NotificationType.status) {
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
              "android_channel_id": "high_importance_channel"
            },
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

  /// 토픽 구독 해제
  Future<void> unSubScribeTopic(String carId) async {
    /// 토픽 및 카풀 삭제
    try {
      if (Prefs.isPushOnRx.get() == true) {
        print("서버 토픽 삭제");
        await FirebaseMessaging.instance.unsubscribeFromTopic(carId);
        await FirebaseMessaging.instance.unsubscribeFromTopic("${carId}_info");
      }
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  /// 토픽 스프링 서버에 저장
  Future<bool> saveTopicToServer(String memberID, String tempCarId) async {
    TopicRequstDTO topicRequstDTO =
        TopicRequstDTO(uid: memberID, carId: tempCarId);

    return await ApiTopic().saveTopoic(topicRequstDTO);
  }

  /// 토픽 구독 메서드 (채팅과 카풀 알림을 구분해서 추가함)
  Future<void> subScribeTopic(String carId) async {
    if (Prefs.isPushOnRx.get() == true) {
      try {
        print("토픽 추가");
        /// 해당 카풀 알림 토픽 추가
        await FirebaseMessaging.instance.subscribeToTopic(carId);
        print("구독 성공! $carId ");


        /// 카풀 정보 토픽 추가
        await FirebaseMessaging.instance.subscribeToTopic("${carId}_info");
      } catch (e) {
        print('Error adding data to Firestore: $e');
      }
    }
  }

  /// 채팅 알림만 구독
  Future<void> subScribeOnlyOne(String topic) async {
    print("==토픽 추가 진행== $topic");
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print("구독 성공! $topic ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  /// 채팅 알림만 구독 해제
  Future<void> unSubScribeOnlyIOne(String topic) async {
    print("==토픽 해제 진행== $topic");
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print("토픽 해제 성공! $topic");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }
}
