import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/screen/main/s_main.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/chat/f_chatroom.dart';
import 'package:inha_Carpool/screen/recruit/w_select_dateTime.dart';
import 'package:inha_Carpool/screen/recruit/w_select_gender.dart';
import 'package:inha_Carpool/screen/recruit/w_recruit_location.dart';
import 'package:inha_Carpool/screen/recruit/w_select_memebers_count.dart';


/// 카풀 생성 페이지
class RecruitPage extends StatefulWidget {
  const RecruitPage({super.key});

  @override
  State<RecruitPage> createState() => _RecruitPageState();
}

class _RecruitPageState extends State<RecruitPage> {
  Key key1 = UniqueKey();
  Key key2 = UniqueKey();

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

  String selectedLimit = '3인'; // 선택된 제한인원 초기값
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
  bool isShowingLoader = false;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    LocationInputWidget startPointInput;
    LocationInputWidget endPointInput;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        // 텍스트 포커스 해제
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
          isShowingLoader ? Colors.black.withOpacity(0.5) : Colors.white,
          surfaceTintColor: Colors.white,
          toolbarHeight: context.height(0.05),
          shape: isShowingLoader
              ? null
              : Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: context.width(0.001),
            ),
          ),
          title: '모집하기'.text.make(),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child:
              Column(
                children: [
                  Height(screenHeight * 0.05),
                  // 출발지 입력 위젯
                  SizedBox(
                    child: startPointInput = LocationInputWidget(
                      key: key1,
                      labelText: startPointName,
                      Point: startPoint,
                      pointText: '출발지',
                      onLocationSelected: (String value) {
                        setState(() {
                          startPointName =
                              LocationHandler.getStringBetweenUnderscores(value)
                                  .trim();
                          startPoint = LatLng(
                              LocationHandler.parseDoubleBeforeUnderscore(
                                  value),
                              LocationHandler.getDoubleAfterSecondUnderscore(
                                  value));
                        });
                      },
                      detailPoint: '요약 주소 (ex 주안역)',
                      detailController: _startPointDetailController,
                    ),
                  ),
                  Height(screenHeight * 0.02),
                  // 출발지, 도착지 교환 버튼
                  SizedBox(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          String tempPointName = startPointName;
                          LatLng tempPoint = startPoint;

                          startPointName = endPointName;
                          startPoint = endPoint;

                          //요약 주소 스왑
                          String temp = _endPointDetailController.text;
                          _endPointDetailController.text =
                              _startPointDetailController.text;
                          _startPointDetailController.text = temp;

                          endPointName = tempPointName;
                          endPoint = tempPoint;

                          // Key를 변경하여 Flutter에게 위젯이 새로운 것임을 알림
                          key1 = UniqueKey();
                          key2 = UniqueKey();
                        });
                      },
                      icon: Icon(
                        Icons.cached_rounded,
                        size: 30,
                        color: Colors.blue[300],
                      ),
                    ),
                  ),
                  Height(screenHeight * 0.01),
                  // 도착지 입력 위젯
                  Container(
                    child: endPointInput = LocationInputWidget(
                      key: key2,
                      labelText: endPointName,
                      Point: endPoint,
                      pointText: '도착지',
                      onLocationSelected: (String value) {
                        setState(() {
                          endPointName =
                              LocationHandler.getStringBetweenUnderscores(value)
                                  .trim();
                          endPoint = LatLng(
                              LocationHandler.parseDoubleBeforeUnderscore(
                                  value),
                              LocationHandler.getDoubleAfterSecondUnderscore(
                                  value));
                        });
                      },
                      detailPoint: '요약 주소 (ex 인하대 후문)',
                      detailController: _endPointDetailController,
                    ),
                  ),

                  Row(
                    children: [
                      DateTimePickerWidget(
                        label: '날짜',
                        selectedDateTime: _selectedDate,
                        onDateTimeChanged: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
                      ),
                      DateTimePickerWidget(
                        label: '시간',
                        selectedDateTime: _selectedTime,
                        onDateTimeChanged: (newTime) {
                          setState(() {
                            _selectedTime = newTime;
                          });
                        },
                      ),
                    ],
                  ),

                  ///  제한인원 및 성별

                  Column(
                    children: [
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
                          });
                        },
                      ),
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
                              options: const ['2인', '3인', '4인'],
                              selectedValue: selectedLimit,
                              onOptionSelected: (value) {
                                setState(() {
                                  _scrollController.jumpTo(
                                      _scrollController.position.maxScrollExtent);
                                });
                                FocusScopeNode currentFocus =
                                FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }

                                setState(() {
                                  selectedLimit = value;
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
                        surfaceTintColor:
                        MaterialStateProperty.all(Colors.blue[200]),
                        backgroundColor:
                        MaterialStateProperty.all(Colors.blue[200]),
                        // 버튼 배경색
                        fixedSize: MaterialStateProperty.all(Size(
                            context.width(0.5), context.height(0.04))), // 버튼 크기
                      ),

                      //카풀 시작하기 버튼
                      onPressed: isButtonDisabled
                          ? null
                          : () async {
                        setState(() {
                          isButtonDisabled = true;
                          isShowingLoader = true; // 버튼 비활성화 시 로딩 표시
                        });

                        // 버튼 동작
                        String startDetailPoint =
                            _startPointDetailController.text;
                        String endDetailPoint =
                            _endPointDetailController.text;

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
                            isShowingLoader = false;
                          });
                          return;
                        }

                        /// 시간 입력 오류 알림창
                        if (!isTimeValid(difference)) {
                          _showTimeAlertDialog(context);
                          setState(() {
                            isButtonDisabled = false;
                            isShowingLoader = false;
                          });
                          return;
                        }

                        if (gender != selectedGender &&
                            selectedGender != '무관') {
                          context.showErrorSnackbar("선택할 수 없는 성별입니다.");
                          isButtonDisabled = false;
                          isShowingLoader = false;
                          return;
                        }

                        context.showSnackbar(
                          "카풀을 생성하는 중입니다. 잠시만 기다려주세요.",
                        );

                        /// 조건 충족 시 파이어베이스에 카풀 정보 저장
                        String carId =
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
                          startDetailPoint: startPointInput
                              .detailController.text
                              .trim(),
                          endDetailPoint:
                          endPointInput.detailController.text.trim(),
                        );

                        if (!mounted) return;
                        Nav.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainScreen()),
                        );
                        if (carId == "") {
                          context.showErrorSnackbar("카풀 생성에 실패했습니다.");
                        } else {
                          context.showSnackbar("카풀 생성 성공! 채팅방으로 이동합니다");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatroomPage(
                                  carId: carId,
                                  groupName: '카풀네임',
                                  userName: nickName,
                                  uid: uid,
                                  gender: gender,
                                )),
                          );
                        }

                        setState(() {
                          isButtonDisabled = false;
                          isShowingLoader = false;
                        });
                      },
                      child: '카풀시작'.text.size(20).white.make(),
                    ).p(50),
                  ),
                ],
              ),
            ),
            isShowingLoader
                ? Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SpinKitThreeBounce(
                      color: Colors.white,
                      size: 25.0,
                    ), // Circular Indicator 추가
                    const SizedBox(height: 16),
                    '🚕 카풀 생성 중'.text.size(20).white.make(),
                  ],
                ),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  // 주소 입력 오류 알림창
  Future<void> _showAddressAlertDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
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
          surfaceTintColor: Colors.transparent,
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
