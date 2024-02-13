import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../screen/main/tab/carpool/w_floating_btn.dart';

class EmptyCarpoolList extends StatelessWidget {
  const EmptyCarpoolList({super.key, required this.floatingMessage});
  final String floatingMessage;

  /// todo : 새로고침 기능 추가하기

  @override
  Widget build(BuildContext context) {

    final height = context.screenHeight;


    return ListView(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Height(height * 0.2),
            floatingMessage
                .text
                .size(20)
                .bold
                .color(context.appColors.text)
                .align(TextAlign.center)
                .make(),
            Height(height * 0.025),
            RecruitFloatingBtn(floatingMessage: floatingMessage),
          ],
        ),
      ],
    );
  }
}
