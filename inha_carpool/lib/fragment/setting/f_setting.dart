import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:inha_Carpool/common/dart/extension/datetime_extension.dart';
import 'package:inha_Carpool/fragment/setting/w_switch_menu.dart';
import 'package:inha_Carpool/screen/main/s_main.dart';
import 'package:nav/nav.dart';
import '../../common/data/preference/prefs.dart';
import '../../common/widget/w_big_button.dart';
import 'f_changepassword.dart';
import 'f_logout_confirmation.dart';
import 'f_secession.dart';

void main() => runApp(SettingPage());

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isMute = false;
  bool isVibrate = true;
  bool isSound = true;
  bool isNightMode = false;
  bool isEventAdsAllowed = true;

  void _navigateToSecessionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SecessionPage()), // SecessionPage로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _CustomAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        children: [
          // 계정 항목
          Container(
            color: Colors.grey[200],
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              '계정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.lock,
              color: Colors.blue,
            ),
            title: Text('비밀번호 변경'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: Text('로그아웃'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LogoutConfirmationDialog(
                    onConfirm: () {
                      Navigator.pop(context); // 닫기 버튼 클릭
                      // 로그아웃 처리
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        // LoginPage로 이동
                        (Route<dynamic> route) => false, // 이전 화면들을 모두 제거
                      );
                    },
                  );
                },
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: Text('회원탈퇴'),
            onTap: () {
              _navigateToSecessionPage(); // 회원탈퇴 화면으로 이동
            },
          ),
          Divider(),

          // 알림 항목
          Container(
            color: Colors.grey[200],
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(
                      () => Switchmenu('푸쉬설정', Prefs.isPushOnRx.get(),
                      onChanged: (isOn) {
                        Prefs.isPushOnRx.set(isOn);
                      }),
                ),
                Divider(),
                Obx(
                      () => Slider(
                      value: Prefs.sliderPosition.get(),
                      onChanged: (value) {
                        Prefs.sliderPosition.set(value);
                      }),
                ),
              ],
            ),
          ),

          // 기타 항목
          Container(
            color: Colors.grey[200],
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              '기타',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.nightlight_round,
              color: Colors.deepPurple,
            ),
            title: Text('야간모드'),
            trailing: Switch(
              value: isNightMode,
              onChanged: (value) {
                setState(() {
                  isNightMode = value;
                });
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.ad_units,
              color: Colors.orange,
            ),
            title: Text('이벤트 및 광고 수신동의'),
            trailing: Switch(
              value: isEventAdsAllowed,
              onChanged: (value) {
                setState(() {
                  isEventAdsAllowed = value;
                });
              },
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class _AppBarTitleCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "설정",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class _AppBarLeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        Nav.push(MainScreen());
      },
    );
  }
}

class _AppBarActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AppBarLeading(),
      ],
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: _AppBarTitleCenter(),
      leading: _AppBarActions(),
      actions: [SizedBox(width: 56)],
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          '로그인 페이지',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
