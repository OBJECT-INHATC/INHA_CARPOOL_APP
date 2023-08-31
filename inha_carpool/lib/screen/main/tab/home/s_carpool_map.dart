import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

import '../../../../common/util/carpool.dart';
import '../../s_main.dart';

class CarpoolMap extends StatefulWidget {
  final LatLng startPoint;
  final String startPointName;
  final String startTime;
  final String carId;
  final String admin;

  CarpoolMap({
    required this.startPoint,
    required this.startPointName,
    required this.startTime,
    required this.carId,
    required this.admin,
  });

  @override
  State<CarpoolMap> createState() => _CarpoolMapState();
}

class _CarpoolMapState extends State<CarpoolMap> {
  late GoogleMapController mapController;
  List<dynamic> list = [];
  String _distanceToLocation = ' ';
  bool firstStep = false;
  Set<Marker> _markers = {};
  late double distanceInMeters;
  LatLng? _myPoint;

  final storage = FlutterSecureStorage();
  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";

  String? token = "";

  @override
  void initState() {
    super.initState();
    _addMarker(
      widget.startPoint,
      widget.startPointName,
      "StartMarker",
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    _getCurrentLocation();
    _loadUserData();
    _getLocalToken();
  }

  _getLocalToken() async {
    token = await storage.read(key: "token");
  }

  Future<void> _loadUserData() async {
    nickName = await storage.read(key: "nickName") ?? "";
    uid = await storage.read(key: "uid") ?? "";
    gender = await storage.read(key: "gender") ?? "";

    setState(() {
      // nickName, email, gender를 업데이트했으므로 화면을 갱신합니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: '${widget.admin}님의 카풀'.text.white.make(),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        children: [
                          widget.startPointName.text.make(),
                          widget.startTime.text.make(),
                          '현재 위치와 거리 ${_distanceToLocation}'.text.make(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
              SizedBox(height: 10), // 간격 추가
              Container(
                height: screenHeight * 0.6, // 지도 높이 조절
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) => mapController = controller,
                      myLocationButtonEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: widget.startPoint,
                        zoom: 16.0,
                      ),
                      markers: _markers,
                      onCameraIdle: () {},
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_myPoint != null) {
                            _moveCameraTo(_myPoint!);
                          }
                        },
                        child: Text('내 위치로 이동'),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: () {
                          _moveCameraTo(widget.startPoint);
                        },
                        child: Text('출발지로 이동'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30), // 간격 추가
              GestureDetector(
                onTap: () async {


                  String carId = widget.carId;
                  String memberID = uid;
                  String memberName = nickName;


                  await FirebaseCarpool.addMemberToCarpool(
                      carId, memberID, memberName, token!)
                      .then((value) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => MainScreen()));
                    ///0830 서은율 : 카풀 참가 시 메시지 전송
                    FireStoreService().sendEntryMessage(carId,memberName);
                  }).catchError((error) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('카풀참가 실패'),
                          content: Text('자리가 마감되었습니다!\n다른 카풀을 이용해주세요.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) => MainScreen()));
                              },
                              child: Text('확인'),
                            ),
                          ],
                        );
                      },
                    );
                  });
                },
                child: Container(
                  height: screenHeight * 0.07,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    border: Border.all(width: 1, color: Colors.blue),
                    color: Colors.white, // 배경색
                  ),
                  child: const Center(
                    child: Text(
                      '카풀 참가하기',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 23,
                          fontWeight: FontWeight.w100),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addMarker(
      LatLng point, String infoText, String markerName, BitmapDescriptor icon) {
    _markers.removeWhere((marker) => marker.markerId.value == markerName);
    _markers.add(Marker(
      markerId: MarkerId(markerName),
      position: point,
      icon: icon,
      infoWindow: InfoWindow(title: infoText),
    ));
  }

  void _moveCameraTo(LatLng target) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 16.0),
    ));
  }

  void ScffoldMsgAndListClear(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$text')),
    );
    list.clear();
  }

  //현재 기기 위치 정보 가져오기 및 권한
  Future<void> _getCurrentLocation() async {
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
      _addMarker(_myPoint!, "내 위치", "BlueMarker",
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

      double distanceInMeters = Geolocator.distanceBetween(
        _myPoint!.latitude,
        _myPoint!.longitude,
        widget.startPoint.latitude,
        widget.startPoint.longitude,
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
