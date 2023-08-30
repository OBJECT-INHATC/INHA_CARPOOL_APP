import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/database/d_chat_dao.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/models/m_chat.dart';
import 'package:inha_Carpool/common/widget/w_messagetile.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

/// 0828 서은율, 한승완
/// 채팅방 페이지 - 채팅방 정보 표시, 채팅 메시지 스트림, 메시지 입력, 메시지 전송
class ChatroomPage extends StatefulWidget {
  /// 0829 서은율 TODO : 채팅방 페이지 최적화 고민 해볼 것

  final String carId;
  final String groupName;
  final String userName;

  /// 생성자
  const ChatroomPage(
      {Key? key,
      required this.carId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  /// 채팅 메시지 스트림
  Stream<QuerySnapshot>? chats;

  /// 로컬 채팅 메시지 스트림
  List<ChatMessage>? localChats;

  /// 메시지 입력 컨트롤러
  TextEditingController messageController = TextEditingController();

  /// 스크롤 컨트롤러
  late ScrollController _scrollController;

  /// 로컬 저장소 SS
  final storage = const FlutterSecureStorage();

  /// 관리자 이름, 토큰, 사용자 Auth 정보
  String admin = "";
  String token = "";
  User? user;

  int previousItemCount = 0;
  bool canSend = true;


  // 멤버 리스트
  List<dynamic>? membersList;

  @override
  void initState() {
    getChatandAdmin();
    /// 로컬 채팅 메시지, 채팅 메시지 스트림, 관리자 이름 호출

    getCurrentUserandToken();
    /// 토큰, 사용자 Auth 정보 호출

    getMembersList();
    /// 멤버 리스트 호출

    super.initState();
    _scrollController = ScrollController();

    /// 스크롤 컨트롤러 초기화


  }

  getLocalChat() async {
    print(widget.carId);

    await ChatDao().getChatbyCarIdSortedByTime(widget.carId).then((val) {
      setState(() {
        localChats = val;
      });
    });
  }

  /// 로컬 채팅 메시지 , 채팅 메시지 스트림, 관리자 이름 호출 메서드
  getChatandAdmin() async {
    await getLocalChat();
    print(localChats!.length);

    if (localChats != null && localChats!.isNotEmpty) {
      final lastLocalChat = localChats?[localChats!.length - 1];

      FireStoreService()
          .getChatsAfterSpecTime(widget.carId, lastLocalChat!.time)
          .then((val) {
        setState(() {
          chats = val;
        });
      });
    } else {
      FireStoreService().getChats(widget.carId).then((val) {
        setState(() {
          chats = val;
        });
      });
    }

    FireStoreService().getGroupAdmin(widget.carId).then((val) {
      setState(() {
        admin = getName(val);
      });
    });
  }

  // 카풀 컬렉션 이름 추출
  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  /// 토큰, 사용자 Auth 정보 호출 메서드
  getCurrentUserandToken() async {
    user = FirebaseAuth.instance.currentUser;
    token = (await storage.read(key: "token"))!;
  }

  // 멤버 리스트 가져오기
  getMembersList() async {
    await FireStoreService().getMembersList(widget.carId).then((val) {
      setState(() {
        membersList = val;
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    // 디바이스 사이즈 가져오기
    double deviceWidth = context.width(1);
    double deviceHeight = context.height(1);
    double topBarHeight = deviceHeight * 0.2;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            widget.groupName, // 채팅방 이름
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: [
              Container(
                height: topBarHeight,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: ListView.builder(
                          itemCount: membersList?.length,
                          itemBuilder: (BuildContext context, int index) {
                            String memberName = getName(membersList?[index]); // 회원 이름을 가져오는 부분입니다.

                            return TextButton(
                              onPressed: () {
                                _showProfileModal(context, '$memberName 님');
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                backgroundColor: admin == memberName ? Colors.blue : Colors.grey,
                                // 방장인 경우 파란색, 아닌 경우 회색
                                padding: const EdgeInsets.all(10.0),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '$memberName 님',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // 우측
                    Expanded(
                        child: Column(
                          children: [
                            Container(
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
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              child: TextButton(
                                onPressed: () {
                                  // 카풀 종료 버튼 동작
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        0), // 직각 모서리로 설정
                                  ),
                                  backgroundColor:
                                      Colors.grey[300], // 연한 그레이 색상
                                ),
                                child: Text('방나가기'),
                              ),
                              ),
                          ],
                    )),
                  ],
                ),
              ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  /// 채팅 메시지 스트림
                  chatMessages(),
                  Container(
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      width: MediaQuery.of(context).size.width,
                      height: 70,
                      color: Colors.grey[600],
                      child: Row(children: [
                        Expanded(
                            child: TextFormField(
                          cursorColor: Colors.white,
                          controller: messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "메시지 보내기",
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 16),
                            filled: true,
                            fillColor: Colors.grey,

                            border: InputBorder.none,
                            // fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                            ),
                          ),
                        )),
                        const SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                          onTap: () {
                            sendMessage();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                                child: Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                          ),
                        )
                      ]),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 채팅 메시지 스트림
  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return const Text("Something went wrong");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData) {
          List<ChatMessage> fireStoreChats = snapshot.data!.docs
              .map<ChatMessage>((e) => ChatMessage.fromMap(
                  e.data() as Map<String, dynamic>, widget.carId))
              .toList();
          if (localChats != null) {
            fireStoreChats.addAll(localChats!);
          }
          // itemCount가 변경되었을 때 스크롤 위치를 조정
          if (fireStoreChats.length > previousItemCount) {
            previousItemCount = fireStoreChats.length;
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
          }

          /// 로컬 디비에 없는 메시지만 저장
          if (fireStoreChats.isNotEmpty) {
            ChatDao().saveChatMessages(fireStoreChats);
          }

          fireStoreChats.sort((a, b) => a.time.compareTo(b.time));

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            controller: _scrollController,
            itemCount: fireStoreChats.length,
            itemBuilder: (context, index) {
              final currentChat = fireStoreChats[index]; // 현재 채팅 메시지
              final previousChat =
                  index > 0 ? fireStoreChats[index - 1] : null; // 이전 채팅 메시지

              // 채팅에 포함된 시간을 DateTime으로 변환
              final currentDate =
                  DateTime.fromMillisecondsSinceEpoch(currentChat.time);
              final previousDate =
                  // 이전 채팅 메시지가 있을 경우에만 변환
                  previousChat != null
                      ? DateTime.fromMillisecondsSinceEpoch(previousChat.time)
                      : null;

              // 날짜 변환 체크

              bool isNewDay = false;
              if (previousDate == null ||
                  currentDate.day != previousDate.day ||
                  currentDate.month != previousDate.month ||
                  currentDate.year != previousDate.year) {
                isNewDay = true;
              }
              return Column(
                children: [
                  // 날짜 헤더
                  if (isNewDay)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${currentDate.year}-${currentDate.month}-${currentDate.day}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  MessageTile(
                    message: fireStoreChats[index].message,
                    sender: fireStoreChats[index].sender,
                    messageType: widget.userName == fireStoreChats[index].sender
                        ? MessageType.me
                        : (fireStoreChats[index].sender == 'service'
                            ? MessageType.service
                            : MessageType.other),
                    time: fireStoreChats[index].time,
                  ),
                ],
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty && canSend) {
      /// 전달할 메시지 Map 생성
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      /// 메시지 전송
      FireStoreService().sendMessage(widget.carId, chatMessageMap);

      /// 스크롤 화면 하단으로 이동
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );

      setState(() {
        /// 메시지 입력 컨트롤러 초기화
        messageController.clear();
        canSend = false;
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          canSend = true;
        });
      });
    }
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
