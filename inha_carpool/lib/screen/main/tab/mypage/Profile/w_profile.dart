import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/Profile/w_my_info.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/Profile/w_my_record.dart';

import '../../../../../common/widget/w_custom_png.dart';
import '../../../../../provider/auth/auth_provider.dart';

class ProFile extends ConsumerStatefulWidget {
  const ProFile({Key? key}) : super(key: key);

  @override
  _ProFileState createState() => _ProFileState();
}

class _ProFileState extends ConsumerState<ProFile> {


  @override
  Widget build(BuildContext context) {
    //프로필 수정 버튼 screenWidth,screenHeight 변수 선언
    double screenWidth = context.screenWidth;
    double screenHeight = context.screenHeight;

    return Stack(
      children: [
        //프로필 이미지
        Container(
          decoration: BoxDecoration(
            // Todo 테두리 원형이 이쁜가 ?
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  context.appColors.myPage2,
                  context.appColors.myPage3,
                  context.appColors.myPage1,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                  spreadRadius: 0,
                )
              ]),
          width: screenWidth,
          height: screenHeight * 0.3,
          child:  Center(
            child: Opacity(
              opacity: 0.3,
              child: CustomPng(
                fileDirectory: 'splash',
                fileName: 'obj1152',
                width: screenWidth * 0.3,
                height: screenHeight * 0.15,
              ),
            ),
            )
          ),

        //프로필 정보
        const Row(
          children: [
            AuthInfoRow(),
          ],
        ),
        //이용기록
        const AuthRecordRow(),
      ],


    );
  }
}
