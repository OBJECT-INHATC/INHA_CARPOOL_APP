import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:nav/nav.dart';

import '../../screen/recruit/s_recruit.dart';

class EmptyCarpoolList extends StatelessWidget {
  const EmptyCarpoolList({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          message
              .text
              .size(20)
              .bold
              .color(context.appColors.text)
              .align(TextAlign.center)
              .make(),
          const SizedBox(
            height: 20,
          ),
          FloatingActionButton(
            heroTag: "heroTag_$message",
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
                .color(Colors.blue[200],)
                .make(),
          ),
        ],
      ),
    );
  }
}
