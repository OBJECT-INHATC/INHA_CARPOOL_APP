import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../../../service/sv_firestore.dart';

/// 카드 리스트의 마지막 메세지 위젯
class ChatLastInfo extends StatelessWidget {
  final emptyChat = '아직 채팅이 시작되지 않은 채팅방입니다.';

  const ChatLastInfo({
    super.key,
    required this.carId,
  });

  final String carId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;

    return Column(
      children: [
        Divider(
          height: 20,
          color: context.appColors.logoColor,
        ).pSymmetric(h: 15),
        Row(
          children: [
            Width(screenWidth * 0.045),
            StreamBuilder<DocumentSnapshot?>(
              stream: FireStoreService().getLatestMessageStream(carId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  DocumentSnapshot? lastMessage = snapshot.data;
                  if (lastMessage == null) {
                    /// 여기 const 주면 에러 빡!
                    return  Text(
                      emptyChat,
                      style: const TextStyle(color: Colors.grey),
                    );
                  } else {
                    String content = lastMessage['message'];
                    String sender = lastMessage['sender'];
                    if (content.length > 16) {
                      content = '${content.substring(0, 16)}...';
                    }
                    return Text(
                      '$sender : $content',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

