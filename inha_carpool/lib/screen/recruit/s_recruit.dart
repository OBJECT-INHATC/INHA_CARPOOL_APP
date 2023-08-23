import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/recruit/s_map.dart';
import 'package:inha_Carpool/screen/recruit/w_dateTimePic.dart';
import 'package:inha_Carpool/screen/recruit/w_recruit_location.dart';

import '../main/tab/carpool/s_masterroom.dart';

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
              // 출발지, 도착지 영역
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
            

            //날짜, 시간 영역
            Expanded(
              child: Row(
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
                        child: Text(
                          '제한인원',
                          style: TextStyle(fontSize: 25.0),
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
                            backgroundColor: selectedLimit == '2인'
                                ? Colors.lightBlue
                                : Colors.grey,
                          ),
                          child: Text(
                            '2인',
                            style: TextStyle(color: Colors.white, fontSize: 17),
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
                            backgroundColor: selectedLimit == '3인'
                                ? Colors.lightBlue
                                : Colors.grey,
                          ),
                          child: Text(
                            '3인',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: Column(// 성별 영역
                        children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: Text(
                          '성별',
                          style: TextStyle(fontSize: 25.0),
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
                                backgroundColor: selectedGender == '남자'
                                    ? Colors.lightBlue
                                    : Colors.grey,
                              ),
                              child: Text(
                                '남자',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
                                backgroundColor: selectedGender == '여자'
                                    ? Colors.lightBlue
                                    : Colors.grey,
                              ),
                              child: Text(
                                '여자',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
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
                            backgroundColor: selectedGender == '무관'
                                ? Colors.lightBlue
                                : Colors.grey,
                          ),
                          child: Text(
                            '무관',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Expanded(
              // 작성 완료 버튼 영역
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(30, 75, 30, 75),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MasterChatroomPage()));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  child: Text(
                    '작성완료',
                    style: TextStyle(color: Colors.white, fontSize: 18),
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
