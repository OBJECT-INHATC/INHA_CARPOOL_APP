import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/provider/record/record_provider.dart';

import '../../../../../common/widget/w_custom_png.dart';
import '../../../../../provider/auth/auth_provider.dart';

class AuthInfoRow extends ConsumerStatefulWidget {
  const AuthInfoRow({super.key});

  @override
  ConsumerState<AuthInfoRow> createState() => _AuthInfoState();
}

class _AuthInfoState extends ConsumerState<AuthInfoRow> {


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final width = context.screenWidth;
    final height = context.screenHeight;

    final recordState = ref.watch(recordCountProvider);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: width * 0.01, horizontal: width * 0.01),
        child: Column(
          children: [
            // 인하대 & 인하공전
            CustomPng(
              fileDirectory: 'splash',
              fileName: 'school_logo',
              height: width * 0.13,
              width: width * 0.7,
            ),


            // 카풀이용, 이름, 경고 누적 row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 앱 이용횟수
                _buildCountColumn('카풀 이용', recordState, width),

                // 사람 이미지 아이콘
                Icon(Icons.account_circle, size: width * 0.14, color: Colors.white),

                // todo : 경고 횟수 받아와서 때리기 (지금은 0 고정)
                _buildCountColumn('경고 누적', 0, width),
              ],
            ),
            Height(height * 0.01),
            state.userName!.text.size(width * 0.05).bold.make(),

            // 닉네임
            "# ${state.nickName!}"
                .text
                .sky900
                .size(width * 0.035)
                .make(),

            // 이메일
           // state.email!.text.size(width * 0.02).make(),
          ],
        ),
      ),
    );
  }

  _buildCountColumn(String text, int num, double width) {
    return Column(
      children: [
        //사이즈 35의 글자
        Height(width * 0.1),
        text.text.size(width * 0.045).semiBold.make(),
        '$num 회'.text.size(width * 0.04).sky900.make(),
      ],
    );
  }
}
