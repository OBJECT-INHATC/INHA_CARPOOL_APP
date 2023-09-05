import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/app.dart';
import 'package:inha_Carpool/common/Colors/app_colors.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/extension/datetime_extension.dart';

import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/screen/recruit/s_recruit.dart';

import '../../../../common/constants.dart';

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
  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  // Retrieve carpools and apply FutureBuilder
  Future<List<DocumentSnapshot>> _loadCarpools() async {
    String myID = uid;
    String myNickName = nickName;
    print(myID);

    List<DocumentSnapshot> carpools =
        await FirebaseCarpool.getCarpoolsWithMember(myID, myNickName);
    return carpools;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
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
                    elevation: 4,
                    backgroundColor: context.appColors.appBar,
                    onPressed: () {
                      Nav.push(RecruitPage());
                    },
                    child: '+'.text.size(50).color(Colors.white).make(),
                  ),
                ],
              ),
            ),
          );
        } else {
          List<DocumentSnapshot> myCarpools = snapshot.data!;

          return Align(
            alignment: Alignment.center,
            child: ListView.builder(
              itemCount: myCarpools.length,
              itemBuilder: (context, i) {
                DocumentSnapshot carpool = myCarpools[i];
                String startPointName = carpool['startPointName'];
                //카풀 날짜 및 시간 변환
                DateTime startTime =
                    DateTime.fromMillisecondsSinceEpoch(carpool['startTime']);
                DateTime currentTime = DateTime.now();
                Duration difference = startTime.difference(currentTime);

                String formattedStartTime =
                    startTime.formattedDateMyCarpool; // 날짜 형식으로 변환

                String formattedTime;
                if (difference.inDays >= 365) {
                  formattedTime = '${difference.inDays ~/ 365}년 후';
                } else if (difference.inDays >= 30) {
                  formattedTime =
                      '${difference.inDays ~/ 30}달 ${difference.inDays.remainder(30)}일 이후';
                } else if (difference.inDays >= 1) {
                  formattedTime =
                      '${difference.inDays}일 ${difference.inHours.remainder(24)}시간 이후';
                } else if (difference.inHours >= 1) {
                  formattedTime =
                      '${difference.inHours}시간 ${difference.inMinutes.remainder(60)}분 이후';
                } else {
                  formattedTime = '${difference.inMinutes}분 후';
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      Nav.globalContext,
                      MaterialPageRoute(
                          builder: (context) => ChatroomPage(
                              carId: carpool['carId'],
                              groupName: '카풀네임',
                              userName: nickName,
                              uid: uid)),
                    );
                  },
                  child: Card(
                    child: Container(
                      color: context.appColors.cardBackground,
                      margin:
                          EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                      padding: EdgeInsets.only(
                          left: 12, right: 12, top: 20, bottom: 20),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        "${formattedStartTime}"
                                            .text
                                            .size(16)
                                            .bold
                                            .make(),
                                        "${carpool['startDetailPoint']} <-> ${carpool['endDetailPoint']}"
                                            .text
                                            .size(16)
                                            .bold
                                            .make(),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        '주안역 2번출구로 오세요 ㅃㄹ '
                                            .text
                                            .size(12)
                                            .bold
                                            .color(context.appColors.subText)
                                            .make(),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        '마지막 채팅 온 시간'
                                            .text
                                            .size(12)
                                            .normal
                                            .color(context.appColors.subText)
                                            .make(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(children: [
                            Text(formattedTime)
                                .text
                                .size(12)
                                .bold
                                .color(context.appColors.text)
                                .make(),
                            const SizedBox(
                              height: 20,
                            ),

                            /// 리스트 우측 하단에 지도 버튼 (카풀 위치, 현재 위치 조회가능)
                            IconButton(
                              icon: const Icon(
                                Icons.map_outlined,
                                size: 30,
                              ),
                              onPressed: () {
                                _getCurrentLocation(carpool['startPoint']);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      insetPadding: const EdgeInsets.all(20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                      title: const Text(
                                        '카풀 위치',
                                        textAlign: TextAlign.center,
                                      ),
                                      content: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        child: Stack(
                                          children: [
                                            Column(
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.5,
                                                  child: Stack(
                                                    children: [
                                                      // 카풀 위치 지도 부분
                                                      GoogleMap(
                                                        onMapCreated:
                                                            (controller) =>
                                                                mapController =
                                                                    controller,
                                                        initialCameraPosition:
                                                            CameraPosition(
                                                          target: LatLng(
                                                              carpool['startPoint']
                                                                  .latitude,
                                                              carpool['startPoint']
                                                                  .longitude),
                                                          zoom: 16,
                                                        ),
                                                        markers: {
                                                          Marker(
                                                            markerId: MarkerId(
                                                                carpool['startPoint']
                                                                    .toString()),
                                                            position: LatLng(
                                                                carpool['startPoint']
                                                                    .latitude,
                                                                carpool['startPoint']
                                                                    .longitude),
                                                            infoWindow:
                                                                InfoWindow(
                                                                    title:
                                                                        '출발지'),
                                                          ),
                                                        },
                                                        myLocationButtonEnabled:
                                                            true,
                                                        myLocationEnabled: true,
                                                      ),
                                                      //카풀위치 버튼
                                                      Positioned(
                                                        bottom: 70,
                                                        right: 5,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            _moveCameraTo(
                                                              LatLng(
                                                                  carpool['startPoint']
                                                                      .latitude,
                                                                  carpool['startPoint']
                                                                      .longitude),
                                                            );
                                                          },
                                                          child: const Text(
                                                              '카풀위치'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20),
                                                  child: Column(
                                                    children: [
                                                      Text(startPointName,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      16)),
                                                      Text(formattedTime,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      16)),
                                                      Text(
                                                          '현재 위치와 거리: $_distanceToLocation',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      16)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        Center(
                                          child: Column(
                                            children: [
                                              Line(
                                                  color: context
                                                      .appColors.divider),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('닫기'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
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
