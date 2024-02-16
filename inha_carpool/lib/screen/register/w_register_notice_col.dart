import 'package:flutter/material.dart';

class NickNameNotice extends StatelessWidget {
  const NickNameNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "* 닉네임은 추후 변경이 불가하므로",
          style: TextStyle(color: Colors.red),
        ),
        Text(
          "  신중하게 입력해주세요. (특수문자 불가)",
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}
