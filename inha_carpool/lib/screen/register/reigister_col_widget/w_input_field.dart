import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../service/sv_auth.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  final double width;
  final String fieldType;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.maxLength,
    required this.width,
    required this.fieldType,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {


  @override
  Widget build(BuildContext context) {

    print("widget.fieldType: ${widget.fieldType}");


    return Container(
      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
      child: Container(
        // 이름 입력 필드
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!, // 연한 회색 테두리
          ),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100], // 연한 회색 배경색
        ),
        child: TextFormField(
          controller: widget.controller,
          inputFormatters: [
            FilteringTextInputFormatter(
              RegExp(r"[a-zA-Z0-9ㄱ-ㅎ가-힣ㄲ-ㅣㆍᆢ]"),
              allow: true,
            )
          ],
          decoration: InputDecoration(
            suffix: widget.fieldType == "닉네임"
                ? ElevatedButton(
                    onPressed: () async {
                      String sampleText = await readTextFromFile();
                      // 닉네임은 2글자에서 7글자 사이여야 함
                      if (!mounted) return;
                      if (widget.controller.text.length < 2 ||
                          widget.controller.text.length > 7) {
                        showSnackbar(
                            context, Colors.red, "닉네임은 2글자에서 7글자 사이여야 합니다.");
                        return;
                      }

                      if (containsProfanity(widget.controller.text,
                          splitStringBySpace(sampleText))) {
                        if (!mounted) return;
                        showSnackbar(context, Colors.red, "금지어가 포함되어 있습니다.");
                      } else {
                        checkNicknameAvailability();
                      }
                      // 중복확인 로직 추가해주세요구르트
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: context.appColors.logoColor,
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
                  )
                : Text(
                    "${widget.controller.text.length}/${widget.maxLength}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: widget.width * 0.033,
                    ),
                  ).pOnly(right: widget.width * 0.03),
            labelText: null,
            counterText: "",
            hintText: widget.fieldType,
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.person,
              color: Colors.grey,
            ),
          ),
          maxLength: widget.maxLength,
          onChanged: (text) {
            setState(() {
              widget.controller.text = text;
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
      ),
    );
  }

  Future<bool> checkNicknameAvailability() async {
    // 입력한 닉네임을 가져옴
    String newNickname = widget.controller.text;

    bool result = await AuthService().checkNicknameAvailability(newNickname);

    // 중복 여부에 따라 알림 메시지 표시
    if (result) {
      showSnackbar(context, Colors.green, '사용 가능한 닉네임입니다.');
      return true;
    } else {
      showSnackbar(context, Colors.red, '이미 사용 중인 닉네임입니다.');
      return false;
    }
  }

  void showSnackbar(context, color, message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: "OK",
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  Future<String> readTextFromFile() async {
    String path = 'assets/fwordList.txt';
    try {
      String content = await rootBundle.loadString(path);
      return content;
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

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
