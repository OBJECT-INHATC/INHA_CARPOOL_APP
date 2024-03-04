import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/data/preference/prefs.dart';
import 'package:inha_Carpool/common/database/d_chat_dao.dart';
import 'package:inha_Carpool/common/models/m_chat.dart';
import 'package:inha_Carpool/common/widget/w_messagetile.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/chat/w_splash_img_opacity.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

import '../../../../../provider/stateProvider/auth_provider.dart';
import 'drawer/f_drawer.dart';

class ChatroomPage extends ConsumerStatefulWidget {
  final String carId;

  /// 생성자
  const ChatroomPage({
    Key? key,
    required this.carId,
  }) : super(key: key);

  @override
  ConsumerState<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends ConsumerState<ChatroomPage>
    with WidgetsBindingObserver {
  /// 채팅 메시지 스트림
  Stream<QuerySnapshot>? chats;

  /// 로컬 채팅 메시지 스트림
  List<ChatMessage>? localChats;

  /// 메시지 입력 컨트롤러
  TextEditingController messageController = TextEditingController();

  /// 스크롤 컨트롤러
  late ScrollController _scrollController;

  /// 관리자 이름, 토큰, 사용자 Auth 정보
  String admin = "";
  String token = "";

  int previousItemCount = 0;
  bool canSend = true;

  // 멤버 리스트
  List<dynamic> membersList = [];

  // 출발 시간
  DateTime startTime = DateTime.now();

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

  late String nickName = '';
  late String uid = '';
  late String gender = '';
  late String userName = '';

  /// 유저 정보 받아오기
  _loadUserData() async {
    nickName = ref.read(authProvider).nickName!;
    uid = ref.read(authProvider).uid!;
    gender = ref.read(authProvider).gender!;
    userName = ref.read(authProvider).userName!;
  }

  @override
  void initState() {
    super.initState();

    /// 로컬 채팅 메시지 , 채팅 메시지 스트림, 관리자 이름 호출 메서드
    getChatAndAdmin();

    ///로그인 정보 불러오기
    _loadUserData();

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
    WidgetsBinding.instance.removeObserver(this);
    Prefs.chatRoomCarIdRx.set("carId");

    messageController.dispose();
    _scrollController.dispose();

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
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        final FocusScopeNode currentscope = FocusScope.of(context);
        if (!currentscope.hasPrimaryFocus && currentscope.hasFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.appColors.logoColor,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 65,
          title: Column(
            children: [
              "$admin의 카풀".text.size(20).make(),
              CountdownTimer(
                endWidget: const Text(
                  '카풀이 시작되었습니다!',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                endTime: startTime.millisecondsSinceEpoch,
                textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
                onEnd: () {},
              ),
            ],
          ),
          centerTitle: true,
        ),

        //----------------------------------------------drawer 대화상대
        endDrawer: ChatDrawer(
          membersList: membersList,
          startTime: startTime,
          admin: admin,
          carId: widget.carId,
          startPoint: startPoint,
          endPoint: endPoint,
          startPointLnt: startPointLnt,
          endPointLnt: endPointLnt,
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
                  /// 인하카풀 로고 배경 이미지
                  const SplashOpacity(),

                  /// 채팅 메시지
                  chatMessages(),

                  /// 최하단 메세지 보내기 컨테이너
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Line(height: 1),
                      const Column(
                        children: [
                          Height(3),
                        ],
                      ),



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
                                    Future.delayed(
                                        const Duration(milliseconds: 300), () {
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position.maxScrollExtent,
                                        duration:
                                            const Duration(milliseconds: 300),
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
                                        color: Colors.black38, fontSize: 13),
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

                  // 백그라운드 배경 이미지 (투명도 30)
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
          }

          /// 로컬 디비에 없는 메시지만 저장
          if (fireStoreChats.isNotEmpty && localChats != null && localChats!.isNotEmpty) {
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
                    messageType: nickName == fireStoreChats[index].sender
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
        "sender": nickName,
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

  getLocalChat() async {
    await ChatDao().getChatbyCarIdSortedByTime(widget.carId).then((val) {
      setState(() {
        localChats = val;
      });
    });
  }

  /// 로컬 채팅 메시지 , 채팅 메시지 스트림, 관리자 이름 호출 메서드
  getChatAndAdmin() async {
    await getLocalChat();

    if (localChats != null && localChats!.isNotEmpty) {
      final lastLocalChat = localChats?[localChats!.length - 1];

      FireStoreService()
          .getChatsFirstTime(widget.carId, lastLocalChat!.time)
          .then((val) {
        setState(() {
          chats = val;
        });
      });
    } else {
      FireStoreService()
          .getChatsAfterSpecTime(
              widget.carId)
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

  // 멤버 리스트, 출발 시간, 요약주소 가져오기
  getCarpoolInfo() async {
    await FireStoreService().getCarDetails(widget.carId).then((val) {
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
      });
    });
  }
}
