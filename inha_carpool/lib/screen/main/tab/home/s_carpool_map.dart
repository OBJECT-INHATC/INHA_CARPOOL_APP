import 'dart:ui' as ui;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/provider/auth/auth_provider.dart';
import 'package:inha_Carpool/service/api/Api_topic.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

import '../../../../common/data/preference/prefs.dart';
import '../../../../common/models/m_carpool.dart';
import '../../../../common/util/carpool.dart';
import '../../../../common/util/addMember_Exception.dart';
import '../../../../dto/TopicDTO.dart';
import '../../../../provider/ParticipatingCrpool/carpool_provider.dart';
import '../../s_main.dart';
import '../carpool/chat/s_chatroom.dart';

class CarpoolMap extends ConsumerStatefulWidget {
  final LatLng startPoint;
  final String startPointName;
  final LatLng endPoint;
  final String endPointName;
  final String? startTime;
  final String? carId;
  final String? admin;
  final String? roomGender;
  final bool? isPopUp;
  final String? isStart;

  const CarpoolMap({
    super.key,
    required this.startPoint,
    required this.startPointName,
    required this.endPoint,
    required this.endPointName,
    this.startTime,
    this.carId,
    this.admin,
    this.roomGender,
    this.isPopUp,
    this.isStart,
  });

  @override
  ConsumerState<CarpoolMap> createState() => _CarpoolMapState();
}

class _CarpoolMapState extends ConsumerState<CarpoolMap> {
  late NaverMapController mapController;

  LatLng? midPoint;

  bool joinButtonEnabled = true;
  bool isJoining = false;

  @override
  void initState() {
    super.initState();
    _moveCamera();
  }


  /// 중간 지점 계산 및 카메라 이동
  _moveCamera() async {
    final double midLat =
        (widget.startPoint.latitude + widget.endPoint.latitude) / 2;
    final double midLng =
        (widget.startPoint.longitude + widget.endPoint.longitude) / 2;
    midPoint = LatLng(midLat, midLng);
    // 뒤로가기 제한 해제
  }

