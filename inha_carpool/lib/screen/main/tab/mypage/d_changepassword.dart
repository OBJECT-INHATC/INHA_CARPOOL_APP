import 'package:flutter/material.dart';
import 'package:inha_Carpool/service/sv_auth.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import '../../../login/s_login.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

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
        leading: const Center(
          child: BackButton(
            color: Colors.black,
          ),
        ),
        title: const Text(
          "비밀번호 변경",
          style: TextStyle(color: Colors.black, fontSize: 17,),
        ),
        centerTitle: false,
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                '학번',
                style: TextStyle(fontSize: 15),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: '학번 입력',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '현재 비밀번호',
                style: TextStyle(fontSize: 15),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: '현재 비밀번호 입력',
                  hintStyle: TextStyle(fontSize: 13),
                ),
                obscureText: true,
                onChanged: (text) async {
                  // 텍스트 필드 값 변경 시 실행할 코드 작성
                  oldPassword = text;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                '새 비밀번호',
                style: TextStyle(fontSize: 15),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: '새로운 비밀번호 입력',
                  hintStyle: TextStyle(fontSize: 13),
                ),
                obscureText: true,
                onChanged: (text) {
                  // 텍스트 필드 값 변경 시 실행할 코드 작성
                  newPassword = text;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                '새 비밀번호 확인',
                style: TextStyle(fontSize: 15),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '새로운 비밀번호 다시 입력',
                  hintStyle: TextStyle(fontSize: 13),
                  suffix: Text(passwordCheck,
                      style: (passwordCheck == "비밀번호가 일치하지 않습니다.")
                          ? const TextStyle(color: Colors.red)
                          : const TextStyle(color: Colors.green)),
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
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  // 비밀번호 변경 로직 구현 예정
                  String isValid =
                  await AuthService().validatePassword(oldPassword);

                  if (isValid == 'Invalid') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('현재 비밀번호가 틀립니다.')),
                    );
                  } else {
                    String result = await AuthService().passwordUpdate(
                        oldPassword: oldPassword, newPassword: newPassword);
                    if (result == 'Success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('성공적으로 변경되었습니다.')),
                      );

                      /// TODO : 로그아웃 로직이 빠져있음 - 로그아웃 로직 추가 필요
                      AuthService().signOut().then((value) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                              (Route<dynamic> route) => false,
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호 변경에 실패했습니다.')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  backgroundColor : Colors.grey,
                ),
                child: const Text('비밀번호 변경', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

