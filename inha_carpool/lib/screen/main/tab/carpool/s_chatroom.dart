import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/database/d_chat_dao.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/models/m_chat.dart';
import 'package:inha_Carpool/common/widget/w_messagetile.dart';
import 'package:inha_Carpool/screen/dialog/d_complainAlert.dart';
import 'package:inha_Carpool/screen/main/s_main.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/f_mypage.dart';
import 'package:inha_Carpool/service/api/ApiService.dart';
import 'package:inha_Carpool/service/api/Api_Topic.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';
import 'package:quiver/collection.dart';


import '../../../../common/data/preference/prefs.dart';

/// 0828 서은율, 한승완
/// 채팅방 페이지 - 채팅방 정보 표시, 채팅 메시지 스트림, 메시지 입력, 메시지 전송
class ChatroomPage extends StatefulWidget {
  /// 0829 서은율 TODO : 채팅방 페이지 최적화 고민 해볼 것

  final String carId;
  final String groupName;
  final String userName;
  final String uid;
  final String gender;


  /// 생성자
  const ChatroomPage(
      {Key? key,
        required this.carId,
        required this.groupName,
        required this.userName,
        required this.uid,
        required this.gender,})
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

  //0927강지윤
  User? user = FirebaseAuth.instance.currentUser;

  /// 관리자 이름, 토큰, 사용자 Auth 정보
  String admin = "";
  String token = "";
  // User? user;

  //0927강지윤
  String? get uid => user?.uid; //uid가져오기

  int previousItemCount = 0;
  bool canSend = true;

  // 멤버 리스트
  List<dynamic> membersList = [];

  // 출발 시간
  DateTime startTime = DateTime.now();

  // 확정 시간
  DateTime agreedTime = DateTime.now();

  // 출발지
  String startPoint = "";

  // 도착지
  String endPoint = "";

  // 나가기 중복 방지
  bool exitButtonDisabled = true;

