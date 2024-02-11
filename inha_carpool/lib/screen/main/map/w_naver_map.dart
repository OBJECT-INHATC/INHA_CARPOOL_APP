import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/screen/main/map/w_location_button.dart';
import 'package:inha_Carpool/screen/main/tab/home/enum/mapType.dart';

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

  bool isMapReady = false;

  @override
  Widget build(BuildContext context) {
    print("mapCategory : ${widget.mapCategory}");
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

    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            indoorEnable: true,
            locationButtonEnable: true,
            consumeSymbolTapEvents: false,
            initialCameraPosition: NCameraPosition(
              target: NLatLng(
                  widget.startPoint.latitude, widget.startPoint.longitude),
              zoom: 15,
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
