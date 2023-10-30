import 'package:flutter/material.dart';

class ComplainShow extends StatelessWidget {
  const ComplainShow({Key? key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: 90,
        width: width - 20,
        child: const Column(
          children: [
            SizedBox(
              height: 35,
              child: Text(
                '주의사항',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Divider(
              height: 1.5,
              color: Colors.grey,
            ),
            SizedBox(height: 25),
            Text(
              '체크박스와 신고내용을 모두 입력 해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.7),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          padding: EdgeInsets.only(right: 10),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ),
      ],
    );
  }
}
