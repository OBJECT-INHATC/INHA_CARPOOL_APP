import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/service/sv_auth.dart';
import 'package:nav/nav.dart';

import '../../service/sv_firestore.dart';
import '../main/s_main.dart';
import '../register/s_findregister.dart';
import '../register/s_register.dart';

/// TODO : 0824 서은율 수정 => 로그인을 통한 로컬 데이터 저장 및 로그인 처리
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          )
        : SafeArea(
            child: Scaffold(
              body: Center(
                child: Form(
                  key: formKey,
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
                        child: TextFormField(
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black), // 밑줄 색상 설정
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                            ),
                            labelText: '이메일',
                          ),
                          onChanged: (text) {
                            email = text;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                        child: TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black), // 밑줄 색상 설정
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                            ),
                            labelText: '비밀번호',
                          ),
                          onChanged: (text) {
                            password = text;
                          },
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
                              /// TODO : 로그인 처리 -완 및 로컬 데이터 저장
                              AuthService()
                                  .loginWithUserNameandPassword(email, password)
                                  .then((value) async {
                                if (value == true) {
                                  QuerySnapshot snapshot =
                                      await FireStoreService()
                                          .gettingUserData(email);
                                  // await storage.write(
                                  //     key: "uid", value: snapshot.docs[0].id);
                                  await storage.write(
                                      key: "nickName",
                                      value: snapshot.docs[0].get("nickName"));
                                  await storage.write(
                                      key: "email",
                                      value: snapshot.docs[0].get("email"));

                                  if (context.mounted) {
                                    Nav.push(MainScreen());
                                  }
                                }
                              });
                            }),
                      ),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Nav.push(FindRegisterPage());
                              },
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
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage()),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
