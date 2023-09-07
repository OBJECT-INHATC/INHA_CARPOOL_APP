import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/screen/main/tab/home/s_carpool_map.dart';
import 'package:nav/nav.dart';

import '../carpool/s_chatroom.dart'; // DocumentSnapshot를 사용하기 위해 필요한 패키지

class CarpoolListWidget extends StatefulWidget {
  final AsyncSnapshot<List<DocumentSnapshot>> snapshot;
  final ScrollController scrollController;
  final int visibleItemCount;
  final String nickName; // nickName 추가
  final String uid; // uid 추가

  const CarpoolListWidget({
    required this.snapshot,
    required this.scrollController,
    required this.visibleItemCount, required this.nickName, required this.uid,
  });

  @override
  State<CarpoolListWidget> createState() => _CarpoolListWidgetState();
}

class _CarpoolListWidgetState extends State<CarpoolListWidget> {



  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 항상 스크롤이 가능하게 만들어서 리스트 갯수가 적을 때도 새로고침 가능하게 만듦
      physics: const AlwaysScrollableScrollPhysics(),
      controller: widget.scrollController,
      itemCount: widget.visibleItemCount,
      itemBuilder: (context, index) {
        DocumentSnapshot carpool = widget.snapshot.data![index];
        Map<String, dynamic> carpoolData =
        carpool.data() as Map<String, dynamic>;

        DateTime startTime =
        DateTime.fromMillisecondsSinceEpoch(carpoolData['startTime']);
        DateTime currentTime = DateTime.now();
        Duration difference = startTime.difference(currentTime);

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
        if (carpoolData['gender'] == '남자') {
          borderColor = Colors.blue; // 남자일 때 보더 색
        } else if (carpoolData['gender'] == '여자') {
          borderColor = Colors.red; // 여자일 때 보더 색
        } else {
          borderColor = Colors.grey; // 무관일 때 보더 색
        }

        // 각 아이템을 빌드하는 로직
        return GestureDetector(
          onTap: () {
            int nowMember = carpoolData['nowMember'];
            int maxMember = carpoolData['maxMember'];

            String currentUser = '${widget.uid}_${widget.nickName}';
            if (carpoolData['members'].contains(currentUser)) {
              // 이미 참여한 경우
              if (carpoolData['admin'] == currentUser) {
                // 방장인 경우
                Navigator.push(
                  Nav.globalContext,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatroomPage(
                          carId: carpoolData['carId'],
                          groupName: '카풀 네임',
                          userName: widget.nickName,
                          uid: widget.uid,)
                  ),
                );
                print('현재 유저: $currentUser');
                print(carpoolData['members']);
              } else {
                Navigator.push(
                  Nav.globalContext,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatroomPage(
                            carId: carpoolData['carId'],
                            groupName: '카풀 네임',
                            userName: widget.nickName,
                            uid: widget.uid,)
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
                    startTime: formattedTime,
                    carId: carpoolData['carId'],
                    admin: carpoolData['admin'],
                  ),
                );
              } else {
                context.showSnackbarMaxmember(context);
              }
            }
          },
          child: Card(
            surfaceTintColor: Colors.transparent,
            color: carpoolData['gender'] == '무관'
                ? Colors.white
           : carpoolData['gender'] == '남자'
                ? Colors.blue[100]
                : Colors.red[100],
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            // shape: RoundedRectangleBorder(
            //   side: BorderSide(width: 2, color: borderColor),
            //   borderRadius: BorderRadius.circular(10),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SizedBox(height: context.height(0.01),),
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

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                        //방장 정보 가져오기
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.grey, size: 25),
                            Text('${carpoolData['admin'].split('_')[1]}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),

                        Row(
                          children: [
                            const Icon(Icons.directions_car_outlined),
                            Text(
                                '${carpoolData['nowMember']}/${carpoolData['maxMember']}명',
                                style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                        //방장 평점
                      ]),
                    ),
                  ),
                ]),
                Container(
                  // margin: const EdgeInsets.all(7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(7.0),
                                  width: context.width(0.02),
                                  // desired width
                                  height: context.height(0.04),
                                  // desired height
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Center(
                                      )),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${carpoolData['startDetailPoint']}  ",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                  Text("${carpoolData['startPointName']}",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              // const SizedBox(width: 5),

                            ],
                          ),
                          Container(

                              margin:
                              const EdgeInsets.only(left: 0, top: 5, bottom: 5),

                              child: const Column(children: [
                                Icon(Icons.arrow_drop_down_outlined),
                                // Icon(Icons.arrow_drop_down_outlined),
                              ])),
                          Row(
                            children: [
                              Container(
                                  margin: const EdgeInsets.all(7.0),
                                  width: context.width(0.02),
                                  // desired width
                                  height: context.height(0.04),
                                  // desired height
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child:  Center(
                                      )),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${carpoolData['endDetailPoint']}",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                  Text("${carpoolData['endPointName']}",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(width: 5),

                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(children: [
                      Expanded(
                        child: Container(
                          // desired width
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                // POINT
                                color: Colors.black,
                              ),
                            ),
                          ),

                          child: Column(children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size:14),
                                Text(
                                    '${startTime.month}월 ${startTime.day}일 ${startTime.hour}시 ${startTime.minute}분 출발',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black)),
                              ],
                            ),

                            //방 생성시 설정했던 성별 표시
                            Row(
                              children: [
                                const Icon(Icons.perm_identity_outlined, size: 12,),
                                Text((carpoolData['gender']),style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    ) ),
                              ],
                            ),
                            Text(formattedTime,
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 10)
              ],
            ),
          ),
        );
      },
    );
  }
}
