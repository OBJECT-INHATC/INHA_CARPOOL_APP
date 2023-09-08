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
    return Scaffold(
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
      body: Center(
        child: Form(
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
                              academy = "@inha.ac.kr";
                            }
                            selectedIndex = index;
                            updateBackgroundColors();
                          });
                        },
                        selectedBackgroundColors: const [
                          Colors.blue,
                          Colors.green
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
                    child: const Text('비밀번호 재설정 요청',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    onPressed: () {
                      auth.sendPasswordResetEmail(email: email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('비밀번호 재설정 메일을 보냈습니다.'),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
