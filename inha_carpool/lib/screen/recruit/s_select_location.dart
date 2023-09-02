import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/common.dart';

class LocationInput extends StatefulWidget {
  final LatLng Point;

  LocationInput(this.Point);

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  int flex = 50;
  bool isMove = false;

  // Google Maps API Key
  final String _apiKey = dotenv.env['GOOGLE_MAP_API_KEY']!;

  // Google Maps API Host
  final String _host = 'https://maps.googleapis.com/maps/api/geocode/json';

  // Google Maps Controller
  late GoogleMapController mapController;

  // 검색창 컨트롤러
  TextEditingController _searchController = TextEditingController();

  // 검색 결과를 저장할 리스트
  List<dynamic> list = [];

  // 검색한 주소의 좌표를 저장할 변수
  LatLng? searchedPosition;

  // 검색한 주소의 좌표를 저장할 변수
  bool firstStep = false;

  // 마커를 저장할 변수
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addMarker(widget.Point, "내 위치", "RedMarker",
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '위치 선택',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
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

                /// 검색 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    _LocationInfo(_searchController.text);
                  },
                  child: 'Search'.tr().text.white.make(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: flex,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  onMapCreated: (controller) => mapController = controller,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: widget.Point,
                    zoom: 16.0,
                  ),
                  markers: _markers,
                  onCameraIdle: () {
                    setState(() {
                      isMove = false;
                    });
                  },
                  onCameraMoveStarted: () {
                    isMove = true;
                  },
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appColors.blueMarker,
                            ),
                            onPressed: () => _moveCameraTo(widget.Point),
                            child: Text(
                              '내 위치로 이동',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      if (firstStep)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () => _moveCameraTo(searchedPosition!),
                          child: Text(
                            '검색 지역 이동',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 10,
          ),

          ///주소 Api
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final roadAddr = '${list[index]['roadAddr']}';
                return GestureDetector(
                  onTap: () {
                    _searchController.text = roadAddr;
                    _searchLocation(roadAddr);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        roadAddr,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 14);
              },
              itemCount: list.length,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.blue),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    Navigator.pop(context,
                        "${searchedPosition!.latitude}_${_searchController.text}_${searchedPosition!.longitude}");
                  },
                  child: Text(
                    '위치 선택 완료',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ).p(20),
          ),
        ],
      ),
    );
  }

  // 카메라를 이동시키는 메서드
  void _moveCameraTo(LatLng target) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 16.0),
    ));
  }

  // 좌표로 주소를 가져오는 메서드
  Future<void> _getGooglecoo(double lat, double lon) async {
    final uri = Uri.parse('$_host?key=$_apiKey&latlng=$lat,$lon&language=ko');

    http.Response response = await http.get(uri);
    final responseJson = json.decode(response.body);

    // 결과가 있으면 주소를 가져옵니다.
    if (responseJson['results'] != null && responseJson['results'].length > 0) {
      final addressComponents =
          responseJson['results'][0]['address_components'];

      // 컴포넌트가 역순으로 생성되기 때문에 그걸 역순으로 가져올 리스트
      List<String> reversedAddressComponents = [];

      // 국가와 인천시는 제외하고 가져오기
      // ex) 123-12 인하로 미추홀구 --> 미추홀구 인하로 123-12)
      for (var i = addressComponents.length - 1; i >= 0; i--) {
        var component = addressComponents[i];
        if (component['types'].contains('country') ||
            component['long_name'] == 'Incheon') {
          continue;
        }
        reversedAddressComponents.add(component['long_name']);
      }
      // 공백으로 연결
      String reversedFormattedAddress = reversedAddressComponents.join(' ');

      // 텍스트필드에 주소를 대입
      setState(() {
        _searchController.text = reversedFormattedAddress;
        searchedPosition = LatLng(lat, lon);
      });
    } else {
      print('No results found');
    }
  }

  // 주소로 좌표를 가져오는 메서드
  void _LocationInfo(String juso) async {
    String? josuUrl = dotenv.env['JUSO_API_KEY'];
    String query = juso;
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
          //   log(response.body);
          var json = jsonDecode(response.body);
          setState(() {
            list = json['results']['juso'];
            if (list.count() == 0) {
              ScffoldMsgAndListClear(context, "검색결과가 없습니다");
            }
            if (list.length == 1) {
              _searchLocation('${list[0]['roadAddr']}');
            } else if (list.length >= 1) {
              flex = 3;
            }
          });
        }).catchError((a, stackTrace) {
          log(a.toString()); // 로그찍기
        });
      } catch (e) {
        print("검색 중 오류 발생: $e");
        ScffoldMsgAndListClear(context, "상세 주소를 입력해 주세요");
      }
    } else {
      ScffoldMsgAndListClear(context, "주소를 입력해 주세요");
    }
  }

  //스낵바 알림 후 리스트 비우기
  void ScffoldMsgAndListClear(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$text')),
    );
    list.clear();
  }

  // 검색한 주소로 카메라를 이동시키는 메서드
  void _searchLocation(String query) async {
    if (query.isNotEmpty) {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        firstStep = true;
        Location location = locations.first;
        searchedPosition = LatLng(location.latitude, location.longitude);

        // 새로운 초록색 마커를 추가합니다.
        setState(() {
          _addMarker(
            searchedPosition!,
            query,
            "searchPosition",
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
        });
        _moveCameraTo(searchedPosition!);
      }
    }
  }

  //마커추가
  void _addMarker(
      LatLng point, String infoText, String markerName, BitmapDescriptor icon) {
    // 기존에 같은 MarkerId가 존재하는 마커를 제거합니다.
    _markers.removeWhere((marker) => marker.markerId.value == markerName);

    _markers.add(Marker(
      markerId: MarkerId(markerName),
      position: point,
      icon: icon,
      infoWindow: InfoWindow(title: infoText),
      draggable: true,
      onDragEnd: (LatLng newPoint) {
        setState(() {
          print("newPoint " + newPoint.toString());
          _addMarker(
            newPoint, // 업데이트된 좌표로 마커를 추가합니다.
            infoText, // 기존의 정보를 사용합니다.
            markerName, // 기존의 마커 이름을 사용합니다.
            icon, // 기존의 아이콘을 사용합니다.
          );
          _getGooglecoo(
              newPoint.latitude, newPoint.longitude); // 좌표로 주소를 가져옵니다.
        });
      },
    ));
  }
}
