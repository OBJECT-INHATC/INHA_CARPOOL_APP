import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/provider/carpool/carpool_notifier.dart';
import 'package:inha_Carpool/provider/doing_carpool/doing_carpool_provider.dart';
import 'package:inha_Carpool/provider/stateProvider/loading_provider.dart';

import '../../screen/main/tab/carpool/w_floating_btn.dart';

class EmptyDoing extends ConsumerWidget {
  const EmptyDoing({
    super.key,
    required this.floatingMessage,
  });

  final String floatingMessage;

  /// todo : 해당 페이지 리빌드 보고 최적화 필요 0227 by.상훈
  @override
  Widget build(BuildContext context, ref) {
    final height = context.screenHeight;

    print("gfsdgd");

    return ListView(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Height(height * 0.2),
            floatingMessage.text
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
