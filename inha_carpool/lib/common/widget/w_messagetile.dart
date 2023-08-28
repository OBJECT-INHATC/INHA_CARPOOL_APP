import 'package:flutter/material.dart';

/// 메시지 타입 ENUM
enum MessageType {
  me,
  other,
  service,
}

/// MessageTile 위젯
class MessageTile extends StatelessWidget {
  final String message;
  final String sender;
  final MessageType messageType;

  const MessageTile({
    Key? key,
    required this.message,
    required this.sender,
    required this.messageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Alignment alignment;
    Color bubbleColor;
    double verticalPadding; // 버블의 수직 패딩 값

    /// 메시지 타입에 따라 정렬, 색상 변경
    switch (messageType) {
      case MessageType.me:
        alignment = Alignment.centerRight;
        bubbleColor = Theme.of(context).primaryColor;
        verticalPadding = 10.0; // 기본 패딩 값
        break;
      case MessageType.other:
        alignment = Alignment.centerLeft;
        bubbleColor = Colors.grey[700]!;
        verticalPadding = 10.0; // 기본 패딩 값
        break;
      case MessageType.service:
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
          ],
        ),
      ),
    );
  }
}