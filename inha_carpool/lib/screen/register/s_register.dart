import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/screen/register/reigister_col_widget/w_id_field.dart';
import 'package:inha_Carpool/screen/register/reigister_col_widget/w_name_nickname_field.dart';
import 'package:inha_Carpool/screen/register/reigister_col_widget/w_password_field.dart';
import 'package:inha_Carpool/screen/register/reigister_col_widget/w_professor_btn.dart';
import 'package:inha_Carpool/screen/register/reigister_col_widget/w_register_notice.dart';
import 'package:inha_Carpool/screen/register/verified/s_verifiedregister.dart';

import '../../service/sv_auth.dart';

class Resigister extends StatefulWidget {
  const Resigister({super.key});

  @override
  State<Resigister> createState() => _ResigisterState();
}

class _ResigisterState extends State<Resigister> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passCheckController = TextEditingController();

  // 로딩 여부
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _nickNameController.dispose();
    _passController.dispose();
    _passCheckController.dispose();
    super.dispose();
  }

  String isProfessorText = "교직원_회원가입";
  bool isProfessor = false;

  String gender = '';
  String groupName = '무관';

  String email = "";
  String academy = "@itc.ac.kr";

  bool isNickNameMatch = false;
  bool isPasswordMatch = false;

  //textController

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss the keyboard
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Height(width * 0.05),

                  /// 학생과 교직원 선택 버튼
                  Row(
                    children: [
                      const Spacer(),
                      ChangeProfessorButton(
                        isProfessorText: isProfessorText,
                        isProfessor: isProfessor,
                        onPressed: () {
                          setState(() {
                            isProfessor = !isProfessor;
                            if (isProfessor) {
                              isProfessorText = "학생 회원가입";
                              email = "";
                              _studentIdController.text = "";

                              print("email+acdemy: $email");
                            } else {
                              isProfessorText = "교수 회원가입";
                            }
                          });
                          print("isProfessor 체인지 : $isProfessor");
                        },
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: NickNameNotice(),
                  ),
                  Height(width * 0.075),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// 회원가입 안내

                      /// 학번 및 이메일 입력 필드
                      StudentIdInputField(
                        isProfessor: isProfessor,
                        // onChaned 는 빼도 될듯 추후 확인
                        onChanged: (text) {
                          setState(() {
                            email = text; // 예시로 "@itc.ac.kr"을 사용하도록 설정되어 있음
                          });
                          if (isProfessor) {
                            print(
                                "$isProfessor 일 때 studentInput email: $email");
                          } else {
                            print(
                                "$isProfessor 일 때 studentInput email: $email$academy");
                          }
                        },
                        academyChanged: (value) {
                          setState(() {
                            academy = value;
                          });
                          print(
                              "$isProfessor 일 때 academyChanged email: $email$academy");
                        },
                        width: width,
                        controller: _studentIdController,
                      ),

                      /// 이름 입력 필드
                      CustomInputField(
                        controller: _nameController,
                        // 상수로 정의된 최대 길이 사용
                        width: width,
                        fieldType: '이름',
                        icon: const Icon(Icons.person),
                      ),

                      /// 닉네임 확인 변수 리턴해주기
                      CustomInputField(
                        controller: _nickNameController,
                        width: width,
                        fieldType: '닉네임',
                        icon: const Icon(Icons.perm_identity_rounded),
                        onNicknameChecked: (isNicknameAvailable) {
                          print(
                              "isNicknameAvailable 클릭 : $isNicknameAvailable");
                          // 닉네임 확인 결과에 따른 동작 구현
                          setState(() {
                            isNickNameMatch = isNicknameAvailable;
                          });
                        },
                      ),

                      /// 패스워드와 패스워드 확인
                      PasswordInputField(
                        width: MediaQuery.of(context).size.width,
                        passController: _passController,
                        passCheckController: _passCheckController,
                        onMatchChanged: (isMatch) {
                          setState(() {
                            isPasswordMatch = isMatch;
                          });
                        },
                      ),

                      Row(
                        children: [
                          Width(width * 0.13),
                          Expanded(
                            child: RadioListTile(
                              activeColor: Colors.blueAccent,
                              title: const Text("남성"),
                              value: "남성",
                              groupValue: groupName,
                              onChanged: (selectedGender) {
                                setState(() {
                                  groupName = selectedGender!;
                                  gender = selectedGender.toString();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              activeColor: Colors.pink,
                              title: const Text("여성"),
                              value: "여성",
                              groupValue: groupName,
                              onChanged: (selectedGender) {
                                setState(() {
                                  groupName = selectedGender!;
                                  gender = selectedGender.toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      Height(width * 0.05),

                      // 가운대 정렬 파란색 배경 흰색 텍스트 가입하기 버튼
                      TextButton(
                        onPressed: () {
                          (isProfessor)
                              ? print("이메일: ${_studentIdController.text}")
                              : print(
                                  "학번: ${_studentIdController.text + academy}");
                          print("이름: ${_nameController.text}");
                          print("닉네임: ${_nickNameController.text}");
                          print("닉네임 체크: $isNickNameMatch");
                          print("비번 유무: $isPasswordMatch");
                          print("성별: $gender");
                          print("학생/교수 구분 (flase면 학생) : $isProfessor");

                          if (isProfessor) {
                            if (!checkInhaMail(email)) {
                              context.showSnackbarText(context, "학교메일로 가입해주세요.",
                                  bgColor: Colors.red);
                              return;
                            }
                          }

                          if (_studentIdController.text.isEmpty ||
                              _studentIdController.text.length <= 5) {
                            context.showSnackbarText(context, "올바른 학번을 입력해주세요",
                                bgColor: Colors.red);
                            return;
                          } else if (_nameController.text.isEmpty ||
                              _nameController.text.length < 2) {
                            context.showSnackbarText(context, "올바른 이름을 입력해주세요",
                                bgColor: Colors.red);
                            return;
                          } else if (!isNickNameMatch) {
                            context.showSnackbarText(context, "닉네임을 중복 확인해주세요",
                                bgColor: Colors.red);
                            return;
                          } else if (!isPasswordMatch) {
                            context.showSnackbarText(context, "비밀번호를 확인해주세요",
                                bgColor: Colors.red);
                            return;
                          } else if (gender.isEmpty) {
                            context.showSnackbarText(context, "성별을 선택해주세요",
                                bgColor: Colors.red);
                            return;
                          } else {
                            setState(() {
                              isLoading = true; // 로그인 로딩 시작
                            });
                            AuthService()
                                .registerUserWithEmailandPassword(
                              userName: _nameController.text,
                              nickName: _nickNameController.text,
                              gender: gender,
                              email: (isProfessor)
                                  ? _studentIdController.text
                                  : _studentIdController.text + academy,
                              password: _passController.text,
                              fcmToken: 'dummy',
                            )
                                .then(
                              (value) async {
                                print("value ================> : $value");
                                if (value == true) {
                                  context.showSnackbarText(
                                    context,
                                    "가입 성공! 학교 메일 인증을 완료해 주세요",
                                  );

                                  await FirebaseAuth.instance.currentUser!
                                      .sendEmailVerification();
                                  if (!mounted) return;
                                  Nav.push(const VerifiedRegisterPage());

                                  setState(() {
                                    isLoading = false; // 로그인 로딩 끝
                                  });
                                } else {
                                  context.showSnackbarText(
                                    context,
                                    "가입 실패! 이미 있는 학번(메일)입니다. 메일 인증을 완료해 주세요.",
                                    bgColor: Colors.red,
                                  );

                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                            );
                          } //else
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: context.appColors.logoColor,
                          minimumSize: Size(width * 0.8, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "가입하기",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      /*                TextButton(onPressed: () {
                        (isProfessor)
                            ?   print("학번: ${_studentIdController.text}")
                            :   print("학번: ${_studentIdController.text + academy}");
                        print("이름: ${_nameController.text}");
                        print("닉네임: ${_nickNameController.text}");
                        print("닉네임 체크: $isNickNameMatch");
                        print("비번 유무: $isPasswordMatch");
                        print("성별: $gender");

                      }, child: Text('입력 값 테스트 버튼'),),*/
                    ],
                  ),
                ],
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
        ),
      ),
    );
  }

  bool checkInhaMail(String userMail) {
    RegExp emailRegex =
        RegExp(r'^[\w-]+(\.[\w-]+)*@inhatc\.ac\.kr|inha\.ac\.kr$');
    return emailRegex.hasMatch(userMail);
  }
}
