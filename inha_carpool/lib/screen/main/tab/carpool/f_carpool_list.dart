import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';

import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/screen/recruit/s_recruit.dart';
import 'dart:math';
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
                            child: Stack(
                              children: [
                                Card(
                                  color: Colors.indigo,
                                  surfaceTintColor: Colors.transparent,
                                  //elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  child: SizedBox(
                                    width: screenWidth - 20,
                                    height: cardHeight - 13,
                                  ),
                                ),
                                Positioned(
                                  top: (cardHeight - containerHeight) / 2 - 18,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    //color: Colors.white,
                                    width: (screenWidth - 20) * 0.8,
                                    height: cardHeight - 35,
                                    //-------지우기
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.black, // 위쪽 테두리 색상을 검은색으로 지정
                                          width: 1.2,          // 위쪽 테두리의 두께를 설정
                                        ),
                                        bottom: BorderSide(
                                          color: Colors.black, // 아래쪽 테두리 색상을 검은색으로 지정
                                          width: 1.2,          // 아래쪽 테두리의 두께를 설정
                                        ),
                                      ),
                                    ),
                                    //-------지우기
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    margin: const EdgeInsets.only(
                                    top: 2,
                                    bottom: 5,
                                    left: 10,
                                    right: 10,
                                  ),

                                    // 3등분
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [

                                        //1. 출발일
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_outlined,
                                              color: Colors.black54,
                                              size: 18,
                                            ),
                                            //달력 아이콘과 날짜의 간격
                                            Width(screenWidth * 0.01),
                                            '${startTime.month}월 ${startTime.day}일 $formattedDate'.text.bold.color(Colors.grey).bold.size(13).make(),
                                          ],
                                        ),

                                        Height(screenHeight * 0.01),

                                        // 2.출,도착지 주소
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            //지도
                                            //출발지
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    //mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        "${carpoolData['startDetailPoint']}",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: screenWidth * 0.03,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: screenWidth * 0.005),
                                                      Text(
                                                        shortenText(carpoolData['startPointName'], 15),
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: screenWidth * 0.025,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            VerticalLine(
                                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                              width: 2, height: 30, color: Colors.grey[300],
                                            ),

                                            //목적지
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${carpoolData['endDetailPoint']}",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: screenWidth * 0.03,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: screenWidth * 0.005),
                                                  Text(
                                                    shortenText(carpoolData['endPointName'], 15),
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: screenWidth * 0.025,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // 3. 메시지
                                        // Row(
                                        //   mainAxisAlignment: MainAxisAlignment.start,
                                        //   children: [
                                        //     Expanded(
                                        //       flex: 1,
                                        //         child: StreamBuilder<DocumentSnapshot?>(
                                        //           stream: FireStoreService().getLatestMessageStream(carpool['carId']),
                                        //           builder: (context, snapshot) {
                                        //             if (snapshot.connectionState == ConnectionState.waiting) {
                                        //               return CircularProgressIndicator();
                                        //             } else if (snapshot.hasError) {
                                        //               return Text('Error: ${snapshot.error}');
                                        //             } else if (!snapshot.hasData || snapshot.data == null) {
                                        //               return const Text(
                                        //                 '아직 채팅이 시작되지 않은 채팅방입니다!',
                                        //                 style: TextStyle(color: Colors.grey),
                                        //               );
                                        //             }
                                        //             DocumentSnapshot lastMessage = snapshot.data!;
                                        //             String content = lastMessage['message'];
                                        //             String sender = lastMessage['sender'];
                                        //
                                        //             // 글자가 16글자 이상인 경우, 17글자부터는 '...'로 대체
                                        //             if (content.length > 16) {
                                        //               content = content.substring(0, 16) + '...';
                                        //             }
                                        //
                                        //             return Row(
                                        //               children: [
                                        //                 Container(
                                        //                   margin: const EdgeInsets.only(left: 5.0),
                                        //                   padding: EdgeInsets.only(
                                        //                     left: MediaQuery.of(context).size.width * 0.02, // 채팅 왼쪽 여백
                                        //                   ),
                                        //                   child: Text(
                                        //                     '$sender : $content',
                                        //                     style: TextStyle(fontSize: 13, color: Colors.grey),
                                        //                   ),
                                        //                 ),
                                        //               ],
                                        //             );
                                        //           },
                                        //         ),
                                        //     ),
                                        //   ],
                                        // ),

                                        Expanded(
                                          child: Container(
                                            //width: (screenWidth - 20) * 0.8,
                                            //margin: const EdgeInsets.only(left: 5.0),
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.width * 0.06, // 채팅 왼쪽 여백
                                            ),
                                            child: StreamBuilder<DocumentSnapshot?>(
                                              stream: FireStoreService().getLatestMessageStream(carpool['carId']),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return CircularProgressIndicator();
                                                } else if (snapshot.hasError) {
                                                  return Text('Error: ${snapshot.error}');
                                                } else if (!snapshot.hasData || snapshot.data == null) {
                                                  return Text(
                                                    '아직 채팅이 시작되지 않은 채팅방입니다!',
                                                    style: TextStyle(color: Colors.grey),
                                                  );
                                                }
                                                DocumentSnapshot lastMessage = snapshot.data!;
                                                String content = lastMessage['message'];
                                                String sender = lastMessage['sender'];

                                                // 글자가 16글자 이상인 경우, 17글자부터는 '...'로 대체
                                                if (content.length > 16) {
                                                  content = content.substring(0, 16) + '...';
                                                }

                                                return Row(
                                                  children: [
                                                    Align(
                                                      alignment: Alignment.bottomLeft, // 좌측 하단 정렬
                                                      child: Text(
                                                          '$sender : $content',
                                                          style: TextStyle(fontSize: 13, color: Colors.grey),
                                                        ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),

                                //지도
                                Positioned(
                                  left: cardHeight / 6, // 카드의 1/6 가로 위치
                                  top: cardHeight / 3, // 카드의 1/3 세로 위치
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          Nav.globalContext,
                                          PageRouteBuilder(
                                            //아래에서 위로 올라오는 효과
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                                CarpoolMap(
                                                  isPopUp : true,
                                                  startPoint: LatLng(
                                                      carpoolData['startPoint'].latitude,
                                                      carpoolData['startPoint']
                                                          .longitude),
                                                  startPointName:
                                                  carpoolData['startPointName'],
                                                  endPoint: LatLng(
                                                      carpoolData['endPoint'].latitude,
                                                      carpoolData['endPoint'].longitude),
                                                  endPointName:
                                                  carpoolData['endPointName'],
                                                  startTime: formattedStartTime,
                                                  carId: carpoolData['carId'],
                                                  admin: carpoolData['admin'],
                                                  roomGender: carpoolData['gender'],
                                                ),

                                            transitionsBuilder: (context, animation,
                                                secondaryAnimation, child) {
                                              const begin = Offset(0.0, 1.0);
                                              const end = Offset.zero;
                                              const curve = Curves.easeInOut;
                                              var tween = Tween(
                                                  begin: begin, end: end)
                                                  .chain(CurveTween(curve: curve));
                                              var offsetAnimation =
                                              animation.drive(tween);
                                              return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child);
                                            },
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.map_outlined,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        surfaceTintColor: Colors.transparent,
                                        padding: EdgeInsets.all(screenWidth * 0.02),
                                        shape: CircleBorder(),
                                        backgroundColor: Colors.blue[100],
                                        minimumSize: Size(
                                          screenWidth * 0.06,
                                          screenWidth * 0.06,
                                        ),
                                      ),

                                    ),
                                ),

                                // 흰색 역삼각형
                                Positioned(
                                  top: 9,
                                  left: ((screenWidth - 20) * 4 / 5) + 1,
                                  child: CustomPaint(
                                    size: Size(
                                        (screenWidth - 20) / 16, cardHeight / 15),
                                    painter: dwonTrianglePainter(),
                                  ),
                                ),

                                //흰색 삼각형
                                Positioned(
                                  bottom: 10, // 카드의 아래쪽에서 5의 위치에 배치
                                  left: ((screenWidth - 20) * 4 / 5) + 1,
                                  child: CustomPaint(
                                    size: Size(
                                        (screenWidth - 20) / 16, cardHeight / 14),
                                    painter: UpTrianglePainter(),
                                  ),
                                ),


                              ],
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


