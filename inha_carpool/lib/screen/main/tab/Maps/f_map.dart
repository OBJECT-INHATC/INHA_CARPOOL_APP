import 'package:app_settings/app_settings.dart';
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

  final LatLng _startingPoint = const LatLng(37.4645862, 126.6803935);

  LatLng? _currentPosition;
  String? _currentAddress;
  String? _distanceToLocation;

  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _addRedMarker(_startingPoint, "출발지");
    _getCurrentLocation();
  }

  void _addRedMarker(LatLng startPoint, String markerText) {
    _markers.add(Marker(
      markerId: MarkerId('redMarker'),
      position: startPoint,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: markerText),
    ));
  }

  _getCurrentLocation() async {
    // 위치 권한 요청
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // 위치 권한이 거부되었을 때 처리
      SnackBar snackBar = SnackBar(
        content: Text("위치 권한이 필요한 서비스입니다."),
        action: SnackBarAction(
          label: "설정으로 이동",
          onPressed: () {
            // 위치 권한 설정 화면으로 이동
            AppSettings.openAppSettings();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);

      // 내 위치 마커 추가
      _markers.add(Marker(
        markerId: const MarkerId('myCurrentLocation'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "내 위치"),
      ));

      _getAddressFromLatLng(); // 좌표를 주소로 변환

      // 출발지와의 거리 계산
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _startingPoint.latitude,
        _startingPoint.longitude,
      );

      _distanceToLocation = (distanceInMeters / 1000).toStringAsFixed(2); // 거리를 킬로미터 단위로 변환
    });

    // 현재 위치로 지도 시점 이동
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 16.0),
    ));
  }

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

  void _moveToMyLocation() {
    if (_currentPosition != null) {
      // 내 위치로 지도 시점 이동
      _getCurrentLocation();
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 16.0),
      ));
    }
  }

  void _moveToStartingPoint() {
    // 출발지로 지도 시점 이동
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _startingPoint, zoom: 16.0),
    ));
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
                  target: _startingPoint, // 초기 지도 위치는 주안역
                  zoom: 16.0,
                ),
                markers: _markers,
              ),
            ),

            // 현재 주소 표시
            _currentAddress != null
                ? _currentAddress!.text.make()
                : SizedBox(),

            // 출발지까지 거리 표시
            _distanceToLocation != null
                ? "출발지와의 거리: $_distanceToLocation km".text.make()
                : SizedBox(),

            // 내 위치로 이동 버튼
            ElevatedButton(
              onPressed: _moveToMyLocation,
              child: Text('내 위치로 이동'),
            ),

            // 출발지로 이동 버튼
            ElevatedButton(
              onPressed: _moveToStartingPoint,
              child: Text('출발지로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
