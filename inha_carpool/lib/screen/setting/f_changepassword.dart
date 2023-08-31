import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/service/sv_auth.dart';

import '../login/s_login.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // 비밀번호
  String newPassword = "";
  String oldPassword = "";

  // 비밀번호 비교
  String checkPassword = "";

  String passwordCheck = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 56,
        leading: Center(
          child: BackButton(
            color: Colors.black,
          ),
        ),
        title: Text(
          "비밀번호 변경",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(
                '학번',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 20),
              Text(
                '현재 비밀번호',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '현재 비밀번호 입력',
                ),
                obscureText: true,
                onChanged: (text) {
                  // 텍스트 필드 값 변경 시 실행할 코드 작성
                  oldPassword = text;

                },
              ),
              SizedBox(height: 10),
              Text(
                '새 비밀번호',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '새로운 비밀번호 입력',
                ),
                obscureText: true,
                onChanged: (text) {
                  // 텍스트 필드 값 변경 시 실행할 코드 작성
                  newPassword = text;
                },
              ),
              SizedBox(height: 10),
              Text(
                '새 비밀번호 확인',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '새로운 비밀번호 다시 입력',
                  suffix: Text(passwordCheck,
                      style: (passwordCheck == "비밀번호가 일치하지 않습니다.")
                          ? TextStyle(color: Colors.red)
                          : TextStyle(color: Colors.green)),
                ),
                obscureText: true,
                onChanged: (text) {
                  // 텍스트 필드 값 변경 시 실행할 코드 작성
                  checkPassword = text;
                  if (newPassword == checkPassword) {
                    setState(() {
                      passwordCheck = "비밀번호가 일치합니다!";
                    });
                  } else {
                    setState(() {
                      passwordCheck = "비밀번호가 일치하지 않습니다.";
                    });
                  }
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  // 비밀번호 변경 로직 구현 예정

                  String result = await AuthService().passwordUpdate(
                      oldPassword: oldPassword,
                      newPassword: newPassword);
                  if (result == 'Success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('성공적으로 변경되었습니다.')),
                    );

                    AuthService().signOut().then((value) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                            (Route<dynamic> route) => false,
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('비밀번호 변경에 실패했습니다.')),
                    );
                  }
                },
                child: Text('비밀번호 변경'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  primary: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
