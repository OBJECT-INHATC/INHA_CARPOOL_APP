import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';

enum MessageType {
  me,
  other,
  service,
}

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

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
    String formattedTime = DateFormat.jm().format(date);
    Alignment alignment;
    Color bubbleColor;
    double verticalPadding;

    switch (messageType) {
      case MessageType.me:
        alignment = Alignment.centerRight;
        bubbleColor = Colors.lightBlueAccent;
        verticalPadding = 7.0;
        break;

      case MessageType.other:
        alignment = Alignment.centerLeft;
        bubbleColor = Colors.grey[700]!;
        verticalPadding = 7.0;
        break;

      case MessageType.service:
        alignment = Alignment.center;
        bubbleColor = Colors.grey[200]!;
        verticalPadding = 5.0;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: messageType == MessageType.service
          ? Center(
              child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: bubbleColor),
                  child: (messageType == MessageType.service)
                      ? Text(message)
                      : Column(
                          crossAxisAlignment: (messageType == MessageType.me)
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              Text(sender.toUpperCase()),
                              Text(message),
                            ]),
                ),
              ],
            ))
          : Align(
              alignment: alignment,
              child: Row(
                mainAxisAlignment: messageType == MessageType.me
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (messageType == MessageType.me)
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.only(left: 20, top: 30),
                      child:
                          Text(formattedTime, style: TextStyle(fontSize: 12)),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:(message.length >= 13)
                          ? MediaQuery.of(context).size.width * 0.6
                          :double.infinity// 최대 너비를 화면 너비의 60%로 설정
                    ),
                    child: ChatBubble(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 15, bottom: 5),
                      clipper: ChatBubbleClipper10(
                          type: messageType == MessageType.me
                              ? BubbleType.sendBubble
                              : BubbleType.receiverBubble),
                      backGroundColor: bubbleColor,
                      child: (messageType == MessageType.service)
                          ? Text(message)
                          : Column(
                              crossAxisAlignment:
                                  (messageType == MessageType.me)
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  Text(
                                    sender,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1,
                                    ),
                                    maxLines: null,
                                    softWrap: true,
                                  ),
                                ]),
                    ),
                  ),
                  if (messageType != MessageType.me)
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.only(right: 20, top: 30),
                      child: Row(
                        children: [
                          Text(formattedTime, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    )
                ],
              ),
            ),
    );
  }
}
