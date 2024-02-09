import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/velocityx_extension.dart';
import 'package:inha_Carpool/global_version.dart';


class VersionAndCopyRight extends StatelessWidget {
  const VersionAndCopyRight({super.key});
  

  @override
  Widget build(BuildContext context) {

    final double height = context.screenHeight;

    return Column(
      children: [
        const Line(),
        Center(
          child: GlobalVersion.version
              .text
              .size(15)
              .semiBold
              .makeWithDefaultFont(),
        ),
        Height(height * 0.1),
      ],
    );
  }
}
