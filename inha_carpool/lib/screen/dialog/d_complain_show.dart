import 'package:flutter/material.dart';

class ComplainShow extends StatelessWidget {
  final String cautionText; // 주의사항 텍스트

  const ComplainShow({Key? key, required this.cautionText}) : super(key: key);

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
        child: Column(
          children: [
            const SizedBox(
              height: 35,
              child: Text(
                '주의사항',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const Divider(
              height: 1.5,
              color: Colors.grey,
            ),
            const SizedBox(height: 25),
            Text(
              cautionText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.7),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          padding: const  EdgeInsets.only(right: 10),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
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
