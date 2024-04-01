import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:quiver/time.dart';

import '../../provider/stateProvider/jusogiban_api_provider.dart';
import '../../service/api/Api_juso.dart';

class TestMap extends ConsumerStatefulWidget {
  final LatLng point;
  final String naverHost =
      'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc';

  const TestMap(this.point, {super.key});

  @override
  ConsumerState<TestMap> createState() => _TestMapState();
}

class _TestMapState extends ConsumerState<TestMap> {
  // 검색창 컨트롤러
  late final TextEditingController _searchController;
  late NaverMapController mapController;

  // 카메라 이동 여부를 저장할 변수
  bool isMove = false;
  bool isListSelect = false;

  // 검색한 주소의 좌표를 저장할 변수
  LatLng? searchedPosition;

  // 검색한 주소를 저장할 변수
  String? address;

  // 주소 검색 결과를 저장할 리스트
  List<String> _addressList = [];

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = context.screenHeight;
    final width = context.screenWidth;

    return Scaffold(
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
          searchContainer(height),

          /// 지도
          buildMapContatiner(height, context),
        ],
      ),
    );
  }

  /// 상단 검색 창
  Widget searchContainer(double height) {
    return Container(
      height: height * 0.05,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        onSubmitted: (value) async {
          selectNearLocation(value).then((value) {
            if (_addressList.isEmpty) {
              context.showSnackbarText(context, '검색 결과가 없습니다.',
                  bgColor: Colors.red);
              return;
            } else {
              buildBottomSheet(context);
            }
          });
        },
        controller: _searchController,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              selectNearLocation(_searchController.text).then((value) {
                if (_addressList.isEmpty) {
                  context.showSnackbarText(context, '검색 결과가 없습니다.',
                      bgColor: Colors.red);
                  return;
                } else {
                  buildBottomSheet(context);
                }
              });
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
    );
  }

  /// 지정한 위치의 지명을 가져오는 메서드 (검색기능)
  Future<void> selectNearLocation(String jusoTrim) async {
    jusoTrim = jusoTrim.trim();
    _addressList =
    await ApiJuso().getAddresses(jusoTrim, ref.read(jusoKeyProvider));

    setState(()  {
      if (_addressList.isEmpty) {
        address = null;
      } else {
        address = _addressList[0];
      }
    });

    print("--------------------------------------");
    print("selectNearLocation 실행 juso : $jusoTrim");
    print("--------------------------------------");
    print("주소 리스트 : $_addressList");
    print("--------------------------------------");
  }

  Expanded buildMapContatiner(double height, BuildContext context) {
    final width = context.screenWidth;

    return Expanded(
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
                target: NLatLng(widget.point.latitude, widget.point.longitude),
                zoom: 15.5,
              ),
            ),
            onMapReady: (controller) async {
              mapController = controller;
            },

            /// 카메라가 멈췄을 때
            onCameraIdle: () {
              mapController.getCameraPosition().then((cameraPosition) async {
                setState(() {
                  isMove = true;
                });
                // 카메라가 이동하면서 좌표를 저장
                searchedPosition = LatLng(cameraPosition.target.latitude,
                    cameraPosition.target.longitude);

                if (isMove == true && searchedPosition != null) {

                  if(isListSelect == false){
                    _addressList = await ApiJuso().getAddressesByLatLon(
                        searchedPosition!.latitude, searchedPosition!.longitude);
                    if (_addressList.isNotEmpty) {
                      print('주소 리스트가 차있음 : $_addressList');
                      address = _addressList[0];
                    } else {
                      print('주소 리스트가 비어있음 : $_addressList');
                      address = null;
                    }
                  }

                }
                setState(() {
                  isMove = false;
                  isListSelect = false;
                });
              });

              print("onCameraIdle 실행");
              print('searchedPosition : $searchedPosition');
            },
          ),
          Positioned(
            top: height / 4,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    /// 입력된 주소가 위, 경도 값이 없을 경우 ( ex. '지하'를 포함한 주소 )
                    if (searchedPosition == null || _addressList.isEmpty) {
                      context.showSnackbarText(context, '위치를 선택해주세요.',
                          bgColor: Colors.red);
                      return; // 주소에 대한 좌표가 없으므로 메서드 종료
                    }
                  },

                  ///가운대 좌표 컨테이너
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset:
                          const Offset(0, 5), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              (searchedPosition == null || _addressList.isEmpty)
                                  ? '위치를 선택해주세요.'
                                  : '$address',
                              style: TextStyle(
                                fontSize: width * 0.035,
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
                          (searchedPosition == null || _addressList.isEmpty)
                              ? '위치를 선택해주세요.'
                              : '위치 선택',
                          style: TextStyle(
                            fontSize: width * 0.028,
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
    );
  }

  buildBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 3 / 5,
            child: Column(
              children: [
                // **닫기 버튼**
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                // **검색 결과 리스트**
                Expanded(
                  child: ListView.builder(
                    itemCount: _addressList.length,
                    itemBuilder: (context, index) {
                      print('주소 갯수 ' + _addressList.length.toString());
                      return ListTile(
                        title: Text(_addressList[index]),
                        onTap: () {
                          // 선택한 주소를 _address 변수에 저장
                          setState(() {
                            isListSelect = true;
                            address = _addressList[index];
                          });
                          _searchLocation(_addressList[index]);

                          print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
                          print('최 종 선 택 은? ');
                          print(address);
                          print(searchedPosition);
                          print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  // 검색한 주소로 카메라를 이동시키는 메서드
  void _searchLocation(String query) async {
    print('query : $query');
    if (query.isNotEmpty) {
      List<Location> locations = await locationFromAddress(cutStringToFirstComma(query));
      print('locations : $locations');
      if (locations.isNotEmpty) {
        // firstStep = true;
        Location location = locations.first;
        searchedPosition = LatLng(location.latitude, location.longitude);
        _moveCameraTo(NLatLng(location.latitude, location.longitude));
      }
    }
  }

  String cutStringToFirstComma(String input) {
    int index = input.indexOf(',');
    if (index == -1) {
      return input;
    } else {
      return input.substring(0, index);
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
