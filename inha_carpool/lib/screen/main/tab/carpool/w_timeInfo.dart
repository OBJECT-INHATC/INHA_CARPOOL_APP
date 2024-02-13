import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/provider/ParticipatingCrpool/carpool_provider.dart';

class CarpoolTimeInfo extends ConsumerWidget {
  final redText = '10분 전 퇴장 불가';
  final blueText = '24시간 이내 출발';
  final greyText = '24시간 이후 출발';
  final blackText = '출발한 카풀';

  const CarpoolTimeInfo({super.key});

  @override
  Widget build(BuildContext context, ref) {

    final width = context.screenWidth;

    return SizedBox(
      height: 90,
      child: Column(
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
                          .size(20)
                          .bold
                          .color(context.appColors.text)
                          .make(),
                      Icon(
                        Icons.local_taxi_rounded,
                        color: context.appColors.logoColor,
                        size: 23,
                      ),
                    ],
                  ),
                  '현재 참여 중인 카풀 ${ref.watch(carpoolNotifierProvider).data.length}개'
                      .text
                      .size(10)
                      .semiBold
                      .color(context.appColors.text)
                      .make(),
                  '위치 아이콘을 눌러주세요!'
                      .text
                      .size(10)
                      .color(context.appColors.text)
                      .make(),
                ],
              ),


              /// 우축 상단 색갈별 시간 안내 위젯
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  colorTimeNotice(redText, Colors.red, context),
                  colorTimeNotice(blueText, Colors.blue,context),
                  colorTimeNotice(greyText, Colors.grey,context),
                  colorTimeNotice(blackText, Colors.black,context),
                ],
              )
            ],
          ).pOnly(left: width * 0.03, right: width * 0.03),
          Line(
            height: 1,
            margin: const EdgeInsets.all(5),
            color: context.appColors.logoColor,
          ),

        ],
      ),
    );
  }

  Widget colorTimeNotice(String text, Color color,BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          color: color,
          size: 10,
        ),
        const Width(5),
        text.text.size(10).color(context.appColors.text).make(),
      ],
    );
  }
}
