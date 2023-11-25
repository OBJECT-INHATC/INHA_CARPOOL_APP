import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/database/d_alarm_dao.dart';
import 'package:inha_Carpool/common/models/m_alarm.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/chat/f_chatroom.dart';

import '../service/sv_firestore.dart';

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
    gender = await storage.read(key: "gender");
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
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
        title: const Text(
          "알림 목록",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            child: const Text(
              "전체 삭제",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              await AlarmDao().deleteAll();
              setState(() {
                notificationListFuture = AlarmDao().getAllAlarms();
              });
            },
          ),
        ],
      ),

      /// 알림 리스트 그리기
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            notificationListFuture = AlarmDao().getAllAlarms();
          });
        },
        child: FutureBuilder<List<AlarmMessage>>(
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
                  return Dismissible(
                    key: Key(notificationList![i].title! +
                        notificationList[i].body! +
                        notificationList[i].time.toString()),
                    //오른쪽으로만 스와이프 가능
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        // 알림 리스트 해당 알림 삭제
                        final deletedItem = notificationList.removeAt(i);
                        if (deletedItem != null) {
                          // 알림 제거
                          AlarmDao().deleteById(deletedItem.title! +
                              deletedItem.body! +
                              deletedItem.time.toString());
                        }
                      });
                    },
                    background: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        //휴지통
                        child: const Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        )),
                    child: InkWell(
                      highlightColor:
                          context.appColors.logoColor.withOpacity(0.5),
                      splashColor: Colors.blue.withOpacity(0.5),
                      onTap: () async {
                        // 알림 타입이 1이면 해당 채팅방 이동
                        if (notificationList![i].type == "chat" ||
                            notificationList[i].type == "status") {
                          AlarmDao().deleteById(
                            notificationList[i].title! +
                                notificationList[i].body! +
                                notificationList[i].time.toString(),
                          );
                          // 해당 카풀방의 startTime 정보를 불러옵니다.
                          var carpoolStartTime = await FireStoreService()
                              .getCarpoolStartTime(notificationList[i].carId!);

                          // 현재 시간을 밀리초 단위의 epoch time으로 변환합니다.
                          var currentTime = DateTime.now().millisecondsSinceEpoch;
                          if (currentTime > carpoolStartTime) {
                            // 현재 시간이 carpoolStartTime을 넘었다면, 카풀이 이미 시작되었으므로 접근을 막습니다.
                            if(!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('이미 끝난 카풀입니다.')));
                            Navigator.pop(context);
                          } else {
                            // 알림 리스트 스택 제거
                            if(!mounted) return;
                            Navigator.pop(context);
                            // 특정 채팅방 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatroomPage(
                                  carId: notificationList[i].carId!,
                                  groupName: "그룹 이름",
                                  userName: nickName!,
                                  uid: uid!,
                                  gender: gender!,
                                ),
                              ),
                            );
                          }
                          // 알람 타입이 카풀 완료 알람일 시
                        } else if (notificationList[i].type == "carpoolDone") {
                          AlarmDao().deleteById(
                            notificationList[i].title! +
                                notificationList[i].body! +
                                notificationList[i].time.toString(),
                          );
                          // 알림 리스트 스택 제거
                          Navigator.pop(context);
                          // 이용기록 페이지로 이동
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => RecordList(
                          //
                          //     ),
                          //   ),
                          // );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 8),
                        child: Column(
                          children: [
                            SizedBox(
                              child: Card(
                                surfaceTintColor: Colors.grey[200],
                                elevation: 4,
                                // 카드 그림자 설정
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                // 여백 설정
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // 원하는 정도의 동그란 형태를 설정
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        15.0), // 원하는 정도의 동그란 형태를 설정
                                  ),
                                  tileColor: Colors.white,
                                  // 알림 타입이 1이면 채팅 아이콘, 나머지 차량 아이콘
                                  leading: notificationList![i].type == "chat"
                                      ? const Icon(Icons.chat, color: Colors.blue)
                                      : const Icon(Icons.notifications,
                                          color: Colors.blue),
                                  title: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(notificationList[i].title,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                      ).paddingOnly(bottom: 3, top: 3),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          DateFormat('yyyy-MM-dd HH:mm')
                                              .format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      notificationList[i].time!))
                                              .toString(),
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    iconSize: 25,
                                    alignment: Alignment.centerRight,
                                    icon: const Icon(Icons.delete,
                                        color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        // 알림 리스트 해당 알림 삭제
                                        final deletedItem =
                                            notificationList.removeAt(i);
                                        if (deletedItem != null) {
                                          // 알림 제거
                                          AlarmDao().deleteById(
                                              deletedItem.title! +
                                                  deletedItem.body! +
                                                  deletedItem.time.toString());
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
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
}
