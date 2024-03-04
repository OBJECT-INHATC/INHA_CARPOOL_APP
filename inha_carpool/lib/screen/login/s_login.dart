import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/common/util/location_handler.dart';
import 'package:inha_Carpool/dto/user_dtd.dart';
import 'package:inha_Carpool/provider/stateProvider/yellow_provider.dart';
import 'package:inha_Carpool/screen/register/agreement/s_agreement.dart';
import 'package:inha_Carpool/service/api/Api_repot.dart';
import 'package:inha_Carpool/service/api/Api_user.dart';
import 'package:inha_Carpool/service/sv_auth.dart';

import '../../common/data/preference/prefs.dart';
import '../../common/models/m_member.dart';
import '../../provider/doing_carpool/doing_carpool_provider.dart';
import '../../provider/stateProvider/latlng_provider.dart';
import '../../provider/stateProvider/auth_provider.dart';
import '../../provider/history/history_notifier.dart';
import '../../provider/stateProvider/jusogiban_api_provider.dart';
import '../../provider/stateProvider/notification_provider.dart';
import '../../service/sv_firestore.dart';
import '../main/s_main.dart';
import '../main/tab/carpool/chat/s_chatroom.dart';
import '../register/s_findrer_password.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {

  //이메일 temp
  String emailTemp = "";

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
    ref.read(isPushOnAlarm.notifier).state = true;

    // 닉네임 가져오기
    String? nickName = await storage.read(key: "nickName");

    if ((message.data['id'] == 'status' || message.data['id'] == 'chat') &&
        nickName != null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatroomPage(
            carId: message.data['groupId'],
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

      /// 상태관리에 로그인 정보 저장
      MemberModel memberModel = MemberModel(
        uid: await storage.read(key: 'uid'),
        nickName: await storage.read(key: 'nickName'),
        gender: await storage.read(key: 'gender'),
        email: await storage.read(key: 'email'),
        userName: await storage.read(key: 'userName'),
      );


      /// 로그인 정보 상태관리 초기화
      setAuthStateProvider(memberModel);

      /// 이용내역 상태관리 초기화
      setHistory(memberModel.uid!);

      /// 경고횟수 상태관리 초기화
      setYellowCardCount(memberModel.nickName!);

      ///자신 위치 상태관리 초기화
      setPositionState();

      /// 주소기반 키 상태관리 초기화
      setJusoKey();

      /// 참여중인 카풀 초기화
      setDoingCarPoolState();

      await setupInteractedMessage();

      if(mounted){
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MainScreen()));
      }

    } else {
      print("로그인 안됨 + 스플래시 제거");
      FlutterNativeSplash.remove();
    }
  }

  /// 참여중인 카풀 수 조회
  void setHistory(String uid) async {
    await ref.read(historyProvider.notifier).loadHistoryData();
  }


  /// 경고 횟수 초기화
  void setYellowCardCount(String nickName) async {
    final yellowCardCount = await ApiService().selectYellowCount(nickName);
    ref.read(yellowCountProvider.notifier).state = yellowCardCount;
  }

  /// 주소기반 키 상태관리 초기화
  void setJusoKey() async {
    final jusoKey = await FireStoreService().getJusoKey();
    ref.read(jusoKeyProvider.notifier).state = jusoKey;
  }

  /// 현재 위치 상태관리 초기화
  void setPositionState() async {
    LatLng position  = await LocationHandler().getCurrentLatLng(context) ?? const LatLng(37.450, 126.650);
    ref.read(positionProvider.notifier).state = position;
  }

  void setDoingCarPoolState() async {
    /// 참여중인 카풀 리스트와 그 중 가장 출발시간이 가장 빠른 카풀을 상태관리에 저장
    ref.read(doingProvider.notifier).getCarpool();
  }

  // 버튼 활성화 여부
  bool loginButtonEnabled = true;

  // 이메일
  String email = "";

  // 비밀번호
  String password = "";

  // 학교 도메인 기본값
  String academy = "@itc.ac.kr";

  bool isProfessor = false; // 학생과 교수님 구

  void toggleProfessorLogin() {
    setState(() {
      isProfessor = !isProfessor;
    });
  }

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

