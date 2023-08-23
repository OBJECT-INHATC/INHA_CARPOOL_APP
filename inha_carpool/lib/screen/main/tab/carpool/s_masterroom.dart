import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/dto_carpoolstore.dart';
import '../../../dialog/d_carpooldone.dart';
import '../../../dialog/d_carpoolready.dart';



class MasterChatroomPage extends StatelessWidget {
  const MasterChatroomPage({super.key});


  @override
  Widget build(BuildContext context) {
    final chatStore = Provider.of<ChatStore>(context);
    Future.delayed(Duration(seconds: 5), () {
      chatStore.getMember();
    });


    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            '07.26/16:00 주안역-인하공전',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 상단 바: 채팅방 정보 표시
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 좌측 column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () {
                              _showProfileModal(context, '홀란드 님');
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.flag, color: Colors.white),
                                Text(
                                  '홀란드 님',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          chatStore.member ?
                          TextButton(
                            onPressed: () {
                              _showProfileModal(context, '흐비챠크바르헬리아 님');
                            },
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.all(10.0)),
                            child: Text(
                              '흐비챠크바르헬리아 님',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ) : Container(),
                          chatStore.member ?
                          TextButton(
                            onPressed: () {
                              _showProfileModal(context, '카리나 님');
                            },
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.all(10.0)),
                            child: Text(
                              '카리나 님',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ): Container(),
                        ],
                      ),
                      // 우측
                      Expanded(
                          child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text(
                                    "주안역",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(40.0)),
                                  ),
                                ),
                                Icon(Icons.arrow_forward),
                                Container(
                                  child: Text(
                                    "인하공전",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(70.0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Text(
                              "출발시간 : 07.26/16:00",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context){
                                        return ReadyDialog();

                                      },
                                    );

                                    // 확정 버튼 동작
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(0), // 직각 모서리로 설정
                                    ),
                                    backgroundColor:
                                        Colors.grey[300], // 연한 그레이 색상
                                  ),
                                  child: Text('카풀 시작'),
                                ),
                                SizedBox(width: 20), // 20 픽셀의 간격
                                TextButton(
                                  onPressed: () {
                                    // 카풀 종료 버튼 동작
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context){
                                        return DoneDialog();
                                      },
                                    );


                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(0), // 직각 모서리로 설정
                                    ),
                                    backgroundColor:
                                        Colors.grey[300], // 연한 그레이 색상
                                  ),
                                  child: Text('카풀 종료'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              // 2. 채팅 창
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.grey[300],
                ),
                child: chatStore.member ? ListView.builder(
                  // 채팅 내용을 ListView.builder를 사용하여 동적으로 표시
                  itemCount: chatStore.chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = chatStore.chatMessages[index];
                    return ListTile(
                      title: Text(message.content),
                      subtitle: Text(
                          '${message.sender} • ${message.timestamp.toString()}'),
                    );
                  },
                ): Container(),
              ),
            ),


            Container(
              // 3. 채팅 입력 창
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      // 채팅 내용을 입력받는 TextField
                      decoration: InputDecoration(
                        hintText: '메시지 입력...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // 메시지 전송 버튼 동작
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 프로필 조회
void _showProfileModal(BuildContext context, String userName) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        // 모달 내용을 구성
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '프로필 조회',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '유저 이름: $userName' '\n이용횟수, 신고횟수, 성별, 신고하기',
              style: TextStyle(fontSize: 16),
            ),
            // 추가적인 프로필 정보를 나열하거나 버튼을 추가할 수 있습니다.
          ],
        ),
      );
    },
  );
}

class ChatMessage {
  final String content;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
  });
}


//알림 내 방식으로 재디자인,