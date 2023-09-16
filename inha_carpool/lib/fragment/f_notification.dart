
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/database/d_alarm_dao.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/models/m_alarm.dart';

import '../screen/main/tab/carpool/s_chatroom.dart';


/// 0901 한승완 수정
/// 알림 목록 페이지
class NotificationList extends StatefulWidget {
  const NotificationList({Key? key}) : super(key: key);

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {

  final storage = const FlutterSecureStorage();

  /// 알림 리스트
  Future<List<AlarmMessage>>? notificationListFuture;

  /// 사용자 닉네임
  String? nickName;
  String? uid;
  String? gender;


  @override
  void initState() {
    /// 알림 리스트 불러오기 및 사용자 닉네임 불러오기
    gettingLocalAlarm();
    gettingNickName();

    super.initState();
  }

  gettingLocalAlarm() async {
    notificationListFuture = AlarmDao().getAllAlarms();
  }

  gettingNickName() async {
    nickName = await storage.read(key: "nickName");
    uid = await storage.read(key: "uid");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        leading: const BackButton(
          color: Colors.black,
        ),
        title: const Text(
          "알림 목록",
          style: TextStyle(color: Colors.black),
        ),
      ),
      /// 알림 리스트 그리기
      body: FutureBuilder<List<AlarmMessage>>(
        future: notificationListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('오류 발생: ${snapshot.error}');
          } else {
            final notificationList = snapshot.data;
            return ListView.builder(
              itemCount: notificationList?.length ?? 0,
              itemBuilder: (c, i) {
                /// 알림 클릭 이벤트
                return GestureDetector(
                  onTap: () {
                    // 알림 타입이 1이면 해당 채팅방 이동
                    if (notificationList![i].type == "1") {

                      // 해당 알림 삭제
                      AlarmDao().deleteById(
                        notificationList[i].title! + notificationList[i].body! + notificationList[i].time.toString(),
                      );

                      // 알림 리스트 스택 제거
                      Navigator.pop(context);

                      // 특정 채팅방 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatroomPage(
                            carId : notificationList[i].carId!,
                            groupName : "그룹 이름",
                            userName: nickName!,
                            uid: uid! ,
                            gender: gender!,
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        child: Card(
                          surfaceTintColor: Colors.grey[200],
                          elevation: 4, // 카드 그림자 설정
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // 여백 설정
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // 원하는 정도의 동그란 형태를 설정
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0), // 원하는 정도의 동그란 형태를 설정
                            ),
                            tileColor: Colors.white,
                            // 알림 타입이 1이면 채팅 아이콘, 나머지 차량 아이콘
                            leading: notificationList![i].type == "1"
                                ? const Icon(Icons.chat, color: Colors.blue)
                                : const Icon(Icons.car_crash_rounded, color: Colors.blue),
                            title: Column(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(notificationList[i].title,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    DateFormat('yyyy-MM-dd HH:mm')
                                        .format(DateTime.fromMillisecondsSinceEpoch(notificationList[i].time!))
                                        .toString(),
                                    style: const TextStyle(fontSize: 11 , color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            trailing:IconButton(
                              iconSize: 25,
                              alignment: Alignment.centerRight,
                                icon: const Icon(Icons.delete , color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    // 알림 리스트 해당 알림 삭제
                                    final deletedItem = notificationList.removeAt(i);
                                    if (deletedItem != null) {
                                      // 알림 제거
                                      AlarmDao().deleteById(
                                          deletedItem.title! + deletedItem.body! + deletedItem.time.toString());
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
