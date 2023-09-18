import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/screen/main/s_main.dart';
import 'package:inha_Carpool/screen/recruit/w_select_dateTime.dart';
import 'package:inha_Carpool/screen/recruit/w_select_gender.dart';
import 'package:inha_Carpool/screen/recruit/w_recruit_location.dart';
import 'package:inha_Carpool/screen/recruit/w_select_memebers_count.dart';


class RecruitPage extends StatefulWidget {
  const RecruitPage({super.key});

  @override
  State<RecruitPage> createState() => _RecruitPageState();
}

class _RecruitPageState extends State<RecruitPage> {
  var _selectedDate = DateTime.now(); // 날짜 값 초기화
  var _selectedTime =
      DateTime.now().add(const Duration(minutes: 15)); // 시간 값 초기화 (현재시간 + 15분)
  //인하대 후문 cu
  LatLng endPoint = const LatLng(37.4514982, 126.6570261);

  // 주안역 (초기 출발 위치)
  LatLng startPoint = const LatLng(37.4650414, 126.6807024);
  String startPointName = "주안역 택시 승강장";
  String endPointName = "인하대 후문 CU";

  late final TextEditingController _startPointDetailController =
      TextEditingController();
  late final TextEditingController _endPointDetailController =
      TextEditingController();

  final storage = const FlutterSecureStorage();
  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";

  final String myID = "";

  @override
  void initState() {
    super.initState();
    //_getCurrentLocation();
    _loadUserData();
  }

  // 로그인한 사용자의 정보를 불러옵니다.
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

  // 주소 입력 오류 확인
  bool isAddressValid(String detailPoint) {
    return detailPoint.length >= 2 && detailPoint.length <= 10;
  }

  // 시간 입력 오류 확인
  bool isTimeValid(Duration difference) {
    return difference.inMinutes >= 10;
  }

  // 카풀 시작하기 버튼 활성화 여부
  bool isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    LocationInputWidget startPointInput;
    LocationInputWidget endPointInput;

    return GestureDetector(
      onTap: () {
        // 텍스트 포커스 해제
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          toolbarHeight: context.height(0.05),
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: context.width(0.001),
            ),
          ),
          title: 'recruit'.tr().text.make(),
        ),
        body: SingleChildScrollView(
          child: Column(

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
                    print("출발지 주소 : $startPointName");
                    print("출발지 위도경도 : $startPoint");
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
                    print("도착지 주소 : $endPointName");
                    print("도착지 위도경도 : $endPoint");
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

                  Column(
                    children: [
                      Column(// 제한인원 영역
                          children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: '인원'
                              .text
                              .size(16)
                              .bold
                              .align(TextAlign.left)
                              .make(),
                        ),
                        LimitSelectorWidget(
                          options: const ['2인', '3인'],
                          selectedValue: selectedLimit,
                          onOptionSelected: (value) {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }

                            setState(() {
                              selectedLimit = value;
                              print("선택된 인원: $selectedLimit");
                            });
                          },
                        ),
                      ]),
                      Column(// 성별 영역
                          children: [
                        // 성별 선택 버튼
                        GenderSelectorWidget(
                          selectedGender: selectedGender,
                          gender: gender,
                          onGenderSelected: (value) {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            setState(() {
                              selectedGender = value;
                              print("선택된 성별: $selectedGender");
                            });
                          },
                        ),
                      ]),
                    ],
                  ),

              SizedBox(height: context.height(0.01)),
              /// 카풀 시작하기 -- 파베 기능 추가하기
              Container(
                child: ElevatedButton(

                  style: ButtonStyle(
                    surfaceTintColor: MaterialStateProperty.all(Colors.blue[200]),
                    backgroundColor: MaterialStateProperty.all(Colors.blue[200]),
                    // 버튼 배경색
                    fixedSize: MaterialStateProperty.all(Size(context.width(0.5), context.height(0.04))), // 버튼 크기
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
                            setState(() {
                              isButtonDisabled = false;
                            });
                            return;
                          }

                          /// 시간 입력 오류 알림창
                          if (!isTimeValid(difference)) {
                            _showTimeAlertDialog(context);
                            setState(() {
                              isButtonDisabled = false;
                            });
                            return;
                          }

                          if (gender != selectedGender &&
                              selectedGender != '무관') {
                            context.showErrorSnackbar("선택할 수 없는 성별입니다.");
                            isButtonDisabled = false;
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
                            selectedRoomGender: selectedGender,
                            memberID: uid,
                            memberName: nickName,
                            memberGender: gender,
                            startDetailPoint:
                            startPointInput.detailController.text,
                            endDetailPoint: endPointInput.detailController.text,
                          );

                          ///TODO 채팅창으로 넘기기
                          if(!mounted) return;
                          Nav.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                          );
                          setState(() {
                            isButtonDisabled = false;
                          });
                  },
                  child: '카풀 시작하기'.text.size(20).white.make(),
                ).p(50),
              ),
            ],

          ),

        ),
      ),
    );
  }

  // Future<void> _getCurrentLocation() async {
  //   Location_handler.getCurrentLocation(context, (LatLng location) {
  //     setState(() {
  //       startPoint = location;
  //     });
  //   });
  // }

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
