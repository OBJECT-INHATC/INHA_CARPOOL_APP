import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import '../../../../../dialog/d_delete_auth.dart';

const kSecessionTitle = '회원 탈퇴';
const kSecessionWarning = '정말 탈퇴하시겠어요?';
const kSecessionInfo = '지금 탈퇴하시면 서비스를 이용할 수 없어요.\n탈퇴하시려면 이메일과 비밀번호를 입력해 주세요.';
const kDeleteButtonLabel = '탈퇴하기';

class SecessionPage extends ConsumerStatefulWidget {
  final String userEmail;
  final String userNickName;

  const SecessionPage({
    Key? key,
    required this.userEmail,
    required this.userNickName,
  }) : super(key: key);

  @override
  ConsumerState<SecessionPage> createState() => _SecessionPageState();
}

class _SecessionPageState extends ConsumerState<SecessionPage> {
  // 이메일
  String inputEmail = '';

  // 비밀번호
  String inputPassword = '';

  bool canSubmit = false;

  @override
  Widget build(BuildContext context) {
    final height = context.screenHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text(kSecessionTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Height(height * 0.04),

              /// 님네임
              _buildWarningRow(),
              Height(height * 0.02),
              const Text(kSecessionInfo,
                  style: TextStyle(fontSize: 14, color: Colors.red)),
              Height(height * 0.04),

              /// 이메일 필드
              _buildEmailField(),
              Height(height * 0.04),

              /// 패스워드 필드
              _buildPasswordField(),
              Height(height * 0.04),

              /// 탈퇴하기 버튼
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.red),
        Text(
          '${widget.userNickName}님.. $kSecessionWarning',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: '이메일',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        prefixIcon: const Icon(Icons.school, color: Colors.grey),
      ),
      onChanged: (text) {
        inputEmail = text;
        _updateSubmitButtonState();
      },
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: '비밀번호',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
      ),
      onChanged: (text) {
        inputPassword = text;
        _updateSubmitButtonState();
      },
    );
  }

  Widget _buildDeleteButton() {
    return TextButton(
      onPressed: canSubmit
          ? () async {
              /// 로그인한 계정과 이메일 체크
              if (inputEmail != widget.userEmail) {
                context.showSnackbarText(context, '이메일이 일치하지 않습니다.',
                    bgColor: Colors.red);
                return;
              }

              try {
                User? user = FirebaseAuth.instance.currentUser;
                AuthCredential credential = EmailAuthProvider.credential(
                    email: inputEmail, password: inputPassword);
                await user!.reauthenticateWithCredential(credential);

                // 탈퇴 확인 다이얼로그 표시
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) =>
                      DeleteAuthDialog(inputEmail, inputPassword),
                );

                if (confirmed ?? false) {
                  // print("탈퇴하기");
                }
              } catch (e) {
                // 에러 처리
                print(e.toString());

                context.showSnackbarText(context, "비밀번호가 일치하지 않습니다.",
                    bgColor: Colors.red);

              }
            }
          : null,
      style: TextButton.styleFrom(
        backgroundColor: Colors.blue,
        minimumSize: const Size(double.infinity, 50),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        maximumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        kDeleteButtonLabel,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _updateSubmitButtonState() {
    setState(() {
      canSubmit = inputEmail.isNotEmpty && inputPassword.isNotEmpty;
    });
  }

  /// 이메일과 비밀번호를 통해 로그인 사용자 재확인 함수
  /// ex) 비밀번호 변경, 회원탈퇴
  Future<bool> validateCredentials(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);
      await user!.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
