import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nav/nav.dart';
import '../../service/sv_auth.dart';
import '../dialog/d_auth_verification.dart';

/// 0824 서은율 한승완
/// 회원 가입 페이지
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final formKey = GlobalKey<FormState>();

  // 이메일
  String email = "";

  // 비밀번호
  String password = "";

  // 비밀번호 비교
  String checkPassword = "";

  // 이름
  String username = "";

  // 학교
  String academy = "";

  // 로딩 여부
  bool isLoading = false;

  // 성별
  String? gender;
  var genders;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          )
        : SafeArea(
            child: Scaffold(
              body: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 20, 40, 0),
                          width: double.infinity,

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[900]),
                                  onPressed: () {
                                    setState(() {
                                      academy = "@itc.ac.kr";
                                    });
                                  },
                                  child: const Text("인하공전")),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[300]),
                                  onPressed: () {
                                    setState(() {
                                      academy = "@inha.ac.kr";
                                    });
                                  },
                                  child: const Text("인하대")),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              labelText: '학번',
                              suffixText: academy,
                            ),
                            onChanged: (text) {
                              // 텍스트 필드 값 변경 시 실행할 코드 작성
                              email = text+academy;
                              print(email);
                            },
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
                              labelText: '이름',
                            ),
                            validator: (val) {
                              if (val!.isNotEmpty) {
                                return null;
                              } else {
                                return "이름이 비어있습니다.";
                              }
                            },
                            onChanged: (text) {
                              username = text;
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
                              labelText: '비밀번호 확인',
                            ),
                            onChanged: (text) {
                              checkPassword = text;
                            },
                            validator: (val) {
                              if (val != password) {
                                return "비밀번호가 일치하지 않습니다.";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 40, 0),
                          child: Column(
                            children: [
                              RadioListTile(
                                title: const Text("남성"),
                                value: "남성",
                                groupValue: genders,
                                onChanged: (value) {
                                  setState(() {
                                    genders = value;
                                    gender = value.toString();
                                  });

                                },
                                fillColor:
                                    MaterialStateProperty.all(Colors.blue),
                              ),
                              RadioListTile(
                                title: const Text("여성"),
                                value: "여성",
                                groupValue: genders,
                                onChanged: (value) {
                                  setState(() {
                                    genders = value;
                                    gender = value.toString();
                                  });
                                },
                                fillColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(height: mediaHeight(context, 0.1)),
                        // Container(
                        //   padding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
                        //   child: Stack(
                        //     children: [
                        //       TextField(
                        //         obscureText: true,
                        //         decoration: const InputDecoration(
                        //           enabledBorder: UnderlineInputBorder(
                        //             borderSide: BorderSide(color: Colors.black),
                        //           ),
                        //           focusedBorder: UnderlineInputBorder(
                        //             borderSide: BorderSide(color: Colors.blue),
                        //           ),
                        //           labelText: '인증 번호',
                        //         ),
                        //         onChanged: (text)async {
                        //           // 텍스트 필드 값 변경 시 실행할 코드 작성
                        //
                        //
                        //           print("인증 메일 전송");
                        //         },
                        //       ),
                        //       Positioned(
                        //         right: 2,
                        //         child: ElevatedButton(
                        //           style: ElevatedButton.styleFrom(
                        //             backgroundColor: Colors.grey[200],
                        //           ),
                        //           onPressed: () {},
                        //           child: const Text('확인',
                        //               style: TextStyle(
                        //                   fontSize: 12,
                        //                   color: Colors.grey,
                        //                   fontWeight: FontWeight.bold)),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        Container(
                          height: 80,
                          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: Colors.grey[700],
                              ),
                              child: const Text('가입완료',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () async{

                                AuthService()
                                    .registerUserWithEmailandPassword(username,
                                        email, password, "dummy", gender!)
                                    .then((value) async{
                                  if (value == true) {
                                    showSnackbar(context, Colors.green, "회원가입이 완료되었습니다. \n 메일 인증을 완료해주세요.");
                                  }
                                  else {
                                    showSnackbar(context, Colors.red, value);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }});

                              }),
                        ),
                        Container(
                          height: 80,
                          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: Colors.grey[200],
                              ),
                              child: const Text('인증번호 전송',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () async{
                                await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                Nav.push(const auth_verificationDialog());

                                /// TODO : 0825 서은율 추가 -> 인증 메일 전송
                              }),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  void showSnackbar(context, color, message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: "OK",
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }


}
