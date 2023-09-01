import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';

import '../../service/sv_auth.dart';
import '../login/s_login.dart';

class DeleteAuthDialog extends StatefulWidget {
  const DeleteAuthDialog({super.key});

  @override
  State<DeleteAuthDialog> createState() => _DeleteAuthDialogState();
}

class _DeleteAuthDialogState extends State<DeleteAuthDialog> {
  // 이메일
  String email = "";

  // 비밀번호
  String password = "";

  String academy = "@itc.ac.kr";

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
    var width = MediaQuery.of(context).size.width; //화면의 가로길이

    return AlertDialog(
      //경고창
      insetPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      //경고창의 내부여백
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //모서리 둥글게
      content: SizedBox(
        //경고창의 크기
        width: width, // -20을 해주는 이유는 경고창의 내부여백이 20이기 때문
        // height: 150, //경고창의 높이
        child: Column(
          //열
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    // padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
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
                    height: context.height(0.08),
                    // padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
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
                        child: const Text('탈퇴하기',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        onPressed: () async{
                          String realDelete = await AuthService().deleteAccount(email, password);
                          if(realDelete == "Success"){
                          AuthService().signOut().then((value) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (Route<dynamic> route) => false,
                            );
                          });} // 로그아웃
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
