import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/screen/register/s_verifiedregister.dart';
import 'package:nav/nav.dart';
import '../../service/sv_auth.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

/// 0824 서은율 한승완
/// 회원 가입 페이지
/// 0830 / 0907 / 0910 / 0922 최은우
/// 디자인 수정

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

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

  // 닉네임
  String nickname = "";

  // 학교
  String academy = "@itc.ac.kr";

  // 로딩 여부
  bool isLoading = false;

  // 성별
  String? gender;
  var genders;

  String passwordCheck = "";

  var selectedIndex = 0;

  List<Color> selectedBackgroundColors = [
    const Color.fromARGB(255, 70, 100, 192)
  ];
  List<Color> unSelectedBackgroundColors = [Colors.black54, Colors.black];

  // 입력 필드 높이 설정
  double inputFieldHeight = 50.0;

  // 토글 배경색 업데이트 메서드
  void updateBackgroundColors() {
    // 선택된 토글의 배경색을 변경
    selectedBackgroundColors = selectedIndex == 0
        ? [const Color.fromARGB(255, 70, 100, 192)]
        : [const Color.fromARGB(255, 70, 100, 192)];

    // 선택되지 않은 토글의 배경색을 변경
    unSelectedBackgroundColors = selectedIndex == 0
        ? [Colors.black54, Colors.black]
        : [Colors.black54, Colors.black];
  }

  bool containsProfanity(String nickname, List<String> profanityList) {
    for (String profanity in profanityList) {
      if (nickname.toLowerCase().contains(profanity.toLowerCase())) {
        return true; // 비속어가 포함된 경우
      }
    }
    return false; // 비속어가 없는 경우
  }

  List<String> splitStringBySpace(String text) {
    List<String> words = text.split('\n'); // 줄바꿈을 기준으로 문자열을 분할
    return words;
  }

  Future<String> readTextFromFile() async {
    String path = 'assets/fwordList.txt';

    try {
      String content = await rootBundle.loadString(path);
      return content;
    } catch (e) {
      return 'Error reading file: $e';
    }
  }


  @override
  Widget build(BuildContext context) {
    //const Color pastelSkyBlue = Color(0xff6CC0FF);
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
                // color: Theme.of(context).primaryColor,
                ),
          )
        : GestureDetector(
            onTap: () {
              // 텍스트 포커스 해제
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  iconSize: 30,
                ),
                title: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                foregroundColor: Colors.white,
                shadowColor: Colors.white,
              ),
              body: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 70),
                        Container(
                            padding: const EdgeInsets.fromLTRB(40, 25, 40, 0),
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                // Container 위젯 안에 있는 TextFormField 부분
                                Container(
                                  // 학번 입력 필드
                                  height: inputFieldHeight, // 높이 변수 적용
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!, // 연한 회색 테두리
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[100], // 연한 회색 배경색
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: null,
                                            // labelText를 null로 설정하고 힌트 텍스트 숨김
                                            hintText: '학번',
                                            border: InputBorder.none,
                                            prefixIcon: Icon(
                                              Icons.school,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          onChanged: (text) {
                                            setState(() {
                                              email = text + academy;
                                            });
                                          },
                                          validator: (val) {
                                            if (val!.isNotEmpty) {
                                              return null;
                                            } else {
                                              return "학번이 비어있습니다.";
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  child: FlutterToggleTab(
                                    width: 30,
                                    borderRadius: 10,
                                    height: 38,
                                    selectedTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    unSelectedTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    labels: const ["인하공전", "인하대"],
                                    selectedLabelIndex: (index) {
                                      setState(() {
                                        if (index == 0) {
                                          academy = "@itc.ac.kr";
                                        } else {
                                          academy = "@inha.edu";
                                          // academy = "@inhatc.ac.kr"; //교수님들 메일
                                        }
                                        selectedIndex = index;
                                        updateBackgroundColors();
                                      });
                                    },
                                    selectedBackgroundColors:
                                        selectedBackgroundColors,
                                    unSelectedBackgroundColors:
                                        unSelectedBackgroundColors,
                                    isScroll: false,
                                    selectedIndex: selectedIndex,
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(height: 15), // 15 아래로 이동
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: Container(
                            // 이름 입력 필드
                            height: inputFieldHeight, // 높이 변수 적용
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[300]!, // 연한 회색 테두리
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[100], // 연한 회색 배경색
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: null,
                                hintText: '이름',
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
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
                        ),
                        const SizedBox(height: 15), // 15 아래로 이동
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: Container(
                            // 닉네임 입력 필드
                            height: inputFieldHeight, // 높이 변수 적용
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[300]!, // 연한 회색 테두리
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[100], // 연한 회색 배경색
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: null,
                                hintText: '닉네임',
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (val) {
                                if (val!.isNotEmpty) {
                                  return null;
                                } else {
                                  return "닉네임이 비어있습니다.";
                                }
                              },
                              onChanged: (text) {
                                nickname = text;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: Container(
                            // 비밀번호 입력 필드
                            height: inputFieldHeight, // 높이 변수 적용
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[300]!, // 연한 회색 테두리
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[100], // 연한 회색 배경색
                            ),
                            child: TextFormField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: null,
                                hintText: '비밀번호',
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                ),
                              ),
                              onChanged: (text) {
                                password = text;

                                if (password == checkPassword) {
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
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: Container(
                            // 비밀번호 확인 입력 필드
                            height: inputFieldHeight, // 높이 변수 적용
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[300]!, // 연한 회색 테두리
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[100], // 연한 회색 배경색
                            ),
                            child: TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: null,
                                hintText: '비밀번호 확인',
                                border: InputBorder.none,
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                ),
                                suffix: Text(
                                  passwordCheck,
                                  style: (passwordCheck == "비밀번호가 일치하지 않습니다.")
                                      ? const TextStyle(color: Colors.red)
                                      : const TextStyle(color: Colors.green),
                                ),
                              ),
                              onChanged: (text) {
                                checkPassword = text;
                                if (password == checkPassword) {
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
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 20),
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
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              // 버튼 높이
                              backgroundColor: context.appColors.logoColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                              // 그림자 추가
                              shadowColor: Colors.black,
                              // 그림자 색상
                              surfaceTintColor: Colors.transparent,
                            ),
                            onPressed:  ()  async {
                              String sampleText = await readTextFromFile();
                              print(sampleText);
                              if (passwordCheck != "비밀번호가 일치합니다!" ||
                                  username == "" ||
                                  email == "" ||
                                  password == "" ||
                                  gender == "") {
                                showSnackbar(context, Colors.red,
                                    "정보가 올바르지 않습니다. 다시 확인해주세요.");
                              } else if (containsProfanity(
                                  nickname, splitStringBySpace(sampleText))) {
                                showSnackbar(context, Colors.red,
                                    "비속어가 포함되어 있습니다.");
                                // 비속어 필터
                              } else {
                                AuthService()
                                    .registerUserWithEmailandPassword(
                                        username,
                                        nickname,
                                        email,
                                        password,
                                        "dummy",
                                        gender!)
                                    .then((value) async {
                                  if (value == true) {
                                    await FirebaseAuth.instance.currentUser!
                                        .sendEmailVerification();
                                    if (!mounted) return;
                                    Nav.push(const VerifiedRegisterPage());
                                  } else {
                                    showSnackbar(context, Colors.red, value);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                });
                              }
                            },
                            child: const Text(
                              '가입하기',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
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

  void updateEmail() {
    // 텍스트 필드에 이미 값이 있는지 확인
    if (email.isNotEmpty) {
      // '@' 문자 앞부분만 가져옴 (학번 부분)
      String id = email.split('@')[0];

      // 새로운 학교 도메인을 붙임
      email = id + academy;
    }
  }
}
