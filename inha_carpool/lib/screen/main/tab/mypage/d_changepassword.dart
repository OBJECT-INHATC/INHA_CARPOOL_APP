import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/service/sv_auth.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import '../../../login/s_login.dart';

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
    return GestureDetector(
      onTap: () {
        // 텍스트 포커스 해제
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: Colors.black,
          shadowColor: Colors.white,
          leadingWidth: 56,
          title:
            "비밀번호 변경".text.color(Colors.black).size(17).bold.make(),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  '학번'.text.size(15).make(),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: '학번 입력',
                    ),
                  ),
                  const SizedBox(height: 20),
                  '현재 비밀번호'.text.size(15).make(),

                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: '현재 비밀번호 입력',
                    ),
                    obscureText: true,
                    onChanged: (text) async {
                      // 텍스트 필드 값 변경 시 실행할 코드 작성
                      oldPassword = text;
                    },
                  ),
                  const SizedBox(height: 10),
                  '새 비밀번호'.text.size(15).make(),

                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: '새로운 비밀번호 입력',
                    ),
                    obscureText: true,
                    onChanged: (text) {
                      // 텍스트 필드 값 변경 시 실행할 코드 작성
                      newPassword = text;
                    },
                  ),
                  const SizedBox(height: 10),
                  '새 비밀번호 확인'.text.size(15).make(),

                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '새로운 비밀번호 다시 입력',
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
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      // 비밀번호 변경 로직 구현 예정
                      String isValid =
                      await AuthService().validatePassword(oldPassword);

                      if (isValid == 'Invalid') {
                        if(!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('현재 비밀번호가 틀립니다.')),
                        );
                      } else {
                        String result = await AuthService().passwordUpdate(
                            oldPassword: oldPassword, newPassword: newPassword);
                        if (result == 'Success') {
                          if(!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('성공적으로 변경되었습니다.')),
                          );

                          AuthService().signOut().then((value) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                                  (Route<dynamic> route) => false,
                            );
                          });
                        } else {
                          if(!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('비밀번호 변경에 실패했습니다.')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      backgroundColor: Colors.grey[300],
                    ),
                    child:'비밀번호 변경'.text.size(14).make(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

