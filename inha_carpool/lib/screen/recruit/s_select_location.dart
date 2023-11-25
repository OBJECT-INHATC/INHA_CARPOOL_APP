import 'dart:convert';
import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/common.dart';

/// 출-목적지의 위치 선택 페이지
class LocationInput extends StatefulWidget {
  final LatLng Point;


  const LocationInput(this.Point, {super.key});

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
  final TextEditingController _searchController = TextEditingController();

  // 검색 결과를 저장할 리스트
  List<dynamic> list = [];

  // 검색한 주소의 좌표를 저장할 변수
  LatLng? searchedPosition;

  // 검색한 주소의 좌표를 저장할 변수
  bool firstStep = false;

  // 마커를 저장할 변수
  final Set<Marker> _markers = {};

  // 위치 정보를 담는 변수
  String? _address;

  // 지정한 위치의 지명을 가져오는 메서드
  void selectNearLocation(String juso) async{
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
          var json = jsonDecode(response.body);
            // 리스트의 0번 값을 저장
            if(json['results']['juso'].length > 0) {
              setState(() {
                _searchLocation(json['results']['juso'][0]['roadAddr']);
                _address = json['results']['juso'][0]['roadAddr'];
              });
            }
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라와도 화면이 줄어들지 않음
      appBar: AppBar(
        // 앱바 타이틀 중앙에 배치
        centerTitle: true,
        title: const Text(
          '위치 선택',
          style: TextStyle(color: Colors.black,fontSize: 17, fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 45,
        // 해당 선을 내릴때만 나오게 해줘
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white
      ),
      body: Column(
        children: [
          Container(
            height: context.height(0.05),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      TextField(
                        onSubmitted: (value) {
                          selectNearLocation(value);
                        },
                      controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '장소 검색',
                          fillColor: Colors.grey[300], // 배경색 설정
                          filled: true, // 배경색을 활성화
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none, // 외곽선 없음
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          // 글씨의 위치를 가운데 정렬
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        ),
                      style: const TextStyle(color: Colors.black, fontSize: 11),
                    ),
                      Positioned(
                        // 텍스트필드에 맞춰서 위치 정렬
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed: () {
                            selectNearLocation(_searchController.text);
                          },
                          icon: const Icon(Icons.search),
                        ),
                      ),
                    ]
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Expanded(
            flex: flex,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 구글맵 중앙에 위치한 마커
                GoogleMap(
                  onMapCreated: (controller) => mapController = controller,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: widget.Point,
                    zoom: 17.0,
                  ),
                  // markers: _markers,
                  onCameraMove: (position) {
                      searchedPosition = position.target;
                  },
                  onCameraIdle: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    setState(() {
                      isMove = false;
                      if(searchedPosition != null){
                            _getGooglecoo(
                            searchedPosition!.latitude, searchedPosition!.longitude
                        );
                      }
                    });
                  },
                  onCameraMoveStarted: () {
                    isMove = true;
                  },
                ),
                Positioned(
                  // 지도의 왼쪽위에 본인의 위치로 이동하는 버튼
                  top: 10,
                  left: 10,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () async {
                      // 위치 권한 확인
                      LocationPermission permission =
                          await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied ||
                          permission == LocationPermission.deniedForever) {
                        _showLocationPermissionSnackBar();
                      } else {
                        // 현재 위치 가져오기
                        Position position =
                            await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high);
                        // 현재 위치로 카메라 이동
                        _moveCameraTo(LatLng(position.latitude, position.longitude));
                      }
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                Positioned(
                  // 해당 위젯을 스택 중간에 위치 시켜줘
                  top: MediaQuery.of(context).size.height / 3.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isMove)
                        GestureDetector(
                          onTap: () {
                            if (_address == null) {
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('주소를 입력해주세요.'),
                              ));
                              return; // 주소가 비어있으므로 메서드 종료
                            }
                            /// 입력된 주소가 위, 경도 값이 없을 경우 ( ex. '지하'를 포함한 주소 )
                            else if (searchedPosition == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('선택할 수 없는 주소 입니다.\n다른 주소를 선택해주세요.'),
                              ));
                              _searchController.clear(); // 검색창 비우기
                              return; // 주소에 대한 좌표가 없으므로 메서드 종료
                            }
                            /// 검색창에 선택된 주소가 위,경도 값이 있을 경우
                            else {
                              Navigator.pop(context,
                                  "${searchedPosition!.latitude}_${_address}_${searchedPosition!.longitude}");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(
                                      0, 5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '이 위치 선택',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _address ?? ' 화면을 이동해서 위치를 선택해주세요.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Icon(
                        Icons.location_on_sharp,
                        size: 44,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 카메라를 이동시키는 메서드
  void _moveCameraTo(LatLng target) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

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
      final addressComponents = responseJson['results'][0]['address_components'];

      // 국가 정보 확인
      String country = '';
      for (var component in addressComponents) {
        if (component['types'].contains('country')) {
          country = component['short_name'];
          break;
        }
      }

      // 대한민국이 아닌 경우 주소 설정
      if (country != 'KR') {
        ScffoldMsgAndListClear(context, "대한민국 내에서만 검색 가능합니다.");
        setState(() {
          _address = null;
          searchedPosition = null;
        });
      } else {
        // 우편번호와 국가, 인천시는 제외하고 가져오기
        List<String> reversedAddressComponents = [];
        for (var i = addressComponents.length - 1; i >= 0; i--) {
          var component = addressComponents[i];
          if (component['types'].contains('postal_code') ||
              component['types'].contains('country') ||
              component['long_name'] == 'Incheon') {
            continue;
          }
          reversedAddressComponents.add(component['long_name']);
        }

        // 공백으로 연결
        String reversedFormattedAddress = reversedAddressComponents.join(' ');

        // 텍스트필드에 주소를 대입
        setState(() {
          _address = reversedFormattedAddress;
          searchedPosition = LatLng(lat, lon);
        });
      }
    } else {
      print('No results found');
    }
  }



  //스낵바 알림 후 리스트 비우기
  void ScffoldMsgAndListClear(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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
        _moveCameraTo(searchedPosition!);
      }
    }
  }

  // 위치 권한이 없을 때 스낵바를 띄워주는 메서드
  void _showLocationPermissionSnackBar() {
    SnackBar snackBar = SnackBar(
      content: const Text("위치 권한이 필요한 서비스입니다."),
      action: SnackBarAction(
        label: "설정으로 이동",
        onPressed: () {
          AppSettings.openAppSettings();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}
