import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/widget/w_rounded_Container.dart';
import 'package:inha_Carpool/common/widget/w_tap.dart';
import 'package:velocity_x/velocity_x.dart';

import 'w_arrow.dart';

class BigButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const BigButton(this.text, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: RoundedContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // n개의 위젯에 최대한의 공간을 주어 밀어내는 것
          children: [
            text.text.white.size(20).bold.make(),
            const Arrow(),
          ],
        ),
      ),
    );
  }
}
