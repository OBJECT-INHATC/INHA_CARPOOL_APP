import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../common.dart';

/// 0828 서은율, 한승완
/// 메시지 타입 ENUM
enum MessageType {
  me,
  other,
  service,
}

/// TODO: 0828 서은율 - 메시지 타일 위젯 디자인,시간 날짜
/// MessageTile 위젯 - 채팅 메시지 UI 위젯
class MessageTile extends StatelessWidget {
  final String message;
  final String sender;
  final MessageType messageType;
  final int time;



  const MessageTile({
    Key? key,
    required this.message,
    required this.sender,
    required this.messageType,
    required this.time,
  }) : super(key: key);


  /// 0829 서은율 TODO : 메시지 타일 위젯의 최적화 고민 + 간단한 디자인 수정

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(time); // 타임스탬프를 DateTime으로 변환
    String formattedTime = DateFormat.jm().format(date); //시간을 오전 오후 표시
    Alignment alignment;
    Color bubbleColor;
    double verticalPadding; // 버블의 수직 패딩 값

    /// 메시지 타입에 따라 정렬, 색상 변경
    switch (messageType) {
      case MessageType.me: //내가 보낸 메시지
        alignment = Alignment.centerRight;
        bubbleColor = Theme.of(context).primaryColor;
        verticalPadding = 10.0; // 기본 패딩 값
        break;
      case MessageType.other: //상대가 보낸 메시지
        alignment = Alignment.centerLeft;
        bubbleColor = Colors.grey[700]!;
        verticalPadding = 10.0; // 기본 패딩 값
        break;
      case MessageType.service: //서비스가 보낸 메시지
        alignment = Alignment.center;
        bubbleColor = Colors.orange; // 서비스 메시지 색상
        verticalPadding = 5.0; // 기본 패딩 값
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      alignment: alignment,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: bubbleColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (messageType != MessageType.service)
              Text(
                sender.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            const SizedBox(height: 7),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            Text(
              formattedTime, // 시간 표시
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),

          ],
        ),
      ),
    );
  }
}


///3. 시간과 채팅 컨테이너 분리