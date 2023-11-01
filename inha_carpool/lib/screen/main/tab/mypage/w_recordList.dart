import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/dto/HistoryRequestDTO.dart';
import 'package:inha_Carpool/service/api/ApiService.dart';

class RecordList extends StatefulWidget {
  final String uid;
  final String nickName;


  const RecordList({Key? key, required this.uid, required this.nickName}) : super(key: key);

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  final ApiService apiService = ApiService();
  late Future<http.Response> _historyFuture;



  // final List<Map<String, dynamic>> dummyHistories = [
  //   {'carPoolId': '1', 'admin': 'Admin 1'},
  //   {'carPoolId': '2', 'admin': 'Admin 2'},
  // ];

  @override
  void initState() {
    super.initState();
    _historyFuture = apiService.selectHistoryList(widget.uid, widget.nickName);
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
          icon: Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: const Text('이용내역',
          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
      ),
      ),
      body:
      // FutureBuilder<http.Response>(
      //   future: _historyFuture,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       print("123");
      //       return Center(child: CircularProgressIndicator());
      //     } else if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     } else if (snapshot.data == null || snapshot.data!.statusCode != 200) {
      //       return Center(child: Text('Failed to fetch history.'));
      //     } else {
      //       final List<dynamic> histories = jsonDecode(utf8.decoder.convert(snapshot.data!.bodyBytes));
      //       if (histories.isEmpty) {
      //         return Center(child: Text('이용기록이 존재하지 않습니다.'));
      //       }
      //
      //       return ListView.builder(
      //         itemCount: histories.length,
      //         itemBuilder: (context, index) {
      //           final history = histories[index];
      //           return ListTile(
      //             title: Text('History: ${history['carPoolId']}'),
      //             subtitle: Text('Admin: ${history['admin']}'),
      //           );
      //         },
      //       );
      //     }
      //   },
      // ),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: ListView(
          children: [
            Card(
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
                        Width(screenWidth * 0.02),
                        Text('날짜',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Height(screenHeight*0.02),
                    Row(
                      children: [
                        Text('시간',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                        ),
                        Width(screenWidth * 0.06),
                        Text('시간',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    Height(screenHeight*0.01),
                    Row(
                      children: [
                        Text('출발지',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                        ),
                        Width(screenWidth * 0.03),
                        Text('풀주소'),
                      ],
                    ),
                    Height(screenHeight*0.01),
                    Row(
                      children: [
                        Text('목적지',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                        ),
                        Width(screenWidth * 0.03),
                        Text('풀주소'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ),

    );
  }
}
