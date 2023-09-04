import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_profile.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_recordDetail.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 내 정보 위젯 ProFile()
          ProFile(),
          SizedBox(height: 10),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                padding: EdgeInsets.fromLTRB(30, 10, 20, 20),
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => RecordDetailPage(),
                          fullscreenDialog: false),
                    );
                  },
                  child: Text(
                    "이용기록",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}





