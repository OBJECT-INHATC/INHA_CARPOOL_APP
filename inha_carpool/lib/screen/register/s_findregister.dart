import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 비밀번호 찾기 페이지

class FindRegisterPage extends StatefulWidget {
  const FindRegisterPage({super.key});

  @override
  State<FindRegisterPage> createState() => _FindRegisterPageState();
}

class _FindRegisterPageState extends State<FindRegisterPage> {
  String email = "";
  final auth = FirebaseAuth.instance;
  bool onChanged = false;

  bool isValidEmail(String input) {
    final RegExp regex = RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Form(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
              Container(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
              child: const Text(
                  '비밀번호를 재설정 하기 위해 학번 이메일을 입력해주세요!',
                  style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
            child: const Text(
              '학교 이메일로 비밀번호 재설정 코드가 전송됩니다.',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextFormField(
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      labelText: null,
                      hintText: '학교 이메일 (ex 200000000@itc.ac.kr)',
                      hintStyle: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                    onChanged: (text) {
                      email = text ;
                      setState(() {
                        onChanged = text.isNotEmpty;
                      });
                    },
                    validator: (val) {
                      if (val!.isEmpty || !isValidEmail(val)) {
                        return "올바른 이메일을 입력해주세요.";
                      } else if (val.length < 15 || !val.contains("@") || !val.contains(".") || val.length > 35) {
                        return "이메일의 형식이 맞지 않습니다.";
                      }
                      else {
                        return null;
                      }
                    }),
              ],
            ),
          ),
          Container(
            height: screenHeight * 0.125,
            padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.transparent,
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: onChanged ? const Color.fromARGB(255, 70, 100, 192) : Colors.grey[400],
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Text('비밀번호 재설정 요청',
                    style: TextStyle(
                        fontSize: 18.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (email != "" && isValidEmail(email)) {
                    auth.sendPasswordResetEmail(email: email);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.transparent,
                          title: const Text("비밀번호 재설정 메일 전송"),
                          content: const Text("비밀번호 재설정 메일을 보내드렸습니다. 변경이 완료된 후 다시 로그인 해주세요!"),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text("확인"),
                              onPressed: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('올바른 이메일을 입력해주세요.'),
                      ),
                    );
                  }
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
