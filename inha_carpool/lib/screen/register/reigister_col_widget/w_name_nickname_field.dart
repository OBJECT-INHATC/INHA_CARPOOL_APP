import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';

import '../../../service/sv_auth.dart';

/// 닉네임과 이름 위젯
class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final double width;
  final String fieldType;
  final Icon icon;
  final Function(bool)? onNicknameChecked; // 닉네임 중복 확인

  const CustomInputField({
    super.key,
    required this.controller,
    required this.width,
    required this.fieldType,
    required this.icon,
    this.onNicknameChecked, // 선택적 매개변수로 변경
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool nickNameCheck = false;
  String inputText = "";


  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    return Container(
      padding: EdgeInsets.fromLTRB(40, width * 0.027, 40, width * 0.027),
      child: Container(
        // 이름 입력 필드
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!, // 연한 회색 테두리
          ),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100], // 연한 회색 배경색
        ),
        child: Stack(
          children: [
            TextFormField(
              controller: widget.controller,
              inputFormatters: [
                FilteringTextInputFormatter(
                  RegExp(r"[a-zA-Z0-9ㄱ-ㅎ가-힣ㄲ-ㅣㆍᆢ]"),
                  allow: true,
                )
              ],
              decoration: InputDecoration(
                /// 닉네임일 경우 중복 확인 버튼이 생김
                suffix: widget.fieldType == "닉네임"
                    ? null
                    : Text(
                  "${widget.controller.text.length}/5",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: widget.width * 0.033,
                  ),
                ).pOnly(right: widget.width * 0.03),
                counterText: "",
                hintText: widget.fieldType,
                border: InputBorder.none,
                prefixIcon: Icon(
                  widget.icon.icon,
                  color: Colors.grey,
                ),
              ),
              maxLength: (widget.fieldType == "닉네임") ? 7 : 5,
              onChanged: (text) {
                (widget.fieldType == "닉네임") ?  widget.onNicknameChecked!(false) : null;

                print("fdf");
                setState(() {
                  nickNameCheck = false;
                  inputText = widget.controller.text;
                });
              },
              /*   validator: (val) {
                if (val!.isNotEmpty) {
                  return null;
                } else {
                  return "이름이 비어있습니다.";
                }
              }*/
            ),
            (widget.fieldType == "닉네임")
                ? Positioned(
              right: 5, // 버튼을 오른쪽에 배치
              child: ElevatedButton(
                onPressed: () async {
                  String sampleText = await readTextFromFile();
                  // 닉네임은 2글자에서 7글자 사이여야 함
                  if (!mounted) return;
                  if (inputText.length < 2 ||
                      inputText.length > 7) {
                    print(inputText.length);
                    context.showSnackbarText(
                        context, "닉네임은 2글자에서 7글자 사이여야 합니다.",
                        bgColor: Colors.red);
                    return;
                  }

                  if (containsProfanity(widget.controller.text,
                      splitStringBySpace(sampleText))) {
                    if (!mounted) return;

                    context.showSnackbarText(context, "금지어가 포함되어 있습니다.",
                        bgColor: Colors.red);
                  } else {
                    nicknameAvailability();
                  }
                  // 중복확인 로직 추가해주세요구르트
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: nickNameCheck
                      ? context.appColors.logoColor
                      : Colors.red,
                  // 글자 색상
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(10), // 여기에서 모양을 조절합니다.
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            )
                : Container(),

          ],
        ),
      ),
    );
  }

  /// 중복 확인
  Future<void> nicknameAvailability() async {
    // 입력한 닉네임을 가져옴
    String newNickname = inputText;

    bool result = await AuthService().checkNicknameAvailability(newNickname);

    // 중복 여부에 따라 알림 메시지 표시
    if (result) {
      widget.onNicknameChecked!(true); // 부모 위젯으로 true 전달
      nickNameCheck = true;
      context.showSnackbarText(context, '사용 가능한 닉네임입니다.',
          bgColor: Colors.green);
    } else {
      // 부모 위젯으로 true 전달
      context.showSnackbarText(context, '이미 사용 중인 닉네임입니다.',
          bgColor: Colors.red);
    }
  }

  /// 비속어 필터
  Future<String> readTextFromFile() async {
    String path = 'assets/fwordList.txt';
    try {
      String content = await rootBundle.loadString(path);
      return content;
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

  /// 비속어 필터
  bool containsProfanity(String nickname, List<String> profanityList) {
    for (String profanity in profanityList) {
      if (nickname.toLowerCase().contains(profanity.toLowerCase())) {
        return true; // 비속어가 포함된 경우
      }
    }
    return false; // 비속어가 없는 경우
  }

  List<String> splitStringBySpace(String text) {
    List<String> words = text.split('\n'); // 줄바꿈을 기준으로 문자열을 분할
    return words;
  }
}
