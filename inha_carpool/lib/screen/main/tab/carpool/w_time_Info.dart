import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../../provider/doing_carpool/doing_carpool_provider.dart';

class CarpoolTimeInfo extends ConsumerWidget {
  final redText = '10분 전 퇴장 불가';
  final blueText = '24시간 이내 출발';
  final greyText = '24시간 이후 출발';
  final blackText = '출발한 카풀';

  CarpoolTimeInfo({super.key});

  bool isShowLine = false;

  @override
  Widget build(BuildContext context, ref) {
    final width = context.screenWidth;

    return Column(
      children: [
        ExpansionTile(
          onExpansionChanged: (value) {
            if (value) {
              isShowLine = true;
            } else {
              isShowLine = false;
            }

          },
          title: '카풀 시간 안내'.text.size(width * 0.05).bold.make(),
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            '출발 예정 카풀'
                                .text
                                .size(width * 0.05)
                                .bold
                                .color(context.appColors.text)
                                .make(),
                            Icon(
                              Icons.local_taxi_rounded,
                              color: context.appColors.logoColor,
                              size: width * 0.07,
                            ),
                          ],
                        ),
                        ' 현재 참여 중인 카풀 ${ref.watch(doingProvider).length}개'
                            .text
                            .size(width * 0.009)
                            .semiBold
                            .color(context.appColors.text)
                            .make(),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: context.appColors.logoColor,
                              size: width * 0.043,
                            ),
                            '위치 아이콘을 눌러 카풀 위치를 확인하세요!'
                                .text
                                .size(width * 0.009)
                                .color(context.appColors.text)
                                .make(),
                          ],
                        ),
                      ],
                    ),

                    /// 우축 상단 색갈별 시간 안내 위젯
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        colorTimeNotice(redText, Colors.red, context, width),
                        colorTimeNotice(
                            blueText, Colors.blue, context, width),
                        colorTimeNotice(
                            greyText, Colors.grey, context, width),
                        colorTimeNotice(
                            blackText, Colors.black, context, width),
                      ],
                    )
                  ],
                ).pOnly(left: width * 0.03, right: width * 0.03, bottom: width * 0.01),
              ],
            ),
          ],
        ),
        Opacity(
          opacity: isShowLine ? 0 : 1,
          child: Line(color: context.appColors.logoColor),
        ),
      ],
    );
  }

  Widget colorTimeNotice(
      String text, Color color, BuildContext context, double width) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          color: color,
          size: width * 0.028,
        ),
        Width(width * 0.01),
        text.text.size(width * 0.0075).color(context.appColors.text).make(),
      ],
    );
  }
}
