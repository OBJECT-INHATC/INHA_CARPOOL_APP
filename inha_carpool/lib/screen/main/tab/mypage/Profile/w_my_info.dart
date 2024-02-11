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

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: width * 0.01, horizontal: width * 0.01),
      child: Column(
        children: [
          // 인하대 & 인하공전
          CustomPng(
            fileDirectory: 'splash',
            fileName: 'school_logo',
            height: width * 0.13,
            width: width * 0.7,
          ),
          Icon(Icons.account_circle, size: width * 0.15, color: Colors.white),
          Height(height * 0.02),

          // 카풀이용, 이름, 경고 누적 row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /// : todo 앱 이용횟수 서버에서 꽃기
              _buildCountColumn('카풀 이용', recordState, width),

              Column(
                children: [
                  // 이름
                  state.userName!.text.size(width * 0.05).bold.make(),
                  // 닉네임
                  "# ${state.nickName!}".text.sky900.size(width * 0.04).make(),
                ],
              ),


              // todo : 경고 횟수 받아와서 때리기 (지금은 0 고정)
              _buildCountColumn('경고 누적', 0, width),
            ],
          ),

          // 이메일
          // state.email!.text.size(width * 0.02).make(),
        ],
      ),
    );
  }

  _buildCountColumn(String text, int num, double width) {
    return Column(
      children: [
        //사이즈 35의 글자
        text.text.size(width * 0.040).semiBold.make(),
        '$num 회'.text.size(width * 0.037).sky900.make(),
      ],
    );
  }
}
