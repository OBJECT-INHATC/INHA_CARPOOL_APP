import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/screen/recruit/w_dateTimePic.dart';
import 'package:inha_Carpool/screen/recruit/w_gender.dart';
import 'package:inha_Carpool/screen/recruit/w_recruit_location.dart';
import 'package:inha_Carpool/screen/recruit/w_select_nop.dart';

import '../../fragment/f_notification.dart';
import '../../fragment/setting/f_setting.dart';

class RecruitPage extends StatefulWidget {
  RecruitPage({super.key});

  @override
  State<RecruitPage> createState() => _RecruitPageState();
}

class _RecruitPageState extends State<RecruitPage> {
  var _selectedDate = DateTime.now(); // 날짜 값 초기화
  var _selectedTime = DateTime.now(); // 시간 값 초기화
  //인하대 후문 cu
  LatLng endPoint = LatLng(37.4514982, 126.6570261);
  // 주안역
  LatLng startPoint = LatLng(37.4645862, 126.6803935);
  String startPointName = "주안역 택시 승강장";
  String endPointName = "인하대 후문 CU";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  String selectedLimit = '2인'; // 선택된 제한인원 초기값
  String selectedGender = '남자'; // 선택된 성별 초기값

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.appColors.appBar,
          title: 'recruit'.tr().text.make(),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                size: 35,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationList()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, size: 35),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingPage()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            LocationInputWidget(
              labelText: startPointName,
              Point: startPoint,
              pointText: '출발지',
            ),
            LocationInputWidget(
              labelText: endPointName,
              Point: endPoint,
              pointText: '도착지',
            ),
            Row(
              children: [
                DateTimePickerWidget(
                  label: '날짜',
                  selectedDateTime: _selectedDate,
                  onDateTimeChanged: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      print("선택된 날짜: $_selectedDate");
                    });
                  },
                ),
                DateTimePickerWidget(
                  label: '시간',
                  selectedDateTime: _selectedTime,
                  onDateTimeChanged: (newTime) {
                    setState(() {
                      _selectedTime = newTime;
                      print("선택된 시간: $_selectedTime");
                    });
                  },
                ),
              ],
            ),

            ///  제한인원 및 성별
            Expanded(
              // 제한인원, 성별 영역
              child: Row(
                children: [
                  Expanded(
                    child: Column(// 제한인원 영역
                        children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: '인원'.text.size(25).align(TextAlign.left).make(),
                      ),
                      LimitSelectorWidget(
                        options: ['2인', '3인'],
                        selectedValue: selectedLimit,
                        onOptionSelected: (value) {
                          setState(() {
                            selectedLimit = value;
                            print("선택된 인원: $selectedLimit");
                          });
                        },
                      ),
                    ]),
                  ),
                  Expanded(
                    child: Column(// 성별 영역
                        children: [
                      // 성별 선택 버튼
                      GenderSelectorWidget(
                        selectedGender: selectedGender,
                        onGenderSelected: (value) {
                          setState(() {
                            selectedGender = value;
                            print("선택된 성별: $selectedGender");
                          });
                        },
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            /// 카풀 시작하기 -- 파베 기능 추가하기
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                  // 버튼 배경색
                  fixedSize: MaterialStateProperty.all(Size(200, 30)), // 버튼 크기
                ),
                onPressed: () {
                  // TODO: 카풀 시작하기 버튼을 눌렀을 때의 동작 추가
                },
                child: '카풀 시작하기'.text.size(20).white.make(),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      startPoint = LatLng(position.latitude, position.longitude);
      print(startPoint.latitude);
      print(startPoint.longitude);
    });
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
}
