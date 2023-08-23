import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dto_registerstore.dart';

/// TODO : 0824 서은율 수정 => 회원가입 처리 + 렌더링 최적화 시간이 될때
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 미디어 쿼리 사용을 위한 함수
  double mediaHeight(BuildContext context, double scale) =>
      MediaQuery.of(context).size.height * scale;

  double mediaWidth(BuildContext context, double scale) =>
      MediaQuery.of(context).size.width * scale;

  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String checkPassword = "";
  String username = "";
  String academy = "";
  bool isLoading= false;
  String? gender;



  @override
  Widget build(BuildContext context) {
    return context.watch<infostore>().isLoading
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900]
                                ),
                                  onPressed: () {

                                    academy ="@itc.ac.kr";
                                  },
                                  child: const Text("인하공전")),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[300]
                                  ),
                                  onPressed: () {
                                    academy ="@inha.ac.kr";
                                  },
                                  child: const Text("인하대")),


                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              labelText: '이메일',
                              suffixText:
                                  academy,
                            ),
                            onChanged: (text) {
                              // 텍스트 필드 값 변경 시 실행할 코드 작성
                              email = text;
                            },
                          ),
                        ),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
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
                              onPressed: () {}),
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
                              context.watch<infostore>().username = text;
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
                                groupValue: gender,
                                onChanged: (value) {},
                                fillColor:
                                    MaterialStateProperty.all(Colors.blue),
                              ),
                              RadioListTile(
                                title: const Text("여성"),
                                value: "여성",
                                groupValue: gender,
                                onChanged: (value) {},
                                fillColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(height: mediaHeight(context, 0.1)),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
                          child: Stack(
                            children: [
                              TextField(
                                obscureText: true,
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  labelText: '인증 번호',
                                ),
                                onChanged: (text) {
                                  // 텍스트 필드 값 변경 시 실행할 코드 작성
                                },
                              ),
                              Positioned(
                                right: 2,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  onPressed: () {},
                                  child: const Text('확인',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                              onPressed: () {
                                Navigator.pop(context);
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
}
