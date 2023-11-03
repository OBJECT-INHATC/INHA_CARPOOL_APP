import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/screen/main/tab/home/s_carpool_map.dart';
import '../carpool/s_chatroom.dart'; // DocumentSnapshot를 사용하기 위해 필요한 패키지

class CarpoolListWidget extends StatefulWidget {
  final AsyncSnapshot<List<DocumentSnapshot>> snapshot;
  final ScrollController scrollController;
  final int visibleItemCount;
  final String nickName; // nickName 추가
  final String uid; // uid 추가
  final String gender;

  const CarpoolListWidget({super.key,
    required this.snapshot,
    required this.scrollController,
    required this.visibleItemCount,
    required this.nickName,
    required this.uid,
    required this.gender,
  });

  @override
  State<CarpoolListWidget> createState() => _CarpoolListWidgetState();
}

Color getColorForGender(String gender) {
  const Color maleColor = Colors.blue; // 남성 아이콘 색상
  const Color femaleColor = Colors.pink; // 여성 아이콘 색상
  const Color otherColor = Colors.black; // 그 외 색상
  if (gender == '남성') {
    return maleColor;
  } else if (gender == '여성') {
    return femaleColor;
  } else {
    return otherColor;
  }
}

String _truncateText(String text, int maxLength) {
  if (text.length <= maxLength) {
    return text;
  } else {
    return '${text.substring(0, maxLength - 3)}...';
  }
}

class _CarpoolListWidgetState extends State<CarpoolListWidget> {
  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이를 가져 와서 화면 비율 계산함
    final screenWidth = MediaQuery.of(context).size.width; //360
    final screenHeight = MediaQuery.of(context).size.height; //727

    // 화면 높이의 75%를 ListView.builder의 높이로 사용
    double listViewHeight = screenHeight * 0.75;
    // 각 카드의 높이
    double cardHeight = listViewHeight * 0.53;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 감추기
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          // Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView.builder(
          // 항상 스크롤이 가능하게 만들어서 리스트 갯수가 적을 때도 새로고침 가능하게 만듦
          physics: const AlwaysScrollableScrollPhysics(),
          controller: widget.scrollController,
          itemCount: widget.snapshot.data!.length,
          itemBuilder: (context, index) {
            // null이거나 인덱스가 범위를 벗어날 때 오류를 방지
            // if (widget.snapshot.data != null &&
            //     index < widget.snapshot.data!.length) {
            DocumentSnapshot carpool = widget.snapshot.data![index];
            Map<String, dynamic> carpoolData =
            carpool.data() as Map<String, dynamic>;

            DateTime startTime =
            DateTime.fromMillisecondsSinceEpoch(carpoolData['startTime']);
            DateTime currentTime = DateTime.now();
            Duration difference = startTime.difference(currentTime);

            String formattedDate = DateFormat('HH:mm').format(startTime);

            String formattedTime;
            if (difference.inDays >= 365) {
              formattedTime = '${difference.inDays ~/ 365}년 후';
            } else if (difference.inDays >= 30) {
              formattedTime = '${difference.inDays ~/ 30}달 후';
            } else if (difference.inDays >= 1) {
              formattedTime = '${difference.inDays}일 후';
            } else if (difference.inHours >= 1) {
              formattedTime = '${difference.inHours}시간 후';
            } else {
              formattedTime = '${difference.inMinutes}분 후';
            }

            // 각 아이템을 빌드하는 로직
            return GestureDetector(
              onTap: () {
                int nowMember = carpoolData['nowMember'];
                int maxMember = carpoolData['maxMember'];

                String currentUser =
                    '${widget.uid}_${widget.nickName}_${widget.gender}';
                if (carpoolData['members'].contains(currentUser)) {
                  // 이미 참여한 경우
                  if (carpoolData['admin'] == currentUser) {
                    // 방장인 경우
                    Navigator.push(
                      Nav.globalContext,
                      MaterialPageRoute(
                          builder: (context) => ChatroomPage(
                            carId: carpoolData['carId'],
                            groupName: '카풀 네임',
                            userName: widget.nickName,
                            uid: widget.uid,
                            gender: widget.gender,
                          )),
                    );
                    print('현재 유저: $currentUser');
                    print(carpoolData['members']);
                  } else {
                    Navigator.push(
                      Nav.globalContext,
                      MaterialPageRoute(
                        builder: (context) => ChatroomPage(
                          carId: carpoolData['carId'],
                          groupName: '카풀 네임',
                          userName: widget.nickName,
                          uid: widget.uid,
                          gender: widget.gender,
                        ),
                      ),
                    );
                  }
                } else {
                  // 참여하기로
                  if (nowMember < maxMember) {
                    // 현재 인원이 최대 인원보다 작을 때
                    Nav.push(
                      CarpoolMap(
                        isPopUp: false,
                        startPoint: LatLng(carpoolData['startPoint'].latitude,
                            carpoolData['startPoint'].longitude),
                        startPointName: carpoolData['startPointName'],
                        endPoint: LatLng(carpoolData['endPoint'].latitude,
                            carpoolData['endPoint'].longitude),
                        endPointName: carpoolData['endPointName'],
                        startTime: formattedTime,
                        carId: carpoolData['carId'],
                        admin: carpoolData['admin'],
                        roomGender: carpoolData['gender'],
                      ),
                    );
                  } else {
                    context.showSnackbarMaxmember(context);
                  }
                }
              },
              //=================================================================================작업
              //=================================================================================작업
              //=================================================================================작업
              //=================================================================================작업
              //=================================================================================작업
              //=================================================================================작업
              //=================================================================================작업
              //=================================================================================작업
              child: Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 3, // 그림자의 깊이를 조절하는 elevation 값
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      //첫번째 줄
                      Row(children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.black,
                          size: 18,
                        ),
                        //달력 아이콘과 날짜의 간격
                        Width( screenWidth * 0.01),
                        '${startTime.month}월 ${startTime.day}일 $formattedDate 예정'.text.size(13).make(),
                        //-- 예정과 택시 아이콘 사이 공간 은우--//
                        //Width(screenWidth * 0.17),
                        Width(screenWidth > 400 ? screenWidth * 0.15 + 45 : screenWidth * 0.15),
                        // 2/2명
                        Icon(
                          Icons.directions_car_outlined,
                          color: getColorForGender(
                              carpoolData['gender']),
                        ),

                        // 택시 아이콘과 인원수 사이 간격
                        Width(screenWidth * 0.01),
                        '${carpoolData['nowMember']} / ${carpoolData['maxMember']}명'.text.bold.size(16).make(),

                        // 인원수와 성별 사이 간격
                        Width(screenWidth * 0.01),
                        //무관
                        '${carpoolData['gender']}'.text.size(13).normal.color(Colors.grey).make(),

                      ]),

