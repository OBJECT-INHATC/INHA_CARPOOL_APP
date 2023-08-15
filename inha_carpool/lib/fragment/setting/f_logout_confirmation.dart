import 'package:flutter/material.dart';

import '../../screen/login/s_login.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  LogoutConfirmationDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('로그아웃'),
      content: Text('정말 로그아웃 하시겠습니까?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('아니오'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
            );
          },
          child: Text('예'),
        ),
      ],
    );
  }
}



