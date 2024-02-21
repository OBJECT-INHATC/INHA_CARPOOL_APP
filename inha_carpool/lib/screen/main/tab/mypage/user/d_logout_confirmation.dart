import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:inha_Carpool/service/sv_auth.dart';
import '../../../../login/s_login.dart';
import 'package:inha_Carpool/common/common.dart';

/// 로그아웃 확인 다이얼로그
class LogoutConfirmationDialog extends StatelessWidget {
  final String email;

  const LogoutConfirmationDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {

    final width = context.width(1);

    return AlertDialog(
      surfaceTintColor: Colors.transparent, // 틴트 빼기
      backgroundColor: Colors.white, // 다이얼로그 배경색
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.exit_to_app_outlined, color: Colors.red),
          Text('로그아웃', style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(email, style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.bold)),
           Text('위 계정에서 로그아웃하시겠습니까?', style: TextStyle(fontSize: width * 0.035)),

        ],
      ),
      actions: <Widget>[
        Line(color: context.appColors.divider),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async{
                await FirebaseMessaging.instance.deleteToken();
                AuthService().signOut().then(
                      (value) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                    );
                  },
                );
              },
              child: const Text('예'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('아니오'),
            ),
          ],
        ),

      ],
    );
  }
}