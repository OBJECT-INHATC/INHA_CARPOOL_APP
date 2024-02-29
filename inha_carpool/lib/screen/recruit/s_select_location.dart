import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/provider/stateProvider/jusogiban_api_provider.dart';

/// 출-목적지의 위치 선택 페이지
/// todo : 검색 하단 굉장히 조잡함.. 리팩토링 필수 (2028.02.28)
class LocationInput extends ConsumerStatefulWidget {
  final LatLng point;

  const LocationInput(this.point, {super.key});

  @override
  ConsumerState<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends ConsumerState<LocationInput> {
  int flex = 50;

  // 네이버 지도 API 호출을 위한 URL
  final String _naverHost =
      'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc';

  // 네이버 지도 컨트롤러
  late NaverMapController mapController;

  // 검색창 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  // 검색한 주소의 좌표를 저장할 변수
  LatLng? searchedPosition;

  // 실제 주소 정보를 저장할 변수
  String? _address;

  String infoText = '지도를 스크롤하여 위치를 선택할 수 있습니다.';

  // 주소 검색 결과를 저장할 리스트
  final List<String> _addressList = [];

  // 카메라 이동 여부를 저장할 변수
  bool isMove = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final height = context.screenHeight;
    final width = context.screenWidth;

    return Scaffold(
      resizeToAvoidBottomInset: (_addressList.isEmpty) ? true : false,
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            '위치 선택',
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          toolbarHeight: 45,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white),
      body: Column(
        children: [
          /// 검색창
          Container(
            height: height * 0.05,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              /// 여긴 갤ㄹㄹ럭시로 테스트
              onSubmitted: (value) async {
                await selectNearLocation(value);
              },
              controller: _searchController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () async {
                    await selectNearLocation(_searchController.text);
                  },
                  icon: const Icon(Icons.search),
                ),
                hintText: '장소 검색',
                fillColor: Colors.grey[300],
                // 배경색 설정
                filled: true,
                // 배경색을 활성화
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none, // 외곽선 없음
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                // 글씨의 위치를 가운데 정렬
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 11),
            ),
          ),

          /// 지도
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 네이버 지도
                NaverMap(
                  options: NaverMapViewOptions(
                    //실내지도가 표시
                    indoorEnable: true,
                    // 위치 버튼 표시
                    locationButtonEnable: true,

                    /// info : 네이버 로고 클릭했을 때 정보 뜨게해주는거 false 하면 정책 위반임
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(
                          widget.point.latitude, widget.point.longitude),
                      zoom: 15.5,
                    ),
                  ),
                  onMapReady: (controller) async {
                    mapController = controller;
                  },

                  /// 카메라가 이동할 때
                  onCameraChange: (reason, animated) {
                    if (animated) {
                      mapController.getCameraPosition().then((cameraPosition) {
                        setState(() {
                          isMove = true;
                          // 카메라가 이동하면서 좌표를 저장
                          searchedPosition = LatLng(
                              cameraPosition.target.latitude,
                              cameraPosition.target.longitude);
                        });
                      });
                    }
                  },

