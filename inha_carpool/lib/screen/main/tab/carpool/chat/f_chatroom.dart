import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/data/preference/prefs.dart';
import 'package:inha_Carpool/common/database/d_chat_dao.dart';
import 'package:inha_Carpool/common/models/m_chat.dart';
import 'package:inha_Carpool/common/widget/w_messagetile.dart';
import 'package:inha_Carpool/screen/dialog/d_complainAlert.dart';
import 'package:inha_Carpool/screen/main/s_main.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/chat/w_location.dart';
import 'package:inha_Carpool/service/api/Api_topic.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';


class ChatroomPage extends StatefulWidget {
  /// 0829 서은율 TODO : 채팅방 페이지 최적화 고민 해볼 것

  final String carId;
  final String groupName;
  final String userName;
  final String uid;
  final String gender;

  /// 생성자
  const ChatroomPage({
    Key? key,
    required this.carId,
    required this.groupName,
    required this.userName,
    required this.uid,
    required this.gender,
  }) : super(key: key);

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage>
    with WidgetsBindingObserver {
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

  User? user = FirebaseAuth.instance.currentUser;

  /// 관리자 이름, 토큰, 사용자 Auth 정보
  String admin = "";
  String token = "";

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

  // 출발지 상세주소
  String startPointDetail = "";

  //도착지 위도경도
  LatLng startPointLnt = const LatLng(0, 0);

  // 도착지
  String endPoint = "";

  // 도착지 상세주소
  String endPointDetail = "";

  //도착지 위도경도
  LatLng endPointLnt = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    /// 로컬 채팅 메시지 , 채팅 메시지 스트림, 관리자 이름 호출 메서드
    getChatandAdmin();

    /// 로컬 채팅 메시지, 채팅 메시지 스트림, 관리자 이름 호출
    getCurrentUserandToken();

    /// 토큰, 사용자 Auth 정보 호출
    getCarpoolInfo();

    /// 멤버 리스트, 출발 시간 가져오기
    _scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    Prefs.chatRoomOnRx.set(false); // 페이지가 활성화되면 true로 설정
    Prefs.chatRoomCarIdRx.set(widget.carId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    Prefs.chatRoomCarIdRx.set("carId");
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed: // 앱이 포그라운드에 있는 경우
        Prefs.chatRoomOnRx.set(false);
        Prefs.chatRoomCarIdRx.set(widget.carId);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused: // 앱이 백그라운드에 있는 경우
      case AppLifecycleState.detached:
        Prefs.chatRoomOnRx.set(true);
        Prefs.chatRoomCarIdRx.set("carId");
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }


  getLocalChat() async {
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
              widget.carId, DateTime.now().millisecondsSinceEpoch)
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
        startPoint = val['startPointName'];
        startPointDetail = val['startDetailPoint'];
        endPoint = val['endPointName'];
        endPointDetail = val['endDetailPoint'];
        endPointLnt =
            LatLng(val['endPoint'].latitude, val['endPoint'].longitude);
        startPointLnt =
            LatLng(val['startPoint'].latitude, val['startPoint'].longitude);
        agreedTime = startTime.subtract(const Duration(minutes: 10));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String formattedDate = DateFormat('HH:mm').format(startTime);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.appColors.logoColor,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 65,
          title: "$admin의 카풀".text.size(20).make(),
        ),

