import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import '../../../dialog/d_delete_auth.dart';

class SecessionPage extends StatefulWidget {
  @override
  State<SecessionPage> createState() => _SecessionPageState();
}

class _SecessionPageState extends State<SecessionPage> {
  // 이메일
  String email = "";
  // 비밀번호
  String password = "";
  String academy = "@itc.ac.kr";
  var onChanges = false;

  var selectedIndex = 0;

  List<Color> selectedBackgroundColors = [const Color.fromARGB(255, 70, 100, 192)];
  List<Color> unSelectedBackgroundColors = [Colors.black54, Colors.black];

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

  final storage = const FlutterSecureStorage();
  late Future<String> nickNameFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    nickNameFuture = _loadUserDataForKey("nickName");
  }

  Future<String> _loadUserDataForKey(String key) async {
    return await storage.read(key: key) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 텍스트 포커스 해제
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: Colors.black,
          shadowColor: Colors.white,
          leadingWidth: 56,
          title: const Text(
            "회원 탈퇴",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center, // 상단 정렬로 변경
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 30,
                        ),

                        // SizedBox(height: 20),
                        FutureBuilder<String>(
                          future: nickNameFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 스피너 표시
                            } else if (snapshot.hasError) {
                              return const Text('닉네임을 불러오는 중 오류 발생');
                            } else {
                              return Text(
                                "${snapshot.data}님.. 정말 탈퇴하시겠어요?",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15), // 간격 조절
                    const Text(
                      "지금 탈퇴하시면 서비스를 이용할 수 없어요!\n탈퇴하시려면 학번과 비밀번호를 입력해 주세요.",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: context.height(0.015)),
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 25, 40, 0),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Container(
                            // 학번 입력 필드
                            height: 50.0, // 높이 변수 적용
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
                                      labelText: '학번',
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.school,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onChanged: (text) {
                                      email = text;
                                      if (text != "") {
                                        setState(() {
                                          onChanges = true;
                                        });
                                      } else {
                                        setState(() {
                                          onChanges = false;
                                        });
                                      }
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
                                FlutterToggleTab(
                                  width: 28,
                                  borderRadius: 10,
                                  height: 50.0,
                                  // 높이 변수 적용
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
                                        academy = "@inha.edu";
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.height(0.01)),
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                      child: Container(
                        // 비밀번호 입력 필드
                        height: 50.0, // 높이 변수 적용
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
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: '비밀번호',
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                          ),
                          onChanged: (text) {
                            password = text;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: context.height(0.01)),
                    Container(
                      height: context.height(0.12),
                      padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: (onChanges != false)?Colors.blue:Colors.grey[300], // 버튼 배경색 회색으로 설정
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),

                          child: const Text('탈퇴하기',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),

                          onPressed: () async {
                            bool isValid = await validateCredentials(
                                email + academy, password);
                            if (isValid) {
                              if (!mounted) return;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DeleteAuthDialog(
                                      email + academy, password);
                                },
                              );
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('잘못된 정보입니다.')));
                            }
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 이메일과 비밀번호를 통해 로그인 사용자 재확인 함수
/// ex) 비밀번호 변경, 회원탈퇴
Future<bool> validateCredentials(String email, String password) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    AuthCredential credential =
    EmailAuthProvider.credential(email: email, password: password);
    await user!.reauthenticateWithCredential(credential);
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

