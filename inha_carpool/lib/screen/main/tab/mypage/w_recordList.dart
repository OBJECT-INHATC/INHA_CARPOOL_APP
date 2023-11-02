import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/dto/HistoryRequestDTO.dart';
import 'package:inha_Carpool/service/api/ApiService.dart';

class RecordList extends StatefulWidget {

  const RecordList({Key? key}) : super(key: key);

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  final storage = FlutterSecureStorage();
  final ApiService apiService = ApiService();
  late String uid;
  late String nickName;
  late String gender;

  @override
  void initState() {
    super.initState();
  }

  Future<List<HistoryRequestDTO>> _loadHistoryData() async {
    await _loadUser();
    final response = await apiService.selectHistoryList(uid, nickName, gender);
    if (response.statusCode == 200) {
      final List<dynamic> histories = jsonDecode(utf8.decode(response.body.runes.toList()));
      List<HistoryRequestDTO> historyList = histories.map((data) => HistoryRequestDTO.fromJson(data)).toList();
      return historyList;
    } else {
      throw Exception('Failed to fetch history');
    }
  }

  Future<void> _loadUser() async {
    uid = await storage.read(key: 'uid') ?? "";
    nickName = await storage.read(key: 'nickName') ?? "";
    gender = await storage.read(key: "gender") ?? "";
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
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: const Text('이용내역',
          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
        ),
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
              return ListView.builder(
                itemCount: historyList?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  // 이용내역을 화면에 표시하는 코드 작성
                  int epoch = historyList![index].startTime;
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
                  String formattedDate = "${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분";
                  return Card(
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
                                color: Colors.yellow,
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
                                historyList![index].startDetailPoint, // 출발지 정보
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
                                historyList![index].endDetailPoint, // 도착지 정보
                                style: const TextStyle(color: Colors.black, fontSize: 15),
                              ),
                            ],
                          ),
                        ],
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
}
