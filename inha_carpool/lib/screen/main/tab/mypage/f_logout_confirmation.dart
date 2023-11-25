import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:inha_Carpool/service/sv_auth.dart';
import '../../../login/s_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inha_Carpool/common/common.dart';

/// 로그아웃 확인 다이얼로그
class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmationDialog({super.key, required this.onConfirm});

  Future<String?> getEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.email;
      } else {
        return null; // 유저가 로그인하지 않았을 때
      }
    } catch (e) {
      print("Error fetching email: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent, // 틴트 빼기
      backgroundColor: Colors.white, // 다이얼로그 배경색
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 1),

            const Text('로그아웃', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            // Title
            const SizedBox(height: 22),
            FutureBuilder<String?>(
              future: getEmail(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  String email = snapshot.data ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 6),
            const Text('위 계정에서 로그아웃하시겠습니까?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('아니오'),
        ),
        TextButton(
          onPressed: () async{
            await FirebaseMessaging.instance.deleteToken();
            AuthService().signOut().then(
                  (value) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
            );
            onConfirm();
          },
          child: const Text('예'),
        ),
      ],
    );
  }
}