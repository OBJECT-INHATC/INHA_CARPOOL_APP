import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/screen/main/s_main.dart';
import 'package:inha_Carpool/screen/recruit/w_select_dateTime.dart';
import 'package:inha_Carpool/screen/recruit/w_select_gender.dart';
import 'package:inha_Carpool/screen/recruit/w_recruit_location.dart';
import 'package:inha_Carpool/screen/recruit/w_select_memebers_count.dart';

import '../../fragment/f_notification.dart';
import '../../screen/setting/f_setting.dart';

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

  late TextEditingController _startPointDetailController =
      TextEditingController();
  late TextEditingController _endPointDetailController =
      TextEditingController();

  final storage = FlutterSecureStorage();
  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";

  final String myID = "";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    nickName = await storage.read(key: "nickName") ?? "";
    uid = await storage.read(key: "uid") ?? "";
    gender = await storage.read(key: "gender") ?? "";

    setState(() {
      // nickName, email, gender를 업데이트했으므로 화면을 갱신합니다.
    });
  }

  String selectedLimit = '2인'; // 선택된 제한인원 초기값
  String selectedGender = '무관'; // 선택된 성별 초기값

  /// 주소 입력 오류 확인
  bool isAddressValid(String detailPoint) {
    return detailPoint.length >= 2 && detailPoint.length <= 10;
  }

  /// 시간 입력 오류 확인
  bool isTimeValid(Duration difference) {
    return difference.inMinutes >= 10;
  }

  /// 카풀 시작하기 버튼 활성화 여부
  bool isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    LocationInputWidget startPointInput;
    LocationInputWidget endPointInput;
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
            startPointInput = LocationInputWidget(
              labelText: startPointName,
              Point: startPoint,
              pointText: '출발지',
              onLocationSelected: (String value) {
                setState(() {
                  startPointName =
                      Location_handler.getStringBetweenUnderscores(value);
                  startPoint = LatLng(
                      Location_handler.parseDoubleBeforeUnderscore(value),
                      Location_handler.getDoubleAfterSecondUnderscore(value));
                  print("출발지 주소 : ${startPointName}");
                  print("출발지 위도경도 : ${startPoint}");
                });
              },
              detailPoint: '요약 주소 (ex 주안역)',
              detailController: _startPointDetailController,
            ),
            endPointInput = LocationInputWidget(
              labelText: endPointName,
              Point: endPoint,
              pointText: '도착지',
              onLocationSelected: (String value) {
                setState(() {
                  endPointName =
                      Location_handler.getStringBetweenUnderscores(value);
                  endPoint = LatLng(
                      Location_handler.parseDoubleBeforeUnderscore(value),
                      Location_handler.getDoubleAfterSecondUnderscore(value));
                  print("도착지 주소 : ${endPointName}");
                  print("도착지 위도경도 : ${endPoint}");
                });
              },
              detailPoint: '요약 주소 (ex 인하대 후문)',
              detailController: _endPointDetailController,
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
                        child: '인원'
                            .text
                            .size(20)
                            .bold
                            .align(TextAlign.left)
                            .make(),
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
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                  // 버튼 배경색
                  fixedSize: MaterialStateProperty.all(Size(200, 30)), // 버튼 크기
                ),

                //카풀 시작하기 버튼
                onPressed: isButtonDisabled
                    ? null
                    : () async {
                        setState(() {
                          isButtonDisabled = true;
                        });

                        // 버튼 동작
                        String startDetailPoint =
                            _startPointDetailController.text;
                        String endDetailPoint = _endPointDetailController.text;

                        // 현재 시간과 선택된 날짜와 시간의 차이 계산
                        DateTime currentTime = DateTime.now();
                        DateTime selectedDateTime = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedTime.hour,
                          _selectedTime.minute,
                        );
                        Duration difference =
                            selectedDateTime.difference(currentTime);

                        /// 주소 입력 오류 알림창
                        if (!isAddressValid(startDetailPoint) ||
                            !isAddressValid(endDetailPoint)) {
                          _showAddressAlertDialog(context);
                          return;
                        }

                        /// 시간 입력 오류 알림창
                        if (!isTimeValid(difference)) {
                          _showTimeAlertDialog(context);
                          return;
                        }

                        /// 조건 충족 시 파이어베이스에 카풀 정보 저장
                        await FirebaseCarpool.addDataToFirestore(
                          selectedDate: _selectedDate,
                          selectedTime: _selectedTime,
                          startPoint: startPoint,
                          endPoint: endPoint,
                          endPointName: endPointName,
                          startPointName: startPointName,
                          selectedLimit: selectedLimit,
                          selectedGender: selectedGender,
                          memberID: uid,
                          memberName: nickName,
                          startDetailPoint:
                              startPointInput.detailController.text,
                          endDetailPoint: endPointInput.detailController.text,
                        );

                        ///TODO 채팅창으로 넘기기
                        Nav.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainScreen()),
                        );
                        setState(() {
                          isButtonDisabled = false;
                        });
                      },
                child: '카풀 시작하기'.text.size(20).white.make(),
              ).p(70),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    Location_handler.getCurrentLocation(context, (LatLng location) {
      setState(() {
        startPoint = location;
      });
    });
  }

  // 주소 입력 오류 알림창
  Future<void> _showAddressAlertDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('카풀 생성 실패'),
          content: const Text('요약주소는 2 ~ 10 글자로 작성해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 시간 입력 오류 알림창
  Future<void> _showTimeAlertDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('카풀 생성 실패'),
          content: const Text('카풀을 생성하기 위한 시간은 현재 시간으로부터 10분 이후여야 합니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
