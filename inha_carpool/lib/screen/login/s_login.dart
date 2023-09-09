import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/service/sv_auth.dart';
import 'package:nav/nav.dart';

import '../../service/sv_firestore.dart';
import '../main/s_main.dart';
import '../register/s_findregister.dart';
import '../register/s_register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // FCM 관련 설정 및 알림 처리를 위한 메서드
  Future<void> setupInteractedMessage() async {
    // 앱이 백그라운드 상태에서 푸시 알림 클릭하여 열릴 경우
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // 메시지 처리
    if (initialMessage != null) _handleMessage(initialMessage);
    // IOS 백그라운드 상태 푸시 알림 클릭 열릴 경우
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  // FCM 푸시 알림 클릭 시 처리 메서드
  void _handleMessage(RemoteMessage message) async {
    // 닉네임 가져오기
    String? nickName = await storage.read(key: "nickName");
    // uid 가져오기
    String? uid = await storage.read(key: "uid");

    // 한승완 TODO: 알림의 id에 따라서 이동 경로 구분 기능
    if (message.data['id'] == '1' && nickName != null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatroomPage(
            carId: message.data['groupId'],
            userName: nickName!,
            groupName: "카풀채팅",
            uid: uid!,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      context.showErrorSnackbar("알림을 불러오는데 실패했습니다.");
    }
  }

  // 로그인 여부 확인 메서드
  void checkLogin() async {
    // 로그인 여부 확인
    var result = await AuthService().checkUserAvailable();
    if (result) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()));
      await setupInteractedMessage();
    }
  }

  // 이메일
  String email = "";

  // 비밀번호
  String password = "";

  // 학교 도메인 기본값
  String academy = "@itc.ac.kr";

  var selectedIndex = 0;

  List<Color> selectedBackgroundColors = [Colors.blue, Colors.black];
  List<Color> unSelectedBackgroundColors = [Colors.white, Colors.white];

  // 토글 배경색 업데이트 메서드
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

  // 로딩 여부
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  // 장치의 FCM 토큰을 가져와 로컬에 저장하는 함수
  void getMyDeviceToken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      print("token : $value");
      storage.write(key: 'token', value: value.toString());
    });
  }

  @override
  void initState() {
    // 로그인 여부 확인
    checkLogin();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
      ),
    )
        : SafeArea(
      child: Scaffold(
        body: Center(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 140),
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Circular',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(40, 10, 30, 0),
                  child: Text(
                    '로그인이 필요한 서비스입니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 70),
                Container(
                  padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.black),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.blue),
                            ),
                            labelText: '',
                            prefixIcon: Icon(Icons.email),
                          ),
                          onChanged: (text) {
                            // 학번 부분을 입력한 텍스트에 더해줌
                            email = text + academy;
                          },
                          validator: (val) {
                            if (val!.isNotEmpty) {
                              return null;
                            } else {
                              return "학번이 비어있습니다.";
                            }
                          }),
                      // 학교 선택 토글 버튼
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
                              if (index == 0) {
                                academy = "@itc.ac.kr";
                              } else {
                                academy = "@inha.edu";
                              }
                              selectedIndex = index;
                              updateBackgroundColors();
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
                Container(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      labelText: '',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: TextButton(
                        onPressed: () {
                          Nav.push(const FindRegisterPage());
                        },
                        child: Text(
                          '비밀번호 찾기',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    onChanged: (text) {
                      password = text;
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(50, 5, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 35),
                          primary: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(90.0),
                          ),
                        ),
                        onPressed: () {
                          // 로그인 버튼 기능 추가
                          AuthService()
                              .loginWithUserNameandPassword(
                              email, password)
                              .then((value) async {
                            if (value == true) {
                              QuerySnapshot snapshot =
                              await FireStoreService()
                                  .gettingUserData(email);

                              getMyDeviceToken();

                              storage.write(
                                key: "nickName",
                                value: snapshot.docs[0]
                                    .get("nickName"),
                              );
                              storage.write(
                                key: "uid",
                                value: snapshot.docs[0].get("uid"),
                              );
                              storage.write(
                                key: "gender",
                                value: snapshot.docs[0].get('gender'),
                              );
                              storage.write(
                                key: "email",
                                value: snapshot.docs[0].get('email'),
                              );
                              storage.write(
                                key: "userName",
                                value: snapshot.docs[0].get('userName'),
                              );
                              storage.write(
                                key: "email",
                                value: snapshot.docs[0].get('email'),
                              );
                              storage.write(
                                key: "userName",
                                value: snapshot.docs[0].get('userName'),
                              );

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const MainScreen(),
                                  ),
                                );
                              }
                            } else {
                              context.showErrorSnackbar(value);
                            }
                          });
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
                          child: const Center(
                            child: Text(
                              '  로그인  ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(30, 190, 30, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '회원이 아니신가요? ',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          '가입하기',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 이메일 업데이트 메서드 추가
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
