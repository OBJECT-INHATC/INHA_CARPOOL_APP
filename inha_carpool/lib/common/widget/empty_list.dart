import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../screen/main/tab/carpool/w_floating_btn.dart';

class EmptyCarpoolList extends StatelessWidget {
  const EmptyCarpoolList({super.key, required this.floatingMessage});
  final String floatingMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          floatingMessage
              .text
              .size(20)
              .bold
              .color(context.appColors.text)
              .align(TextAlign.center)
              .make(),
          const SizedBox(
            height: 20,
          ),
          RecruitFloatingBtn(floatingMessage: floatingMessage),
        ],
      ),
    );
  }
}
