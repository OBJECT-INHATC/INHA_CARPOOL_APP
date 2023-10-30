import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/screen/main/tab/home/s_carpool_map.dart';
import 'package:nav/nav.dart';
import 'package:intl/intl.dart';
import '../carpool/s_chatroom.dart'; // DocumentSnapshot를 사용하기 위해 필요한 패키지

class CarpoolListWidget extends StatefulWidget {
  final AsyncSnapshot<List<DocumentSnapshot>> snapshot;
  final ScrollController scrollController;
  final int visibleItemCount;
  final String nickName; // nickName 추가
  final String uid; // uid 추가
  final String gender;

  const CarpoolListWidget({
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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

            Color borderColor;
            if (carpoolData['gender'] == '남성') {
              borderColor = Colors.blue; // 남자일 때 보더 색
            } else if (carpoolData['gender'] == '남성') {
              borderColor = Colors.red; // 여자일 때 보더 색
            } else {
              borderColor = Colors.grey; // 무관일 때 보더 색
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
              child: Card(
                surfaceTintColor: Colors.transparent,
                // color: Colors.blue[100],
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // 원하는 모서리 반지름 값
                  side: BorderSide(
                      color: context.appColors.divider, width: 1), // 모서리의 색과 굵기
                ),
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                // shape: RoundedRectangleBorder(
                //   side: BorderSide(width: 2, color: borderColor),
                //   borderRadius: BorderRadius.circular(10),
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: context.height(0.005),
                    ),
                    Row(children: [
                      Expanded(
                        child: Container(
                          // width: context.width(0.8),

                          // desired width
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                              // border: Border(
                              //   bottom: BorderSide(
                              //     // POINT
                              //     color: Colors.black,
                              //   ),
                              // ),
                              ),

                          child:
                              /*Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(Icons.calendar_today_outlined,
                                            size: 14),
                                        SizedBox(
                                          width: context.width(0.01),
                                        ),
                                        Text(
                                            '${startTime.month}월 ${startTime.day}일 ${startTime.hour}시 ${startTime.minute}분 예정',
                                            style: const TextStyle(
                                                fontSize: 13, color: Colors.black)),
                                      ],
                                    ), */
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                //방장 정보 가져오기
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        color: Colors.black, size: 18),
                                    SizedBox(
                                      width: context.width(0.01),
                                    ),
                                    Text(
                                        '${startTime.month}월 ${startTime.day}일 ' +
                                            formattedDate +
                                            ' 예정',
                                        style: const TextStyle(
                                          fontSize: 13,
                                        )),
                                  ],
                                ),

                                // 방의 인원 및 성별
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car_outlined,
                                      color: getColorForGender(
                                          carpoolData['gender']),
                                    ),
                                    SizedBox(
                                      width: context.width(0.01),
                                    ),
                                    Text(
                                      '${carpoolData['nowMember']} / ${carpoolData['maxMember']}명 ',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      carpoolData['gender'],
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),

                                //방장 평점
                              ]),
                        ),
                      ),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  // 출발지 아이콘 왼쪽 여백 추가
                                  child: Icon(Icons.circle_outlined,
                                      color: Color.fromARGB(255, 70, 100, 192),
                                      size: 12),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _truncateText(
                                          carpoolData['startDetailPoint'], 32),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _truncateText(
                                          carpoolData['startPointName'], 32),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 13),
                              // 여백을 위아래로 5픽셀 추가
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                width: screenWidth - 100,
                                height: 0.5,
                                color: Colors.grey,
                              ),
                            ),

                            //방 생성시 설정했던 성별 표시
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  // 목적지 아이콘의 왼쪽 여백 추가
                                  child: Icon(Icons.circle,
                                      color: context.appColors.logoColor,
                                      size: 12),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _truncateText(
                                          carpoolData['endDetailPoint'], 32),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _truncateText(
                                          carpoolData['endPointName'], 32),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //화면 하단 **일 후 출발 박스
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: context.appColors.logoColor, width: 2),
                          ),

                          height: MediaQuery.of(context).size.height * 0.055,
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Center(
                            child: Text('$formattedTime 출발',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: context.appColors.logoColor,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ).pSymmetric(v: 15)
                      ],
                    ),
                  ],
                ),
              ),
            );
            // } else {
            //   return null;
            // }
          },
        ),
      ),
    );
  }
}
