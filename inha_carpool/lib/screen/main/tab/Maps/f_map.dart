import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const GoogleMaps());

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({Key? key}) : super(key: key);

  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController mapController;

  // 주안역의 위치 좌표  // 이 값을 나중에 방의 좌표로 가져옴
  final LatLng _jooanStation = const LatLng(37.4645862, 126.6803935);

  LatLng? _currentPosition; // 현재 위치 좌표
  String? _currentAddress; // 현재 주소
  String? _distanceToJooan; // 현재 위치와 주안역 간 거리

  Set<Marker> _markers = {}; // 마커들 저장

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _addRedMarker(_jooanStation); // 빨간색 마커 추가
    _getCurrentLocation(); //위치 권한 및 현재 내 좌표 가져오기
  }

  // 빨간색 마커 추가하는 함수
  void _addRedMarker(LatLng position) {
    _markers.add(Marker(
      markerId: MarkerId('redMarker'),
      position: position,
      icon: BitmapDescriptor.defaultMarker, // 빨간색 마커 아이콘
    ));
  }

  // 현재 위치 가져오는 함수
  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);

      // 파란색 마커 추가
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // 파란색 마커 아이콘
      ));

      _getAddressFromLatLng(); // 좌표를 주소로 변환

      // 주안역과의 거리 계산
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _jooanStation.latitude,
        _jooanStation.longitude,
      );

      _distanceToJooan = (distanceInMeters / 1000).toStringAsFixed(2); // 거리를 킬로미터 단위로 변환
    });

    // 현재 위치로 카메라 이동
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 13.0),
    ));
  }

  // 좌표를 주소로 변환하는 함수
  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
        "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('000의 카풀 방')),
        body: Column(
          children: [
            // 지도 표시 부분
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 2,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _jooanStation, // 초기 지도 위치는 주안역
                  zoom: 13.0,
                ),
                markers: _markers,
              ),
            ),

            // 현재 주소 표시
            _currentAddress != null
                ? _currentAddress!.text.make()
                : SizedBox(),

            // 주안역까지 거리 표시
            _distanceToJooan != null
                ? "주안역까지 거리: $_distanceToJooan km".text.make()
                : SizedBox(),

            // 내 위치 버튼
            ElevatedButton(
              onPressed: () {
                _getCurrentLocation(); // 버튼을 누르면 현재 위치 가져와서 보여주기
              },
              child: Text('내 위치 새로고침'),
            ),
          ],
        ),
      ),
    );
  }
}
