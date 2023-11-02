import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FindRegisterPage extends StatefulWidget {
  const FindRegisterPage({super.key});

  @override
  State<FindRegisterPage> createState() => _FindRegisterPageState();
}

class _FindRegisterPageState extends State<FindRegisterPage> {
  // 이메일
  String email = "";

  // 학교
  String academy = "@itc.ac.kr";
  final auth = FirebaseAuth.instance;

  var selectedIndex = 0;

  List<Color> selectedBackgroundColors = [Color.fromARGB(255, 70, 100, 192)];
  List<Color> unSelectedBackgroundColors = [Colors.black54, Colors.black];

// 토글 배경색 업데이트 메서드
  void updateBackgroundColors() {
    // 선택된 토글의 배경색을 변경
    selectedBackgroundColors = selectedIndex == 0
        ? [Color.fromARGB(255, 70, 100, 192)]
        : [Color.fromARGB(255, 70, 100, 192)];

    // 선택되지 않은 토글의 배경색을 변경
    unSelectedBackgroundColors = selectedIndex == 0
        ? [Colors.black54, Colors.black]
        : [Colors.black54, Colors.black];
  }

  var onChanged =false;

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        // 텍스트 포커스 해제
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
                      '비밀번호를 재설정 하기 위해 \n학번을 입력해주세요!',
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
                              labelText: null,  // labelText를 null로 설정하고 힌트 텍스트 숨김
                              hintText: '학번',
                              hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                            onChanged: (text) {
                              // 텍스트 필드 값 변경 시 실행할 코드 작성
                              email = text + academy;
                              if(text!=""){
                                setState(() {
                                  onChanged = true;
                                });
                              }else{
                                setState(() {
                                  onChanged = false;
                                });
                              }},
                            validator: (val) {
                              if (val!.isNotEmpty) {
                                return null;
                              } else {
                                return "학번이 비어있습니다.";
                              }
                            }),
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
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
                            labels: const ["인하공전", "인하대"],
                            selectedLabelIndex: (index) {
                              setState(() {
                                if (index == 0) {
                                  academy = "@itc.ac.kr";
                                } else {
                                  academy = "@inha.ac.kr";
                                }
                                selectedIndex = index;
                                updateBackgroundColors();
                              });
                            },
                            selectedBackgroundColors: const [Color.fromARGB(255, 70, 100, 192)],
                            unSelectedBackgroundColors: const [
                              Colors.black54,
                              Colors.black
                            ],
                            isScroll: false,
                            selectedIndex: selectedIndex,
                          ),
                        ),
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
                          backgroundColor: (onChanged != false)? Color.fromARGB(255, 70, 100, 192) : Colors.grey[400],
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.0), //버튼 위아래 패딩 크기 늘리기
                        ),
                        child: const Text('비밀번호 재설정 요청',
                            style: TextStyle(
                                fontSize: 18.5,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          auth.sendPasswordResetEmail(email: email);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                surfaceTintColor: Colors.transparent,
                                title: Text("비밀번호 재설정 메일 전송"),
                                content: Text("비밀번호 재설정 메일을 보내드렸습니다. 변경이 완료된 후 다시 로그인 해주세요!"),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text("확인"),
                                    onPressed: () {
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
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
