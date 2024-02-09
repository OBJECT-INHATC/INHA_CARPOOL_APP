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

    final recordState = ref.watch(recordCountProvider);

    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: width * 0.02),
        child: Column(
          children: [
            CustomPng(
              fileDirectory: 'splash',
              fileName: 'school_logo',
              height: width * 0.12,
              width: width * 0.5,
            ),
            // 사람 이미지 아이콘
            Icon(Icons.account_circle, size: width * 0.2, color: Colors.white),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 앱 이용횟수
                _buildCountColumn('카풀 이용', recordState, width),
                Column(
                  children: [
                    // 이름
                    // 이름
                    state.userName!.text.size(width * 0.05).bold.make(),

                    // 닉네임
                    "# ${state.nickName!}"
                        .text
                        .sky900
                        .size(width * 0.045)
                        .make(),
                  ],
                ),
                // todo : 경고 횟수 받아와서 때리기 (지금은 0 고정)
                _buildCountColumn('경고 누적', 0, width),
              ],
            ),
            // 이메일
            state.email!.text.size(width * 0.03).make(),
          ],
        ),
      ),
    );
  }

  _buildCountColumn(String text, int num, double width) {
    return Column(
      children: [
        text.text.size(width * 0.04).make(),
        '$num 회'.text.size(width * 0.045).sky900.make(),
      ],
    );
  }
}
