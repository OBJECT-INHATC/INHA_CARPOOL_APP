import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_profile.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_recordDetail.dart';

import '../../../../dto/ReportRequstDTO.dart';
import '../../../../service/api/ApiService.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 내 정보 위젯 ProFile()
          ProFile(),
          SizedBox(height: 10),
          Column(
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    padding: EdgeInsets.fromLTRB(30, 10, 20, 20),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => RecordDetailPage(),
                              fullscreenDialog: false),
                        );
                      },
                      child: const Text(
                        "이용기록",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: () {
                        testAPI();

                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(70, 24),
                      ),
                      child: const Text(
                        "테스트버튼",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  testAPI() async{

    // ReportRequstDTO 객체를 생성 또는 채웁니다.
    final reportRequstDTO = ReportRequstDTO(
      content: '신고 내용',
      carpoolId: '카풀 ID',
      userName: '피신고자 ID',
      reporter: '신고자 ID',
      reportType: '잠수',
      reportDate: '신고 일자',
    );

    // API 호출
    final response = await apiService.saveReport(reportRequstDTO);
  }



}

