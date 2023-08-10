import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:fast_app_base/screen/main/s_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nav/nav.dart';

import '../register/s_register.dart';


class LoginPage extends StatefulWidget  {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with AfterLayoutMixin {

  // 일단 로그인으로 이동하게끔 코드 수정
  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    // awit loogin() 기능 넣으면 됌
    // awit 인증()

    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
                child: const FlutterLogo(
                  size: 100,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                    ),
                    labelText: '이메일',
                  ),
                  onChanged: (text) {},
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                child: TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                    ),
                    labelText: '비밀번호',
                  ),
                  onChanged: (text) {},
                ),
              ),
              Container(
                height: 80,
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90.0),
                      ),
                    ),
                    child: const Text('로그인',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    }),
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '아이디 / 비밀번호 찾기',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.grey[700],
                    ),
                    child: const Text('회원가입',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
