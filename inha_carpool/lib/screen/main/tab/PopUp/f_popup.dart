import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
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
            text: '다른거 Api 테스트',
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
     print(jsonDecode(utf8.decoder.convert(response.bodyBytes)));
  }


  /// 신고하기
  reportSaveAPI() async{
    // 밑에 값들은 나중에 외부에서 받아야겠죠?
    final reportRequstDTO = ReportRequstDTO(
      content: '신고 내용',
      carpoolId: '카풀 ID',
      userName: '피신고자 ID',
      reporter: '신고자 ID',
      reportType: '잠2수',
      reportDate: '신고 일자',
    );

    // API 호출
    final response = await apiService.saveReport(reportRequstDTO);
  }
}
