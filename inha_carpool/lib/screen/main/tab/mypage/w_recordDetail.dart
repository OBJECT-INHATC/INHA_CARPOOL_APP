import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_recordList.dart';

class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 60,
                padding: EdgeInsets.fromLTRB(30, 20, 20, 0),
                child: Text(
                  "이용기록",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
                itemCount: 12,
                itemBuilder: (context, i) {
                  return RecordList();
                }),
          ),
        ],
      ),
    );
  }
}