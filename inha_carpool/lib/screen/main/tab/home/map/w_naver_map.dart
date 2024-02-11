import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NaeverMap extends StatefulWidget {
  const NaeverMap(
      {super.key, required this.startPoint, required this.endPoint});

  final LatLng startPoint;
  final LatLng endPoint;

  @override
  State<NaeverMap> createState() => _greenMapState();
}

class _greenMapState extends State<NaeverMap> {
  late NaverMapController mapController;

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

    return NaverMap(
      options: NaverMapViewOptions(
        indoorEnable: true,
        locationButtonEnable: true,
        consumeSymbolTapEvents: false,
        initialCameraPosition: NCameraPosition(
          target: NLatLng(
              widget.startPoint.latitude, widget.startPoint.longitude),
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
    );
  }
}
