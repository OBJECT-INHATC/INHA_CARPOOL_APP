import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';

import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/screen/recruit/s_recruit.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

import '../home/s_carpool_map.dart';

class CarpoolList extends StatefulWidget {
  const CarpoolList({Key? key}) : super(key: key);

  @override
  State<CarpoolList> createState() => _CarpoolListState();
}

class _CarpoolListState extends State<CarpoolList> {
  late final AnimationController _animationController;

  final storage = FlutterSecureStorage();
  late String nickName = ""; // Initialize with a default value
  late String uid = "";
  late String gender = "";

  DocumentSnapshot? oldLastMessage;

  late GoogleMapController mapController;

  bool isPopUp = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // User data retrieval
  Future<void> _loadUserData() async {
    nickName = await storage.read(key: "nickName") ?? "";
    uid = await storage.read(key: "uid") ?? "";
    gender = await storage.read(key: "gender") ?? "";

    setState(() {
      // Update the state to trigger a UI refresh
    });
  }

  // 카풀 컬렉션 이름 추출
  // String getName(String res) {
  //   return res.substring(res.indexOf("_") + 1);
  // }

// 시간 포멧 ver.2
  String _getFormattedDateString(DateTime dateTime) {
    final now = DateTime.now();
    var difference = now.difference(dateTime);

    if (difference.isNegative) {
      difference = difference.abs();
    }

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}년 전';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}달 전';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inMinutes}분 전';
    }
  }

  String getName(String res) {
    int start = res.indexOf("_") + 1;
    int end = res.lastIndexOf("_");
    return res.substring(start, end);
  }

  String shortenText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength - 4)}...';
    }
  }

  // Retrieve carpools and apply FutureBuilder
  Future<List<DocumentSnapshot>> _loadCarpools() async {
    String myID = uid;
    String myNickName = nickName;
    String myGender = gender;

    List<DocumentSnapshot> carpools =
        await FirebaseCarpool.getCarpoolsWithMember(myID, myNickName, myGender);
    return carpools;
  }

  String _getFormattedDateForMap(DateTime dateTime) {
    return '${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분';
  }

  String _getWeekdayString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '월';
      case DateTime.tuesday:
        return '화';
      case DateTime.wednesday:
        return '수';
      case DateTime.thursday:
        return '목';
      case DateTime.friday:
        return '금';
      case DateTime.saturday:
        return '토';
      case DateTime.sunday:
        return '일';
      default:
        return '';
    }
  }

  bool isCarpoolOver(DateTime startTime) {
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(startTime);
    return difference.inHours >= 1;
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이를 가져 와서 화면 비율 계산함
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 화면 높이의 70%를 ListView.builder의 높이로 사용
    double listViewHeight = screenHeight * 0.7;
    // 각 카드의 높이
    double cardHeight = listViewHeight * 0.3; //1101
    // 카드 높이의 1/2 사용
    double containerHeight = cardHeight / 2;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadCarpools();
          });
        },
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: _loadCarpools(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      '참가하고 계신 카풀이 없습니다.\n카풀을 등록해보세요!'
                          .text
                          .size(20)
                          .bold
                          .color(context.appColors.text)
                          .align(TextAlign.center)
                          .make(),
                      const SizedBox(
                        height: 20,
                      ),
                      FloatingActionButton(
                        heroTag: "recruit_from_myCarpool",
                        elevation: 10,
                        backgroundColor: Colors.white,
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                          //side: const BorderSide(color: Colors.white, width: 1),
                        ),
                        onPressed: () {
                          Navigator.push(
                            Nav.globalContext,
                            MaterialPageRoute(
                                builder: (context) => const RecruitPage()),
                          );
                        },
                        child: '+'
                            .text
                            .size(50)
                            .color(
                              Colors.blue[200],
                              //Color.fromARGB(255, 70, 100, 192),
                            )
                            .make(),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              List<DocumentSnapshot> myCarpools = snapshot.data!;

              return SafeArea(
                child: Scaffold(
                  floatingActionButton: FloatingActionButton(
                    heroTag: "recruit_from_myCarpool",
                    elevation: 10,
                    backgroundColor: Colors.white,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      //side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    onPressed: () {
                      Navigator.push(
                        Nav.globalContext,
                        MaterialPageRoute(
                            builder: (context) => const RecruitPage()),
                      );
                    },
                    child: '+'
                        .text
                        .size(50)
                        .color(
                          context.appColors.logoColor,
                        )
                        .make(),
                  ),
                  body: Column(
                    children: [
                      Line(
                        height: 1,
                        margin: const EdgeInsets.all(5),
                        color: context.appColors.logoColor,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: myCarpools.length,
                          itemBuilder: (context, i) {
                            DocumentSnapshot carpool = myCarpools[i];
                            // DocumentSnapshot carpool = widget.snapshot.data![index];
                            Map<String, dynamic> carpoolData =
                                carpool.data() as Map<String, dynamic>;

                            DateTime startTime = DateTime.fromMillisecondsSinceEpoch(carpool['startTime']);

                            // 지도를 위한 변수
                            String formattedForMap =
                            _getFormattedDateForMap(startTime);

                            // 채팅방을 위한 변수
                            String formattedStartTime = _getFormattedDateString(startTime);





                            return GestureDetector(
                              onTap: () {
                                if (isCarpoolOver(startTime)) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content:
                                              Text('해당 방은 이미 종료된 카풀방입니다!')))
                                      .closed
                                      .then((value) {
                                    _loadCarpools();
                                    setState(() {});
                                  });
                                } else {
                                  Navigator.push(
                                    Nav.globalContext,
                                    MaterialPageRoute(
                                        builder: (context) => ChatroomPage(
                                              carId: carpool['carId'],
                                              groupName: '카풀네임',
                                              userName: nickName,
                                              uid: uid,
                                              gender: gender,
                                            )),
                                  );
                                }
                              },

                              /*-----------------------------------------------Card---------------------------------------------------------------*/
                              child: Card(
                                color: Colors.white,
                                surfaceTintColor: Colors.transparent,
                                elevation: 3,
                                // 그림자의 깊이를 조절하는 elevation 값
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),

                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: context.appColors.logoColor
                                          .withOpacity(0.67),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Column(
                                    children: [
                                      //첫번째 줄
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // 왼쪽에 날짜 위젯 배치
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, top: 15),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .calendar_today_outlined,
                                                    color: context
                                                        .appColors.logoColor,
                                                    size: 18,
                                                  ),
                                                  Width(screenWidth * 0.01),
                                                  formattedStartTime
                                                      .text
                                                      .bold
                                                      .color(Colors.grey)
                                                      .size(13)
                                                      .make(),
                                                ],
                                              )),
                                          const Spacer(),

                                          // 지도
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                Nav.globalContext,
                                                PageRouteBuilder(
                                                  //아래에서 위로 올라오는 효과
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      CarpoolMap(
                                                    isStart: 'default',
                                                    isPopUp: true,
                                                    startPoint: LatLng(
                                                        carpoolData[
                                                                'startPoint']
                                                            .latitude,
                                                        carpoolData[
                                                                'startPoint']
                                                            .longitude),
                                                    startPointName: carpoolData[
                                                        'startPointName'],
                                                    endPoint: LatLng(
                                                        carpoolData['endPoint']
                                                            .latitude,
                                                        carpoolData['endPoint']
                                                            .longitude),
                                                    endPointName: carpoolData[
                                                        'endPointName'],
                                                    startTime:
                                                        formattedForMap,
                                                    carId: carpoolData['carId'],
                                                    admin: carpoolData['admin'],
                                                    roomGender:
                                                        carpoolData['gender'],
                                                  ),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    const begin =
                                                        Offset(0.0, 1.0);
                                                    const end = Offset.zero;
                                                    const curve =
                                                        Curves.easeInOut;
                                                    var tween = Tween(
                                                            begin: begin,
                                                            end: end)
                                                        .chain(CurveTween(
                                                            curve: curve));
                                                    var offsetAnimation =
                                                        animation.drive(tween);
                                                    return SlideTransition(
                                                        position:
                                                            offsetAnimation,
                                                        child: child);
                                                  },
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 55, bottom: 10),
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: Image.asset(
                                                  'assets/image/icon/map.png',
                                                  width: 30,
                                                  height: 45,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      //출발지와 row의간격
                                      Height(screenHeight * 0.01),

                                      //2번째 줄 출발지
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(
                                          children: [
                                            Icon(Icons.circle_outlined,
                                                color:
                                                    context.appColors.logoColor,
                                                size: 12),

                                            // 아이콘과 주소들 사이 간격
                                            Width(screenWidth * 0.03),

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // 출발지 요약주소
                                                Text(
                                                  "${carpoolData['startDetailPoint']}",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // 출발지 풀주소
                                                Text(
                                                  shortenText(
                                                      carpoolData[
                                                          'startPointName'],
                                                      15),
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.arrow_downward_rounded,
                                              size: 18,
                                              color: Colors.indigo,
                                            ),
                                          ],
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(
                                          children: [
                                            Icon(Icons.circle,
                                                color:
                                                    context.appColors.logoColor,
                                                size: 12),

                                            // 아이콘과 주소들 사이 간격
                                            Width(screenWidth * 0.03),

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // 출발지 요약주소
                                                Text(
                                                  "${carpoolData['endDetailPoint']}",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // 출발지 풀주소
                                                Text(
                                                  shortenText(
                                                      carpoolData[
                                                          'endPointName'],
                                                      15),
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 박스와 간격
                                      Height(screenHeight * 0.01),

                                      //--------------------------------- 하단 메시지
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Divider(
                                            height: 20,
                                            color: context.appColors.logoColor),
                                      ),

                                      Padding(
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              /*-----------------------------------------------Card---------------------------------------------------------------*/
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
