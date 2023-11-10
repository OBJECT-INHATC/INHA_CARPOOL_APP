import 'package:flutter/material.dart';

class ComplainComplete extends StatelessWidget {
  const ComplainComplete({Key? key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: 150,
        width: width - 20,
        child: const Column(
          children: [
            SizedBox(
              height: 40,
              child: Text(
                '신고완료',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Divider(
              height: 1.5,
              color: Colors.grey,
            ),
            SizedBox(height: 15),
            Text(
              '신고가 정상적으로 완료되었습니다.\n더 나은 서비스를 위해 노력하겠습니다.\n감사합니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.7),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          padding: const EdgeInsets.only(right: 10),
          child: ElevatedButton(

            style: ButtonStyle(

              backgroundColor: MaterialStateProperty.all(Colors.redAccent),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ),
      ],
    );
  }
}