/*  // 장치의 FCM 토큰을 가져와 로컬에 저장하는 함수
  void getMyDeviceToken() async {
    String? token = await storage.read(key: 'token');

    // 토큰이 없는 경우에만 새로운 토큰을 생성합니다.
    if (token == null) {
      token = await FirebaseMessaging.instance.getToken();
      storage.write(key: 'token', value: token); // 생성된 토큰을 로컬에 저장합니다.
    }

  }*/

  @override
  void initState() {
    // 로그인 여부 확인
    checkLogin();
    // 현재는 개인 fcmToken을 사용하지 않음으로 주석처리
   // getMyDeviceToken();
    super.initState();
  }

  // 로그인 정보 객체에 담기 0207 이상훈
  void setAuthStateProvider(MemberModel memberModel) async {
    if (memberModel.uid == "" ||
        memberModel.nickName == "" ||
        memberModel.gender == "" ||
        memberModel.email == "" ||
        memberModel.userName == "") {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("로그인 정보가 없습니다."),
              content: const Text("다시 로그인 해주세요."),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                    },
                    child: const Text("확인")),
              ],
            );
          });
    } else {
      ref.read(authProvider.notifier).state = MemberModel(
        uid: memberModel.uid,
        nickName: memberModel.nickName,
        gender: memberModel.gender,
        email: memberModel.email,
        userName: memberModel.userName,
      );

      print("===========상태관리 저장 완료==================");
      print("상태관리 로그인 성별 :  ${ref.read(authProvider).gender}");
      print("상태관리 로그인 닉네임 :  ${ref.read(authProvider).nickName}");
      print("상태관리 로그인 이메일 :  ${ref.read(authProvider).email}");
      print("상태관리 로그인 UID :  ${ref.read(authProvider).uid}");
      print("상태관리 로그인 유저이름 :  ${ref.read(authProvider).userName}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이를 가져와서 화면 비율 계산함
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // 키보드 감추기
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, screenHeight * 0.2, 0, 0), // 위쪽 패딩을 늘림
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
                          child: isProfessor
                              ? '교직원'
                                  .text
                                  .bold
                                  .color(Colors.grey[500])
                                  .make()
                              : FlutterToggleTab(
                                  width: screenWidth * 0.077,
                                  borderRadius: 40,
                                  height: screenHeight * 0.047,
                                  selectedTextStyle:  TextStyle(
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.016,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  unSelectedTextStyle:  TextStyle(
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.0132,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  labels: const ["인하공전", "인하대"],
                                  selectedLabelIndex: (index) {
                                    setState(() {
                                      if (index == 0) {
                                        academy = "@itc.ac.kr"; // 인하공전생
                                        email = emailTemp + academy;
                                      } else {
                                        academy = "@inha.edu"; // 인하대생
                                        email = emailTemp + academy;
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
                        ),
                        /// 학번 입력 필드
                        Container(
                          padding: isProfessor
                              ? EdgeInsets.fromLTRB(screenWidth * 0.1,
                                  screenHeight * 0.005, screenWidth * 0.1, 0)
                              : EdgeInsets.fromLTRB(screenWidth * 0.1,
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
                              keyboardType: isProfessor
                                  ? TextInputType.emailAddress
                                  : TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                labelText: null,
                                hintText: isProfessor ? '학교 메일' : '학번',
                                hintStyle: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                                prefixIcon: isProfessor
                                    ? const Icon(Icons.email,
                                        color: Colors.grey)
                                    : const Icon(Icons.school,
                                        color: Colors.grey),
                              ),
                              onChanged: (text) {
                                isProfessor
                                    ? email = text
                                    : email = text + academy;
                                emailTemp = text;
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

                        /// 비밀번호 입력 필드
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
                              decoration: const InputDecoration(
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
                                prefixIcon:
                                    Icon(Icons.lock, color: Colors.grey),
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                              onChanged: (text) {
                                password = text;
                              },
                            ),
                          ),
                        ),


                        /// 로그인 버튼
                        Container(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.1,
                              screenHeight * 0.02, screenWidth * 0.1, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              surfaceTintColor: Colors.transparent,
                              elevation: 5,
                              backgroundColor:
                                  const Color.fromARGB(255, 50, 113, 190),
                              shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0), //버튼 위아래 패딩 크기 늘리기
                            ),
                            onPressed: () async {
                              setState(() {
                                isLoading = true; // 로그인 로딩 시작
                              });

                              if (loginButtonEnabled) {
                                // 로그인 버튼이 활성화 되어 있는지 확인
                                loginButtonEnabled = false;

                                // 로그인 버튼 기능 추가
                                await AuthService()
                                    .loginWithUserNameandPassword(
                                        email, password)
                                    .then((value) async {
                                  if (value == true) {
                                    QuerySnapshot snapshot =
                                        await FireStoreService()
                                            .gettingUserData(email);

                                    String nickname = snapshot.docs[0].get("nickName");
                                    String uid = snapshot.docs[0].get("uid");
                                    String userName = snapshot.docs[0].get('userName');
                                    String gender = snapshot.docs[0].get('gender');



                                    // 유저 정보 서저에 저장 --풀기 1101================
                                    UserRequstDTO userDTO = UserRequstDTO(
                                        uid: uid,
                                        nickname: nickname,
                                        email: email);
                                    bool isOpen =
                                        await ApiUser().saveUser(userDTO);

                                    if (isOpen) {
                                      print("스프링부트 서버 성공 #############");

                                      /// 로그인 성공
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
                                        value: gender,
                                      );
                                      storage.write(
                                        key: "email",
                                        value: email,
                                      );

                                      storage.write(
                                        key: "userName",
                                        value: userName,
                                      );

                                      String memberUser =
                                          "${uid}_${nickname}_${snapshot.docs[0].get('gender')}";
                                      print("------------memberUser: $memberUser-----------------");

                                      ///  0207 이상훈 로그인 정보 상태관리 초기화

                                      MemberModel memberModel = MemberModel(
                                        uid: uid,
                                        nickName: nickname,
                                        gender: gender,
                                        email: email,
                                        userName: userName,
                                      );

                                      setAuthStateProvider(memberModel);

                                      /// 0207 이상훈 이용내역 상태관리 초기화
                                      /// 로그인 정보 상태관리 초기화
                                      setAuthStateProvider(memberModel);

                                      /// 이용내역 상태관리 초기화
                                      setHistory(memberModel.uid!);


                                      /// 경고횟수 상태관리 초기화
                                      setYellowCardCount(memberModel.nickName!);

                                      ///자신 위치 상태관리 초기화
                                      setPositionState();

                                      /// 주소기반 키 상태관리 초기화
                                      setJusoKey();

                                      /// 참여중인 카풀 초기화
                                      setDoingCarPoolState();

                                      // Firestore에서 해당 사용자가 속한 모든 carId를 가져옵니다.
                                      FirebaseFirestore.instance
                                          .collection('carpool')
                                          .where('members',
                                              arrayContains: memberUser)
                                          .get()
                                          .then((QuerySnapshot querySnapshot) {
                                        for (var doc in querySnapshot.docs) {
                                          // 각 carId에 대해 푸시 알림을 구독합니다.
                                          String carId = doc.id;

                                          print("---------carId: $carId------------");

                                          FirebaseMessaging.instance
                                              .subscribeToTopic(carId);
                                          FirebaseMessaging.instance
                                              .subscribeToTopic(
                                                  "${carId}_info");
                                        }
                                      });

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

                                      try {
                                        await FirebaseMessaging.instance
                                            .subscribeToTopic(
                                                "AppNotification");

                                        if (Prefs.isSchoolPushOnRx.get() ==
                                            true) {
                                          // 학교 공지사항 토픽 저장
                                          await FirebaseMessaging.instance
                                              .subscribeToTopic(
                                                  "SchoolNotification");
                                        } else {
                                          print('APNS token is not available');
                                        }
                                      } catch (e) {
                                        print('APNS token is not available');
                                      }

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
                                      print("스프링부트 서버 실패 #############");

                                      /// 로그인 실패
                                      if (!mounted) return;
                                      context.showErrorSnackbar(
                                          "서버가 불안정합니다. 잠시 후 다시 시도해주세요.");
                                    }
                                  } else {
                                    context.showErrorSnackbar(value);
                                  }
                                });
                                // 로그인 버튼 활성화
                                setState(() {
                                  loginButtonEnabled = true;
                                  isLoading = false; // 로그인 로딩 종료
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

                        /// 회원가입 버튼
                        Container(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.1,
                              screenHeight * 0.02, screenWidth * 0.1, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              surfaceTintColor: Colors.transparent,
                              elevation: 5,
                              backgroundColor: Colors.black,
                              shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  // secondaryAnimation: 화면 전환시 사용되는 보조 애니메이션 효과
                                  // child: 화면이 전환되는 동안 표시할 위젯 의미함
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const Agreement(),
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

                        /// 비밀번호 찾기 | 학생/교직원 구분
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(bottom: screenHeight * 0.03),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const FindPasswordPage(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));
                                            var offsetAnimation =
                                                animation.drive(tween);
                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      '비밀번호 찾기',
                                      style: TextStyle(
                                        color: Colors.indigo,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFF1976D2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25, // 구분선의 높이 조정
                                    child: VerticalDivider(
                                      width: 1,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      toggleProfessorLogin();
                                    },
                                    child: isProfessor
                                        ? const Text(
                                            '학생이신가요?',
                                            style: TextStyle(
                                              color: Colors.indigo,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  Color(0xFF1976D2),
                                            ),
                                          )
                                        : const Text(
                                            '교직원이신가요?',
                                            style: TextStyle(
                                              color: Colors.indigo,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  Color(0xFF1976D2),
                                            ),
                                          ),
                                  ),
                                ],
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
        ),
        isLoading
            ? Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      '🚕'.text.size(20).white.make(),
                      const SizedBox(height: 13),
                      const SpinKitThreeBounce(
                        color: Colors.white,
                        size: 25.0,
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  // 이메일 업데이트 메서드 추가
  void updateEmail() {
    String id = "";
    // 텍스트 필드에 이미 값이 있는지 확인
    if (email.isNotEmpty && isProfessor == false) {
      // '@' 문자 앞부분만 가져옴 (학번 부분)
      id = email.split('@')[0];

      // 새로운 학교 도메인을 붙임
      email = id + academy;
    } else if (email.isNotEmpty && isProfessor == true) {
      // 교수님버전
      id = email;
      email = id;
    }
  }
}