        //----------------------------------------------drawer 대화상대
        endDrawer: Drawer(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            children: [
              //-------------------------------대화상대 상단
              Container(
                height: AppBar().preferredSize.height * 2.2,
                width: double.infinity,
                color: context.appColors.logoColor,
                child: Column(
                  children: [
                    SizedBox(height: screenWidth * 0.17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          '대화 상대',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            _exitIconBtn(context);
                          },
                          icon: const Icon(
                            Icons.exit_to_app,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //---------------------------------대화상대 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: membersList.length >= 4 ? 4 : membersList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    String memberName = getName(membersList[index]);
                    String memberGender = getGender(membersList[index]);
                    String memberId = getMemberId(membersList[index]);

                    return ListTile(
                      onTap: () {
                        _showProfileModal(
                          context,
                          memberId,
                          '$memberName 님',
                          memberGender,
                        );
                      },
                      leading: Icon(
                        Icons.account_circle,
                        size: 35,
                        color: admin == memberName ? Colors.blue : Colors.black,
                      ),
                      title: Row(
                        children: [
                          memberName.text
                              .size(16)
                              .color(admin == memberName
                                  ? Colors.blue
                                  : Colors.black)
                              .make(),
                        ],
                      ),
                      trailing: const Icon(Icons.navigate_next_rounded),
                    );
                  },
                ),
              ),
              const Line(height: 1),
              // 경계라인을 위젯으로 만들어서 사용
              const Line(height: 1),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  child: Column(
                    children: [
                      ChatLocation(
                          title: '출발지',
                          location: startPoint,
                          point: startPointLnt,
                          isStart: 'true'),
                      const Line(height: 1),
                      ChatLocation(
                          title: '도착지',
                          location: endPoint,
                          point: endPointLnt,
                          isStart: 'false'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        //----------------------------------------------body
          resizeToAvoidBottomInset: true,
          body: Column(
          children: [
            //출발 목적지
            const Height(3),
            Expanded(
              child: Stack(
                children: <Widget>[
                  // 채팅 메시지
                  chatMessages(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Line(height: 1),
                      const Column(
                        children: [
                          Height(3),
                        ],
                      ),
                      '${startTime.month}월 ${startTime.day}일 $formattedDate 출발'
                          .text
                          .medium
                          .size(13)
                          .make(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextField(
                                  // 스크롤을 최하단으로
                                  onTap: () {
                                    //0.4초 기다렸다가 스크롤을 최하단으로
                                    Future.delayed(const Duration(milliseconds: 400),
                                        () {
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position.maxScrollExtent,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    });
                                },
                                  cursorColor: Colors.white,
                                  controller: messageController,
                                  style: const TextStyle(
                                      color: Colors.black87,
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
                                  color: context.appColors.logoColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exitIconBtn(BuildContext context) {
    final currentTime = DateTime.now();
    final timeDifference = agreedTime.difference(currentTime);
    final minutesDifference = timeDifference.inMinutes;

    // 출발 시간과 현재 시간 사이의 차이가 10분 이상인 경우 나가기 작업 수행
    if (minutesDifference > 10) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            surfaceTintColor: Colors.transparent,
            title: const Text('카풀 나가기'),
            content: admin == widget.userName
                ? const Text('현재 카풀의 방장 입니다. \n 정말 나가시겠습니까?')
                : const Text('정말로 카풀을 나가시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // 나가기 메소드
                  _exitCarpool(context);
                },
                child: const Text('나가기'),
              ),
            ],
          );
        },
      );
    } else {
      if (membersList.length < 2) {
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
                    Navigator.pop(context);
                    // 나가기 메소드
                    _exitCarpool(context);
                  },
                  child: const Text('나가기'),
                ),
              ],
            );
          },
        );
        // // agreedTime과 현재 시간 사이의 차이가 10분 이상인 경우 경고 메시지 또는 아무 작업도 수행하지 않음
      } else {
        // 나가기 불가
        _exitImpossible(context);
      }
    }
  }

  //--------------------------------------------------

  // 나가기 처리 메소드
  void _exitCarpool(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FutureBuilder(
          // 나가기 처리를 수행하는 비동기 함수
          future: _exitCarpoolFuture(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.5),
                surfaceTintColor: Colors.transparent,
                title: const Text(''),
                content: Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: const Center(
                    child: Column(
                      children: [
                        Center(
                          child: SpinKitThreeBounce(
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        Text(
                          "나가는 중",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              if (snapshot.error != null) {
                // 에러가 발생한 경우
                return const AlertDialog(
                  title: Text('카풀 나가기'),
                  content: Text('카풀 나가기에 실패했습니다.'),
                );
              } else {
                // 나가기 처리가 완료된 경우
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
                );
                return Container(); // 빈 컨테이너를 반환
              }
            }
          },
        );
      },
    );
  }

  /// 나가기 처리를 수행하는 비동기 함수
  Future<void> _exitCarpoolFuture() async {
    ApiTopic apiTopic = ApiTopic();
    bool isOpen = await apiTopic.deleteTopic(widget.uid, widget.carId);

    if (isOpen) {
      print("스프링부트 서버 성공 #############");
      try {
        if (Prefs.isPushOnRx.get() == true) {
          await FirebaseMessaging.instance.unsubscribeFromTopic(widget.carId);
          await FirebaseMessaging.instance
              .unsubscribeFromTopic("${widget.carId}_info");
        }
      } catch (e) {
        print("Ios 시뮬 에러~");
      }

      if (admin != widget.userName) {
        // 방장이 아닐 때 exitCarpool 메소드 호출
        await FireStoreService().exitCarpool(
            widget.carId, widget.userName, widget.uid, widget.gender);
      } else {
        // 방장일 때 exitCarpoolAsAdmin 메소드 호출
        await FireStoreService().exitCarpoolAsAdmin(
            widget.carId, widget.userName, widget.uid, widget.gender);
      }
    } else {
      print("스프링부트 서버 실패 #############");
      if (!mounted) return;
      showErrorDialog(context, "현재 서버가 불안정합니다.\n잠시 후 다시 시도해주세요.");
    }
  }

  /// 나가기 불가 메소드
  void _exitImpossible(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
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

  //--------------------------

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
            WidgetsBinding.instance.addPostFrameCallback((_) {
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
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      /// 메시지 전송
      FireStoreService().sendMessage(widget.carId, chatMessageMap);

      /// 스크롤 화면 하단으로 이동
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );



    setState(() {
        /// 메시지 입력 컨트롤러 초기화
        messageController.clear();
        canSend = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          canSend = true;
        });
      });
    }
  }

  void _showProfileModal(BuildContext context, String memberId, String userName,
      String memberGender) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: const Text(
                  '프로필 조회',
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
                      Icons.person_search,
                      size: 120,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(
                        memberGender,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          viewProfile(context, uid, memberId);
                          if (uid != memberId) {
                            print("uid: $uid");
                            // UID와 MemberId가 다르면 ComplainAlert 다이얼로그 표시
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => ComplainAlert(
                                  reportedUserNickName: userName,
                                  myId: widget.userName,
                                  carpoolId: widget.carId),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.transparent,
                          backgroundColor:
                              const Color.fromARGB(255, 255, 167, 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                (uid == memberId)
                                    ? Icons.double_arrow_rounded
                                    : Icons.warning_rounded,
                                color: (uid == memberId)
                                    ? Colors.white
                                    : Colors.white),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              (uid == memberId) ? "프로필로 이동" : "신고하기",
                              style: TextStyle(
                                  color: (uid == memberId)
                                      ? Colors.white
                                      : Colors.white,
                                  fontWeight: FontWeight.bold),
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
  void viewProfile(BuildContext context, String? uid, String memberId) {
    if (uid == memberId) {
      print("마이페이지로 이동");
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(temp: 'MyPage'),
        ),
      );
    }
  }

  /// 에러 다이얼로그
  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Text('카풀참가 실패'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  Nav.globalContext,
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  ),
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
