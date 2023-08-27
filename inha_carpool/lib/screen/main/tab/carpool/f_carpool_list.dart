import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/Colors/app_colors.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/util/carpool.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';

import '../../../../common/constants.dart';

class CarpoolList extends StatefulWidget {
  const CarpoolList({super.key});

  @override
  State<CarpoolList> createState() => _CarpoolListState();
}

class _CarpoolListState extends State<CarpoolList> {

  final storage = FlutterSecureStorage();
  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";

  List<DocumentSnapshot> myCarpools = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loadCarpools();
  }
  //유저 데이터 조회
  Future<void> _loadUserData() async {
    nickName = await storage.read(key: "nickName") ?? "";
    uid = await storage.read(key: "uid") ?? "";
    gender = await storage.read(key: "gender") ?? "";

    setState(() {
      // nickName, email, gender를 업데이트했으므로 화면을 갱신합니다.
    });
  }

  //내가 참여한 카풀 목록 조회
  Future<void> loadCarpools() async {
    String myID = 'subari'; // 내 아이디

    List<DocumentSnapshot> carpools =
        await FirebaseCarpool.getCarpoolsWithMember(myID);

    setState(() {
      myCarpools = carpools;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ListView.builder(
        itemCount: myCarpools.length,
        itemBuilder: (c, i) {
          DocumentSnapshot carpool = myCarpools[i];

          //카풀 날짜 및 시간 변환
          DateTime startTime =
              DateTime.fromMillisecondsSinceEpoch(carpool['startTime']);
          DateTime currentTime = DateTime.now();
          Duration difference = startTime.difference(currentTime);

          String formattedStartTime =
              DateFormat('yyyy.MM.dd HH:mm').format(startTime); // 날짜 형식으로 변환

          String formattedTime;
          if (difference.inDays >= 365) {
            formattedTime = '${difference.inDays ~/ 365}년 후';
          } else if (difference.inDays >= 30) {
            formattedTime =
                '${difference.inDays ~/ 30}달 ${difference.inDays.remainder(30)}일 이후';
          } else if (difference.inDays >= 1) {
            formattedTime =
                '${difference.inDays}일 ${difference.inHours.remainder(24)}시간 이후';
          } else if (difference.inHours >= 1) {
            formattedTime =
                '${difference.inHours}시간 ${difference.inMinutes.remainder(60)}분 이후';
          } else {
            formattedTime = '${difference.inMinutes}분 후';
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatroomPage()),
              );
            },
            child: Card(
              child: Container(
                color: context.appColors.cardBackground,
                margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                padding:
                    EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: Image.asset(
                              "${basePath}/splash/logo600.png",
                            ).image,
                            backgroundColor: Colors.grey.shade200,
                            maxRadius: 35,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  "${formattedStartTime}  ${carpool['startDetailPoint']} - ${carpool['endDetailPoint']}"
                                      .text
                                      .size(16)
                                      .bold
                                      .make(),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  '더워 죽겠는데 빨리 와주세요. 젭라'
                                      .text
                                      .size(12)
                                      .bold
                                      .color(context.appColors.subText)
                                      .make(),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  '마지막 채팅 온 시간'
                                      .text
                                      .size(12)
                                      .normal
                                      .color(context.appColors.subText)
                                      .make(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(children: [
                      Text('${formattedTime}')
                          .text
                          .size(12)
                          .bold
                          .color(context.appColors.text)
                          .make(),
                      const SizedBox(
                        height: 20,
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
