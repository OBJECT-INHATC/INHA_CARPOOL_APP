import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key, required this.point, required this.controller, required this.right, required this.color});

  final NaverMapController controller;
  final double right;
  final Color color;

  final LatLng point;

  @override
  Widget build(BuildContext context) {

    final height = context.screenHeight;

    return Positioned(
      bottom: height * 0.03,
      right : height * right,
      child: FloatingActionButton(
        heroTag: point.toString(),
        backgroundColor: color,
        mini: true,
        onPressed: () {
          _moveCameraTo(NLatLng(point.latitude,
              point.longitude));
        },
        // 도착지점을 나타내는 아이콘
        child: const Icon(Icons.location_on_outlined,
            color: Colors.white),
      ),
    );
  }

  /// 카메라 이동 메서드
  void _moveCameraTo(NLatLng target) {
    controller.updateCamera(NCameraUpdate.fromCameraPosition(
      NCameraPosition(
        target: target,
        zoom: 15,
      ),
    ));
  }
}
