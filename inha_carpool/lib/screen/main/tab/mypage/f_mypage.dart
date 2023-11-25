import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/velocityx_extension.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/s_feedback.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_profile.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_recordList.dart';
import 'package:inha_Carpool/service/api/Api_user.dart';

import '../../../../common/data/preference/prefs.dart';
import '../../../../fragment/opensource/s_opensource.dart';
import '../../../dialog/d_message.dart';
import 'd_changepassword.dart';
import 'f_logout_confirmation.dart';
import 'f_secession.dart';
import 'notificationButton/w_switch_menu.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final storage = FlutterSecureStorage();
  late String uid;
  late String nickName;

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  Future<void> _loadUid() async {
    uid = await storage.read(key: 'uid') ?? "";
    nickName = await storage.read(key: 'nickName') ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const ProFile(),
            const SizedBox(height: 10),
            Column(
              children: [
                // 계정 항목
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // 추가
                    children: [
                      Text(
                        '계정',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.history_toggle_off_rounded,
                    color: Colors.black,
                  ),
                  title: const Text('이용기록'),
                  onTap: () {
                    print("이용기록 onTap 이동준비");
                    // 이용기록 페이지로 이동
                    Navigator.of(Nav.globalContext).push(
                        MaterialPageRoute(builder: (context) => RecordList()));
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                  title: const Text('비밀번호 변경'),
                  onTap: () {
                    // 비밀번호 변경 페이지로 이동
                    Navigator.of(Nav.globalContext).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangePasswordPage(), // ChangePasswordPage로 이동
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: const Text('로그아웃'),
                  onTap: () {
                    // 로그아웃 다이얼로그를 표시
                    showDialog(
                      context: context,
                      builder: (context) => LogoutConfirmationDialog(
                        onConfirm: () {},
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.delete,
                    color: Colors.black,
                  ),
                  title: const Text('회원탈퇴'),
                  onTap: () {
                    // 회원탈퇴 페이지로 이동하
                    Navigator.of(Nav.globalContext).push(MaterialPageRoute(
                        builder: (context) => SecessionPage()));
                  },
                ),

                // 알림 항목
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0), // vertical 값을 조정
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '알림',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Obx(
                  () => Switchmenu('채팅 알림', Prefs.isPushOnRx.get(),
                      onChanged: (isOn) async {
                    Prefs.isPushOnRx.set(isOn);
                    ApiUser apiUser = ApiUser();
                    List<String> topicList =
                        await apiUser.getAllCarIdsForUser(uid);
                    if (isOn) {
                      print('채팅 알림 on');

                      /// 서버 db 에서 카풀Id 다 가져와서 다 구독
                      for (String carId in topicList) {
                        try {
                          await FirebaseMessaging.instance
                              .subscribeToTopic(carId);
                        } catch (e) {
                          print("ios 시뮬 에러");
                        }
                        print('채팅 구독 완료: $carId');
                      }
                    } else {
                      /// 서버 db 에서 카풀Id 다 가져와서 다 구독 해제
                      print('채팅 알림 off');
                      for (String carId in topicList) {
                        try {
                          await FirebaseMessaging.instance
                              .unsubscribeFromTopic(carId);
                        } catch (e) {
                          print("ios 시뮬 에러");
                        }
                        print('채팅 구독 취소: $carId');
                      }
                    }
                  }),
                ),
                // 광고부분 일단 주석처리
                //Obx(
                //    () => Switchmenu('광고 및 마케팅', Prefs.isAdPushOnRx.get(),
                //  onChanged: (isOn) async {
                //  Prefs.isAdPushOnRx.set(isOn);
                //if (isOn) {
                //print('광고 및 마케팅 알림 on');
                //await FirebaseMessaging.instance.subscribeToTopic("AdNotification");
                //} else {
                // print('광고 및 마케팅 알림 off');
                // await FirebaseMessaging.instance.unsubscribeFromTopic("AdNotification");
                //}
                //}),
                //),

                Obx(
                  () => Switchmenu('학교 공지사항', Prefs.isSchoolPushOnRx.get(),
                      onChanged: (isOn) async {
                    Prefs.isSchoolPushOnRx.set(isOn);
                    if (isOn) {
                      print('학교 공지사항 알림 on');
                      await FirebaseMessaging.instance
                          .subscribeToTopic("SchoolNotification");
                    } else {
                      print('학교 공지사항 알림 off');
                      await FirebaseMessaging.instance
                          .unsubscribeFromTopic("SchoolNotification");
                    }
                  }),
                ),

                // 기타 항목
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0), // vertical 값을 조정
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // 추가
                    children: [
                      Text(
                        '기타',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                ListTile(
                  leading: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.grey,
                  ),
                  title: '건의/제안사항'.tr().text.make(),
                  onTap: () {
                    // 건의/제안사항 페이지로 이동
                    Navigator.of(Nav.globalContext).push(
                      MaterialPageRoute(
                        builder: (context) => FeedBackPage(
                          reporter: nickName,
                        ),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.cached_outlined,
                    color: Colors.grey,
                  ),
                  title: 'clear_cache'.tr().text.make(),
                  onTap: () async {
                    final manager = DefaultCacheManager();
                    await manager.emptyCache();
                    if (mounted) {
                      MessageDialog('clear_cache_done'.tr()).show();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.code_rounded,
                    color: Colors.grey,
                  ),
                  title: 'opensource'.tr().text.make(),
                  onTap: () async {
                    Nav.push(const OpensourceScreen());
                  },
                ),
              ],
            ),
            const Line(),
            const Height(10),
            Row(
              children: [
                Expanded(
                  child: Container(
                      height: 30,
                      width: 100,
                      padding: const EdgeInsets.only(left: 15),
                      child: '  © INHAtc 2023 컴퓨터시스템과 Object Beta ver.1.9'
                          .text
                          .size(15)
                          .semiBold
                          .makeWithDefaultFont()),
                ),
              ],
            ),
            const Height(90),
          ],
        ),
      ),
    );
  }
}
