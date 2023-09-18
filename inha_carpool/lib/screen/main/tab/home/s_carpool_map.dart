import 'dart:ui' as ui;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/service/api/Api_Topic.dart';

import '../../../../common/data/preference/prefs.dart';
import '../../../../common/util/carpool.dart';
import '../../../../common/util/addMember_Exception.dart';
import '../../../../dto/TopicDTO.dart';
import '../../s_main.dart';

class CarpoolMap extends StatefulWidget {
  final LatLng startPoint;
  final String startPointName;
  final LatLng endPoint;
  final String endPointName;
  final String startTime;
  final String carId;
  final String admin;
  final String roomGender;

  const CarpoolMap({
    super.key,
    required this.startPoint,
    required this.startPointName,
    required this.startTime,
    required this.carId,
    required this.admin,
    required this.roomGender,
    required this.endPoint,
    required this.endPointName,
  });

  @override
  State<CarpoolMap> createState() => _CarpoolMapState();
}

class _CarpoolMapState extends State<CarpoolMap> {
  late GoogleMapController mapController;
  List<dynamic> list = [];
  bool firstStep = false;
  late double distanceInMeters;

  final storage = const FlutterSecureStorage();
  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";

  String? token = "";

  DateTime? currentBackPressTime;

  bool isLoading = true; // 뒤로가기 버튼 누른 시간

  LatLng? midPoint;

  BitmapDescriptor startCustomIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor endCustomIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    addCustomIcon(); // 커스텀 아이콘 추가
    _moveCamera(); // 카메라 이동
    _loadUserData();
    _getLocalToken();
  }

  /// 커스텀 아이콘 이미지 추가 - 0915 한승완
  void addCustomIcon() async {
    final Uint8List? starticon =
        await getBytesFromAsset('assets/image/startmarker.png', 200);
    setState(() {
      startCustomIcon = BitmapDescriptor.fromBytes(starticon!);
    });

    final Uint8List? endicon =
        await getBytesFromAsset('assets/image/endmarker.png', 200);
    setState(() {
      endCustomIcon = BitmapDescriptor.fromBytes(endicon!);
    });
  }

  /// 중간 지점 계산 및 카메라 이동 - 0914 한승완
  _moveCamera() async {
    final double midLat =
        (widget.startPoint.latitude + widget.endPoint.latitude) / 2;
    final double midLng =
        (widget.startPoint.longitude + widget.endPoint.longitude) / 2;
    midPoint = LatLng(midLat, midLng);
    // 뒤로가기 제한 해제
    handlePageLoadComplete();
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
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          title: '${widget.admin.split("_")[1]}님의 카풀 정보'.text.black.make(),
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
            Padding(
              padding: EdgeInsets.only(bottom: context.height(0.25)),
              child: GoogleMap(
                onMapCreated: (controller) {
                  mapController = controller;
                },
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: midPoint!,
                  zoom: 13.5,
                ),
                cameraTargetBounds: CameraTargetBounds(
                  getCurrentBounds(widget.startPoint, widget.endPoint),
                ),
                markers: {
                  /// 시작 지점 마커
                  Marker(
                    markerId: const MarkerId('start'),
                    position: widget.startPoint,
                    icon: startCustomIcon,
                    infoWindow: InfoWindow(
                      title: "출발 지점 : ${widget.startPointName}",
                    ),
                  ),

                  /// 도착 지점 마커
                  Marker(
                    markerId: const MarkerId('end'),
                    position: widget.endPoint,
                    icon: endCustomIcon,
                    infoWindow: InfoWindow(
                      title: "도착 지점 : ${widget.endPointName}",
                    ),
                  ),
                },
                onCameraIdle: () {},
              ),
            ),
            Positioned(
              bottom: context.height(0),
              // 가운데 위치
              child: Container(
                height: context.height(0.25),
                width: context.width(1),
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
                                          fontSize: 11,
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
                                              fontSize: 11,
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
                                      const Icon(Icons.location_on,
                                          color: Colors.lightGreenAccent),
                                      const SizedBox(width: 3),
                                      const Text(
                                        "도착 지점",
                                        style: TextStyle(
                                          fontSize: 11,
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
                                            widget.endPointName,
                                            style: const TextStyle(
                                              fontSize: 11,
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
                                          fontSize: 11,
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
                                              fontSize: 11,
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
                                      gender,
                                      token!,
                                      selectedRoomGender);
                                  if (!mounted) return;

                                  ///  해당 카풀 알림 토픽 추가 0919 이상훈
                                  if (Prefs.isPushOnRx.get() == true) {
                                    await FirebaseMessaging.instance
                                        .subscribeToTopic(carId);
                                  }
                                  ApiTopic apiTopic = ApiTopic();
                                  TopicRequstDTO topicRequstDTO =
                                      TopicRequstDTO(
                                          uid: memberID, carId: carId);
                                  await apiTopic.saveTopoic(topicRequstDTO);
                                  ///--------------------------------------------


                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      Nav.globalContext,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreen()));
                                } catch (error) {
                                  if (error is DeletedRoomException) {
                                    // 방 삭제 예외 처리
                                    showErrorDialog(context, error.message);
                                  } else if (error is MaxCapacityException) {
                                    // 인원 초과 예외 처원리
                                    showErrorDialog(context, error.message);
                                  } else {
                                    // 기타 예외 처리
                                    print('카풀 참가 실패 (다른 예외): $error');
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Container(
                                width: context.width(0.8),
                                alignment: Alignment.center,
                                child: const Text(
                                  '카풀 참가하기',
                                  style: TextStyle(
                                    fontSize: 15,
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
              top: context.height(0.01),
              left: 10,
              child: FloatingActionButton(
                heroTag: 'definite',
                backgroundColor: Colors.blue,
                mini: true,
                onPressed: () {
                  _moveCameraTo(widget.startPoint);
                },
                // 도착지점을 나타내는 아이콘
                child:
                    const Icon(Icons.location_on_outlined, color: Colors.white),
              ),
            ),
            Positioned(
              top: context.height(0.01),
              left: 60,
              child: FloatingActionButton(
                heroTag: 'start',
                backgroundColor: Colors.lightGreenAccent.shade700,
                mini: true,
                onPressed: () {
                  _moveCameraTo(widget.endPoint);
                },
                // 도착지점을 나타내는 아이콘
                child:
                    const Icon(Icons.location_on_outlined, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 카메라 이동 메서드
  void _moveCameraTo(LatLng target) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 15),
    ));
  }

  /// 페이지 로딩 완료 메서드
  void handlePageLoadComplete() {
    setState(() {
      isLoading = false; // 로딩이 완료되었음을 표시
    });
  }

  /// 에러 다이얼로그
  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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

  /// 현재 위치를 포함하는 LatLngBounds 객체를 반환하는 메서드 - 0914 한승완
  LatLngBounds getCurrentBounds(LatLng position1, LatLng position2) {
    LatLngBounds bounds;

    try {
      bounds = LatLngBounds(
        northeast: position1,
        southwest: position2,
      );
    } catch (_) {
      bounds = LatLngBounds(
        northeast: position2,
        southwest: position1,
      );
    }

    return bounds;
  }

  /// 이미지 크기 조정 메서드- 0915 한승완
  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }
}
