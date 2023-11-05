import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/dto/HistoryRequestDTO.dart';
import 'package:inha_Carpool/screen/dialog/d_complainAlert.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/service/api/ApiService.dart';
import 'package:isar/isar.dart';

class RecordList extends StatefulWidget {

   RecordList({Key? key}) : super(key: key);

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  final storage = FlutterSecureStorage();
  final ApiService apiService = ApiService();
  late String uid;
  late String nickName;

  @override
  void initState() {
    super.initState();
  }

  Future<List<HistoryRequestDTO>> _loadHistoryData() async {
    await _loadUser();
    final response = await apiService.selectHistoryList(uid);
    if (response.statusCode == 200) {
      final List<dynamic> histories = jsonDecode(utf8.decode(response.body.runes.toList()));
      List<HistoryRequestDTO> historyList = histories.map((data) =>
          HistoryRequestDTO.fromJson(data)).toList();
      return historyList;
    } else if (response.statusCode == 204) {
      // 카풀 이용 내역이 없는 경우
      return <HistoryRequestDTO>[]; // 빈 리스트를 반환
    } else {
      // 다른 상태 코드 처리
      throw Exception('Failed to fetch history');
    }
  }


  Future<void> _loadUser() async {
    uid = await storage.read(key: 'uid') ?? "";
    nickName = await storage.read(key: 'nickName') ?? "";
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width; //360
    final screenHeight = MediaQuery.of(context).size.height; //727

    // 화면 높이의 75%를 ListView.builder의 높이로 사용
    double listViewHeight = screenHeight * 0.75;
    // 각 카드의 높이
    double cardHeight = listViewHeight * 0.53;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black,),
        ),
        title: const Text('이용내역',
          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: FutureBuilder<List<HistoryRequestDTO>>(
          future: _loadHistoryData(),
          builder: (BuildContext context, AsyncSnapshot<List<HistoryRequestDTO>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('이용내역을 불러오는 데 실패했습니다'),
              );
            } else {
              List<HistoryRequestDTO>? historyList = snapshot.data;
              if (historyList == null || historyList.isEmpty) {
                return  Center(
                  child: '이용 내역이 없습니다'.text.size(20).bold.make(),
                );
              }
              return ListView.builder(
                itemCount: historyList?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  // 이용내역을 화면에 표시하는 코드 작성
                  int epoch = historyList![index].startTime;
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
                  String formattedDate = "${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분";

                  String member1 = historyList[index].member1;
                  String member2 = historyList[index].member2;
                  String member3 = historyList[index].member3;

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
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  formattedDate, // 출발 날짜 시간
                                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              children: [
                                const Text(
                                  '출발지:',
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  historyList[index].startDetailPoint, // 출발지 정보
                                  style: const TextStyle(color: Colors.black, fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              children: [
                                const Text(
                                  '도착지:',
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  historyList[index].endDetailPoint, // 도착지 정보
                                  style: const TextStyle(color: Colors.black, fontSize: 15),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            const Row(
                              children: [
                                Text(
                                  '함께 한 사람',
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            if(member1 != "" && member1.split('_')[1] != nickName)
                              buildMemberRow(member1,historyList[index].carPoolId), // 함께한 사람 정보 리스트
                            if(member2 != "" && member2.split('_')[1] != nickName)
                              buildMemberRow(member2, historyList[index].carPoolId),
                            if(member3 != "" && member3.split('_')[1] != nickName)
                              buildMemberRow(member3, historyList[index].carPoolId),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),

    );

  }


  Widget buildMemberRow(String member, String carpoolId) { // 함께한 사람 정보

    final screenWidth = MediaQuery.of(context).size.width; //360
    final screenHeight = MediaQuery.of(context).size.height; //727

    return Row(
      children: [
        const Icon(
          Icons.account_circle,
          size: 35,
          color: Colors.black,
        ),
        SizedBox(width: screenWidth * 0.03),
        Text(
          member.split('_')[1], // 함께한 사람 닉네임
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ComplainAlert(
                reportedUserNickName: member.split('_')[1], // 피신고자 닉네임
                myId: nickName, // 신고자 닉네임 (나)
                carpoolId: carpoolId, // 신고 카풀 아이디
              ),
            );
          },
        ),
      ],
    );
  }
}
