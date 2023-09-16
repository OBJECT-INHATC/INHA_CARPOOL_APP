import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import '../../../dialog/d_delete_auth.dart';

class SecessionPage extends StatefulWidget {
  const SecessionPage({super.key});

  @override
  State<SecessionPage> createState() => _SecessionPageState();
}

class _SecessionPageState extends State<SecessionPage> {
  // 이메일
  String email = "";

  // 비밀번호
  String password = "";

  String academy = "@itc.ac.kr";

  var selectedIndex = 0;

  List<Color> selectedBackgroundColors = [Colors.blue, Colors.black];
  List<Color> unSelectedBackgroundColors = [Colors.white, Colors.white];

  void updateBackgroundColors() {
    // 선택된 토글의 배경색을 변경
    selectedBackgroundColors = selectedIndex == 0
        ? [Colors.blue, Colors.black]
        : [Colors.black, Colors.blue];

    // 선택되지 않은 토글의 배경색을 변경
    unSelectedBackgroundColors = selectedIndex == 0
        ? [Colors.white, Colors.white]
        : [Colors.white, Colors.white];
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 56,
        leading: const Center(
          child: BackButton(
            color: Colors.black,
          ),
        ),
        title: const Text(
          "회원탈퇴",
          style: TextStyle(color: Colors.black, fontSize: 17),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬로 변경
          children: <Widget>[
            const SizedBox(height: 25),
            const Icon(
              Icons.warning,
              color: Colors.red,
              size: 40,
            ),
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: nickNameFuture,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 스피너 표시
                } else if (snapshot.hasError) {
                  return const Text('닉네임을 불러오는 중 오류 발생');
                } else {
                  return Text(
                    "${snapshot.data}님..\n정말 탈퇴하시겠어요?",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  );
                }
              },
            ),
            const SizedBox(height: 25), // 간격 조절
            const Text(
              "지금 탈퇴하시면 서비스를 이용할 수 없어요!\n 탈퇴하시려면 학번과 비밀번호를 입력해주세요.",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold ,color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Stack(
              alignment: Alignment.centerRight, // 텍스트를 오른쪽 중앙에 배치
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: '학번',
                  ),
                  onChanged: (text) {
                    // 텍스트 필드 값 변경 시 실행할 코드 작성
                    email = text;
                  },
                  validator: (val) {
                    if (val!.isNotEmpty) {
                      return null;
                    } else {
                      return "학번이 비어있습니다.";
                    }
                  },
                ),
                Positioned(
                  right: 0,
                  child: FlutterToggleTab(
                    width: 30,
                    borderRadius: 30,
                    height: 40,
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
                        selectedIndex = index;
                        updateBackgroundColors();
                        if (index == 0) {
                          academy = "@itc.ac.kr";
                        } else {
                          academy = "@inha.edu";
                        }
                      });
                    },
                    selectedBackgroundColors: selectedBackgroundColors,
                    unSelectedBackgroundColors: unSelectedBackgroundColors,
                    isScroll: false,
                    selectedIndex: selectedIndex,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: context.height(0.08),
              child: TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black), // 밑줄 색상 설정
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.blue), // 포커스된 상태의 밑줄 색상 설정
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
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey, // 버튼 배경색 회색으로 설정
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90.0),
                    ),
                  ),
                  child: const Text('탈퇴하기',
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    bool isValid = await validateCredentials(email + academy, password);
                    if (isValid) {
                      if(!mounted) return;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DeleteAuthDialog(email + academy, password);
                        },
                      );
                    } else {
                      if(!mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('잘못된 정보입니다.')));
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}




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

//탈퇴하기를 누르면 dialog 뜨고 아이디 비밀번호 입력하고 맞으면 확인 눌러서 탈퇴 로직 구현
