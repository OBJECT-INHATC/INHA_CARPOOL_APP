import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/main/tab/home/btn_floating/w_stream_carpool_btn.dart';
import 'package:quiver/time.dart';

import '../../../../../common/widget/w_height_and_width.dart';
import '../../../../../provider/doing_carpool/doing_carpool_provider.dart';
import '../../carpool/chat/s_chatroom.dart';

class CarpoolCountDown extends ConsumerStatefulWidget {
  const CarpoolCountDown({super.key});

  @override
  ConsumerState<CarpoolCountDown> createState() => _TimerCountdownState();
}

class _TimerCountdownState extends ConsumerState<CarpoolCountDown> {
  @override
  Widget build(BuildContext context) {
    /// 가장 가까운 카풀 상태를 가져옴 (현재 참여중인 카풀 중에서)
    final state = ref.watch(floatingProvider);

    /// 카풀이 시작되었고 24시간 이내일때
    if (state.startTime != null && is24Hours(state.startTime!)) {
      bool timerEnd = false;

      final width = context.screenWidth;
      final height = context.screenHeight;

      final timerController = CountdownTimerController(
          endTime: state.startTime! );

          /// 시간이 끝나면 호출되는 콜백함수

      final textSize = width * 0.03;

      return Padding(
        padding: EdgeInsets.fromLTRB(width * 0.08, 0, 0, height * 0.01),
        child: SizedBox(
          height: height * 0.075,
          width: width * 0.93,
          child: FloatingActionButton(
            elevation: 3,
            mini: false,
            backgroundColor: Colors.grey[800],
            splashColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.black38, width: 1),
            ),
            onPressed: () {
              ref.read(doingProvider.notifier).getNearest();
              Nav.push(ChatroomPage(carId: state.carId!));
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '🚕 ',
                  style: TextStyle(
                      fontSize: textSize + width * 0.03,
                      fontWeight: FontWeight.bold),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          '카풀이',
                          style: TextStyle(
                            fontSize: textSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Width(width * 0.015),
                        CountdownTimer(
                          endWidget: Text(
                            '시작되었습니다!',
                            style: (timerEnd)
                                ? TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.bold)
                                : TextStyle(
                                    fontSize: textSize + 2,
                                    fontWeight: FontWeight.bold),
                          ),
                          controller: timerController,
                          textStyle: TextStyle(
                              fontSize: textSize + width * 0.008,
                              fontWeight: FontWeight.bold),
                          onEnd: ()  {
                            ref.read(doingProvider.notifier).removeCarpool(state.carId!);

                            setState(() {
                              timerEnd = true;
                            });
                          },
                        ),
                        Width(width * 0.015),
                        (timerEnd)
                            ? const SizedBox()
                            : Text(
                                '후에 출발 예정입니다.',
                                style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.bold),
                              ),
                      ],
                    ),
                    Text(
                      '${state.startDetailPoint} - ${state.endDetailPoint}',
                      style: TextStyle(
                        fontSize: textSize + width * 0.008,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: textSize + width * 0.03,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  bool is24Hours(int startTime) {
    if (startTime == null || startTime == 0) return false;
    final currentTime = DateTime.now();
    final startTimeDate = DateTime.fromMillisecondsSinceEpoch(startTime);
    final diff = currentTime.difference(startTimeDate);
    return diff.inSeconds <=
        0; // Check if within 24 hours (negative difference)
  }
}
