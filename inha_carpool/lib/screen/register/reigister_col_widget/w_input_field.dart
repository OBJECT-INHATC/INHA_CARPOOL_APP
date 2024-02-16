import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inha_Carpool/common/common.dart';

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
            suffix: Text(
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
}
