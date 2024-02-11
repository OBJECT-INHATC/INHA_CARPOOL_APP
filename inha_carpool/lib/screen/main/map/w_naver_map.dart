import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/main/map/w_location_button.dart';
import 'package:inha_Carpool/screen/main/tab/home/enum/mapType.dart';

/// 초기 zoom 값은 직선거리를 기준으로 계산하여 설정함 변수 -> zoomLevel (0212 이상훈)
class NaeverMap extends StatefulWidget {
  const NaeverMap({
    Key? key,
    required this.startPoint,
    required this.endPoint,
    required this.mapCategory,
  }) : super(key: key);

  final LatLng startPoint;
  final LatLng endPoint;
  final MapCategory mapCategory;

  @override
  State<NaeverMap> createState() => _naeverMapState();
}

class _naeverMapState extends State<NaeverMap> {
  late NaverMapController mapController;

  // 지도 준비 여부
  bool isMapReady = false;

  // 중간 지점
  late NLatLng midPoint;

  // 직선거리
  late double zoomLevel;

  double calculateDistance(LatLng startPoint, LatLng endPoint) {
    const double earthRadius = 6371.0; // 지구 반지름 (킬로미터 단위)

    // 위도 및 경도를 라디안 단위로 변환
    double startLatRadians = degreesToRadians(startPoint.latitude);
    double startLngRadians = degreesToRadians(startPoint.longitude);
    double endLatRadians = degreesToRadians(endPoint.latitude);
    double endLngRadians = degreesToRadians(endPoint.longitude);

    // 위도 및 경도의 차이 계산
    double latDiff = endLatRadians - startLatRadians;
    double lngDiff = endLngRadians - startLngRadians;

    // Harvesine 공식을 사용하여 두 지점 간의 직선 거리 계산
    double distance = 2 *
        earthRadius *
        asin(sqrt(pow(sin(latDiff / 2), 2) +
            cos(startLatRadians) *
                cos(endLatRadians) *
                pow(sin(lngDiff / 2), 2)));

    //반올림
    distance = double.parse(distance.toStringAsFixed(2));

    /// zoomLevel 계산
    if (distance < 1) {
      return 13.5;
    } else if (distance >= 1 && distance <= 3) {
      // 주안역 <=> 인후
      return 13;
    } else if (distance > 3 && distance <= 5) {
      return 12.5;
    } else if (distance > 5 && distance <= 10) {
      return 12;
    } else if(distance > 11 && distance <= 20){
      // 김포에서 오는 직선거리 18키로 이거 잘 잡아주는데 더 멀리서 오는 미친놈은 고려할 필요가 없음
      return 10;
    } else {
      return 9;
    }
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// 중간 지점 계산 및 카메라 이동 -> todo : 지도 파일에 코드 넣기
  _moveCamera() {
    final double midLat =
        (widget.startPoint.latitude + widget.endPoint.latitude) / 2;
    final double midLng =
        (widget.startPoint.longitude + widget.endPoint.longitude) / 2;
    midPoint = NLatLng(midLat, midLng);

    zoomLevel = calculateDistance(widget.startPoint, widget.endPoint);

  }

  @override
  void initState() {
    _moveCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 네이버 마커 추가
    NMarker startMarker = NMarker(
      id: 'start',
      position:
          NLatLng(widget.startPoint.latitude, widget.startPoint.longitude),
    );

    /// todo : 마커 색 변경

    NMarker endMarker = NMarker(
      id: 'end',
      position: NLatLng(widget.endPoint.latitude, widget.endPoint.longitude),
    );

    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            indoorEnable: true,
            locationButtonEnable: true,
            consumeSymbolTapEvents: false,
            initialCameraPosition: NCameraPosition(
              target: midPoint,
              zoom: zoomLevel,
            ),
          ),
          onMapReady: (controller) async {
            mapController = controller;
            setState(() {
              isMapReady = true;
            });
            mapController.addOverlayAll(
              {startMarker, endMarker},
            );
          },
        ),

        if (isMapReady) ...[
          (widget.mapCategory == MapCategory.start)
              ? LocationButton(
                  point: widget.startPoint,
                  controller: mapController,
                  right: 0.02,
                  color: Colors.green,
                )
              : (widget.mapCategory == MapCategory.end)
                  ? LocationButton(
                      point: widget.endPoint,
                      controller: mapController,
                      right: 0.02,
                      color: Colors.blue,
                    )
                  : Stack(
                      children: [
                        LocationButton(
                          point: widget.startPoint,
                          controller: mapController,
                          right: 0.1,
                          color: Colors.green,
                        ),
                        LocationButton(
                          point: widget.endPoint,
                          controller: mapController,
                          right: 0.02,
                          color: Colors.blue,
                        ),
                      ],
                    ),
        ],

        // Positioned(child: PositionIcon(point: widget.startPoint, controller: mapController)),
      ],
    );
  }
}
