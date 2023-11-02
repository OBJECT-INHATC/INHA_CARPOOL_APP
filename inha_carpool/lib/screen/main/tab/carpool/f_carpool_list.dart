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
        color: Colors.grey,
      ),
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

                                  color:
                                  Color.fromARGB(255, 70, 100, 192),
                                  surfaceTintColor: Colors.transparent,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: SizedBox(
                                    width: screenWidth - 20,
                                    height: cardHeight -13,

                                  ),

                                ),

                                Positioned(
                                  top: (cardHeight - containerHeight) / 2 -20 ,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 0),
                                    margin: const EdgeInsets.only(
                                        top: 2, bottom: 5, left: 10, right: 10),
                                    child: Container(
                                      width: (screenWidth - 20) * 0.8,
                                      // 카드의 너비의 4/5로 설정
                                      margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                      height: containerHeight + 30,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  width: (screenWidth - 20) * 0.8,
                                                  height: cardHeight * 0.15,
                                                  margin: const EdgeInsets.only(
                                                      left: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      // 날짜
                                                      SizedBox(
                                                        width:
                                                        (screenWidth - 20) * 0.8 / 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                          children: [
                                                            const Flexible(
                                                              flex: 1,
                                                              child: Align(
                                                                alignment: Alignment.centerRight,
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 50),
                                                                  child: Icon(
                                                                    Icons.calendar_today_rounded,
                                                                    size: 16,
                                                                    color: Colors.black54,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Flexible(
                                                              flex: 1,
                                                              child: Align(
                                                                alignment: Alignment.centerRight,
                                                                child: Container(
                                                                  //margin: EdgeInsets.only(left: 5),
                                                                  // padding: EdgeInsets.only(right: 3),
                                                                  alignment:
                                                                  Alignment.center,
                                                                  child: Text(
                                                                    formattedStartTime,
                                                                    style:
                                                                    const TextStyle(
                                                                      fontSize: 14,
                                                                      color: Colors.black54,
                                                                      fontWeight:
                                                                      FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      // 시간
                                                      SizedBox(
                                                        width:
                                                        (screenWidth - 20) * 0.58 / 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                          children: [
                                                            const Flexible(
                                                              flex: 0,
                                                              child: Align(
                                                                alignment: Alignment.centerRight,
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 20),
                                                                  child: Icon(
                                                                    Icons.access_time_rounded,
                                                                    size: 18,
                                                                    color: Colors.black54,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Flexible(
                                                              flex: 1,
                                                              child: Align(
                                                                alignment: Alignment.centerRight,
                                                                child: Container(
                                                                  // margin: EdgeInsets.only(left: 5),
                                                                  // padding: EdgeInsets.only(right: 3),
                                                                  alignment:
                                                                  Alignment.center,
                                                                  child: Text(
                                                                    formattedDate,
                                                                    style:
                                                                    const TextStyle(
                                                                      fontSize: 14,
                                                                      color: Colors.black54,
                                                                      fontWeight:
                                                                      FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                    ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Row(
                                            children: [
                                              // 지도 버튼
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: MediaQuery.of(context).size.width * 0.05,
                                                  top: MediaQuery.of(context).size.width * 0.02, // 위쪽 여백 추가
                                                  right: MediaQuery.of(context).size.width * 0.03,
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    // TODO: 한승완 - 지도 연결 해주세요
                                                  },
                                                  child: Icon(
                                                    Icons.map_outlined,
                                                    color: Colors.white,
                                                    size: MediaQuery.of(context).size.width * 0.04,
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    surfaceTintColor: Colors.transparent,
                                                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                                    shape: CircleBorder(),
                                                    backgroundColor: Colors.blue[100],
                                                    minimumSize: Size(
                                                      MediaQuery.of(context).size.width * 0.06,
                                                      MediaQuery.of(context).size.width * 0.06,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // 출발지 및 목적지 정보
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
                                                  child: Row(
                                                    children: [
                                                      // 출발지 정보
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // 출발지 상세주소
                                                          Text(
                                                            "${carpoolData['startDetailPoint']}",
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: MediaQuery.of(context).size.width * 0.04,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),

                                                          SizedBox(height: MediaQuery.of(context).size.width * 0.005), // endDetailPoint - endPointName 사이 간격
                                                          // 출발지 이름
                                                          Text(
                                                            shortenText(carpoolData['startPointName'], 17),
                                                            style: TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: MediaQuery.of(context).size.width * 0.03,
                                                              fontWeight: FontWeight.bold,

                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      // 세로선을 추가
                                                      Container(
                                                        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
                                                        width: MediaQuery.of(context).size.width * 0.005, // 세로선의 너비
                                                        height: cardHeight * 0.25, // 세로선의 높이를 설정, 출발지와 목적지와 동일한 높이
                                                        color: Colors.grey[300], // 세로선의 색상
                                                      ),
                                                      // 목적지 정보
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // 목적지 상세주소
                                                          Text(
                                                            "${carpoolData['endDetailPoint']}",
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: MediaQuery.of(context).size.width * 0.04,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: MediaQuery.of(context).size.width * 0.005), // endDetailPoint - endPointName 사이 간격
                                                          // 목적지 이름
                                                          Text(
                                                            shortenText(carpoolData['endPointName'], 17),
                                                            style: TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: MediaQuery.of(context).size.width * 0.03,
                                                              fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ),
                                            ],
                                          ),


                                          Expanded(
                                            child: Container(
                                              width: (screenWidth - 20) * 0.8,
                                              margin: const EdgeInsets.only(left: 5.0),
                                              padding: EdgeInsets.only(
                                                left: MediaQuery.of(context).size.width * 0.03, // 채팅 왼쪽 여백
                                              ),
                                              child: StreamBuilder<DocumentSnapshot?>(
                                                stream: FireStoreService().getLatestMessageStream(carpool['carId']),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return CircularProgressIndicator();
                                                  } else if (snapshot.hasError) {
                                                    return Text('Error: ${snapshot.error}');
                                                  } else if (!snapshot.hasData || snapshot.data == null) {
                                                    return Padding(
                                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02), // 위 여백 추가
                                                      child: Text(
                                                        '아직 채팅이 시작되지 않은 채팅방입니다!',
                                                        style: TextStyle(color: Colors.grey),
                                                      ),
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
                                                      Container(
                                                        padding: EdgeInsets.only(
                                                          left: MediaQuery.of(context).size.width * 0.01, // 채팅 왼쪽 여백
                                                        ),
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
                                ),

                                //수직 점선
                                // Positioned(
                                //   top: 18,
                                //   // 점선 수직 위치 조정
                                //   left: ((screenWidth - 20) * 4 / 5) + 10,
                                //   // 카드를 1/5해서 가장 오른쪽 위치 계산
                                //   child: CustomPaint(
                                //     painter: DashedLinePainter(),
                                //     child: Container(
                                //       width: 2,
                                //       height: cardHeight - 10,
                                //     ),
                                //   ),
                                // ),

                                // 흰색 역삼각형
                                Positioned(
                                  top: 5,
                                  left: ((screenWidth - 20) * 4 / 5) + 1,
                                  child: CustomPaint(
                                    size: Size(
                                        (screenWidth - 20) / 16, cardHeight / 11),
                                    painter: dwonTrianglePainter(),
                                  ),
                                ),

                                //흰색 삼각형
                                Positioned(
                                  bottom: 5, // 카드의 아래쪽에서 5의 위치에 배치
                                  left: ((screenWidth - 20) * 4 / 5) + 1,
                                  child: CustomPaint(
                                    size: Size(
                                        (screenWidth - 20) / 16, cardHeight / 11),
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

//수직 점선
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5;
    double dashSpace = 5;
    double startY = 0;

    final paint = Paint()
      ..color = Color.fromARGB(255, 224, 224, 224)
      ..strokeWidth = 3;

    while (startY < size.height) {
      final endY = startY + dashWidth;
      canvas.drawLine(
          Offset(1.5, startY), Offset(1.5, min(endY, size.height)), paint);
      startY = endY + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

//역삼각형
class dwonTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0) // 왼쪽 위
      ..lineTo(size.width, 0) // 오른쪽 위
      ..lineTo(size.width / 2, size.height) // 아래 중앙
      ..close();

    final paint = Paint()
      ..color = Color(0xFFFAFAFA) //grey[100] 배경색과 동일
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
//반원
// class SemiCirclePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.white;
//
//     // 반원을 그리기 위한 사각형 영역 정의
//     final rect = Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height * 2));
//
//     // 시작 각도 0도, 끝 각도 180도 (π 라디안)로 설정하여 반원 그리기
//     canvas.drawArc(rect, 0, pi, true, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

//삼각형
class UpTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0) // 중앙 위
      ..lineTo(0, size.height) // 왼쪽 아래
      ..lineTo(size.width, size.height) // 오른쪽 아래
      ..close();

    final paint = Paint()..color = Color(0xFFFAFAFA);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}