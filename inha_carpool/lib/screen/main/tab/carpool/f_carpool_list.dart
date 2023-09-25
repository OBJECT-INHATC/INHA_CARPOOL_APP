import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/extension/datetime_extension.dart';

import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/screen/recruit/s_recruit.dart';

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
      return text.substring(0, maxLength - 3) + '...';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown[50],
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
                      backgroundColor: context.appColors.appBar,
                      onPressed: () {
                        Navigator.push(
                          Nav.globalContext,
                          MaterialPageRoute(
                              builder: (context) => const RecruitPage()),
                        );
                      },
                      child: '+'.text.size(50).color(Colors.white).make(),
                    ),
                  ],
                ),
              ),
            );
          } else {
            List<DocumentSnapshot> myCarpools = snapshot.data!;

            return Scaffold(
              floatingActionButton: FloatingActionButton(
                heroTag: "recruit_from_home",
                elevation: 5,
                // mini: false,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.grey, width: 1),
                ),
                onPressed: () {
                  Navigator.push(
                    Nav.globalContext,
                    MaterialPageRoute(
                      builder: (context) => const RecruitPage(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.add,
                  color: Colors.blue,
                  size: 50,
                ),
              ),
              body: Align(

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
                    DateTime startTime =
                        DateTime.fromMillisecondsSinceEpoch(carpool['startTime']);
                    DateTime currentTime = DateTime.now();
                    Duration difference = startTime.difference(currentTime);

                    String formattedStartTime =
                        startTime.formattedDateMyCarpool; // 날짜 형식으로 변환


                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          Nav.globalContext,
                          MaterialPageRoute(
                              builder: (context) => ChatroomPage(
                                  carId: carpool['carId'],
                                  groupName: '카풀네임',
                                  userName: nickName,
                                  uid: uid,
                                  gender: gender,)),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),

                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(

                                      child: Container(

                                        color: Colors.transparent,
                                        child: Column(

                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 3),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        // child: Text(formattedTime)
                                                        //   .text
                                                        //    .size(15)
                                                        //   .bold
                                                        //  .color(context.appColors.text)
                                                        //    .make(),
                                                      ),
                                                      Text(
                                                        formattedStartTime,
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 10.0),
                                                    child: Container(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(Icons.person, color: Colors.grey, size: 22),
                                                              SizedBox(width: 5), // 왼쪽으로 이동
                                                              Text(
                                                                '${carpoolData['admin'].split('_')[1]}',
                                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 8), // 날짜 아래 여백 추가
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              margin: const EdgeInsets.all(7.0),
                                                              width: context.width(0.015),
                                                              height: context.height(0.01),
                                                              // desired height
                                                              decoration: BoxDecoration(
                                                                color: Colors.brown[100], // 출발지 포인트
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: const Center(),
                                                            ),
                                                            const SizedBox(width: 5),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            "${carpoolData['startDetailPoint']}  ",
                                                                            style: const TextStyle(
                                                                              color: Colors.brown,
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            shortenText(carpoolData['startPointName'], 16),
                                                                            style: TextStyle(
                                                                              color: Colors.grey[600],
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets.only(left: 10, top: 0, bottom: 10, right: 10),
                                                                      child: Icon(Icons.arrow_circle_right_outlined, size: 20, color: Colors.grey[700]),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Container(
                                                                          margin: const EdgeInsets.all(7.0),
                                                                          width: context.width(0.015),
                                                                          height: context.height(0.01),
                                                                          decoration: BoxDecoration(
                                                                            color: Colors.brown[100], //목적지 포인트
                                                                            borderRadius: BorderRadius.circular(10),
                                                                          ),
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Center(),
                                                                        ),
                                                                        const SizedBox(width: 5),
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "${carpoolData['endDetailPoint']}",
                                                                              style: const TextStyle(
                                                                                color: Colors.brown,
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              shortenText(carpoolData['endPointName'], 16),
                                                                              style: TextStyle(
                                                                                color: Colors.grey[600],
                                                                                fontSize: 11,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 13),
                                            Container(
                                              child: StreamBuilder<DocumentSnapshot?>(
                                                stream: FireStoreService().getLatestMessageStream(carpool['carId']),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return CircularProgressIndicator();
                                                  } else if (snapshot.hasError) {
                                                    return Text('Error: ${snapshot.error}');
                                                  } else if (!snapshot.hasData || snapshot.data == null) {
                                                    return Text('아직 채팅이 시작되지 않은 채팅방입니다!', style: TextStyle(color: Colors.grey));
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
                                                        margin: EdgeInsets.only(bottom: 8.0), // 채팅 밑 여백
                                                        padding: EdgeInsets.only(left: 3.0), // 채팅 왼쪽 여백
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
                      ),

                    );
                  },
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
