import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';

import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/provider/auth/auth_provider.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/chat/s_chatroom.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/w_notice.dart';
import 'package:inha_Carpool/screen/recruit/s_recruit.dart';

import '../../../../common/widget/empty_list.dart';
import '../../../../provider/ParticipatingCrpool/carpool_provider.dart';
import 'w_card_Item.dart';
import 'w_last_chat.dart';

/// 참여중인 카풀 리스트
class CarpoolList extends ConsumerStatefulWidget {
  const CarpoolList({Key? key}) : super(key: key);

  @override
  ConsumerState<CarpoolList> createState() => _CarpoolListState();
}

class _CarpoolListState extends ConsumerState<CarpoolList> {
  late String nickName = ref.read(authProvider).nickName!;
  late String uid = ref.read(authProvider).uid!;
  late String gender = ref.read(authProvider).gender!;


  /// 카풀 조회 메서드
  Future<List<DocumentSnapshot>> _loadCarpools() async {
    String myID = uid;
    String myNickName = nickName;
    String myGender = gender;

    List<DocumentSnapshot> carpools =
        await FirebaseCarpool.getCarpoolsRemainingForDay(
            myID, myNickName, myGender);
    return carpools;
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이를 가져 와서 화면 비율 계산함
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final carpoolCount = ref.watch(carpoolNotifierProvider);

    // 화면 높이의 70%를 ListView.builder의 높이로 사용
    double listViewHeight = screenHeight * 0.7;
    // 각 카드의 높이
    double cardHeight = listViewHeight * 0.3; //1101

    // uri 확인
    bool isOnUri = true;

    return Column(
      children: [
        /// 공지사항 위젯 호출
        NoticeBox(cardHeight, "carpool"),
        /// 상단에 참여중인 카풀 수와 안내문구 위젯 호출
        carPoolFirstWidget(context, carpoolCount.data.length, screenWidth),



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
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: _loadCarpools(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    /// 참가하고 있는 카풀이 없는 경우
                    return const SafeArea(
                      child: EmptyCarpoolList(
                        message: '참가하고 계신 카풀이 없습니다.\n카풀을 등록해 보세요!',
                      ),
                    );
                  }
                  /// 참가하고 있는 카풀이 있는 경우
                  else {
                    List<DocumentSnapshot> myCarpools = snapshot.data!;

                    return SafeArea(
                      child: Scaffold(
                        floatingActionButton: FloatingActionButton(
                          heroTag: "recruit_from_myCarpool",
                          elevation: 10,
                          backgroundColor: Colors.white,
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            //side: const BorderSide(color: Colors.white, width: 1),
                          ),
                          onPressed: () {
                            Navigator.push(
                              Nav.globalContext,
                              MaterialPageRoute(
                                  builder: (context) => const RecruitPage()),
                            );
                          },
                          child: '+'
                              .text
                              .size(50)
                              .color(context.appColors.logoColor,)
                              .make(),
                        ),
                        body: Column(
                          children: [

                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    myCarpools.isNotEmpty ? myCarpools.length : 0,
                                itemBuilder: (context, i) {

                                    DocumentSnapshot carpool = myCarpools[i];
                                    Map<String, dynamic> carpoolData =
                                        carpool.data() as Map<String, dynamic>;

                                    DateTime startTime =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            carpool['startTime']);
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
                                                      carId: carpool['carId'],
                                                    )),
                                          );
                                        }
                                      },

                                      /*-----------------------------------------------Card---------------------------------------------------------------*/
                                      child: Card(
                                        color: Colors.white,
                                        surfaceTintColor: Colors.transparent,
                                        elevation: 3,
                                        // 그림자의 깊이를 조절하는 elevation 값
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),

                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: context.appColors.logoColor
                                                  .withOpacity(0.67),
                                              width: 1,
                                            ),
                                          ),
                                          padding: const EdgeInsets.only(bottom: 15),
                                          child: Column(
                                            children: [
                                              /// 참여중인 카풀리스트의 카드 아이템 위젯 호출
                                              CardItem(
                                                  colorTemp: getColorBasedOnSuffix(
                                                      formattedStartTime),
                                                  screenWidth: screenWidth,
                                                  formattedStartTime:
                                                      formattedStartTime,
                                                  carpoolData: carpoolData,
                                                  formattedForMap: formattedForMap),
                                              //출발지와 row의간격
                                              Height(screenHeight * 0.01),
                                              //2번째 줄 출발지
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.circle_outlined,
                                                        color: context.appColors.logoColor,
                                                        size: 12),
                                                    // 아이콘과 주소들 사이 간격
                                                    Width(screenWidth * 0.03),

                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        // 출발지 요약주소
                                                        Text(
                                                          "${carpoolData['startDetailPoint']}",
                                                          style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        // 출발지 풀주소
                                                        Text(
                                                          shortenText(
                                                              carpoolData[
                                                                  'startPointName'],
                                                              15),
                                                          style: const TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_downward_rounded,
                                                      size: 18,
                                                      color: Colors.indigo,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.circle,
                                                        color: context
                                                            .appColors.logoColor,
                                                        size: 12),
                                                    // 아이콘과 주소들 사이 간격
                                                    Width(screenWidth * 0.03),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        // 출발지 요약주소
                                                        Text(
                                                          "${carpoolData['endDetailPoint']}",
                                                          style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        // 출발지 풀주소
                                                        Text(
                                                          shortenText(
                                                              carpoolData[
                                                                  'endPointName'],
                                                              15),
                                                          style: const TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // 박스와 간격
                                              Height(screenHeight * 0.01),

                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                child: Divider(
                                                    height: 20,
                                                    color:
                                                        context.appColors.logoColor),
                                              ),
                                              //--------- 하단 라스트 메시지 위젯 호출
                                              chatLastMSG(carpool: carpool),
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
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  SizedBox carPoolFirstWidget(BuildContext context,
      int countCarpool, double screenWidth) {
    const redText = '10분전 퇴장 불가';
    const blueText = '24시간 전';
    const greyText = '24시간 이후';
    const blackText = '종료된 카풀';

    return SizedBox(
      height: 90,
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  '현재 참여 중인 카풀 $countCarpool개'
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
              Width(screenWidth * 0.03),
              /// 우축 상단 색갈별 시간 안내 위젯
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  colorTimeNotice(redText, Colors.red),
                  colorTimeNotice(blueText, Colors.blue),
                  colorTimeNotice(greyText, Colors.grey),
                  colorTimeNotice(blackText, Colors.black),
                ],
              )
            ],
          ),
          Line(
            height: 1,
            margin: const EdgeInsets.all(5),
            color: context.appColors.logoColor,
          ),

        ],
      ),
    );
  }

  Widget colorTimeNotice(String text, Color color) {
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

  String _getFormattedDateString(DateTime dateTime) {
    final now = DateTime.now();
    var difference = now.difference(dateTime);

    if (difference.isNegative) {
      if (difference.inDays < -1) {
        return '${(difference.inDays.abs())}일 후 예정';
      } else if (difference.inDays == -1) {
        return '하루 전';
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


  String shortenText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength - 4)}...';
    }
  }

  String _getFormattedDateForMap(DateTime dateTime) {
    return '${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분';
  }

  bool isCarpoolOver(DateTime startTime) {
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(startTime);
    return difference.inHours >= 24;
  }

  Color getColorBasedOnSuffix(String text) {
    if (text.endsWith('가')) {
      return context.appColors.logoColor; // '가'로 끝나면 초록색 반환
    } else if (text.endsWith('요')) {
      return Colors.red; // '요'로 끝나면 빨간색 반환
    }
    return Colors.grey; // 다른 경우에는 회색 반환
  }
}
