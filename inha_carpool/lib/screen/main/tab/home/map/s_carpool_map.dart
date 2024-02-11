import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/provider/auth/auth_provider.dart';
import 'package:inha_Carpool/screen/main/tab/home/map/w_map_info.dart';
import 'package:inha_Carpool/screen/main/tab/home/map/w_naver_map.dart';
import 'package:inha_Carpool/service/api/Api_topic.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

import '../../../../../common/data/preference/prefs.dart';
import '../../../../../common/models/m_carpool.dart';
import '../../../../../common/util/carpool.dart';
import '../../../../../common/util/addMember_Exception.dart';
import '../../../../../dto/TopicDTO.dart';
import '../../../../../provider/ParticipatingCrpool/carpool_provider.dart';
import '../../../s_main.dart';
import '../../carpool/chat/s_chatroom.dart';
import '../enum/mapType.dart';

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
  final MapCategory mapType;

  // 출발지, 도착지, 전체지도 구분
  final String? mapTypeTemp;

  const CarpoolMap({
    super.key,
    required this.startPoint,
    required this.mapType,
    required this.startPointName,
    required this.endPoint,
    required this.endPointName,
    this.startTime,
    this.carId,
    this.admin,
    this.roomGender,
    this.isPopUp,
    this.mapTypeTemp,
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

    MapCategory mapCategory = widget.mapType;

    if (mapCategory == MapCategory.start) {
      markers['start'] = startMarker;
    } else if (mapCategory == MapCategory.end) {
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
        title: ((widget.admin?.split("_").length ?? 0) > 1
                ? '${widget.admin!.split("_")[1]}님의 카풀 정보'
                : '위치정보')
            .text
            .black
            .make(),
      ),
      body: Stack(
        children: [
          NaeverMap(
            startPoint: widget.startPoint,
            endPoint: widget.endPoint,
          ),
          Positioned(
            bottom: context.height(0),
            // 가운데 위치
            child: Container(
              height: mapCategory == MapCategory.all
                  ? (widget.isPopUp!
                      ? context.height(0.2)
                      : context.height(0.27)) // 'all'일 때 isPop에 따라 높이 변경
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
                child:
                mapCategory == MapCategory.all
                    ? Column(
                        children: [
                          MapInfo(
                              title: '출발 지점',
                              content: widget.startPointName,
                              icon: const Icon(Icons.location_on,
                                  color: Colors.blue, size: 20)),
                          MapInfo(
                              title: '도착 지점',
                              content: widget.endPointName,
                              icon: const Icon(Icons.location_on,
                                  color: Colors.green, size: 20)),
                          MapInfo(
                              title: '출발 시간',
                              content: widget.startTime!,
                              icon: const Icon(Icons.access_time,
                                  color: Colors.blue, size: 20)),
                        ],
                      )
                    :    MapInfo(
                    title: '출발 시간',
                    content: widget.startTime!,
                    icon: const Icon(Icons.access_time,
                        color: Colors.blue, size: 20)),

              ),
            ),
          ),
          widget.mapType == 'false'
              ? Container()
              : Positioned(
                  bottom: widget.mapType == 'default'
                      ? (widget.isPopUp!
                          ? context.height(0.22)
                          : context
                              .height(0.29)) // 'default'일 때 isPop에 따라 높이 변경
                      : context.height(0.14), // 'default'가 아닐 때 높이
                  right: widget.mapType == 'default' ? 65 : 15,
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
          widget.mapType == 'true'
              ? Container()
              : Positioned(
                  bottom: widget.mapType == 'default'
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
                      _moveCameraTo(NLatLng(
                          widget.endPoint.latitude, widget.endPoint.longitude));
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
