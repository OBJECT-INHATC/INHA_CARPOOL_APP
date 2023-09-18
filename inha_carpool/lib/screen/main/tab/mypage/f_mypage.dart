import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/velocityx_extension.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_profile.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_recordList.dart';

import '../../../../common/data/preference/prefs.dart';
import '../../../dialog/d_message.dart';
import '../../../opensource/s_opensource.dart';
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
  bool isEventAdsAllowed = true; // 스위치의 초기 상태를 설정
  bool isEvent = true; // 스위치의 초기 상태를 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        // 스크롤 가능한 ListView로 변경
        children: [
          // 내 정보 위젯 ProFile()
          ProFile(),
          SizedBox(height: 10),
          Column(
            children: [
              // 계정 항목
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0), // vertical 값을 조정
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // 추가
                  children: [
                    Text(
                      '계정',
                      style: TextStyle(
                        fontSize: 17.5,
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
                  // 이용기록 페이지로 이동
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const recordList()));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.lock,
                  color: Colors.blue,
                ),
                title: const Text('비밀번호 변경'),
                onTap: () {
                  // 비밀번호 변경 페이지로 이동
                  Navigator.of(context).push(
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
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SecessionPage()));
                },
              ),

              // 알림 항목
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0), // vertical 값을 조정
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '알림',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

                Obx(
                      () => Switchmenu('푸쉬 알림', Prefs.isPushOnRx.get(), onChanged: (isOn) {
                    Prefs.isPushOnRx.set(isOn);
                  }),
                ),
              //Todo : Prefs.isPushOnRx.get() 이 값은 bool 타입으로
              //Todo : 현재 알림 설정이 off 면 false 반환 on 이면 true 반환 -상훈


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
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                    child: '  © INHAtc 컴퓨터시스템과 Object 2023 beta 1.0'
                        .text
                        .size(15)
                        .semiBold
                        .makeWithDefaultFont()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
