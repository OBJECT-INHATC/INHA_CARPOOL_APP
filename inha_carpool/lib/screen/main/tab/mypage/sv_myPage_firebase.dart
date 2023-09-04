import 'package:firebase_auth/firebase_auth.dart';

class fireMy{
  ///비밀번호 변경
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future nickNameUpdate({ required String oldNickName, required String newNickName}) async {
    // 현재 로그인된 유저 가져오기
    User? user =FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Current user: ${user.email}');
      try {
        await user.updatePassword(newNickName);

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


  /// 현재 비밀번호 확인
  Future <String> validatePassword(String password) async {
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

      return 'Failed  :${e.toString()}';
    }
  }

  Future<bool> validateCredentials(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await user!.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

}