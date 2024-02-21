import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/provider/history/history_notifier.dart';
import 'package:inha_Carpool/screen/dialog/d_complainAlert.dart';
import 'package:inha_Carpool/service/api/Api_repot.dart';

import '../../../../../common/widget/empty_list.dart';
import '../../../../../provider/auth/auth_provider.dart';

class HistoryList extends ConsumerStatefulWidget {
  HistoryList({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryList> createState() => _RecordListState();
}

class _RecordListState extends ConsumerState<HistoryList> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    final screenHeight = context.screenHeight;

    final currentUserState = ref.read(authProvider);
    final historyState = ref.read(historyProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '이용내역',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        surfaceTintColor: Colors.white,
      ),
      body: Container(
        child: (historyState.isEmpty)
            ? const EmptyCarpoolList(
                floatingMessage: '아직 이용내역이 없습니다.\n\n카풀을 등록하여\n택시 비용을 줄여 보세요!',
              )
            : ListView.builder(
                itemCount: historyState.length,
                itemBuilder: (BuildContext context, int index) {
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                      historyState[index].startTime);
                  String formattedDate =
                      "${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분";

                  // '함께 한 사람' 정보 리스트를 생성
                  List<String> members = [
                    historyState[index].member1,
                    historyState[index].member2,
                    historyState[index].member3,
                    historyState[index].member4
                  ];

                  // 멤버 리스트에서 현재 유저와 동일한 이름의 멤버를 필터링
                  List<String> validMembers = members.where((member) {
                    return member != '' &&
                        member.split('_')[1] != currentUserState.nickName;
                  }).toList();

                  return Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 2,
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.indigoAccent, width: 0.7),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Height(screenHeight * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              pointCol(historyState[index].startDetailPoint,
                                  'startMarker', screenWidth),
                              Icon(
                                Icons.arrow_forward,
                                size: screenWidth * 0.06,
                              ),
                              pointCol(historyState[index].endDetailPoint,
                                  'endMarker', screenWidth),
                            ],
                          ),
                          Height(screenHeight * 0.02),
                          validMembers.isNotEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_alt,
                                      size: screenHeight * 0.03,
                                      color: Colors.black,
                                    ),
                                    Width(screenWidth * 0.02),
                                    '함께 한 사람'
                                        .text
                                        .size(screenWidth * 0.04)
                                        .bold
                                        .make(),
                                  ],
                                )
                              : const SizedBox(),
                          Height(screenHeight * 0.01),
                          for (var member in validMembers)
                            buildMemberRow(
                                member,
                                historyState[index].carPoolId,
                                currentUserState.nickName!,
                                screenWidth),
                          historyTime(
                            screenWidth,
                            formattedDate,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Column pointCol(String point, String marker, double screenWidth) {
    return Column(
      children: [
        Image(
          image: AssetImage('assets/image/map/$marker.png'),
          width: screenWidth * 0.17,
          height: screenWidth * 0.09,
        ),
        point.text.size(screenWidth * 0.04).bold.make(),
      ],
    );
  }

  Column historyTime(
    double screenWidth,
    String formattedDate,
  ) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Line(
            color: Colors.black26,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
          child: Row(
            children: [
              Icon(
                Icons.local_taxi_rounded,
                size: screenWidth * 0.055,
                color: Colors.blue,
              ),
              SizedBox(width: screenWidth * 0.015),
              Text(
                '이용날짜',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: screenWidth * 0.03),
              formattedDate.text.size(screenWidth * 0.04).make(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMemberRow(
      String member, String carpoolId, String myNickName, double screenWidth) {
    String friendsNickName = member.split('_')[1];
    // 함께한 사람 정보

    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.warning_rounded,
            size: 20,
            color: Colors.red,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ComplainAlert(
                reportedNickName: friendsNickName, // 피신고자 닉네임
                myId: myNickName, // 신고자 닉네임 (나)
                carpoolId: carpoolId,
              ),
            );
          },
        ),
        friendsNickName.text.size(16).make(),
      ],
    );
  }
}
