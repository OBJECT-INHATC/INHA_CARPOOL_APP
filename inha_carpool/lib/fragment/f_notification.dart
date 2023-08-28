import 'package:flutter/material.dart';

import '../screen/main/tab/carpool/s_chatroom.dart';


class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  var notificationmap = {
    "10분 뒤 인하대학교-주안역 카풀이 시작됩니다!": Icons.access_alarm,
    "1시간뒤, 인하대학교-주안역 탑승을 확정했습니다.": Icons.flag,
    "카리나 님을 신고했습니다.": Icons.report,
    "카리나 님이 주안역-인하공전(방장:홀란드) 카풀에 참여하였습니다. ": Icons.car_rental,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
        title: Text(
          "알림화면",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: GestureDetector(
        onTap:(){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Placeholder()));
        },
        child: ListView.builder(itemCount: notificationmap.length,
    itemBuilder: (c, i) {
          return Column(
            children: [
              ListTile(
                leading: Icon(
                    notificationmap.values.elementAt(i),
                ),
                title: Text(notificationmap.keys.elementAt(i)),
                trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                    });
                  },
                ),
              ),
            ],
          );}
        ),
      ),
    );
  }
}
