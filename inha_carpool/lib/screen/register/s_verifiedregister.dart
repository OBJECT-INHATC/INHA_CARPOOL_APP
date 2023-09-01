import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifiedRegisterPage extends StatefulWidget {
  const VerifiedRegisterPage({super.key});

  @override
  State<VerifiedRegisterPage> createState() => _VerifiedRegisterPageState();
}

class _VerifiedRegisterPageState extends State<VerifiedRegisterPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String verificationText = "본인인증 대기중...";

  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    user = _auth.currentUser;
    if (user != null) {
      await user!.reload();
      if (user!.emailVerified) {
        setState(() { // This will cause the widget to rebuild with the new text.
          verificationText = "본인 인증 완료!";
        });
      }
    }
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
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(verificationText, style: (verificationText=="본인인증 대기중...")?TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.red):TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.green),),
              const SizedBox(
                height: 15,
              ),
              (verificationText == "본인인증 대기중...")?Text("본인인증이 완료되면 카풀이 가능합니다.\n 학교 이메일에서 가입 인증을 해주세요!", style: TextStyle(fontSize: 14,),):
              Text("본인인증이 완료되었습니다!\n 확인을 눌러 로그인을 진행하세요!", style: TextStyle(fontSize: 14,),),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90.0),
                    ),
                  ),
                  child: const Text('확인',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  onPressed: (verificationText == "본인인증 대기중...")?(){
                    checkUserStatus();
                  }:(){
                    Navigator.pop(context);
                    Navigator.pop(context);

                  }),
            ],
          ),
      ),
      ),);
  }
}
