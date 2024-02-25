/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../../../provider/carpool/carpool_notifier.dart';
import '../../../../../provider/doing_carpool/doing_carpool_provider.dart';

class StreamFloating extends  ConsumerStatefulWidget {
  const StreamFloating({Key? key}) : super(key: key);

  @override
  ConsumerState<StreamFloating> createState() => _State();
}

class _State extends ConsumerState<StreamFloating> {
  @override
  Widget build(BuildContext context) {

    final width = context.screenWidth;
    final height = context.screenWidth;
    final carpoolData = ref.watch(doingCarpoolNotifierProvider);

    return SizedBox(
      height: height * 0.1,
      width: width * 0.9,

      child: FloatingActionButton(
        elevation: 3,
        mini: false,
        backgroundColor: Colors.grey[800],
        splashColor: Colors.transparent,
        // 클릭 모션 효과 삭제
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.black38, width: 1),
        ),
        onPressed: () {
          // Handle button press here and update the stream data
        },
        child: StreamBuilder<DateTime>(
          stream: _timeStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final data = snapshot.data;
              Duration diff = startTime.difference(data!);
              // diff가 0초일 경우 페이지 새로고침
              if (diff.inSeconds <= 0) {
                 ref.read(doingCarpoolNotifierProvider.notifier).getCarpool();
                // return SizedBox.shrink(); // 혹은 다른 UI 요소
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Width(width *0.05),
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
                        '${carpoolData['startDetailPoint']} - ${carpoolData['endDetailPoint']}',
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
                  Width(width *0.05),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
*/
