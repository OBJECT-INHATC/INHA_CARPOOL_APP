import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/dto/HistoryRequestDTO.dart';
import '../../../../common/widget/round_button_theme.dart';
import '../../../../common/widget/w_arrow.dart';
import '../../../../common/widget/w_round_button.dart';
import '../../../../common/widget/w_text_badge.dart';
import '../../../../dto/ReportRequstDTO.dart';
import '../../../../service/api/ApiService.dart';
import '../../../dialog/d_color_bottom.dart';
import '../../../dialog/d_confirm.dart';
import '../../../dialog/d_message.dart';

class PopUpFragment extends StatefulWidget {
  const PopUpFragment({
    Key? key,
  }) : super(key: key);

  @override
  State<PopUpFragment> createState() => _PopUpFragmentState();
}

class _PopUpFragmentState extends State<PopUpFragment> {
  final apiService = ApiService();


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.withOpacity(0.2),
      child: Column(
        children: [
          const Height(20),
          RoundButton(
              text: '신고 하기 Api 테스트',
              onTap: () {
                reportSaveAPI();
              }
          ),
          const Height(20),
          RoundButton(
              text: '신고 조회 Api 테스트',
              onTap: () {
                reportSelectListAPI("신고자 ID");
              }
          ),
          const Height(20),
          RoundButton(
            text: '이용기록 저장 Api 테스트',
            onTap: () {
              historySaveApi();
            }
          ),
          const Height(20),
          RoundButton(
              text: '이용기록 조회 Api 테스트',
              onTap: () {
                selectHistoryList("yeongjae", "xxx");
              }
          ),
          const Height(20),
          RoundButton(
              text: '다른거 테스트',
              onTap: () {
                // 다른거 추가
              }
          ),

          EmptyExpanded(),

        ],
      ),
    );
  }


  /// 내가 신고한 리스트 조회
  reportSelectListAPI(String myId) async{
     final response = await apiService.selectReportList(myId);
  }


  /// 신고하기
  reportSaveAPI() async{
    // 밑에 값들은 나중에 외부에서 받아야겠죠?
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

  // 이용내역 저장
  historySaveApi() async {

    final historyRequestDTO = HistoryRequestDTO(
      carPoolId: "vJuRYQ49pAAUAJmQYtcG",
      admin: "4IoZ0qp17me9v1QA3ljYw2SRbbh2_yeongjae",
      member1: "aa",
      member2: "bb",
      member3: "cc",
      nowMember: 1,
      maxMember: 3,
      startDetailPoint: "출발지 요약주소",
      startPoint: "출발지 위도경도",
      startPointName: "출발지 이름",
      startTime: 123456789,
      endDetailPoint: "도착지 요약주소",
      endPoint: "도착지 위도경도",
      endPointName: "도착지 이름",
      gender: "남자",
    );

    final response = await apiService.saveHistory(historyRequestDTO);
  }

  // 이용내역 조회
  selectHistoryList(String uid, String nickName) async {
    final response = await apiService.selectHistoryList(uid, nickName);
  }

}


