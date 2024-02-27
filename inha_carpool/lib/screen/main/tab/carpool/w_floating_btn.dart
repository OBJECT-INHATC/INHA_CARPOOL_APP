import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../recruit/s_recruit.dart';

class RecruitFloatingBtn extends StatelessWidget {
  const RecruitFloatingBtn({super.key, required this.floatingMessage});
  final String floatingMessage;

  @override
  Widget build(BuildContext context) {
    return  FloatingActionButton(
      heroTag: "heroTag_$floatingMessage",
      elevation: 10,
      backgroundColor: Colors.white,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(40),
        //side: const BorderSide(color: Colors.white, width: 1),
      ),
      onPressed: () {
        Navigator.push(
          Nav.globalContext,
          MaterialPageRoute(
              builder: (context) => const RecruitPage()),
        );
      },
      child: '+'
          .text
          .size(50)
          .color(context.appColors.logoColor,)
          .make(),
    );
  }
}
