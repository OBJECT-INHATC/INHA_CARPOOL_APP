import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/screen/main/tab/home/btn_floating/w_stream_carpool_btn.dart';

import '../../../../../provider/doing_carpool/doing_carpool_provider.dart';

class CarpoolCountDown extends ConsumerStatefulWidget {
  const CarpoolCountDown({super.key});

  @override
  ConsumerState<CarpoolCountDown> createState() => _TimerCountdownState();
}

class _TimerCountdownState extends ConsumerState<CarpoolCountDown> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doingFirstStateProvider);

    if(state.startTime != null && is24Hours(state.startTime!)) {
      return  SizedBox(
        height: 20,
        child: Text('🚕 카풀이 ${fomattedTime(state.startTime)} 후에 출발 예정이에요'),
      );
    }else{
      return const SizedBox();
    }
  }

  bool is24Hours(int startTime) {
    if (startTime == null || startTime == 0) return false;
    final currentTime = DateTime.now();
    final startTimeDate = DateTime.fromMillisecondsSinceEpoch(startTime);
    final diff = currentTime.difference(startTimeDate);
    return diff.inSeconds <= 0; // Check if within 24 hours (negative difference)
  }

  int _calculateRemainingTime(int departureTime) {
    final now = DateTime.now();
    final departureDateTime = DateTime.fromMillisecondsSinceEpoch(departureTime);
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