  @override
  Widget build(BuildContext context) {

    final carpoolProvider = ref.watch(carpoolNotifierProvider.notifier);

    final String nickName = ref.read(authProvider).nickName!;
    final String uid = ref.read(authProvider).uid!;
    final String gender = ref.read(authProvider).gender!;

    // 네이버 마커 추가
    NMarker startMarker = NMarker(
      id: 'start',
      position:
          NLatLng(widget.startPoint.latitude, widget.startPoint.longitude),
    );

    NMarker endMarker = NMarker(
      id: 'end',
      position: NLatLng(widget.endPoint.latitude, widget.endPoint.longitude),
    );
    Map<String, NMarker> markers = {};

    String isStart = widget.isStart ?? 'default';
    if (isStart == 'true') {
      markers['start'] = startMarker;
    } else if (isStart == 'false') {
      markers['end'] = endMarker;
    } else {
      markers['start'] = startMarker;
      markers['end'] = endMarker;
    }

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        title: ((widget.admin?.split("_").length ?? 0) > 1
                ? '${widget.admin!.split("_")[1]}님의 카풀 정보'
                : '위치정보')
            .text
            .black
            .make(),
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
            padding: widget.isStart == 'default'
                ? (widget.isPopUp!
                    ? EdgeInsets.only(bottom: context.height(0.2))
                    : EdgeInsets.only(bottom: context.height(0.27)))
                : EdgeInsets.only(bottom: context.height(0.1)),
            child: NaverMap(
              options: NaverMapViewOptions(
                indoorEnable: true,
                locationButtonEnable: true,
                consumeSymbolTapEvents: false,
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(widget.startPoint.latitude,
                      widget.startPoint.longitude),
                  zoom: 15,
                ),
                logoClickEnable: false,
              ),
              onMapReady: (controller) async {
                mapController = controller;
                mapController.addOverlayAll(
                  {startMarker, endMarker},
                );

              },
            ),


          ),
          Positioned(
            bottom: context.height(0),
            // 가운데 위치
            child: Container(
              height: widget.isStart == 'default'
                  ? (widget.isPopUp!
                      ? context.height(0.2)
                      : context.height(0.27)) // 'default'일 때 isPop에 따라 높이 변경
                  : context.height(0.1), // 'default'가 아닐 때 높이
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              widget.isStart == 'false'
                                  ? Container()
                                  : Container(
                                      padding: const EdgeInsets.all(5),
                                      child: widget.isStart == 'default'
                                          ? Row(
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
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 3,
                                                        horizontal: 8),
                                                    // 내부 패딩
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[
                                                          300], // 회색 배경색
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20), // 동그란 모양 설정
                                                    ),
                                                    child: Text(
                                                      widget.startPointName,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .black, // 텍스트 색상
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.blue,
                                                  size: 28,
                                                ),
                                                const SizedBox(width: 3),
                                                const Text(
                                                  "출발 지점",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 3,
                                                        horizontal: 8),
                                                    // 내부 패딩
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[
                                                          300], // 회색 배경색
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20), // 동그란 모양 설정
                                                    ),
                                                    child: Text(
                                                      widget.startPointName,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .black, // 텍스트 색상
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                              widget.isStart == 'true'
                                  ? Container()
                                  : Container(
                                      padding: const EdgeInsets.all(5),
                                      child: widget.isStart == 'default'
                                          ? Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.location_on,
                                                    color: Colors
                                                        .lightGreenAccent),
                                                const SizedBox(width: 3),
                                                const Text(
                                                  "도착 지점",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 3,
                                                        horizontal: 8),
                                                    // 내부 패딩
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[
                                                          300], // 회색 배경색
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20), // 동그란 모양 설정
                                                    ),
                                                    child: Text(
                                                      widget.endPointName,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .black, // 텍스트 색상
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.location_on,
                                                    color: Colors
                                                        .lightGreenAccent),
                                                const SizedBox(width: 3),
                                                const Text(
                                                  "도착 지점",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 3,
                                                        horizontal: 8),
                                                    // 내부 패딩
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[
                                                          300], // 회색 배경색
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20), // 동그란 모양 설정
                                                    ),
                                                    child: Text(
                                                      widget.endPointName,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .black, // 텍스트 색상
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                              widget.startTime == null
                                  ? Container()
                                  : Container(
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
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3,
                                                      horizontal: 8),
                                              // 내부 패딩
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .grey[300], // 회색 배경색
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20), // 동그란 모양 설정
                                              ),
                                              child: Text(
                                                widget.startTime ?? '',
                                                // startTime이 null인 경우 'default'를 사용
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      Colors.black, // 텍스트 색상
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
                          widget.isPopUp ?? false
                              ? Container()
                              : ElevatedButton(
                                  onPressed: () async {
                                    String carId = widget.carId ?? 'default';
                                    String memberID = uid;
                                    String memberName = nickName;
                                    String selectedRoomGender =
                                        widget.roomGender ?? 'default';

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

                                        /// 카풀 참가
                                        await FirebaseCarpool
                                            .addMemberToCarpool(
                                                carId,
                                                memberID,
                                                memberName,
                                                gender,
                                                selectedRoomGender);
                                        if (!mounted) return;

                                        try {
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

                                        if (isOpen) {
                                          print("스프링부트 서버 성공 #############");
                                          carpoolProvider.addCarpool(CarpoolModel(
                                            /// 디테일 주소 수정 필요 0207
                                              carId: carId,
                                              endDetailPoint: widget.endPointName,
                                              endPointName: widget.endPointName,
                                              startPointName: widget.startPointName,
                                              startDetailPoint: widget.startPointName,
                                              startTime: 0,
                                              recentMessageSender: "service",
                                              recentMessage: "$nickName님이 입장하였습니다."
                                          ));
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
                                              '서버에 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.');
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
          widget.isStart == 'false'
              ? Container()
              : Positioned(
                  bottom: widget.isStart == 'default'
                      ? (widget.isPopUp!
                          ? context.height(0.22)
                          : context
                              .height(0.29)) // 'default'일 때 isPop에 따라 높이 변경
                      : context.height(0.14), // 'default'가 아닐 때 높이
                  right: widget.isStart == 'default' ? 65 : 15,
                  child: FloatingActionButton(
                    heroTag: 'definite',
                    backgroundColor: Colors.blue,
                    mini: true,
                    onPressed: () {
                      _moveCameraTo(NLatLng(widget.startPoint.latitude,
                          widget.startPoint.longitude));
                    },
                    // 도착지점을 나타내는 아이콘
                    child: const Icon(Icons.location_on_outlined,
                        color: Colors.white),
                  ),
                ),
          widget.isStart == 'true'
              ? Container()
              : Positioned(
                  bottom: widget.isStart == 'default'
                      ? (widget.isPopUp!
                          ? context.height(0.22)
                          : context
                              .height(0.29)) // 'default'일 때 isPop에 따라 높이 변경
                      : context.height(0.14), // 'default'가 아닐 때 높이
                  right: 15,
                  child: FloatingActionButton(
                    heroTag: 'start',
                    backgroundColor: Colors.lightGreenAccent.shade700,
                    mini: true,
                    onPressed: () {
                      _moveCameraTo(NLatLng(widget.endPoint.latitude,
                          widget.endPoint.longitude));
                    },
                    // 도착지점을 나타내는 아이콘
                    child: const Icon(Icons.location_on_outlined,
                        color: Colors.white),
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
    );
  }

  /// 카메라 이동 메서드
  void _moveCameraTo(NLatLng target) {
    mapController.updateCamera(NCameraUpdate.fromCameraPosition(
      NCameraPosition(
        target: target,
        zoom: 15,
      ),
    ));
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
}
