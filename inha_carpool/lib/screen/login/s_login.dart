import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/dto/UserDTO.dart';
import 'package:inha_Carpool/screen/main/tab/carpool/s_chatroom.dart';
import 'package:inha_Carpool/screen/register/s_agreement.dart';
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
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

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
    if ((message.data['id'] == 'status' || message.data['id'] == 'chat') &&
        nickName != null) {
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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MainScreen()));
      await setupInteractedMessage();
    } else {
      print("로그인 안됨 + 스플래시 제거");
      FlutterNativeSplash.remove();
    }
  }

  // 버튼 활성화 여부
  bool loginButtonEnabled = true;

  // 이메일
  String email = "";

  // 비밀번호
  String password = "";

  // 학교 도메인 기본값
  String academy = "@itc.ac.kr";

  var selectedIndex = 0;

  List<Color> selectedBackgroundColors = [
    const Color.fromARGB(255, 70, 100, 192)
  ];
  List<Color> unSelectedBackgroundColors = [Colors.black54, Colors.black];

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
      UserRequstDTO userDTO =
          UserRequstDTO(uid: uid, nickname: nickName, email: email);
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.2, 0, 0),
                      // 위쪽 패딩을 늘림
                      child: Image.asset(
                        'assets/image/splash/banner.png',
                        width: 200,
                        height: 100,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08),
                    Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.1,
                          screenHeight * 0.007, screenWidth * 0.1, 0),
                      // 학교 선택 토글 버튼
                      child: FlutterToggleTab(
                        width: 30,
                        borderRadius: 40,
                        height: 30,
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
                    // 학번 입력 필드
                    Container(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.1,
                          screenHeight * 0.02, screenWidth * 0.1, 0),
                      child: Container(
                        // height: inputFieldHeight, // 높이 변수 적용
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!, // 연한 회색 테두리
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200], // 연한 회색 배경색
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            labelText: null,
                            hintText: '학번',
                            hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                            prefixIcon: Icon(Icons.school, color: Colors.grey),
                          ),
                          onChanged: (text) {
                            email = text + academy;
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
                    ),
                    // 비밀번호 입력 필드
                    Container(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.1,
                          screenHeight * 0.01, screenWidth * 0.1, 0),
                      child: Container(
                        //height: inputFieldHeight,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!, // 연한 회색 테두리
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200], // 연한 회색 배경색
                        ),
                        child: TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            labelText: null,
                            hintText: '비밀번호',
                            hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                          ),
                          style: TextStyle(
                            fontSize: 15,
                          ),
                          onChanged: (text) {
                            password = text;
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.1,
                          screenHeight * 0.02, screenWidth * 0.1, 0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Color.fromARGB(255, 50, 113, 190),
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0), //버튼 위아래 패딩 크기 늘리기
                        ),
                        onPressed: () async {
                          if (loginButtonEnabled) {
                            // 로그인 버튼이 활성화 되어 있는지 확인
                            loginButtonEnabled = false;

                            // 로그인 버튼 기능 추가
                            AuthService()
                                .loginWithUserNameandPassword(email, password)
                                .then((value) async {
                              if (value == true) {
                                QuerySnapshot snapshot =
                                    await FireStoreService()
                                        .gettingUserData(email);

                                getMyDeviceToken();

                                String nickname =
                                    snapshot.docs[0].get("nickName");
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
                                // Todo: 별거 아닌데 여기 누가 작업한대서 빨리 비켜줘야돼서 냅둠
                                // 유저 정보 서저에 저장
                                userSaveAPi(uid, nickname, email);

                                // 토픽 저장 전 - IOS APNS 권한 요청
                                await FirebaseMessaging.instance
                                    .requestPermission(
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
                                  await FirebaseMessaging.instance
                                      .subscribeToTopic("AdNotification");
                                } else {
                                  print('APNS token is not available');
                                }

                                // 학교 공지사항 토픽 저장
                                if (Prefs.isSchoolPushOnRx.get() == true) {
                                  await FirebaseMessaging.instance
                                      .subscribeToTopic("SchoolNotification");
                                } else {
                                  print('APNS token is not available');
                                }

                                ///---------- ---------- ------------ ---------------

                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(),
                                    ),
                                  );
                                }
                              } else {
                                context.showErrorSnackbar(value);
                              }
                            });

                            // 로그인 버튼 활성화
                            setState(() {
                              loginButtonEnabled = true;
                            });
                          }
                        },
                        child: const Center(
                          child: Text(
                            '로그인',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.1,
                          screenHeight * 0.02, screenWidth * 0.1, 0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.black,
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                        ),
                        // onPressed: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const RegisterPage(),
                        //     ),
                        //   );
                        // },
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              // secondaryAnimation: 화면 전환시 사용되는 보조 애니메이션 효과
                              // child: 화면이 전환되는 동안 표시할 위젯 의미함
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const Agreement(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0,
                                    0.0); //0ffset에서 x값 1은 오른쪽 끝, y값 1은 아래쪽 끝
                                const end = Offset.zero; //애니메이션이 부드럽게 동작하도록 명령
                                const curve =
                                    Curves.easeInOut; //애니메이션의 시작과 끝 담당
                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                return SlideTransition(
                                    position: offsetAnimation, child: child);
                              },
                            ),
                          );
                        },
                        child: const Center(
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 비밀번호찾기
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  // secondaryAnimation: 화면 전환시 사용되는 보조 애니메이션 효과
                                  // child: 화면이 전환되는 동안 표시할 위젯 의미함
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      FindRegisterPage(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0,
                                        0.0); //0ffset에서 x값 1은 오른쪽 끝, y값 1은 아래쪽 끝
                                    const end =
                                        Offset.zero; //애니메이션이 부드럽게 동작하도록 명령
                                    const curve =
                                        Curves.easeInOut; //애니메이션의 시작과 끝 담당
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);
                                    return SlideTransition(
                                        position: offsetAnimation,
                                        child: child);
                                  },
                                ),
                              );
                            },
                            child: Text(
                              '비밀번호찾기',
                              style: TextStyle(
                                color: Colors.indigo,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF1976D2),
                              ),
                            ),
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
