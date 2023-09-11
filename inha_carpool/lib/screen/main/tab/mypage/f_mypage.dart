import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_profile.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_recordDetail.dart';

import 'package:inha_Carpool/common/data/preference/prefs.dart';
import '../../../setting/w_switch_menu.dart';
import 'd_changepassword.dart';
import 'f_logout_confirmation.dart';
import 'f_secession.dart';

import '../../../../dto/ReportRequstDTO.dart';
import '../../../../service/api/ApiService.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  bool isEventAdsAllowed = true; // 스위치의 초기 상태를 설정

  final apiService = ApiService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView( // 스크롤 가능한 ListView로 변경
        children: [
          // 내 정보 위젯 ProFile()
          ProFile(),
          SizedBox(height: 10),
          Column(
            children: [

              // 계정 항목
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0), // vertical 값을 조정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // 추가
                  children: [
                    Text(
                      '계정',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.blue,
                ),
                title: Text('비밀번호 변경'),
                onTap: () {
                  // 비밀번호 변경 페이지로 이동
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordPage(), // ChangePasswordPage로 이동
                    ),
                  );
                },
              ),


              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: Text('로그아웃'),
                onTap: () {
                  // 로그아웃 다이얼로그를 표시
                  showDialog(
                    context: context,
                    builder: (context) => LogoutConfirmationDialog(onConfirm: () {  },),
                  );
                },
              ),


              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
                title: Text('회원탈퇴'),
                onTap: () {
                  // 회원탈퇴 페이지로 이동하
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecessionPage()));
                },
              ),


              // 알림 항목
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0), // vertical 값을 조정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '알림',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.alarm_rounded,
                  color: Colors.blueGrey,
                ),
                title: Text('알림 설정'),
                trailing: Switch(
                  value: isEventAdsAllowed,
                  onChanged: (value) {
                    setState(() {
                      isEventAdsAllowed = value;
                    });
                  },
                ),
              ),

              // 기타 항목
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0), // vertical 값을 조정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // 추가
                  children: [
                    Text(
                      '기타',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.history_toggle_off_rounded,
                  color: Colors.black,
                ),
                title: Text('이용기록'),
                onTap: () {
                  // 이용기록 페이지로 이동
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RecordDetailPage()));
                },
              ),


              ListTile(
                leading: Icon(
                  Icons.nightlight_round,
                  color: Colors.deepPurple
                ),
                title: Text('야간모드'),
                trailing: Switch(
                  value: isEventAdsAllowed,
                  onChanged: (value) {
                    setState(() {
                      isEventAdsAllowed = value;
                    });
                  },
                ),
              ),

              ListTile(
                leading: Icon(
                  Icons.ad_units,
                  color: Colors.orange,
                ),
                title: Text('이벤트 및 광고 수신동의'),
                trailing: Switch(
                  value: isEventAdsAllowed,
                  onChanged: (value) {
                    setState(() {
                     isEventAdsAllowed = value;
                  });
                },
              ),
            ),

            ],
          ),
        ],
      ),
    );
  }
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
    // final response = await apiService.saveReport(reportRequstDTO);
  }


