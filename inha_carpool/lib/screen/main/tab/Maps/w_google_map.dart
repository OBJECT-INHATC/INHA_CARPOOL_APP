import 'dart:convert';
import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GoogleMapsWidget extends StatefulWidget {
  const GoogleMapsWidget({Key? key}) : super(key: key);

  @override
  _GoogleMapsWidgetState createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  late GoogleMapController mapController;
  TextEditingController _searchController = TextEditingController();

  List<dynamic> list = [];

  final LatLng _startingPoint = const LatLng(37.4645862, 126.6803935);

  LatLng? _currentPosition;
  LatLng? searchedPosition;
  String? _currentAddress;
  String? _distanceToLocation;
  bool firstStep = false;
  String search = "검색";
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addMarker(
        _startingPoint, "출발지", "RedMarker", BitmapDescriptor.defaultMarker);
    _getCurrentLocation();
  }



  //현재 기기 위치 정보 가져오기 및 권한
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showLocationPermissionSnackBar();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _addMarker(_currentPosition!, "내 위치", "BlueMarker",
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));
      _getAddressFromLatLng();

      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _startingPoint.latitude,
        _startingPoint.longitude,
      );

      _distanceToLocation = (distanceInMeters / 1000).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '장소 검색',
                  ),
                ),
              ),
              const SizedBox(width: 5), // 오른쪽 여백
              ElevatedButton(
                onPressed: () {
                  _LocationInfo();
                },

                child: 'Search'.tr().text.make(),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                onMapCreated: (controller) => mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: _startingPoint,
                  zoom: 16.0,
                ),
                markers: _markers,
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () => _moveCameraTo(_currentPosition!),
                          child: Text('내 위치로 이동'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => _moveCameraTo(_startingPoint),
                          child: Text('출발지로 이동'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 180,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (firstStep)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () => _moveCameraTo(searchedPosition!),
                            child: Text('검색 지역'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              final roadAddr = '${list[index]['roadAddr']}';
              return GestureDetector(
                onTap: () {
                  _searchController.text = roadAddr;
                  _searchLocation(roadAddr);
                },
                child: roadAddr.text.size(14).make(),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: list.length,
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1), // 테두리 설정
            borderRadius: BorderRadius.circular(10), // 테두리의 모서리를 둥글게
            color: Colors.white, // 배경색
          ),
          margin: EdgeInsets.only(bottom: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _currentAddress != null
                  ? _currentAddress!.text.make()
                  : SizedBox(),
              _distanceToLocation != null
                  ? "출발지와의 거리: $_distanceToLocation km".text.make()
                  : SizedBox(),
              "현재인원 2/4명".text.make(),
            ],
          ),
        ),
      ],
    );
  }

  void _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "출발지 주소: ${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  void _showLocationPermissionSnackBar() {
    SnackBar snackBar = SnackBar(
      content: Text("위치 권한이 필요한 서비스입니다."),
      action: SnackBarAction(
        label: "설정으로 이동",
        onPressed: () {
          AppSettings.openAppSettings();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _moveCameraTo(LatLng target) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 16.0),
    ));
  }

  void _LocationInfo() async {
    String? josuUrl = dotenv.env['JUSO_API_KEY'];
    String query = _searchController.text;
    if (query.isNotEmpty) {
      try {
        Map<String, String> params = {
          'confmKey': josuUrl!,
          'keyword': query,
          'resultType': 'json',
        };
        http.post(
          Uri.parse('https://business.juso.go.kr/addrlink/addrLinkApi.do'),
          body: params,
          headers: {
            'content-type': 'application/x-www-form-urlencoded',
          },
        ).then((response) {
          log(response.body);
          var json = jsonDecode(response.body);
          setState(() {
            list = json['results']['juso'];
            if (list.length == 1) {
              _searchLocation('${list[0]['roadAddr']}');
            }
          });
        }).catchError((a, stackTrace) {
          log(a.toString()); // 로그찍기
        });
      } catch (e) {
        print("검색 중 오류 발생: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상세 주소를 입력해 주세요.')),
        );
        list.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소를 입력해 주세요.')),
      );
      list.clear();
    }
  }

  void _searchLocation(String query) async {
    if (query.isNotEmpty) {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        firstStep = true;
        Location location = locations.first;
        searchedPosition = LatLng(location.latitude!, location.longitude!);
        setState(() {
          _addMarker(
            searchedPosition!,
            query,
            query,
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          );
        });

        _moveCameraTo(searchedPosition!);
      }
    }
    return;
  }

  void _addMarker(
      LatLng point, String infoText, String markerName, BitmapDescriptor icon) {
    _markers.add(Marker(
      markerId: MarkerId(markerName),
      position: point,
      icon: icon,
      infoWindow: InfoWindow(title: infoText),
    ));
  }
}
