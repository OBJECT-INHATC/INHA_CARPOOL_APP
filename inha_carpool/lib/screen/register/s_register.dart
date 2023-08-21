import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dto_registerstore.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  // 미디어 쿼리 사용을 위한 함수
  double mediaHeight(BuildContext context, double scale) =>
      MediaQuery.of(context).size.height * scale;

  double mediaWidth(BuildContext context, double scale) =>
      MediaQuery.of(context).size.width * scale;

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
                key: context.watch<infostore>().formKey,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // SizedBox(height: mediaHeight(context, 0.2)),
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 20, 40, 0),
                          child: Column(
                            children: [
                              RadioListTile(
                                title: Text("인하공전"),
                                value: "@itc.ac.kr",
                                groupValue: gender,
                                onChanged: (value) {
                                  context.read<infostore>().chagneAcademy(value.toString());
                                },
                                fillColor: MaterialStateProperty.all(Colors.blue[900]),
                              ),
                              RadioListTile(
                                title: Text("인하대"),
                                value: "@inha.ac.kr",
                                groupValue: gender,
                                onChanged: (value) {
                                  context.read<infostore>().chagneAcademy(value.toString());
                                },
                                fillColor: MaterialStateProperty.all(Colors.blue[400]),
                              ),
                            ],
                          ),
                          ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: Stack(
                            children: [
                              TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  labelText: '이메일',
                                  suffixText: '${context.watch<infostore>().academy}',
                                ),
                                onChanged: (text) {
                                  // 텍스트 필드 값 변경 시 실행할 코드 작성
                                  context.watch<infostore>().email = text;
                                },


                              ),
                              Positioned(
                                right: 2,
                                child: ElevatedButton(

                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(60, 30),

                                    backgroundColor: Colors.grey[200],
                                  ),
                                  onPressed: () {},
                                  child: Text('인증번호 전송',
                                      style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: TextFormField(
                            decoration: InputDecoration(
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
                            decoration: InputDecoration(
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
                              context.watch<infostore>().password = text;
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
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
                              context.watch<infostore>().checkPassword = text;
                            },
                            validator: (val) {
                              if (val != context.watch<infostore>().password) {
                                return "비밀번호가 일치하지 않습니다.";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 20, 40, 0),
                          child: Column(
                            children: [
                              RadioListTile(
                                title: Text("남성"),
                                value: "남성",
                                groupValue: gender,
                                onChanged: (value) {},
                                fillColor: MaterialStateProperty.all(Colors.blue),
                              ),
                              RadioListTile(
                                title: Text("여성"),
                                value: "여성",
                                groupValue: gender,
                                onChanged: (value) {},
                                fillColor: MaterialStateProperty.all(Colors.red),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: mediaHeight(context, 0.1)),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                          child: Stack(
                            children: [
                              TextField(
                                obscureText: true,
                                decoration: InputDecoration(
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
                                  child: Text('확인',
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
