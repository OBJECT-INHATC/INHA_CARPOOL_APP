
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/main/map/w_enter_button.dart';
import 'package:inha_Carpool/screen/main/map/w_map_info.dart';
import 'package:inha_Carpool/screen/main/map/w_naver_map.dart';

import '../tab/home/enum/mapType.dart';


class CarpoolMap extends ConsumerStatefulWidget {
  final LatLng startPoint;
  final String startPointName;
  final LatLng endPoint;
  final String endPointName;
  final String? startTime;
  final String? carId;
  final String? admin;
  final String? roomGender;
  final bool isMember;
  final MapCategory mapType;


  const CarpoolMap({
    super.key,
    required this.startPoint,
    required this.mapType,
    required this.startPointName,
    required this.endPoint,
    required this.endPointName,
    required this.isMember,
    this.startTime,
    this.carId,
    this.admin,
    this.roomGender,
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

  /// 중간 지점 계산 및 카메라 이동 -> todo : 지도 파일에 코드 넣기
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
    MapCategory mapCategory = widget.mapType;

    /// 새로고침을 위한 상태변수
    final enterState = ref.watch(enterProvider);

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
                child: (mapCategory == MapCategory.all)
                    ? Column(
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
                          !(widget.isMember) ?
                          EnterButton(
                              carId: widget.carId!,
                              roomGender: widget.roomGender!,
                              startPointName: widget.startPointName,
                              endPointName: widget.endPointName) :
                              const SizedBox(),
                        ],

                        /// todo : 카테고리가 All이 아닐때 처리 하기
                      )
                    : (mapCategory == MapCategory.start) ?
                MapInfo(
                  title: '출발 지점',
                  content: widget.startPointName,
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 20,
                  ),
                ) :  MapInfo(
                  title: '도착 지점',
                  content: widget.endPointName,
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
    enterState
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
}
