import 'package:flutter/material.dart';
import 'package:inha_Carpool/service/sv_auth.dart';

import '../../../login/s_login.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  LogoutConfirmationDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      title: const Text('로그아웃'),
      content: const Text('정말 로그아웃 하시겠습니까?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('아니오'),
        ),
        TextButton(
          onPressed: () {
            AuthService().signOut().then(
                  (value){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                          (Route<dynamic> route) => false,
                    );
                  }); // 로그아웃
            onConfirm();
          },
          child: Text('예'),
        ),
      ],
    );
  }
}



