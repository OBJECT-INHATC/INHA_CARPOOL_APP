import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/recruit/w_dateTimePic.dart';
import 'package:inha_Carpool/screen/recruit/w_gender.dart';
import 'package:inha_Carpool/screen/recruit/w_recruit_location.dart';
import 'package:inha_Carpool/screen/recruit/w_select_nop.dart';


class RecruitPage extends StatefulWidget {
  RecruitPage({super.key});

  @override
  State<RecruitPage> createState() => _RecruitPageState();
}

class _RecruitPageState extends State<RecruitPage> {
  var _selectedDate = DateTime.now(); // 날짜 값 초기화
  var _selectedTime = DateTime.now(); // 시간 값 초기화

  String selectedLimit = '2인'; // 선택된 제한인원 초기값
  String selectedGender = '남자'; // 선택된 성별 초기값

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              /// 출발지, 도착지 영역
              child: Column(
                children: [
                  Expanded(
                    child: LocationInputWidget(labelText: '출발지'),
                  ),
                  Expanded(
                    child: LocationInputWidget(labelText: '도착지'),
                  ),
                ],
              ),
            ),

            ///날짜, 시간 영역
            Expanded(
              child: Row(
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
            ),

            ///  제한인원
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
}
