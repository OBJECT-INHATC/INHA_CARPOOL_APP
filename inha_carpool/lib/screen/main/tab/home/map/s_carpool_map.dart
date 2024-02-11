import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/provider/auth/auth_provider.dart';
import 'package:inha_Carpool/screen/main/tab/home/map/w_enter_button.dart';
import 'package:inha_Carpool/screen/main/tab/home/map/w_map_info.dart';
import 'package:inha_Carpool/screen/main/tab/home/map/w_naver_map.dart';
import 'package:inha_Carpool/service/api/Api_topic.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

import '../../../../../provider/ParticipatingCrpool/carpool_provider.dart';
import '../../../s_main.dart';
import '../../carpool/chat/s_chatroom.dart';
import '../enum/mapType.dart';
import 'w_location_button.dart';

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

  LatLng? midPoint;
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
        title: ((widget.admin
            ?.split("_")
            .length ?? 0) > 1
            ? '${widget.admin!.split("_")[1]}님의 카풀 정보'
            : '위치정보')
            .text
            .black
            .make(),
        toolbarHeight: 45,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: NaeverMap(
                  startPoint: widget.startPoint,
                  endPoint: widget.endPoint,
                  mapCategory: mapCategory,
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10),
                child: (mapCategory == MapCategory.all) ?
                Column(
                  children: [
                    MapInfo(
                      title: '출발 지점',
                      content: widget.startPointName,
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    MapInfo(
                      title: '도착 지점',
                      content: widget.endPointName,
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    MapInfo(
                      title: '출발 시간',
                      content: widget.startTime!,
                      icon: const Icon(
                        Icons.access_time,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    EnterButton(carId: widget.carId!,
                        roomGender: widget.roomGender!,
                        startPointName: widget.startPointName,
                        endPointName: widget.endPointName),


                  ],
                ) : Container(),
              ),

            ],
          ),


          /// ----------------------------------------------


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
                  '🚕 카풀 참가 중'.text
                      .size(20)
                      .white
                      .make(),
                ],
              ),
            ),
          )
              : Container(),
        ],
      ),
    );
  }


}
