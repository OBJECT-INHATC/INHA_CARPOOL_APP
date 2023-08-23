import 'package:flutter/material.dart';


import '../screen/main/tab/carpool/s_chatroom.dart';

class ChatStore extends ChangeNotifier {
  List<ChatMessage> chatMessages = [
    ChatMessage(
      content: '안녕하세요!',
      sender: '홀란드',
      timestamp: DateTime.now(),
    ),
    ChatMessage(
      content: '안녕하세요! 반갑습니다.',
      sender: '카리나',
      timestamp: DateTime.now(),
    ),
    // 추가적인 메시지들을 나열할 수 있습니다.
  ];
  var checkJoin = false;

  changeCheckJoin() {
    if (checkJoin == true) {
      checkJoin = false;
    } else {
      checkJoin = true;
    }
    notifyListeners();
  }
  var member = false;

  getMember(){
    member = true;
    notifyListeners();
  }
  exitMember(){
    member = false;
    notifyListeners();
  }
}

