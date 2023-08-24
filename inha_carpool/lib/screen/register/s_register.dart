import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nav/nav.dart';
import '../../service/sv_auth.dart';
import '../dialog/d_auth_verification.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

/// 0824 서은율 한승완
/// 회원 가입 페이지
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final formKey = GlobalKey<FormState>();

  /// 0825 서은율 TODO : 화면 비율 + 유효성 확인 + Alert 창 수정

  // 이메일
  String email = "";

  // 비밀번호
  String password = "";

  // 비밀번호 비교
  String checkPassword = "";

  // 이름
  String username = "";

  // 학교
  String academy = "@itc.ac.kr";

  // 로딩 여부
  bool isLoading = false;

  // 성별
  String? gender;
  var genders;

  String passwordCheck = "";

  var selectedIndex = 0;

  List<Color> selectedBackgroundColors = [Colors.blue, Colors.green];
  List<Color> unSelectedBackgroundColors = [Colors.white, Colors.white];
  void updateBackgroundColors() {
    // 선택된 토글의 배경색을 변경
    selectedBackgroundColors = selectedIndex == 0
        ? [Colors.blue, Colors.white]
        : [Colors.white, Colors.green];

    // 선택되지 않은 토글의 배경색을 변경
    unSelectedBackgroundColors = selectedIndex == 0
        ? [Colors.white, Colors.green]
        : [Colors.blue, Colors.white];
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
              body: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                          child: Stack(
                            alignment: Alignment.centerRight, // 텍스트를 오른쪽 중앙에 배치
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  labelText: '학번',
                                ),
                                onChanged: (text) {
                                  // 텍스트 필드 값 변경 시 실행할 코드 작성
                                  email = text + academy;
                                  print(email);
                                },
                              ),
                              Positioned( // 중간 텍스트를 겹쳐서 배치
                                right: 140,
                                child: Text(academy),
                              ),
                              Positioned( // 중간 텍스트를 겹쳐서 배치
                                right: 0,
                                child:FlutterToggleTab(
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
                                      if(index == 0){
                                        academy = "@itc.ac.kr";
                                      }
                                      else{
                                        academy = "@inha.ac.kr";
                                      }
                                      selectedIndex = index;
                                      updateBackgroundColors();
                                    });
                                  },
                                  selectedBackgroundColors: const [Colors.blue, Colors.green],
                                  unSelectedBackgroundColors: const [Colors.white, Colors.white],
                                  isScroll: false, selectedIndex: selectedIndex,
                                ),

                              ),
                            ],
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
                              suffix: Text(passwordCheck, style: (passwordCheck=="비밀번호가 일치하지 않습니다.")?TextStyle(color: Colors.red):TextStyle(color: Colors.green)),
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
                                    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                    Navigator.pop(context);
                                    if(!mounted) return ;
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context){
                                      return VerificationDialog();
                                    },);

                                  }
                                  else {
                                    showSnackbar(context, Colors.red, value);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }});

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

/// TODO: 0824 서은율 : 비율 맞추기, 비밀번호 안맞으면 가입 못하게