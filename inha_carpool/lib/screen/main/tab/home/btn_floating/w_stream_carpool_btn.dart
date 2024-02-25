import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/models/m_carpool.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/chat/s_chatroom.dart';

import '../../../../../provider/doing_carpool/doing_carpool_provider.dart';

class StreamFloating extends ConsumerStatefulWidget {
  const StreamFloating({Key? key}) : super(key: key);

  @override
  ConsumerState<StreamFloating> createState() => _State();
}

class _State extends ConsumerState<StreamFloating> {
  final _timeStream =
      Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final height = context.screenWidth;
    final carpoolData = ref.watch(doingFirstStateProvider);

    /// todo : 초기화 이후 참여중인 카풀의 상태가 바뀌었을 때
    /// 비동기 작업으로 동기화가 적절하지 않음 0225 이상훈 -> 카풀 나가기 및 추가할때 동기화가 필요함

    print(
        "carpoolData : ${carpoolData.startDetailPoint} - ${carpoolData.endDetailPoint}}");

    return ref.watch(doingFirstStateProvider).startTime != null &&
            is24Hours(carpoolData.startTime!)
        ? SizedBox(
            height: height * 0.14,
            width: width * 0.9,
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
                Nav.push(ChatroomPage(carId: carpoolData.carId!));
              },
              child: StreamBuilder<DateTime>(
                stream: _timeStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      carpoolData.startTime == null) {
                    return const Text('Loading...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final data = snapshot.data;
                    final startTime = DateTime.fromMillisecondsSinceEpoch(
                        carpoolData.startTime!);

                    Duration diff = startTime.difference(data!);
                    // 시간이 지나면 새로고침
                    if (diff.inSeconds == 0) {
                      print('  if (diff.inSeconds == 0) { 카풀 시간이 지났습니다.');
                      ref
                          .read(doingCarpoolNotifierProvider.notifier)
                          .getCarpool();
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Width(width * 0.05),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🚕 카풀이 ${formatDuration(diff)} 후에 출발 예정이에요',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${carpoolData.startDetailPoint} - ${carpoolData.endDetailPoint}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                          ],
                        ),
                        Width(width * 0.05),
                      ],
                    );
                  }
                },
              ),
            ),
          )
        : Container();
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // 현재시간보다 startTime이 24시간 이내인지 판별 하는 함수
  bool is24Hours(int startTime) {
    if (startTime == null || startTime == 0) return false;

    final currentTime = DateTime.now();
    final diff =
        currentTime.difference(DateTime.fromMillisecondsSinceEpoch(startTime));
    return diff.inHours < 24;
  }
}
