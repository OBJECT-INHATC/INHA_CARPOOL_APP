import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/models/m_carpool.dart';
import 'package:inha_Carpool/common/widget/empty_doing.dart';

import 'package:inha_Carpool/screen/main/tab/carpool/chat/s_chatroom.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/w_floating_btn.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/w_notice.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/w_time_info.dart';

import '../../../../provider/doing_carpool/doing_carpool_provider.dart';
import 'cardItem/w_point_row.dart';
import 'cardItem/w_time_map_row.dart';
import 'cardItem/w_last_chat_row.dart';

/// 참여중인 카풀 리스트
class CarpoolList extends ConsumerStatefulWidget {
  const CarpoolList({Key? key}) : super(key: key);

  @override
  ConsumerState<CarpoolList> createState() => _CarpoolListState();
}

class _CarpoolListState extends ConsumerState<CarpoolList> {
  /// 카풀 조회 메서드
  _loadCarpools() async {
    await ref.read(doingProvider.notifier).getCarpool();
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이를 가져 와서 화면 비율 계산함

    final screenHeight = context.screenHeight;

    List<CarpoolModel> carpoolList = ref.watch(doingProvider);


    // 화면 높이의 70%를 ListView.builder의 높이로 사용
    double listViewHeight = screenHeight * 0.7;
    // 각 카드의 높이
    double cardHeight = listViewHeight * 0.3; //1101

    return Column(
      children: [
        /// 공지사항 위젯 호출
        NoticeBox(cardHeight, "carpool"),
        /// 상단에 참여중인 카풀 수와 안내문구 위젯 호출
         CarpoolTimeInfo(),

        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: RefreshIndicator(
              color: context.appColors.logoColor,
              onRefresh: () async {
                setState(() {
                  _loadCarpools();
                });
              },
              child: Scaffold(
                floatingActionButton: (carpoolList.isEmpty) ? null : const RecruitFloatingBtn(
                    floatingMessage: '카풀 등록하기'),
                body: (carpoolList.isEmpty)
                    ? const EmptyDoing(floatingMessage: '참가하고 계신 카풀이 없습니다.\n카풀을 등록해 보세요!')
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: carpoolList.length,
                              itemBuilder: (context, i) {
                                DateTime startTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        carpoolList[i].startTime!);
                                // 지도를 위한 변수
                                String formattedForMap =
                                    _getFormattedDateForMap(startTime);
                                // 채팅방을 위한 변수
                                String formattedStartTime =
                                    _getFormattedDateString(startTime);
                                return InkWell(
                                  highlightColor: Colors.blue.withOpacity(0.2),
                                  splashColor: context.appColors.logoColor
                                      .withOpacity(0.2),
                                  onTap: () {
                                    if (isCarpoolOver(startTime)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('해당 방은 이미 종료된 카풀방입니다!')))
                                          .closed
                                          .then((value) {
                                        _loadCarpools();
                                        setState(() {});
                                      });
                                    } else {
                                      Navigator.push(
                                        Nav.globalContext,
                                        MaterialPageRoute(
                                            builder: (context) => ChatroomPage(
                                                  carId: carpoolList[i].carId!,
                                                )),
                                      );
                                    }
                                  },
                                  /*-----------------------------------------------Card---------------------------------------------------------------*/
                                  child: Card(
                                    color: Colors.white,
                                    surfaceTintColor: Colors.white,
                                    elevation: 3,
                                    // 그림자의 깊이를 조절하는 elevation 값
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: context.appColors.logoColor
                                              .withOpacity(0.67),
                                          width: 1,
                                        ),
                                      ),
                                      padding:
                                          const EdgeInsets.only(bottom: 15),

                                      /// 참여중인 카풀리스트의 카드 아이템 위젯 호출
                                      child: Column(
                                        children: [
                                          // 캘린터 아이콘과 시간 정보
                                          TimeAndMapInfo(
                                              colorTemp: getMapColor(startTime),
                                              formattedStartTime:
                                                  formattedStartTime,
                                              carpoolData: carpoolList[i],
                                              formattedForMap: formattedForMap),

                                          // 출발지 정보
                                          PointInfo(

                                            pointName:
                                                carpoolList[i].startPointName!,
                                            detailPoint:
                                                carpoolList[i].startDetailPoint!,
                                            icon: const Icon(
                                                Icons.circle_outlined),
                                            isStart: true,
                                          ),

                                          // /도착지 정보
                                          PointInfo(
                                            pointName:
                                                carpoolList[i].endPointName!,
                                            detailPoint:
                                                carpoolList[i].endDetailPoint!,
                                            icon: const Icon(Icons.circle),
                                            isStart: false,
                                          ),

                                          /// 마지막 채팅 메시지 정보
                                          ChatLastInfo(
                                              carId: carpoolList[i].carId!),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

String _getFormattedDateString(DateTime dateTime) {
  final now = DateTime.now();
  var difference = now.difference(dateTime);

  if (difference.isNegative) {
    if (difference.inDays < -1) {
      return '${(difference.inDays.abs())}일 후 예정';
    } else if (difference.inDays == -1) {
      return '내일 출발';
    } else if (difference.inHours < -1) {
      return '${(difference.inHours.abs())}시간 후 예정';
    } else if (difference.inHours == -1) {
      return '한 시간 전';
    } else if (difference.inMinutes < -1) {
      return '${(difference.inMinutes.abs())}분 후, 출발지를 확인해 주세요';
    } else if (difference.inMinutes <= 0) {
      return '카풀 출발 시간입니다!';
    }
  } else {
    if (difference.inDays >= 1) {
      return '${difference.inDays}일 전 진행된 카풀';
    } else if (difference.inDays == 1) {
      return '하루 전 진행된 카풀';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}시간 지난 카풀';
    } else {
      return '${difference.inMinutes}분 지난 카풀';
    }
  }
  return '';
}

String _getFormattedDateForMap(DateTime dateTime) {
  return '${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분';
}

// 카풀이 종료되었는지 확인하는 메서드
bool isCarpoolOver(DateTime startTime) {
  DateTime currentTime = DateTime.now();
  Duration difference = currentTime.difference(startTime);
  return difference.inHours >= 24;
}

// 시간과 비례하여 map icon 색상 반환
Color getMapColor(DateTime startTime) {
  // 현재 시간 가져오기
  DateTime now = DateTime.now();

  // 현재 시간과 시작 시간의 차이 계산 (분 단위)
  int differenceInMinutes = startTime.difference(now).inMinutes;

  // 현재 시간이 시작 시간보다 이전인 경우 (출발한 카풀)
  if (differenceInMinutes < 0) {
    return Colors.black; // 검정색 반환
  }
  // 현재 시간이 시작 시간보다 이후인 경우 (출발 예정 카풀)
  else {
    // 현재 시간과 시작 시간의 차이가 10분 이내인 경우
    if (differenceInMinutes <= 10) {
      return Colors.red; // 빨간색 반환
    }
    // 현재 시간과 시작 시간의 차이가 24시간 이내인 경우
    else if (differenceInMinutes <= 1440) {
      return Colors.blue; // 파란색 반환
    }
    // 현재 시간과 시작 시간의 차이가 24시간 이후인 경우
    else {
      return Colors.grey; // 회색 반환
    }
  }
}
