import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/util/carpool.dart';
import '../../../recruit/s_recruit.dart';

/// 진행 중인 카풀이 없을 때 반환할 위젯
class EmptyCarpool extends StatelessWidget {

  const EmptyCarpool({Key? key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [

        Height(MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Text(
            '카풀을 등록하여\n택시 비용을 줄여 보세요!',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Height(MediaQuery.of(context).size.height * 0.03),
        FloatingActionButton(
          elevation: 10,
          backgroundColor: Colors.white,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(40),
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
              .size(70)
              .color(
            Colors.blue[200],
            //Color.fromARGB(255, 70, 100, 192),
          )
              .make(),
        ),
      ],
    );
  }
}
