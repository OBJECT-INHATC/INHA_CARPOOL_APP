import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/dto/UserDTO.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/service/api/Api_user.dart';
import 'package:inha_Carpool/service/sv_auth.dart';
import 'package:nav/nav.dart';

import '../../common/data/preference/prefs.dart';
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

    String? gender = await storage.read(key: "gender");

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
            gender: gender!,
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
    }else{
      print("로그인 안됨 + 스플래시 제거");
      FlutterNativeSplash.remove();
    }
  }



  // 이메일
  String email = "";

  // 비밀번호
  String password = "";

  // 학교 도메인 기본값
  String academy = "@itc.ac.kr";

  var selectedIndex = 0;

  List<Color> selectedBackgroundColors = [Color(0xff6CC0FF), Colors.black];
  List<Color> unSelectedBackgroundColors = [Colors.white, Colors.white];

// 토글 배경색 업데이트 메서드
  void updateBackgroundColors() {
    // 선택된 토글의 배경색을 변경
    selectedBackgroundColors = selectedIndex == 0
        ? [Color(0xff6CC0FF), Colors.black]
        : [Color(0xff6CC0FF), Colors.black];

    // 선택되지 않은 토글의 배경색을 변경
    unSelectedBackgroundColors = selectedIndex == 0
        ? [Colors.white, Colors.white]
        : [Colors.white, Colors.white];
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
    // 화면의 너비와 높이를 가져와서 화면 비율 계산함
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 화면 비율에 따라 폰트 크기 조정
    final titleFontSize = screenWidth * 0.1;
    final subTitleFontSize = screenWidth * 0.04;

    Future<void> userSaveAPi(String uid, String nickName, String email) async {
      final ApiUser apiUser = ApiUser();
      UserRequstDTO userDTO = UserRequstDTO(uid: uid, nickname: nickName, email: email);
      await apiUser.saveUser(userDTO);
    }

    return GestureDetector(
      onTap: () {
        // 키보드 감추기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(

          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.2, 0, 0), // 위쪽 패딩을 늘림
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: titleFontSize - 5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Circular',
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.01, screenWidth * 0.08, 0),
                      child: Text(
                        '로그인이 필요한 서비스입니다.',
                        style: TextStyle(
                          fontSize: subTitleFontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                    Container(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.02, screenWidth * 0.1, 0),
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
                                fontWeight: FontWeight.w700,
                              ),
                              unSelectedTextStyle: const TextStyle(
                                color: Colors.black87,
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
                                  }
                                  selectedIndex = index;
                                  updateBackgroundColors();
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
                        ),
                    Container(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.02, screenWidth * 0.1, 0),
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
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.12, screenHeight * 0.01, screenWidth * 0.04, 0),
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

                                      String nickname = snapshot.docs[0]
                                          .get("nickName");
                                      String uid = snapshot.docs[0].get("uid");

                                      storage.write(
                                        key: "nickName",
                                        value: nickname,
                                      );
                                      storage.write(
                                        key: "uid",
                                        value: uid,
                                      );
                                      storage.write(
                                        key: "gender",
                                        value: snapshot.docs[0].get('gender'),
                                      );
                                      storage.write(
                                        key: "email",
                                        value: email,
                                      );
                                      storage.write(
                                        key: "userName",
                                        value: snapshot.docs[0].get('userName'),
                                      );
                                      ///유저 정보저장 ------------ Topic 발급 - logout or 알림 Off 시 해제
                                      // Todo: 이미 저장한 uid가 있으면 저장 안하는 로직 추가하기 - 상훈 0919
                                      // Todo: 광고성 알림 Topic on/off 기능 추가하기 - 상훈 0919
                                      // Todo: 별거 아닌데 여기 누가 작업한데서 빨리 비켜줘야되서 냅둠
                                      // 유저 정보 서저에 저장
                                      userSaveAPi(uid, nickname, email);

                                      // 토픽 저장 전 - IOS APNS 권한 요청
                                      await FirebaseMessaging.instance.requestPermission(
                                        alert: true,
                                        announcement: false,
                                        badge: true,
                                        carPlay: false,
                                        criticalAlert: false,
                                        provisional: false,
                                        sound: true,
                                      );

                                      // 광고성 마케팅 토픽 저장
                                      if (Prefs.isAdPushOnRx.get() == true) {
                                        await FirebaseMessaging.instance.subscribeToTopic("AdNotification");
                                      } else {
                                        print('APNS token is not available');
                                      }

                                      // 학교 공지사항 토픽 저장
                                      if (Prefs.isSchoolPushOnRx.get() == true) {
                                        await FirebaseMessaging.instance.subscribeToTopic("SchoolNotification");
                                      } else {
                                        print('APNS token is not available');
                                      }
                                      ///---------- ---------- ------------ ---------------


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
                                  colors: [Color(0xff6CC0FF), Colors.black],
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
                    Spacer(), // 화면 아래에 여백을 추가
                    Container(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.09, 0, screenWidth * 0.09, screenHeight * 0.04),
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
                                fontSize: subTitleFontSize,
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