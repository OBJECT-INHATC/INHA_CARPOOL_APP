import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 본인인증 완료 페이지

class VerifiedRegisterPage extends StatefulWidget {
  const VerifiedRegisterPage({super.key});

  @override
  State<VerifiedRegisterPage> createState() => _VerifiedRegisterPageState();
}

class _VerifiedRegisterPageState extends State<VerifiedRegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String verificationText = "본인인증 대기중...";

  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
        body: FutureBuilder(
          future: checkUserStatus(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // loading spinner
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      verificationText,
                      style: (verificationText == "본인인증 대기중...")
                          ? const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)
                          : const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          (verificationText == "본인인증 대기중...")
                              ? const Text(
                                  "학교 이메일로 가입 인증 메일이 전송되었습니다. \n 이메일에 접속하여 인증을 진행해 주세요!",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                )
                              : const Text(
                                  "본인인증이 완료되었습니다! 확인을 눌러 로그인을 진행하세요!",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                        ]),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: context.width(0.9),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                              const Text("1단계"),
                              const Text("이메일에서 인증 요청 메시지 확인"),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_downward_rounded,
                            color: Colors.grey,
                          ),
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.grey,
                                ),
                              ),
                              const Text("2단계"),
                              const Text("링크를 눌러 인증하기"),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_downward_rounded,
                            color: Colors.grey,
                          ),
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Icon(
                                  Icons.phone_android_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                              const Text("3단계"),
                              const Text("앱으로 돌아와서 인증 완료 버튼 누르기"),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        surfaceTintColor: Colors.transparent,
                        minimumSize: Size(context.width(1), 50),
                        backgroundColor: (verificationText=="본인인증 대기중...")?Colors.grey[300]:Colors.blue[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0),
                        ),
                      ),
                      child: const Text('인증 완료',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (verificationText == "본인인증 대기중...") {
                          await checkUserStatus();
                          setState(() {});
                        } else {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                    ),

                  ],
                ),
              );
            } else {
              return const Text('잘못된 접근입니다..!');
            }
          },
        ),
      ),
    );
  }

  Future<void> checkUserStatus() async {
    user = _auth.currentUser;
    if (user != null) {
      await user!.reload();
      if (user!.emailVerified) {
        verificationText = "본인 인증 완료!";
      }
    }
  }
}
