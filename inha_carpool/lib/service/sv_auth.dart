import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

/// Auth Service
/// Firebase Auth 인증 관련 메서드
/// 0824 한승완, 서은율 생성
class AuthService {

  /// Firebase Auth Instance
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();

  /// 로그인 메서드
  /// 0824 서은율, 한승완
  Future loginWithUserNameandPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password))
          .user!;

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// 회원 가입 메서드
  /// 0824 서은율 한승완
  Future registerUserWithEmailandPassword(
      String nickName, String email, String password, String fcmToken, String gender,) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password))
          .user!;

      print("유저 데이터 저장");

      if (user != null) {
        /// Fire Store 사용자 정보 저장
        await FireStoreService(uid: user.uid).savingUserData(nickName, email, "dummy", gender);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// 로그 아웃 메서드
  /// 0824 서은율, 한승완
  Future signOut() async {
    try {
      await storage.delete(key: 'email');
      await storage.delete(key: 'nickName');
      await storage.delete(key: 'gender');
      await firebaseAuth.signOut();
      print('로그아웃');
    } catch (e) {
      return null;
    }
  }

  /// 로그인 여부 확인
  /// 0824 서은율, 한승완
  Future<bool> checkUserAvailable() async{
    User? user = FirebaseAuth.instance.currentUser;

    if(user != null){
      return true;
    }else{
      return false;
    }

  }

}