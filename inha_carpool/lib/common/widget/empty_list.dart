import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/provider/carpool/carpool_notifier.dart';
import 'package:inha_Carpool/provider/stateProvider/loading_notifier.dart';
import 'package:provider/provider.dart';

import '../../screen/main/tab/carpool/w_floating_btn.dart';

class EmptyCarpoolList extends ConsumerWidget {
  const EmptyCarpoolList({
    super.key,
    required this.floatingMessage,
    required this.isSearch,
  });

  final String floatingMessage;
  final bool isSearch;

  @override
  Widget build(BuildContext context, ref) {

    final isSearchState = ref.watch(searchProvider);
    final height = context.screenHeight;
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
            (!isSearchState && !isSearch)
                ? RecruitFloatingBtn(floatingMessage: floatingMessage)
                : IconButton(
                    onPressed: () {
                      ref.read(carpoolProvider.notifier).loadCarpoolTimeBy();
                      ref.read(searchProvider.notifier).state = false;
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 40,
                      color: context.appColors.logoColor,
                    )),
          ],
        ),
      ],
    );
  }
}
