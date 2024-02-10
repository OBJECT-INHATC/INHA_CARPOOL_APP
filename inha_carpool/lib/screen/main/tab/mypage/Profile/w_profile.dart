import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/Profile/w_my_info.dart';


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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
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
            child: const AuthInfoRow(),
            ),
        ),


        //프로필 정보



      ],


    );
  }

  _ProFileState();
}
