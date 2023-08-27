import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/service/sv_auth.dart';
import 'package:nav/nav.dart';

import '../../service/sv_firestore.dart';
import '../main/s_main.dart';
import '../register/s_findregister.dart';
import '../register/s_register.dart';

/// 0824 서은율, 한승완
/// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  void checkLogin() async{
    var result = await AuthService().checkUserAvailable();
    if(result){
      if(!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()),);
    }

  }

  // 이메일
  String email = "";

  // 비밀번호
  String password = "";

  // 로딩 여부
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    // 로그인 여부 확인
    checkLogin();

    super.initState();
  }

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
                        height: context.height(0.2),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
                        child: FlutterLogo(
                          size: context.height(0.2),
                        ),
                      ),
                      Container(
                        height: context.height(0.08),
                        padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
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
                        height: context.height(0.08),
                        padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
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
                        height: context.height(0.09),
                        padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
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
                              /// 로그인 + 로컬 데이터 저장
                              AuthService()
                                  .loginWithUserNameandPassword(email, password)
                                  .then((value) async {
                                if (value == true) {
                                  QuerySnapshot snapshot = await FireStoreService().gettingUserData(email);

                                  storage.write(
                                      key: "nickName",
                                      value: snapshot.docs[0].get("nickName"));
                                  storage.write(
                                      key: "email",
                                      value: snapshot.docs[0].get("email"));
                                  storage.write(
                                      key: "gender",
                                      value: snapshot.docs[0].get('gender'));


                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreen()),
                                    );
                                  }
                                }else{
                                  context.showErrorSnackbar(value);
                                }
                              });
                            }),
                      ),
                      Container(
                        height: context.height(0.04),
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Nav.push(const FindRegisterPage());
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
                        padding: EdgeInsets.only(top: context.height(0.1)),
                        child: Container(
                          height: context.height(0.09),
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
                                    builder: (context) => const RegisterPage()),
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
