import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/velocityx_extension.dart';

class VersionAndCopyRight extends StatelessWidget {
  const VersionAndCopyRight({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        const Line(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: version
                .text
                .size(15)
                .semiBold
                .makeWithDefaultFont(),
          ),
        ),
      ],
    );
  }
}