  @override
  void initState() {
    getChatandAdmin();

    /// 로컬 채팅 메시지, 채팅 메시지 스트림, 관리자 이름 호출

    getCurrentUserandToken();

    /// 토큰, 사용자 Auth 정보 호출

    getCarpoolInfo();
    // 멤버 리스트, 출발 시간 가져오기

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
      FireStoreService()
          .getChatsAfterSpecTime(
          widget.carId, DateTime
          .now()
          .millisecondsSinceEpoch)
          .then((val) {
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
    int start = res.indexOf("_") + 1;
    int end = res.lastIndexOf("_");
    return res.substring(start, end);
  }

  String getGender(String res) {
    print("Input string: $res");
    print("Last index of _: ${res.lastIndexOf("_")}");
    String gender = res.substring(res.lastIndexOf("_") + 1);
    print("Extracted gender: $gender");
    return gender;
  }

  // 1002,memberId
  String getMemberId(String res) {
    int start = 0;
    int end = res.indexOf("_");
    return res.substring(start, end);
  }


  /// 토큰, 사용자 Auth 정보 호출 메서드
  getCurrentUserandToken() async {
    user = FirebaseAuth.instance.currentUser;
    token = (await storage.read(key: "token"))!;
  }

  // 멤버 리스트, 출발 시간, 요약주소 가져오기
  getCarpoolInfo() async {
    await FireStoreService().getCarDetails(widget.carId).then((val) {
      print("Fetched data: $val");
      setState(() {
        membersList = val['members'];
        startTime = DateTime.fromMillisecondsSinceEpoch(val['startTime']);
        startPoint = val['startDetailPoint'];
        endPoint = val['endDetailPoint'];
        agreedTime = startTime.subtract(Duration(minutes: 10));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isExitButtonDisabled = false; // 나가기 버튼 기본적으로 활성화
    final screenWidth = MediaQuery.of(context).size.width;

    String formattedDate = DateFormat('HH:mm').format(startTime);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          toolbarHeight: 45,
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              //Colors.white,
              width: 1,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:  admin,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "님의 방",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        endDrawer: Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // 모서리를 직각으로 설정
          ),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft, // 왼쪽 정렬
                  child: Padding(
                    padding: EdgeInsets.only(top: AppBar().preferredSize.height, left: 15),
                    child: ListTile(
                      title: Text(
                        "대화상대",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        iconSize: 30,
                        onPressed: isExitButtonDisabled
                            ? null
                            : () async {
                          final currentTime = DateTime.now();
                          final timeDifference = agreedTime.difference(currentTime);
                          // 현재 시간과 agreedTime 사이의 차이를 분 단위로 계산
                          final minutesDifference = timeDifference.inMinutes;

                          if (minutesDifference > 10) {
                            // agreedTime과 현재 시간 사이의 차이가 10분 이상인 경우 나가기 작업 수행
                            if (admin != widget.userName) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    surfaceTintColor: Colors.transparent,
                                    title: const Text('카풀 나가기'),
                                    content: const Text('정말로 카풀을 나가시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if(exitButtonDisabled) {
                                            exitButtonDisabled = false;

                                            /// 토픽 추가 및 서버에 토픽 삭제 요청 0919 이상훈
                                            if (Prefs.isPushOnRx.get() == true) {
                                              await FirebaseMessaging.instance
                                                  .unsubscribeFromTopic(widget.carId);

                                              await FirebaseMessaging.instance
                                                  .unsubscribeFromTopic(
                                                  "${widget.carId}_info");
                                            }
                                            ApiTopic apiTopic = ApiTopic();
                                            await apiTopic.deleteTopic(
                                                widget.uid, widget.carId);

                                            ///--------------------------------------------------------------------

                                            // 데이터베이스 작업을 비동기로 수행
                                            await FireStoreService().exitCarpool(
                                                widget.carId,
                                                widget.userName,
                                                widget.uid,
                                                widget.gender);

                                            // 데이터베이스 작업이 완료되면 다음 페이지로 이동
                                            if (!mounted) return;
                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                const MainScreen(),
                                              ),
                                            );

                                            setState(() {
                                              exitButtonDisabled = true;
                                            });
                                          }
                                        },
                                        child: const Text('나가기'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('카풀 나가기'),
                                    content:
                                    const Text('현재 카풀의 방장 입니다. \n 정말 나가시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if(exitButtonDisabled) {
                                            exitButtonDisabled = false;

                                            if (Prefs.isPushOnRx.get() == true) {
                                              await FirebaseMessaging.instance
                                                  .unsubscribeFromTopic(widget.carId);

                                              await FirebaseMessaging.instance
                                                  .unsubscribeFromTopic(
                                                  "${widget.carId}_info");
                                            }
                                            ApiTopic apiTopic = ApiTopic();
                                            await apiTopic.deleteTopic(
                                                widget.uid, widget.carId);

                                            await FireStoreService().exitCarpoolAsAdmin(
                                                widget.carId,
                                                widget.userName,
                                                widget.uid,
                                                widget.gender);

                                            if (!mounted) return;
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const MainScreen()),
                                            );
                                            setState(() {
                                              exitButtonDisabled = true;
                                            });
                                          }
                                        },
                                        child: const Text('나가기'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } else {
                            // agreedTime과 현재 시간 사이의 차이가 10분 이상인 경우 경고 메시지 또는 아무 작업도 수행하지 않음
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('카풀 나가기 불가'),
                                  content: const Text('카풀 시작 10분 전이므로 불가능합니다.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('확인'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * 0.7,
                  child: Divider(
                    color: Colors.grey.shade200,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0), // ListView.builder에 패딩 설정
                    itemCount: membersList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String memberName = getName(membersList[index]);
                      String memberGender = getGender(membersList[index]);
                      String memberId = getMemberId(membersList[index]);

                      return ListTile(
                        onTap: () {
                          _showProfileModal(context, memberId, '$memberName 님', memberGender);
                        },
                        leading: Icon(
                          Icons.account_circle,
                          size: 35,
                          color: admin == memberName ? Colors.blue : Colors.black,
                        ),
                        title: Row(
                          children: [
                            Text(
                              '$memberName  ',
                              style: TextStyle(
                                fontSize: 16,
                                color: admin == memberName ? Colors.blue : Colors.black,
                              ),
                            ),
                            // Text(
                            //   memberGender,
                            //   style: TextStyle(
                            //     fontSize: 13,
                            //     fontWeight: FontWeight.w500,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                          ],
                        ),
                        trailing: Icon(Icons.navigate_next_rounded),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: context.height(0.08),
             // height: membersList.length > 2 ? context.height(0.20) : context.height(0.15), //높이 조절
              margin: EdgeInsets.fromLTRB(5, 0, 8, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 224, 224, 224),
                    //Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // const Icon(Icons.calendar_today_outlined ,
                        //     color: Colors.black, size: 18),
                        // SizedBox(
                        //   width: context.width(0.01),
                        // ),
                        Text('${startTime.month}월 ${startTime.day}일 '+ formattedDate + ' 출발',

                            style: const TextStyle(
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /*--출/도착*/
                      Container(
                        height: context.height(0.05),
                        width: (screenWidth - 20) * 0.8,
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                        child:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  // height: containerHeight,
                                  padding: const EdgeInsets.only(left: 5),
                                  // width: context.width(0.4),
                                  child:
                                      Text(
                                        startPoint,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                ),
                                Container(
                                  //padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
                                  child: Icon(
                                    Icons.arrow_right_outlined,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  // height: containerHeight,
                                 // padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                                  // width: context.width(0.4),
                                  child:
                                      Text(
                                        endPoint,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                ),
                              ],
                            ),
                      ),
                      /*--출/도착*/
                    ],
                  ),
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
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      color: //Colors.grey[200],
                      Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                              constraints: const BoxConstraints(
                                minHeight: 38, // Minimum height for the input field
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextField(
                                cursorColor: Colors.white,
                                controller: messageController,
                                style: const TextStyle(color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: "메시지 보내기...",
                                  hintStyle: TextStyle(
                                      color: Colors.black54, fontSize: 13),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                                sendMessage();
                            },
                            child: Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                 color:
                                 //Color.fromARGB(255, 238, 238, 238),
                                Color.fromARGB(255, 70, 100, 192),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
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
              .map<ChatMessage>((e) =>
              ChatMessage.fromMap(e.data() as Map<String, dynamic>, widget.carId))
              .toList();
          if (localChats != null) {
            fireStoreChats.addAll(localChats!);
          }
          // itemCount가 변경되었을 때 스크롤 위치를 조정
          if (fireStoreChats.length > previousItemCount) {
            previousItemCount = fireStoreChats.length;
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
              final previousChat = index > 0 ? fireStoreChats[index - 1] : null; // 이전 채팅 메시지

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
                        style: const TextStyle(color: Colors.grey),
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
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
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

  void _showProfileModal(BuildContext context, String memberId ,String userName, String memberGender) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(

          // 크기 지정
          height: context.height(0.35),
          width: double.infinity,

          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: const Text('프로필 조회',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.fromLTRB(20, 5, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: const Icon(
                      Icons.person_search, size: 120,),
                  ),
                  const SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(memberGender,style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey),),
                      ElevatedButton(
                        onPressed: () {
                          viewProfile(context, uid, memberId);
                          if(uid != memberId) {
                            // UID와 MemberId가 다르면 ComplainAlert 다이얼로그 표시
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => ComplainAlert(
                                  reportedUserNickName: userName,
                                  myId: widget.userName,
                                  carpoolId: widget.carId
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color.fromARGB(255, 255, 167, 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //Icon(Icons.warning_rounded, color: (uid == memberId) ? Colors.grey : Colors.white),
                            Icon(
                                (uid == memberId) ? Icons.double_arrow_rounded : Icons.warning_rounded,
                                color: (uid == memberId) ? Colors.white : Colors.white
                            ),
                            SizedBox(width: 8,),
                            Text(
                              (uid == memberId) ? "프로필로 이동" : "신고하기",
                              style: TextStyle(color: (uid == memberId) ? Colors.white : Colors.white, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

//uid와 memberID비교
  void viewProfile(BuildContext context, String? uid, String memberId){
    if( uid == memberId){
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MyPage()));
    }else{

    }
  }


}


