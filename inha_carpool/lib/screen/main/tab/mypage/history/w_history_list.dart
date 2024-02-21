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

    final authState = ref.read(authProvider);
    final historyState = ref.read(historyProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '이용내역',
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: (historyState.isEmpty)
            ? const EmptyCarpoolList(
                floatingMessage: '아직 이용내역이 없습니다.\n\n카풀을 등록하여\n택시 비용을 줄여 보세요!',
              )
            : ListView.builder(
                itemCount: historyState.length,
                itemBuilder: (BuildContext context, int index) {
                  // 이용내역을 화면에 표시하는 코드 작성
                  int epoch = historyState![index].startTime;
                  DateTime dateTime =
                      DateTime.fromMillisecondsSinceEpoch(epoch);
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
                        member.split('_')[1] != authState.nickName;
                  }).toList();

                  // 함께한 사람이 없는 경우에 대한 처리
                  Widget buildMemberSection() {
                    if (validMembers.isEmpty) {
                      return const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '함께 한 사람이 없습니다',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          const Row(
                            children: [
                              Text(
                                '함께 한 사람',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          for (var member in validMembers)
                            buildMemberRow(
                                member,
                                historyState[index].carPoolId,
                                authState.nickName!),
                        ],
                      );
                    }
                  }

                  return GestureDetector(
                    child: Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 2,
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_taxi_rounded,
                                  color: Colors.indigoAccent,
                                  size: 30,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  formattedDate, // 출발 날짜 시간
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                const Text(
                                  '출발지',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  historyState[index].startDetailPoint,
                                  // 출발지 정보
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              children: [
                                const Text(
                                  '도착지',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  historyState[index].endDetailPoint, // 도착지 정보
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            buildMemberSection(),
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

  Widget buildMemberRow(String member, String carpoolId, String nickName) {
    // 함께한 사람 정보
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        SizedBox(width: screenWidth * 0.03),
        Text(
          member.split('_')[1], // 함께한 사람 닉네임
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
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
                reportedNickName: member.split('_')[1], // 피신고자 닉네임
                myId: nickName, // 신고자 닉네임 (나)
                carpoolId: carpoolId,
              ),
            );
          },
        ),
      ],
    );
  }
}
