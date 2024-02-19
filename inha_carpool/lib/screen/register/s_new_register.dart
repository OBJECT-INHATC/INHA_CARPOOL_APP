import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/screen/register/reigister_col_widget/w_id_field.dart';
import 'package:inha_Carpool/screen/register/reigister_col_widget/w_input_field.dart';
import 'package:inha_Carpool/screen/register/reigister_col_widget/w_professor_btn.dart';
import 'package:inha_Carpool/screen/register/reigister_col_widget/w_register_notice.dart';

class NewResigister extends StatefulWidget {
  const NewResigister({super.key});

  @override
  State<NewResigister> createState() => _NewResigisterState();
}

class _NewResigisterState extends State<NewResigister> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();

  String isProfessorText = "교직원_회원가입";
  bool isProfessor = false;

  String email = "";
  String academy = "itc.ac.kr";

  //textController

  @override
  Widget build(BuildContext context) {
    const int nameMaxLength = 5; //이름최대길이
    const int nicknameMaxLength = 7; //닉넴최대길이
    const int passwordMaxLength = 16;
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
      body: SingleChildScrollView(
        child: Column(
          children: [
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

            Column(
              children: [
                /// 회원가입 안내
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: NickNameNotice(),
                ),

                /// 학번 및 이메일 입력 필드
                StudentIdInputField(
                  isProfessor: isProfessor,
                  // onChaned 는 빼도 될듯 추후 확인
                  onChanged: (text) {
                    setState(() {
                      email = text; // 예시로 "@itc.ac.kr"을 사용하도록 설정되어 있음
                    });
                    if (isProfessor) {
                      print("$isProfessor 일 때 studentInput email: $email");
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
                  maxLength: nameMaxLength, // 상수로 정의된 최대 길이 사용
                  width: width,
                  fieldType: '이름',
                ),

                CustomInputField(
                  controller: _nickNameController,
                  maxLength: nameMaxLength, // 상수로 정의된 최대 길이 사용
                  width: width,
                  fieldType: '닉네임',
                ),














                ElevatedButton(
                  onPressed: () {
                    print("학번: ${_studentIdController.text}");
                    print("이름: ${_nameController.text+academy}");
                    print("닉네임: ${_nickNameController.text}");
                  },
                  child: const Text("값 체크"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