                      //출발지와 row의간격
                      Height(screenHeight*0.02),

//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------

                      //2번째 줄 출발지
                      Row(
                        children: [
                          Icon(Icons.circle_outlined,
                              color: context.appColors.logoColor,
                              size: 12),

                          // 아이콘과 주소들 사이 간격
                          Width(screenWidth * 0.03),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 출발지 요약주소
                              _truncateText(carpoolData['startDetailPoint'], 32)
                                  .text.color(Colors.black).size(15).bold.make(),
                              // 출발지 풀주소
                              _truncateText(carpoolData['startPointName'], 32)
                                  .text.color(Colors.grey[600]).size(13).bold.make(),
                            ],
                          ),
                        ],
                      ),

                      //구분선 --------------
                      Divider(height: 20, color: Colors.grey[400]),

                      Row( // 3번째 줄 도착지
                        children: [
                          Icon(Icons.circle,
                              color:
                              context.appColors.logoColor,
                              size: 12),

                          // 아이콘과 주소들 사이 간격
                          Width(screenWidth * 0.03),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 도착지 요약주소
                              _truncateText(carpoolData['endDetailPoint'], 32).text
                                  .color(Colors.black).size(15).bold.make(),
                              // 도착지 풀주소
                              _truncateText(carpoolData['endPointName'], 32)
                                  .text.color(Colors.grey[600]).size(13).bold.make(),
                            ],
                          ),
                        ],
                      ),
                      // 박스와 간격
                      Height(screenHeight*0.02),
                      //---------------------------------
                      Row( // 4번째 줄 박스
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //화면 하단 **일 후 출발 박스
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: context.appColors.logoColor,
                                  width: 2),
                            ),
                            height: MediaQuery.of(context).size.height *
                                0.050,
                            width:
                            MediaQuery.of(context).size.width * 0.50,
                            child: Center(
                              child: '$formattedTime 출발'.text.size(17).bold.color(context.appColors.logoColor).make(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}/**/