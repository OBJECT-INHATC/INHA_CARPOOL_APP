import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
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

      if (user != null && user.emailVerified) {
        return true;
      } else if (user != null && !user.emailVerified) {
        return "이메일 인증이 완료되지 않은 사용자 입니다.";
      }
    } on FirebaseAuthException catch (e) {
      return "이메일 또는 비밀번호가 일치하지 않습니다.";
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
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future passwordUpdate({ required String oldPassword, required String newPassword}) async {
    // 현재 로그인된 유저 가져오기
    User? user =FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Current user: ${user.email}');
        try {
          await user.updatePassword(newPassword);

          return 'Success';
        } catch (e) {
          print(e);
          if (e is FirebaseAuthException && e.code == 'user-mismatch') {
            print('The provided credentials do not match the currently logged in user.');
            return 'Failed - User Mismatch';
          }
          return 'Failed';
        }
      } else {
        print('User not found or wrong email');
        return 'Failed - User Not Found Or Wrong Email';
      }
    }



  Future<String> validatePassword(String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    AuthCredential credential = EmailAuthProvider.credential(email: user!.email!, password: password);

    try {
      // Reauthenticate
      await user.reauthenticateWithCredential(credential);
      return 'Valid'; //
    } catch (e) {
      print(e.toString());
      return 'Invalid'; // If an error occurs (which means the password is wrong), return 'Invalid'
    }
  }

  Future<String> deleteAccount(String email, String password) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      // Create a credential
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

      // Reauthenticate
      await user!.reauthenticateWithCredential(credential);

      // Delete the user
      await user.delete();


      return 'Success';
    } catch (e) {
      print(e.toString());

      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        return 'Requires recent login';
      }

      return 'Failed';
    }
  }





}