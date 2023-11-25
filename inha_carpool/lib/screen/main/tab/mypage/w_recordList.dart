import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/dto/HistoryRequestDTO.dart';
import 'package:inha_Carpool/screen/dialog/d_complainAlert.dart';
import 'package:inha_Carpool/service/api/Api_repot.dart';

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
      final List<dynamic> histories =
          jsonDecode(utf8.decode(response.body.runes.toList()));
      List<HistoryRequestDTO> historyList =
          histories.map((data) => HistoryRequestDTO.fromJson(data)).toList();

      // 시작 시간을 기준으로 내림차순 정렬
      historyList.sort((a, b) => b.startTime.compareTo(a.startTime));

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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadHistoryData();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: FutureBuilder<List<HistoryRequestDTO>>(
            future: _loadHistoryData(),
            builder: (BuildContext context,
                AsyncSnapshot<List<HistoryRequestDTO>> snapshot) {
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
                  return Center(
                    child: '이용 내역이 없습니다'.text.size(20).bold.make(),
                  );
                }
                return ListView.builder(
                  itemCount: historyList?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    // 이용내역을 화면에 표시하는 코드 작성
                    int epoch = historyList![index].startTime;
                    DateTime dateTime =
                        DateTime.fromMillisecondsSinceEpoch(epoch);
                    String formattedDate =
                        "${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분";

                    String member1 = historyList[index].member1;
                    String member2 = historyList[index].member2;
                    String member3 = historyList[index].member3;
                    String member4 = historyList[index].member4;

                    // '함께 한 사람' 정보 리스트를 생성
                    List<String> members = [member1, member2, member3, member4];

                    // 멤버 리스트에서 현재 유저와 동일한 이름의 멤버를 필터링
                    List<String> validMembers = members.where((member) {
                      return member != '' && member.split('_')[1] != nickName;
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
                              buildMemberRow(member, historyList[index].carPoolId),
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
                                    historyList[index].startDetailPoint,
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
                                    historyList[index].endDetailPoint, // 도착지 정보
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
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildMemberRow(String member, String carpoolId) {
    // 함께한 사람 정보

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        SizedBox(width: screenWidth * 0.03),
        Text(
          member.split('_')[1], // 함께한 사람 닉네임
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.warning_rounded, size: 20, color: Colors.red,),
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
