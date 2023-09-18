import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../../common/widget/w_tap.dart';

class Menu extends StatelessWidget {
  final String text;
  final Function() onTap;

  const Menu(this.text, {Key? key, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Tap(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 20),
          child: Row(
            children: [
              Expanded(
                  child: text.text
                      .textStyle(defaultFontStyle())
                      .color(context.appColors.drawerText)
                      .size(15)
                      .make()),
            ],
          ),
        ),
      ),
    );
  }
}