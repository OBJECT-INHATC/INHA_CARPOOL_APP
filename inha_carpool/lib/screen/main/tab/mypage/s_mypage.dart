import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/Profile/w_profile.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_category.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_list_item.dart';
import 'package:inha_Carpool/screen/main/tab/mypage/w_version_copyright.dart';
import 'package:inha_Carpool/service/api/Api_user.dart';
import 'package:inha_Carpool/service/sv_fcm.dart';

import '../../../../common/data/preference/prefs.dart';
import '../../../../fragment/opensource/s_opensource.dart';
import '../../../../provider/stateProvider/auth_provider.dart';
import '../../../../provider/doing_carpool/doing_carpool_provider.dart';
import '../../../dialog/d_message.dart';
import 'alarm_switch/w_switch_menu.dart';
import 'feedback/s_feedback.dart';
import 'history/w_history_list.dart';
import 'user/d_changepassword.dart';
import 'user/d_logout_confirmation.dart';
import 'user/secession/f_secession.dart';

class MyPage extends ConsumerStatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  late String uid;
  late String nickName;
  late String gender;
  late String email;

  Future<void> _loadAuthData() async {
    nickName = ref.read(authProvider).nickName!;
    uid = ref.read(authProvider).uid!;
    gender = ref.read(authProvider).gender!;
    email = ref.read(authProvider).email!;
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
            const Height(20),
            // 상단 프로필 항목
            const ProFile(),
            const Category(title: '계정'),
            MypageListItem(
              icon: Icons.history_toggle_off_rounded,
              title: '이용기록',
              onTap: () {
                Navigator.of(Nav.globalContext).push(
                    MaterialPageRoute(builder: (context) => HistoryList()));
              },
              color: Colors.black,
            ),
            MypageListItem(
              icon: Icons.lock,
              title: '비밀번호 변경',
              onTap: () {
                Navigator.of(Nav.globalContext).push(
                    MaterialPageRoute(builder: (context) => ChangePasswordPage(studentId: email,)));
              },
              color: Colors.black,
            ),
            MypageListItem(
              icon: Icons.logout,
              title: '로그아웃',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => LogoutConfirmationDialog(email: email,),
                );
              },
              color: Colors.red,
            ),
            MypageListItem(
              icon: Icons.delete,
              title: '회원탈퇴',
              onTap: () {
                Navigator.of(Nav.globalContext).push(
                    MaterialPageRoute(builder: (context) =>  SecessionPage(userEmail: email, userNickName: nickName)));
              },
              color: Colors.black,
            ),
            /// 알림 항목
            const Category(title: '알림'),
            Obx(
              () => SwitchMenu('채팅 알림', Prefs.isPushOnRx.get(),
                  onChanged: (isOn) async {
                Prefs.isPushOnRx.set(isOn);

                // 서버에서 토픽을 가져옴
                List<String> topicList = await ApiUser().getAllCarIdsForUser(uid);

                // 가져온 토픽을 알림 허용 유무에 따라 구독하거나 해제
                for(String carId in topicList) {
                  if(isOn) {
                    bool isCheckAlarm = await ref.read(doingProvider.notifier).getAlarm(carId);
                  if (isCheckAlarm){
                    FcmService().subScribeTopic(carId);
                  }
                  } else {
                    FcmService().unSubScribeTopic(carId);
                  }
                }

              }),
            ),
            Obx(
              () => SwitchMenu('학교 공지사항', Prefs.isSchoolPushOnRx.get(),
                  onChanged: (isOn) async {
                Prefs.isSchoolPushOnRx.set(isOn);
                if(isOn) {
                  FcmService().subScribeOnlyOne("SchoolNotification");
                } else {
                  FcmService().unSubScribeOnlyIOne("SchoolNotification");
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
                  MessageDialog('캐시 삭제 완료', textAlign: TextAlign.center,).show();
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
