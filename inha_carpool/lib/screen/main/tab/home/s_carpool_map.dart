import 'dart:ui' as ui;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/service/api/Api_Topic.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

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
  final bool isPopUp;

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
    required this.isPopUp,
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

  bool joinButtonEnabled = true;
  bool isJoining = false;

  @override
  void initState() {
    super.initState();
    addCustomIcon();
    _moveCamera();
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
        // backgroundColor:
        //     isLoading ? Colors.black.withOpacity(0.3) : Colors.white,
        appBar: AppBar(
          titleTextStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          title: '${widget.admin.split("_")[1]}님의 카풀 정보'.text.black.make(),
          backgroundColor: isJoining ? Colors.black.withOpacity(0.5) : null,
          surfaceTintColor: Colors.white,
          toolbarHeight: 45,
          shape: isJoining
              ? null
              : Border(
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
                height: context.height(0.27),
                width: context.width(1),
                decoration: BoxDecoration(
                  //color: Colors.grey.shade100,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
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
                            widget.isPopUp
                                ? Container()
                                : ElevatedButton(
                                    onPressed: () async {
                                      String carId = widget.carId;
                                      String memberID = uid;
                                      String memberName = nickName;
                                      String selectedRoomGender =
                                          widget.roomGender;

                                      if (joinButtonEnabled) {
                                        joinButtonEnabled = false;

                                        if (gender != selectedRoomGender &&
                                            selectedRoomGender != '무관') {
                                          context.showErrorSnackbar(
                                              '입장할 수 없는 성별입니다.\n다른 카풀을 이용해주세요!');
                                          return;
                                        }
                                        try {
                                          setState(() {
                                            isJoining = true;
                                          });

                                          await FirebaseCarpool
                                              .addMemberToCarpool(
                                                  carId,
                                                  memberID,
                                                  memberName,
                                                  gender,
                                                  token!,
                                                  selectedRoomGender);
                                          if (!mounted) return;

                                          try {
                                            ///  해당 카풀 알림 토픽 추가 0919 이상훈
                                            if (Prefs.isPushOnRx.get() ==
                                                true) {
                                              /// 채팅 토픽
                                              await FirebaseMessaging.instance
                                                  .subscribeToTopic(carId);

                                              /// 카풀 정보 토픽 - 서버 저장 X
                                              await FirebaseMessaging.instance
                                                  .subscribeToTopic(
                                                      "${carId}_info");
                                            }
                                          } catch (e) {
                                            print("토픽 추가 실패가 아닌 버전 이슈~");
                                          }

                                          ApiTopic apiTopic = ApiTopic();
                                          TopicRequstDTO topicRequstDTO =
                                              TopicRequstDTO(
                                                  uid: memberID, carId: carId);
                                          bool isOpen = await apiTopic
                                              .saveTopoic(topicRequstDTO);

                                          ///--------------------------------------------
                                          if (isOpen) {
                                            print("스프링부트 서버 성공 #############");
                                            if (!mounted) return;
                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                                Nav.globalContext,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const MainScreen()));
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatroomPage(
                                                          carId: carId,
                                                          groupName: '카풀네임',
                                                          userName: nickName,
                                                          uid: uid,
                                                          gender: gender,
                                                        )));
                                          } else {
                                            print("스프링부트 서버 실패 #############");
                                            await FireStoreService()
                                                .exitCarpool(carId, nickName,
                                                    uid, gender);
                                            if (Prefs.isPushOnRx.get() ==
                                                true) {
                                              await FirebaseMessaging.instance
                                                  .unsubscribeFromTopic(carId);
                                              await FirebaseMessaging.instance
                                                  .unsubscribeFromTopic(
                                                      "${carId}_info");
                                            }
                                            if (!mounted) return;
                                            Navigator.pop(context);
                                            showErrorDialog(context,
                                                '서버가 비정상 작동중입니다.\n잠시 후 다시 시도해주세요.');
                                          }
                                        } catch (error) {
                                          if (error is DeletedRoomException) {
                                            // 방 삭제 예외 처리
                                            showErrorDialog(
                                                context, error.message);
                                          } else if (error
                                              is MaxCapacityException) {
                                            // 인원 초과 예외 처원리
                                            showErrorDialog(
                                                context, error.message);
                                          } else {
                                            // 기타 예외 처리
                                            print('카풀 참가 실패 (다른 예외): $error');
                                          }
                                        }
                                        setState(() {
                                          joinButtonEnabled = true;
                                        });
                                      } else {
                                        context.showErrorSnackbar(
                                            '참가 중입니다. 잠시만 기다려주세요.');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      surfaceTintColor: Colors.transparent,
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
                                        '입장하기',
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
            isJoining
                ? Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SpinKitThreeBounce(
                            color: Colors.white,
                            size: 25.0,
                          ),
                          const SizedBox(height: 16),
                          '🚕 카풀 참가 중'.text.size(20).white.make(),
                        ],
                      ),
                    ),
                  )
                : Container(),
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
          surfaceTintColor: Colors.transparent,
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
