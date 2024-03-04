import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

class PasswordInputField extends StatefulWidget {
  final double width;
  final TextEditingController passController;
  final TextEditingController passCheckController;
  final Function(bool) onMatchChanged;

  const PasswordInputField({
    Key? key,
    required this.width,
    required this.passController,
    required this.passCheckController,
    required this.onMatchChanged,
  }) : super(key: key);

  @override
  PasswordInputFieldState createState() => PasswordInputFieldState();
}

class PasswordInputFieldState extends State<PasswordInputField> {
  late String password = '';
  late String checkPassword = '';
  late bool isPasswordMatch;

  @override
  void initState() {
    super.initState();
    isPasswordMatch = false;
  }


  void _checkPasswordMatch() {
    final bool isMatch = widget.passController.text == widget.passCheckController.text &&
        widget.passController.text.length >= 6;
    widget.onMatchChanged(isMatch);
    setState(() {
      isPasswordMatch = isMatch;
    });
  }


  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(40, width * 0.027, 40, width * 0.027),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100],
            ),
            child: TextFormField(
              obscureText: true,
              maxLength: 16,
              decoration: InputDecoration(
                counterText: '',
                suffix: Text(
                  '${widget.passController.text.length}/${16}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ).pOnly(right: widget.width * 0.03),
                hintText: '비밀번호',
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
              ),
              onChanged: (text) {
                setState(() {
                  widget.passController.text = text;
                });
                _checkPasswordMatch();
              },
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(40, width * 0.027, 40, width * 0.027),
          child: Container(
            // 비밀번호 확인 입력 필드
            height: 50, // 높이 변수 적용
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!, // 연한 회색 테두리
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100], // 연한 회색 배경색
            ),
            child: TextFormField(
              maxLength: 16,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호 확인',
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
                counterText: "",
                suffix: Text(
                  "${widget.passCheckController.text.length}/16",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ).pOnly(right: width * 0.03),
              ),
              onChanged: (text) {
                setState(() {
                  widget.passCheckController.text = text;
                });
                _checkPasswordMatch();
              },
            ),
          ),
        ),

        /// 이름 입력 필드
        Padding(
          padding: EdgeInsets.fromLTRB(40, width * 0.023, 40, width * 0.023),
          child: Visibility(
            visible: widget.passController.text.isNotEmpty ||
                widget.passCheckController.text.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
              child: Center(
                child: (widget.passController.text ==
                            widget.passCheckController.text &&
                        widget.passController.text.length >= 6)
                    ? Text(
                        '비밀번호가 일치합니다!',
                        style: TextStyle(
                            color: Colors.green, fontSize: width * 0.037),
                      )
                    : (widget.passController.text.length < 6)
                        ? Text(
                            '비밀번호의 길이는 6~16글자여야 합니다.',
                            style: TextStyle(
                                color: Colors.red, fontSize: width * 0.037),
                          )
                        : Text(
                            '비밀번호가 일치하지 않습니다.',
                            style: TextStyle(
                                color: Colors.red, fontSize: width * 0.037),
                          ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
