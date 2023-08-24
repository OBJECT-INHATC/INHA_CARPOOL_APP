import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';

class LocationInputPage extends StatefulWidget {
  final LatLng Point;

  LocationInputPage(this.Point);

  @override
  State<LocationInputPage> createState() => _LocationInputPageState();
}

class _LocationInputPageState extends State<LocationInputPage> {
  bool isMove = false;
  late GoogleMapController mapController;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> list = [];

  LatLng? searchedPosition;
  bool firstStep = false;
  String search = "검색";
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
        title: Text('위치 선택'),
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
                  backgroundColor: Colors.blue, ),
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
                            child: Text('내 위치로 이동'),
                          ),
                        ],
                      ),
                      if (firstStep)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () => _moveCameraTo(searchedPosition!),
                          child: Text('검색 지역 이동'),
                        ),
                    ],
                  ),

                ),
              ],
            ),
          ),

          SizedBox(height: 10,),
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


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // 원하는 높이와 너비 지정
                  minimumSize: Size(150, 50), // 너비와 높이를 변경하려면 이 부분을 조정하세요
                  // 추가로 버튼의 배경색 등의 스타일을 지정할 수 있습니다.
                  backgroundColor: Colors.blue, // 원하는 배경색으로 변경
                  // 필요한 다른 스타일을 지정할 수 있습니다.
                ),
                onPressed: () {
                  Navigator.pop(context,
                      "${searchedPosition!.latitude}_${_searchController.text}_${searchedPosition!.longitude}");
                },
                child: Text('위치 선택 완료'),
              ),
            ),
          ).p(30),
        ],
      ),
    );
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
            if (list.count() == 0) {
              ScffoldMsgAndListClear(context, "검색결과가 없습니다");
            }
            if (list.length == 1) {
              _searchLocation('${list[0]['roadAddr']}');
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
    ));
  }


}