                  /// 카메라가 멈췄을 때
                  onCameraIdle: () {
                    //    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    setState(() {
                      // 카메라가 멈추면서 저장된 좌표로 주소를 가져옴
                      if (isMove == true && searchedPosition != null) {
                        _getAddressByPosition(searchedPosition!.latitude,
                            searchedPosition!.longitude);
                      }
                      isMove = false;
                    });
                  },
                ),
                Positioned(
                  // 해당 위젯을 스택 중간에 위치 시켜줘
                  top: height / 4,
                  child: Column(
                    children: [
                      /// 주소 설정 버튼 (선택한 주소를 반환)
                      GestureDetector(
                        onTap: () {
                          print('위치 선택 버튼 클릭 _address : $_address');

                          /// 주소가 없는 경우
                          if (_address == null) {
                            setState(() {
                              infoText = '선택된 주소가 없습니다.';
                            });

                            return; // 주소가 비어있으므로 메서드 종료
                          }

                          /// 입력된 주소가 위, 경도 값이 없을 경우 ( ex. '지하'를 포함한 주소 )
                          else if (searchedPosition == null) {
                            setState(() {
                              _addressList.clear();
                              infoText = '선택할 수 없는 주소 입니다.\n다른 주소를 선택해주세요.';
                            });

                            _searchController.clear(); // 검색창 비우기
                            return; // 주소에 대한 좌표가 없으므로 메서드 종료
                          }

                          /// 검색창에 선택된 주소가 위,경도 값이 있을 경우
                          else {
                            Navigator.pop(context,
                                "${searchedPosition!.latitude}_${_address}_${searchedPosition!.longitude}");
                          }
                        },

                        ///가운대 좌표 컨테이너
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
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '이 위치 선택',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.grey[500],
                                    size: 17,
                                  ),
                                ],
                              ),
                              Text(
                                _address ?? ' 화면을 이동해서 주소가 나오면 위치를 선택해주세요.',
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

          /// 검색 결과 리스트
          const Line(),
          Container(
            height: _addressList.isNotEmpty ? height * 0.4 : height * 0.1,
            decoration: const BoxDecoration(
              color: Colors.white, // 원하는 색상 설정
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15.0)), // 원하는 모양 설정
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: (_addressList.isNotEmpty)
                ? Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _addressList.clear();
                          infoText = '지도를 스크롤하여 위치를 선택할 수 있습니다.';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors
                            .logoColor, // Set your desired color here
                      ),
                      child: Text(
                        '리스트 내리기',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: _addressList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: width * 0.7,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: RichText(
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    text: TextSpan(
                                                      text: _addressList[index],
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        height: height * 0.0017,
                                                        fontSize: height * 0.018,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _searchController.text = _addressList[index];
                                          setState(() {
                                            _searchLocation(
                                                _addressList[index].split(',')[0]);
                                            _address = _addressList[index];
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: context.appColors
                                              .logoColor, // Set your desired color here
                                        ),
                                        child: Text(
                                          '선택',
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            /*      const Line(
                                    color: Colors.grey,
                                  ),*/
                                ],
                              ),
                            );
                          },
                        ),
                    ),
                  ],
                )
                : Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: width * 0.07,
                        ),
                        Text(
                          infoText,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 지정한 위치의 지명을 가져오는 메서드 (검색기능)
  Future<void> selectNearLocation(String juso) async {
    juso = juso.trim();

    print("-=-------------------------------------");
    print("selectNearLocation 실행 juso : $juso");
    print("-=-------------------------------------");

    if (_searchController.text.length < 2 || juso.isEmpty) {
      print('2글자 이상 입력해주세요.');
      setState(() {
        infoText = '2글자 이상 입력해주세요.';
        _addressList.clear();
      });
      // context.showSnackbarText(context, '2글자 이상 입력해주세요.');

      return;
    }

    String? josuUrl = ref.read(jusoKeyProvider);
    String query = juso;
    if (query.isNotEmpty) {
      try {
        Map<String, String> params = {
          'confmKey': josuUrl!,
          'keyword': query,
          'resultType': 'json',
        };
        await http.post(
          Uri.parse('https://business.juso.go.kr/addrlink/addrLinkApi.do'),
          body: params,
          headers: {
            'content-type': 'application/x-www-form-urlencoded',
          },
        ).then((response) {
          var json = jsonDecode(response.body);
          print('주소 json : $json');
          if (json['results']['juso'].length > 0) {
            for (var juso in json['results']['juso']) {
              var address = juso['roadAddr'];
              var bdNm = juso['bdNm'];
              var tempAddress = '$address, $bdNm';
              print(address); // 추가: 주소 출력

              // address 뒤에 빌딩이름을 추가적으로 더한 것을 tempAddress에 저장 후 리스트에 추가 및 표시
              _addressList.add(tempAddress);
            }
            setState(() {}); // _addressList 상태 업데이트
          } else {
            infoText = '검색 결과가 없습니다.';
          }

          setState(() {});
        }).catchError((a, stackTrace) {
          log(a.toString()); // 로그찍기
          setState(() {
            _addressList.clear();
            infoText = '검색 결과가 없거나 상세 주소가 필요합니다.';
          });
          print('&& 주소 검색 오류 : $a'); // 에러 출력
        });
      } catch (e) {
        print("검색 중 오류 발생: $e");
        setState(() {
          _addressList.clear();
          infoText = '검색 결과가 없습니다.';
        });
      }
    } else {
      setState(() {
        _addressList.clear();
        infoText = '주소를 입력해 주세요.';
      });
    }
  }

  /// 좌표로 주소를 가져오는 메서드
  Future<void> _getAddressByPosition(double lat, double lon) async {
    String? naverClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    String? naverClientSecret = dotenv.env['NAVER_MAP_CLIENT_SECRET'];

    String? uri =
        '$_naverHost?&coords=$lon,$lat&orders=admcode,legalcode,addr,roadaddr&output=json';

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': naverClientId!,
        'X-NCP-APIGW-API-KEY': naverClientSecret!,
      },
    );
    final responseJson = json.decode(response.body);
    print(responseJson);

    // 주소 정보를 저장할 리스트
    List<Map<String, dynamic>> addressList = [];

    void parseAddressData(Map<String, dynamic> responseJson) {
      if (responseJson['results'] != null &&
          responseJson['results'].length > 0) {
        final addressResults = responseJson['results'];

        // 리스트 초기화
        addressList.clear();

        for (var result in addressResults) {
          Map<String, dynamic> addressInfo = {};

          if (result['region'] != null || result['land'] != null) {
            final region = result['region'];
            final land = result['land'];

            // 주소 정보 추출
            String area1 = region['area1']['name'];
            String area2 = region['area2']['name'];

            // 추출한 정보를 Map에 저장
            addressInfo['area1'] = area1;
            addressInfo['area2'] = area2;

            // 도로명 주소가 있는 경우
            if (land != null) {
              String? landName = land['name'];
              String? landNumber1 = land['number1'];
              String? landNumber2 = land['number2'];
              String? addition0 = land['addition0']['value'];

              // 추출한 정보를 Map에 저장
              if (landName != null) {
                addressInfo['name'] = landName;
              }
              if (landNumber1 != null) {
                addressInfo['number1'] = landNumber1;
              }
              if (landNumber2 != null) {
                addressInfo['number2'] = landNumber2;
              }
              if (addition0 != null) {
                addressInfo['addition0'] = addition0;
              }
            }

            // 리스트에 주소 정보 추가
          }
          addressList.add(addressInfo);
        }

        // 주소 정보 리스트 출력
        print('주소 리스트 : $addressList');
      } else {
        print('No results found');
      }
    }

    parseAddressData(responseJson);

    /// 첫 번째 결과를 사용하여 _address 변수에 상세 주소 설정
    if (addressList.isNotEmpty) {
      String address = '${addressList[0]['area1']} ${addressList[0]['area2']}';

      // 추가 상세 주소 정보가 있는 경우 추가
      String? landName = addressList[addressList.length - 1]['name'];
      String? landNumber1 = addressList[addressList.length - 1]['number1'];
      String? landNumber2 = addressList[addressList.length - 1]['number2'];
      String? addition0 = addressList[addressList.length - 1]['addition0'];

      if (landName != null && landName.isNotEmpty) {
        address += ' $landName';
      }
      if (landNumber1 != null && landNumber1.isNotEmpty) {
        address += ' $landNumber1';
      }
      if (landNumber2 != null && landNumber2.isNotEmpty) {
        address += '-$landNumber2';
      }
      if (addition0 != null && addition0.isNotEmpty) {
        address += ' $addition0';
      }

      setState(() {
        _address = address;
        searchedPosition = LatLng(lat, lon);
        print('카메라 이동 완료');
      });
    } else {
      setState(() {
        _address = '위치를 확인해주세요.';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    mapController.dispose();
    super.dispose();
  }

  // 검색한 주소로 카메라를 이동시키는 메서드
  void _searchLocation(String query) async {
    if (query.isNotEmpty) {
      List<Location> locations = await locationFromAddress(query);
      print('locations : $locations');
      if (locations.isNotEmpty) {
        // firstStep = true;
        Location location = locations.first;
        searchedPosition = LatLng(location.latitude, location.longitude);
        _moveCameraTo(NLatLng(location.latitude, location.longitude));
      }
    }
  }

  // 카메라를 이동시키는 메서드
  void _moveCameraTo(NLatLng target) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    mapController.updateCamera(NCameraUpdate.fromCameraPosition(
      NCameraPosition(
        target: target,
        zoom: 15,
      ),
    ));
  }
}
