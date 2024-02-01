import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inha_Carpool/service/api/Api_user.dart';
import 'package:inha_Carpool/dto/UserDTO.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  String uid = "";
  String email = "";
  String nickname = "";

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return Center(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Container(
              child: Text("사용자 정보 저장"),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: TextField(
                onChanged: (text) => uid = text,
              ),
            ),
            Container(
              child: TextField(
                onChanged: (text) => email = text,
              ),
            ),
            Container(
              child: TextField(
                onChanged: (text) => nickname = text,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: ElevatedButton(
                child: Text("저장"),
                onPressed: () async {
                  // DTO 생성
                  UserRequstDTO userDTO =
                      UserRequstDTO(uid: uid, nickname: nickname, email: email);
                  bool check = await ApiUser().saveUser(userDTO);
                  if (check) {
                    Fluttertoast.showToast(msg: '성공!');
                  } else {
                    Fluttertoast.showToast(msg: '실패!');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
