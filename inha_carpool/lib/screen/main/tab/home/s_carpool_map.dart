import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/common/widget/w_round_button.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

import '../../../../common/util/carpool.dart';
import '../../s_main.dart';

class CarpoolMap extends StatefulWidget {
  final LatLng startPoint;
  final String startPointName;
  final String startTime;
  final String carId;
  final String admin;
  final String roomGender;

  CarpoolMap({
    required this.startPoint,
    required this.startPointName,
    required this.startTime,
    required this.carId,
    required this.admin,
    required this.roomGender,
  });

  @override
  State<CarpoolMap> createState() => _CarpoolMapState();
}

class _CarpoolMapState extends State<CarpoolMap> {
  late GoogleMapController mapController;
  List<dynamic> list = [];
  String _distanceToLocation = '계산중...';
  bool firstStep = false;
  Set<Marker> _markers = {};
  late double distanceInMeters;
  LatLng? _myPoint;

  final storage = const FlutterSecureStorage();
  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";

  String? token = "";

  DateTime? currentBackPressTime;

  bool isLoading = true; // 뒤로가기 버튼 누른 시간

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
    return WillPopScope(
      onWillPop: () async {
        if (isLoading) {
          print('뒤로가기 제한');
          // 페이지가 로딩 중이면 뒤로가기 막음
          return false;
        } else {
          print('뒤로가기 허용');
          return true; // 로딩이 완료되면 뒤로가기 허용
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.normal,
          ),
          title: '${widget.admin.split("_").last}님의 카풀 정보'.text.black.make(),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          toolbarHeight: 45,
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        body: Stack(
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
              top: context.height(0.02),
              // 가운데 위치
              left: context.width(0.1),
              child: Container(
                height: context.height(0.3),
                width: context.width(0.8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.blue,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0), // 내부 패딩 추가
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // 가로 가운데 정렬
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.blue),
                                      const SizedBox(width: 3),
                                      const Text(
                                        "출발 지점",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3, horizontal: 8),
                                          // 내부 패딩
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300], // 회색 배경색
                                            borderRadius: BorderRadius.circular(
                                                20), // 동그란 모양 설정
                                          ),
                                          child: Text(
                                            widget.startPointName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black, // 텍스트 색상
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.access_time,
                                          color: Colors.blue),
                                      const SizedBox(width: 3),
                                      const Text(
                                        "출발 시간",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3, horizontal: 8),
                                          // 내부 패딩
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300], // 회색 배경색
                                            borderRadius: BorderRadius.circular(
                                                20), // 동그란 모양 설정
                                          ),
                                          child: Text(
                                            widget.startTime,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black, // 텍스트 색상
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.directions_car,
                                          color: Colors.blue),
                                      const SizedBox(width: 3),
                                      const Text(
                                        "남은 거리",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3, horizontal: 8),
                                          // 내부 패딩
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300], // 회색 배경색
                                            borderRadius: BorderRadius.circular(
                                                20), // 동그란 모양 설정
                                          ),
                                          child: Text(
                                            _distanceToLocation,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black, // 텍스트 색상
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                String carId = widget.carId;
                                String memberID = uid;
                                String memberName = nickName;
                                String selectedRoomGender = widget.roomGender;

                                if (gender != selectedRoomGender &&
                                    selectedRoomGender != '무관') {
                                  context.showErrorSnackbar(
                                      '입장할 수 없는 성별입니다.\n다른 카풀을 이용해주세요!');
                                  return;
                                }
                                try {
                                  await FirebaseCarpool.addMemberToCarpool(
                                      carId,
                                      memberID,
                                      memberName,
                                      token!,
                                      selectedRoomGender);
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreen()));
                                } catch (error) {
                                  // addMemberToCarpool에서 던진 예외를 처리함
                                  print('카풀 참가 실패 ( s_carpool_map )');
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('카풀 참가 실패'),
                                        content: const Text(
                                            '자리가 마감되었습니다!\n다른 카풀을 이용해주세요.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const MainScreen()));
                                            },
                                            child: const Text('확인'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Container(
                                height: context.height(0.04),
                                width: context.width(0.8),
                                alignment: Alignment.center,
                                child: const Text(
                                  '카풀 참가하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
            ),
            Positioned(
              bottom: context.height(0.05),
              left: 20,
              child: SizedBox(
                width: context.width(0.4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (_myPoint != null) {
                      _moveCameraTo(_myPoint!);
                    }
                  },
                  child: const Text('내 위치로 이동',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            Positioned(
              bottom: context.height(0.05),
              right: 20,
              child: SizedBox(
                width: context.width(0.4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    _moveCameraTo(widget.startPoint);
                  },
                  child: const Text('출발지로 이동',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
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

  void handlePageLoadComplete() {
    setState(() {
      isLoading = false; // 로딩이 완료되었음을 표시
    });
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
      print('로딩 상태 : $isLoading');
      handlePageLoadComplete();
      print('로딩 상태 ; $isLoading');
    });
  }
}
