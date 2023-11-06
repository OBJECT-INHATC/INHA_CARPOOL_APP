import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
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
  final storage = FlutterSecureStorage();
  late String nickName = ""; // Initialize with a default value
  late String uid = "";
  late String gender = "";

  DocumentSnapshot? oldLastMessage;

  //구글맵 변수
  LatLng? _myPoint;
  String _distanceToLocation = ' ';

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

  String getName(String res) {
    int start = res.indexOf("_") + 1;
    int end = res.lastIndexOf("_");
    return res.substring(start, end);
  }

  String shortenText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength - 4) + '...';
    }
  }

  // Retrieve carpools and apply FutureBuilder
  Future<List<DocumentSnapshot>> _loadCarpools() async {
    String myID = uid;
    String myNickName = nickName;
    String myGender = gender;
    print(myID);

    List<DocumentSnapshot> carpools =
    await FirebaseCarpool.getCarpoolsWithMember(myID, myNickName, myGender);
    return carpools;
  }

  String _getFormattedDateString(DateTime dateTime) {
    return '${dateTime.month}. ${dateTime.day}. ${_getWeekdayString(dateTime.weekday)}';
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
                      //Colors.blue[200],
                      Color.fromARGB(255, 70, 100, 192),
                    )
                        .make(),
                  ),
                  body: Container( //이 부분 추가
                    /*컨테이너 배경색 추가*/
                    decoration: BoxDecoration(
                      color:
                      Colors.grey[100],
                      // Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    /*--------------*/

                    child:  Align(
                      alignment: Alignment.center,
                      child: ListView.builder(
                        itemCount: myCarpools.length,
                        itemBuilder: (context, i) {
                          DocumentSnapshot carpool = myCarpools[i];
                          // DocumentSnapshot carpool = widget.snapshot.data![index];
                          Map<String, dynamic> carpoolData =
                          carpool.data() as Map<String, dynamic>;
                          String startPointName = carpool['startPointName'];


                          //카풀 날짜 및 시간 변환
                          DateTime startTime = DateTime.fromMillisecondsSinceEpoch(
                              carpool['startTime']);
                          DateTime currentTime = DateTime.now();
                          Duration difference = startTime.difference(currentTime);

                          String formattedDate = DateFormat('HH:mm').format(startTime);

                          String formattedStartTime =
                          _getFormattedDateString(startTime);

                          return GestureDetector(
                            onTap: () {

                              if (isCarpoolOver(startTime)) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                    content: Text('해당 방은 이미 종료된 카풀방입니다!')))
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
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  color: Colors.black,
                                                  size: 18,
                                                ),
                                                Width(screenWidth * 0.01),
                                                '${startTime.month}월 ${startTime.day}일 $formattedDate'
                                                    .text
                                                    .bold
                                                    .color(Colors.grey)
                                                    .bold
                                                    .size(13)
                                                    .make(),
                                              ],
                                            )),
                                        const Spacer(),

                                        // 지도
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 50, bottom: 10),
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child:
                                            Image.asset(
                                              'assets/image/icon/map3.png',
                                              width: 33,
                                              height: 45,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    //출발지와 row의간격
                                    Height(screenHeight * 0.01),

                                    //2번째 줄 출발지
                                    Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 15),
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
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 12),
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
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 15),
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
                                                    carpoolData['endPointName'],
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
                                          height: 20, color: Colors.grey[400]),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Row(
                                        children: [
                                          StreamBuilder<DocumentSnapshot?>(
                                            stream: FireStoreService()
                                                .getLatestMessageStream(
                                                carpool['carId']),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data == null) {
                                                return Text(
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
                                                    content.substring(0, 16) +
                                                        '...';
                                              }
                                              return Text(
                                                '$sender : $content',
                                                style: TextStyle(
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
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  //카메라 이동 메서드
  void _moveCameraTo(LatLng target) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 16.0),
    ));
  }

  //현재 기기 위치 정보 가져오기 및 권한
  Future<void> _getCurrentLocation(GeoPoint startPoint) async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      //  _showLocationPermissionSnackBar();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _myPoint = LatLng(position.latitude, position.longitude);
      double distanceInMeters = Geolocator.distanceBetween(
        _myPoint!.latitude,
        _myPoint!.longitude,
        startPoint!.latitude,
        startPoint!.longitude,
      );

      double distanceInKm = distanceInMeters / 1000;
      if (distanceInKm >= 1) {
        _distanceToLocation = distanceInKm.toStringAsFixed(1) + "km";
      } else {
        _distanceToLocation = (distanceInMeters).toStringAsFixed(0) + "m";
      }
    });
  }
}


