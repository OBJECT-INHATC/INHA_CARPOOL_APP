import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/register/s_verifiedregister.dart';
import 'package:nav/nav.dart';
import '../../service/sv_auth.dart';
// import '../dialog/d_auth_verification.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
// import 'package:inha_Carpool/common/extension/context_extension.dart';

/// 0824 서은율 한승완
/// 회원 가입 페이지
/// 0830 최은우
/// 디자인 1차 수정
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
  //닉네임
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

  List<Color> selectedBackgroundColors = [Colors.blue, Colors.black];
  List<Color> unSelectedBackgroundColors = [Colors.white, Colors.white];

  void updateBackgroundColors() {
    // 선택된 토글의 배경색을 변경
    selectedBackgroundColors = selectedIndex == 0
        ? [Colors.blue, Colors.white]
        : [Colors.white, Colors.black];

    // 선택되지 않은 토글의 배경색을 변경
    unSelectedBackgroundColors = selectedIndex == 0
        ? [Colors.white, Colors.black]
        : [Colors.blue, Colors.white];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
      child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor),
    )

        : Scaffold(
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 37, // 간격 조절 SizedBox
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          iconSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 70), // 간격 조절 SizedBox
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: Stack(
                        alignment: Alignment.centerRight, // 텍스트를 오른쪽 중앙에 배치
                        children: [
                          TextFormField(
                            // 학번 입력 필드
                              decoration: InputDecoration(
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                labelText: '학번',
                                prefixIcon: Icon(Icons.school), // 학번 아이콘
                              ),
                              onChanged: (text) {
                                // 텍스트 필드 값 변경 시 실행할 코드 작성
                                email = text + academy;
                              },
                              validator: (val) {
                                if (val!.isNotEmpty) {
                                  return null;
                                } else {
                                  return "학번이 비어있습니다.";
                                }
                              }),
                          Positioned(
                            // 중간 텍스트를 겹쳐서 배치
                            right: 140,
                            child: Text(academy),
                          ),
                          Positioned(
                            // 중간 텍스트를 겹쳐서 배치
                            right: 0,
                            child: FlutterToggleTab(
                              width: 30,
                              borderRadius: 30,
                              height: 40,
                              // initialIndex: 0,
                              selectedTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                              unSelectedTextStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500),
                              labels: const ["인하공전", "인하대"],
                              selectedLabelIndex: (index) {
                                setState(() {
                                  if (index == 0) {
                                    academy = "@itc.ac.kr";
                                  } else {
                                    academy = "@inha.edu";
                                  }
                                  selectedIndex = index;
                                  updateBackgroundColors();
                                  updateEmail();
                                });
                              },
                              selectedBackgroundColors: const [
                                Colors.blue,
                                Colors.black
                              ],
                              unSelectedBackgroundColors: const [
                                Colors.white,
                                Colors.white
                              ],
                              isScroll: false,
                              selectedIndex: selectedIndex,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9), // 간격 조절 SizedBox
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: TextFormField(
                        // 이름 입력 필드
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                          ),
                          labelText: '이름',
                          prefixIcon: Icon(Icons.person), //이름 아이콘
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
                    ),const SizedBox(height: 9), // 간격 조절 SizedBox
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: TextFormField(
                        // 이름 입력 필드
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                          ),
                          labelText: '닉네임',
                          prefixIcon: Icon(Icons.person), //이름 아이콘
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
                    const SizedBox(height: 9), //간격 조절 SizedBox
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: TextFormField(
                        // 비밀번호 입력 필드
                        obscureText: true,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                          ),
                          labelText: '비밀번호',
                          prefixIcon: Icon(Icons.lock), // 비밀번호 아이콘
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
                    const SizedBox(height: 9), // 간격 조절 SizedBox
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: TextFormField(
                        // 비밀번호 확인 입력 필드
                        obscureText: true,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
                          ),
                          labelText: '비밀번호 확인',
                          prefixIcon: Icon(Icons.lock), // 비밀번호 아이콘
                          suffix: Text(passwordCheck,
                              style: (passwordCheck == "비밀번호가 일치하지 않습니다.")
                                  ? TextStyle(color: Colors.red)
                                  : TextStyle(color: Colors.green)),
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
                    const SizedBox(
                      height: 9,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 20, 40, 0),
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
                              MaterialStateProperty.all(Colors.black)
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
                            MaterialStateProperty.all(Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 1, 110, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 1), backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(90.0),
                                ),
                              ),
                              onPressed: () {
                                // 로그인 버튼 기능 추가

                                if (passwordCheck != "비밀번호가 일치합니다!" ||
                                    username == "" ||
                                    email == "" ||
                                    password == "" ||
                                    gender == "") {
                                  showSnackbar(context, Colors.red,
                                      "정보가 올바르지 않습니다. 다시 확인해주세요.");
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
                                      Nav.push(VerifiedRegisterPage());
                                    } else {
                                      showSnackbar(context, Colors.red, value);
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue, Colors.black],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(90.0),
                                ),
                                child: Center(
                                  child: Text(
                                    '  가입하기  ',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]
                      ),
                    ),
                  ],
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