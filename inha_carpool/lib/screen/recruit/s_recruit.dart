import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/recruit/s_map.dart';
import 'package:inha_Carpool/screen/recruit/w_recruit_map.dart';

import '../main/tab/carpool/s_masterroom.dart';

class RecruitPage extends StatefulWidget {
  RecruitPage({super.key});

  @override
  State<RecruitPage> createState() => _RecruitPageState();
}

class _RecruitPageState extends State<RecruitPage> {
  var selectedDate = DateTime.now(); // 날짜 값 초기화
  var selectedTime = DateTime.now(); // 시간 값 초기화

  String selectedLimit = '2인'; // 선택된 제한인원 초기값
  String selectedGender = '남자'; // 선택된 성별 초기값

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context); // 이전 화면으로
            },
          ),
          title: Text(
            '모집하기',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded( // 출발지, 도착지 영역
              child: Column(
                children: [
                  Expanded(child: LocationInputWidget(labelText: '출발지'),),
                  Expanded(child: LocationInputWidget(labelText: '도착지'),),
                ],
              ),
            ),
            Expanded( // 날짜, 시간 선택 영역
              child: Container(
                decoration: BoxDecoration( // 상하 테두리
                    border: Border(
                        top: BorderSide(
                            color: Colors.grey,
                            width: 1.0
                        ),
                        bottom: BorderSide(
                            color: Colors.grey,
                            width: 1.0
                        )
                    )
                ),
                child: Row(
                  children: [
                    Expanded( // 날짜 영역
                      child: GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup( // 아이폰 스타일의 날짜 팝업
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 300, // 날짜 선택 위젯의 높이 설정
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date, // 날짜 선택 모드
                                  initialDateTime: DateTime.now(),
                                  minimumDate: DateTime(2023),
                                  maximumDate: DateTime(2099),
                                  onDateTimeChanged: (DateTime newDate) {
                                    // 날짜가 선택되었을 때 실행되는 콜백 함수
                                    setState(() {
                                      selectedDate = newDate;
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Colors.grey,
                                      width: 0.5
                                  )
                              )
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                                child: Text(
                                  '날짜',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Text(
                                selectedDate.year.toString(), // 연도
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${selectedDate.month.toString().padLeft(2, '0')}."
                                    "${selectedDate.day.toString().padLeft(2, '0')}", // 월, 일
                                style: TextStyle(
                                  fontSize: 40,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded( // 시간 영역
                      child: GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup( // 아이폰 스타일의 시간 팝업
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 300, // 시간 선택 위젯의 높이 설정
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.time, // 시간 선택 모드
                                  initialDateTime: DateTime.now(),
                                  onDateTimeChanged: (DateTime newTime) {
                                    // 시간이 선택되었을 때 실행되는 콜백 함수
                                    setState(() {
                                      selectedTime = newTime;
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: Colors.grey,
                                      width: 0.5
                                  )
                              )
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                                child: Text(
                                  '시간',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Text(
                                selectedTime.hour > 12 ? '오후' : '오전',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${selectedTime.hour > 12 ? (selectedTime.hour - 12).toString().padLeft(2, '0') : selectedTime.hour.toString().padLeft(2, '0')}:"
                                    "${selectedTime.minute.toString().padLeft(2, '0')}", // 선택한 시간 표시
                                style: TextStyle(
                                  fontSize: 40,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded( // 제한인원, 성별 영역
              child: Row(
                children: [
                  Expanded(
                    child: Column( // 제한인원 영역
                        children: [
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.all(15),
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Text(
                              '제한인원',
                              style: TextStyle(
                                  fontSize: 25.0
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          // 제한인원 선택 버튼
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedLimit = '2인';
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: selectedLimit == '2인' ? Colors.lightBlue : Colors.grey,
                              ),
                              child: Text(
                                '2인',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedLimit = '3인';
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: selectedLimit == '3인' ? Colors.lightBlue : Colors.grey,
                              ),
                              child: Text(
                                '3인',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17
                                ),
                              ),
                            ),
                          ),
                        ]
                    ),
                  ),
                  Expanded(
                    child: Column( // 성별 영역
                        children: [
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.all(15),
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Text(
                              '성별',
                              style: TextStyle(
                                  fontSize: 25.0
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          // 성별 선택 버튼
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(30, 0, 12, 0),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedGender = '남자';
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: selectedGender == '남자' ? Colors.lightBlue : Colors.grey,
                                  ),
                                  child: Text(
                                    '남자',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(13, 0, 30, 0),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedGender = '여자';
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: selectedGender == '여자' ? Colors.lightBlue : Colors.grey,
                                  ),
                                  child: Text(
                                    '여자',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedGender = '무관';
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: selectedGender == '무관' ? Colors.lightBlue : Colors.grey,
                              ),
                              child: Text(
                                '무관',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17
                                ),
                              ),
                            ),
                          ),
                        ]
                    ),
                  ),
                ],
              ),
            ),
            Expanded( // 작성 완료 버튼 영역
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(30, 75, 30, 75),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MasterChatroomPage()));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  child: Text(
                    '작성완료',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
