import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/main/tab/home/btn_floating/w_stream_carpool_btn.dart';

import '../../../../../common/widget/w_height_and_width.dart';
import '../../../../../provider/doing_carpool/doing_carpool_provider.dart';
import '../../carpool/chat/s_chatroom.dart';

class CarpoolCountDown extends ConsumerStatefulWidget {
  const CarpoolCountDown({super.key});

  @override
  ConsumerState<CarpoolCountDown> createState() => _TimerCountdownState();
}

class _TimerCountdownState extends ConsumerState<CarpoolCountDown> {

  bool timeout = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doingFirstStateProvider);

    if (state.startTime != null && is24Hours(state.startTime!) && timeout) {
      print("state.startTime : ${state.startTime}");
    }

    if (state.startTime != null && is24Hours(state.startTime!)) {
      final width = context.screenWidth;
      final height = context.screenHeight;

      final textSize = width * 0.035;
      final iconSize = width * 0.05;

      return Padding(
        padding:  EdgeInsets.fromLTRB(width * 0.08, 0, 0, height * 0.01),
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
              Nav.push(ChatroomPage(carId: state.carId!));
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🚕 ',
                      style:
                      TextStyle(fontSize: textSize+6, fontWeight: FontWeight.bold),
                    ),
                    Height(height * 0.005),
                  ],
                ),
                Text(
                  '카풀이',
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Width(width * 0.015),
                CountdownTimer(
                  endTime: state.startTime!,
                  textStyle:
                       TextStyle(fontSize: textSize+4, fontWeight: FontWeight.bold),
                  onEnd: () {
                    ///todo : 타이머 종료시 동작
                    setState(() {
                      timeout = false;
                    });
                  },
                ),
                Width(width * 0.015),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Text(
                        '후에 출발 예정이에요',
                        style:
                        TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: textSize+6,
                      ),
                    ],),
                  ],
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

  int _calculateRemainingTime(int departureTime) {
    final now = DateTime.now();
    final departureDateTime =
        DateTime.fromMillisecondsSinceEpoch(departureTime);
    final difference = departureDateTime.difference(now);
    return difference.inSeconds; // Calculate remaining seconds
  }

  String fomattedTime(int? startTime) {
    final now = DateTime.now();
    final startTimeDate = DateTime.fromMillisecondsSinceEpoch(startTime!);
    final remainingTime = startTimeDate.difference(now);
    final formattedTime = formatDuration(remainingTime);
    return formattedTime;
  }
}
