import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import '../../../../provider/stateProvider/auth_provider.dart';
import '../../map/s_carpool_map.dart';
import '../carpool/chat/s_chatroom.dart';
import 'enum/map_type.dart'; // DocumentSnapshot를 사용하기 위해 필요한 패키지

class CarpoolListItem extends ConsumerStatefulWidget {
  final AsyncSnapshot<List<DocumentSnapshot>> snapshot;
  final ScrollController scrollController;
  final int visibleItemCount;

  const CarpoolListItem({
    super.key,
    required this.snapshot,
    required this.scrollController,
    required this.visibleItemCount,
  });

  @override
  ConsumerState<CarpoolListItem> createState() => _CarpoolListItemState();
}

Color getColorForGender(String gender) {
  if (gender == '남성') {
    return  Colors.blue;
  } else if (gender == '여성') {
    return Colors.pink;
  } else {
    return Colors.black;
  }
}

String _truncateText(String text, int maxLength) {
  if (text.length <= maxLength) {
    return text;
  } else {
    return '${text.substring(0, maxLength - 1)}...';
  }
}



class _CarpoolListItemState extends ConsumerState<CarpoolListItem> {

  late String nickName = "";
  late String uid = "";
  late String gender = "";




  Future<void> _loadUserData() async {
    nickName = ref.read(authProvider).nickName!;
    uid = ref.read(authProvider).uid!;
    gender = ref.read(authProvider).gender!;
  }

  @override
  void initState() {
    _loadUserData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이를 가져 와서 화면 비율 계산함
    final width = context.screenWidth; //360
    final height =context.screenHeight; //360


    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: widget.scrollController,
        itemCount: (widget.snapshot.data?.length ?? 0) ,
        itemBuilder: (context, index) {
            // 원래의 리스트 아이템
            final originalIndex = index;
            if (widget.snapshot.data != null &&
                originalIndex < widget.snapshot.data!.length) {
              DocumentSnapshot carpool = widget.snapshot.data![originalIndex];

              Map<String, dynamic> carpoolData =
                  carpool.data() as Map<String, dynamic>;

              DateTime startTime =
                  DateTime.fromMillisecondsSinceEpoch(carpoolData['startTime']);

              DateTime currentTime = DateTime.now();
              Duration difference = startTime.difference(currentTime);


              String formattedDate = DateFormat('HH:mm').format(startTime);

              String formattedTime = getDate(difference);

              // 각 아이템을 빌드하는 로직
              return GestureDetector(
                onTap: () {
                  int nowMember = carpoolData['nowMember'];
                  int maxMember = carpoolData['maxMember'];

                  String currentUser =
                      '${uid}_${nickName}_$gender';
                  if (carpoolData['members'].contains(currentUser)) {
                    // 이미 참여한 경우
                    if (carpoolData['admin'] == currentUser) {
                      // 방장인 경우
                      Navigator.push(
                        Nav.globalContext,
                        MaterialPageRoute(
                            builder: (context) => ChatroomPage(
                                  carId: carpoolData['carId'],
                                )),
                      );
                    } else {
                      Navigator.push(
                        Nav.globalContext,
                        MaterialPageRoute(
                          builder: (context) => ChatroomPage(
                            carId: carpoolData['carId'],
                          ),
                        ),
                      );
                    }
                  } else {
                    // 현재 인원이 최대 인원보다 작을 때
                    if (nowMember < maxMember) {
                      Nav.push(
                        CarpoolMap(
                          startTime: startTime.millisecondsSinceEpoch,
                          mapType: MapCategory.all,
                          isMember: false,
                          startPoint: LatLng(carpoolData['startPoint'].latitude,
                              carpoolData['startPoint'].longitude),
                          startPointName: carpoolData['startPointName'],
                          endPoint: LatLng(carpoolData['endPoint'].latitude,
                              carpoolData['endPoint'].longitude),
                          endPointName: carpoolData['endPointName'],
                          startTimeString: formattedTime,
                          carId: carpoolData['carId'],
                          admin: carpoolData['admin'],
                          roomGender: carpoolData['gender'],
                        ),
                      );
                    } else {
                      context.showSnackbarText(context, '카풀 시작 10분 전이므로 불가능합니다.', bgColor: Colors.red );
                    }
                  }
                },
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 3,
                  // 그림자의 깊이를 조절하는 elevation 값
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        //첫번째 줄
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.black,
                              size: 18,
                            ),
                            Width(height * 0.01),
                            '${startTime.month}월 ${startTime.day}일 $formattedDate 예정'
                                .text
                                .size(13)
                                .make(),
                            const Spacer(),
                            Icon(
                              Icons.directions_car_outlined,
                              color: getColorForGender(carpoolData['gender']),
                            ),
                            Width(height * 0.01),
                            '${carpoolData['nowMember']} / ${carpoolData['maxMember']}명'
                                .text
                                .bold
                                .size(16)
                                .make(),
                            Width(height * 0.01),
                            '${carpoolData['gender']}'
                                .text
                                .size(13)
                                .normal
                                .color(Colors.grey)
                                .make(),
                          ],
                        ),
                        //출발지와 row의간격
                        Height(height * 0.02),

                        //2번째 줄 출발지
                        Row(
                          children: [
                            Icon(Icons.circle_outlined,
                                color: context.appColors.logoColor, size: 12),
                            // 아이콘과 주소들 사이 간격
                            Width(width * 0.03),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 출발지 요약주소
                                _truncateText(
                                    carpoolData['startDetailPoint'], 32)
                                    .text
                                    .color(Colors.black)
                                    .size(15)
                                    .bold
                                    .make(),
                                // 출발지 풀주소
                                _truncateText(carpoolData['startPointName'], 30)
                                    .text
                                    .color(Colors.grey[600])
                                    .size(13)
                                    .bold
                                    .make(),
                              ],
                            ),
                          ],
                        ),

                        //구분선 --------------
                        Divider(height: 20, color: Colors.grey[400]),

                        Row(
                          // 3번째 줄 도착지
                          children: [
                            Icon(Icons.circle,
                                color: context.appColors.logoColor, size: 12),

                            // 아이콘과 주소들 사이 간격
                            Width(width * 0.03),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 도착지 요약주소
                                _truncateText(carpoolData['endDetailPoint'], 32)
                                    .text
                                    .color(Colors.black)
                                    .size(15)
                                    .bold
                                    .make(),
                                // 도착지 풀주소
                                _truncateText(carpoolData['endPointName'], 32)
                                    .text
                                    .color(Colors.grey[600])
                                    .size(13)
                                    .bold
                                    .make(),
                              ],
                            ),
                          ],
                        ),
                        // 박스와 간격
                        Height(height * 0.02),
                        //---------------------------------
                        Row(
                          // 4번째 줄 박스
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //화면 하단 **일 후 출발 박스
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: context.appColors.logoColor,
                                      width: 2),
                                ),
                                height: height * 0.05,
                                child: Center(
                                  child: '$formattedTime 출발'
                                      .text
                                      .size(17)
                                      .bold
                                      .color(context.appColors.logoColor)
                                      .make(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

        },
      ),
    );
  }

  // 날짜를 계산하는 함수
  String getDate(Duration difference) {
    if (difference.inDays >= 365) {
      return '${difference.inDays ~/ 365}년 후';
    } else if (difference.inDays >= 30) {
      return '${difference.inDays ~/ 30}달 후';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}일 후';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}시간 후';
    } else {
      return '${difference.inMinutes}분 후';
    }
  }
}
