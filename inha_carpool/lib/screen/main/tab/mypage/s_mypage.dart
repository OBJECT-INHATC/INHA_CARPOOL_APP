import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/item_page/s_feedback.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/Profile/w_profile.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/item_page/w_recordList.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/switch/w_switch_menu.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_category.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_list_item.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_version_copyRight.dart';
import 'package:inha_Carpool/service/api/Api_user.dart';

import '../../../../common/data/preference/prefs.dart';
import '../../../../fragment/opensource/s_opensource.dart';
import '../../../../provider/auth/auth_provider.dart';
import '../../../dialog/d_message.dart';
import 'item_page/d_changepassword.dart';
import 'item_page/f_logout_confirmation.dart';
import 'item_page/f_secession.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  late String uid;
  late String nickName;
  late String gender;

  Future<void> _loadAuthData() async {
    nickName = ref.read(authProvider).nickName!;
    uid = ref.read(authProvider).uid!;
    gender = ref.read(authProvider).gender!;
  }

  @override
  void initState() {
    super.initState();
    _loadAuthData();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 프로필 항목
            const Height(20),
            const ProFile(),
            const Category(title: '계정'),
            MypageListItem(
              icon: Icons.history_toggle_off_rounded,
              title: '이용기록',
              onTap: () {
                Navigator.of(Nav.globalContext).push(
                    MaterialPageRoute(builder: (context) => RecordList()));
              },
              color: Colors.black,
            ),
            MypageListItem(
              icon: Icons.lock,
              title: '비밀번호 변경',
              onTap: () {
                Navigator.of(Nav.globalContext).push(
                    MaterialPageRoute(builder: (context) => ChangePasswordPage()));
              },
              color: Colors.black,
            ),
            MypageListItem(
              icon: Icons.logout,
              title: '로그아웃',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => LogoutConfirmationDialog(
                    onConfirm: () {},
                  ),
                );
              },
              color: Colors.red,
            ),
            MypageListItem(
              icon: Icons.delete,
              title: '회원탈퇴',
              onTap: () {
                Navigator.of(Nav.globalContext).push(
                    MaterialPageRoute(builder: (context) => SecessionPage()));
              },
              color: Colors.black,
            ),
            // 알림 항목
            const Category(title: '알림'),
            Obx(
              () => SwitchMenu('채팅 알림', Prefs.isPushOnRx.get(),
                  onChanged: (isOn) async {
                Prefs.isPushOnRx.set(isOn);
                ApiUser apiUser = ApiUser();
                List<String> topicList = await apiUser.getAllCarIdsForUser(uid);
                if (isOn) {
                  print('채팅 알림 on');
                  /// 서버 db 에서 카풀Id 다 가져와서 다 구독
                  for (String carId in topicList) {
                    try {
                      await FirebaseMessaging.instance.subscribeToTopic(carId);
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
            Obx(
              () => SwitchMenu('학교 공지사항', Prefs.isSchoolPushOnRx.get(),
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
            const Category(title: '기타'),
            MypageListItem(
              icon: Icons.help_outline_rounded,
              title: '건의/제안사항',
              onTap: () {
                Navigator.of(Nav.globalContext).push(
                  MaterialPageRoute(
                    builder: (context) => FeedBackPage(
                      reporter: nickName,
                    ),
                  ),
                );
              },
              color: Colors.grey,
            ),
            MypageListItem(
              icon: Icons.cached_outlined,
              title: 'clear cache',
              onTap: () async {
                final manager = DefaultCacheManager();
                await manager.emptyCache();
                if (mounted) {
                  MessageDialog('캐시 삭제 완료').show();
                }
              },
              color: Colors.grey,
            ),

            MypageListItem(
              icon: Icons.code_rounded,
              title: 'opensource',
              onTap: () async {
                Nav.push(const OpensourceScreen());
              },
              color: Colors.grey,
            ),

            /// 하단 버전 정보
            const VersionAndCopyRight(),
          ],
        ),
      ),
    );
  }
}
