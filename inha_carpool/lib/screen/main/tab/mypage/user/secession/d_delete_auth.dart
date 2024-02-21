import 'package:flutter/material.dart';

class DeleteAuthDialog extends StatelessWidget {
  const DeleteAuthDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('정말 탈퇴하시겠어요?'),
      content: const Text('탈퇴하면 모든 정보가 삭제됩니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () { Navigator.pop(context, true); },
          child: const Text('탈퇴하기'),
        ),
      ],
    );
  }
}
