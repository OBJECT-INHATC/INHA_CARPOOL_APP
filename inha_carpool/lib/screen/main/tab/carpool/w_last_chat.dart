import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../service/sv_firestore.dart';

/// 카드 리스트의 마지막 메세지 위젯
class chatLastMSG extends StatelessWidget {
  const chatLastMSG({
    super.key,
    required this.carpool,
  });

  final DocumentSnapshot<Object?> carpool;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(left: 15),
      child: Row(
        children: [
          StreamBuilder<DocumentSnapshot?>(
            stream: FireStoreService()
                .getLatestMessageStream(
                carpool['carId']),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(
                    'Error: ${snapshot.error}');
              } else if (!snapshot.hasData ||
                  snapshot.data == null) {
                return const Text(
                  '아직 채팅이 시작되지 않은 채팅방입니다!',
                  style: TextStyle(
                      color: Colors.grey),
                );
              }
              DocumentSnapshot lastMessage =
              snapshot.data!;
              String content =
              lastMessage['message'];
              String sender =
              lastMessage['sender'];

              // 글자가 16글자 이상인 경우, 17글자부터는 '...'로 대체
              if (content.length > 16) {
                content =
                '${content.substring(0, 16)}...';
              }
              return Text(
                '$sender : $content',
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey),
              );
            },
          ),
        ],
      ),
    );
  }
}

