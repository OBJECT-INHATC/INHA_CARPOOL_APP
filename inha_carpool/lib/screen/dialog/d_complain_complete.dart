import 'package:flutter/material.dart';

class ComplainComplete extends StatefulWidget {
  final bool isReport;

  const ComplainComplete({required this.isReport, Key? key});

  @override
  State<ComplainComplete> createState() => _ComplainCompleteState();
}

class _ComplainCompleteState extends State<ComplainComplete> {
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
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: widget.isReport
                  ? const Text(
                      '접수완료',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : const Text(
                      '신고완료',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
            ),
            const Divider(
              height: 1.5,
              color: Colors.grey,
            ),
            const SizedBox(height: 15),
            widget.isReport
                ? const Text('접수가 정상적으로 완료되었습니다.\n소중한 의견 감사합니다!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.7))
                : const Text(
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
              backgroundColor: widget.isReport
                  ? MaterialStateProperty.all(Colors.lightBlueAccent)
                  : MaterialStateProperty.all(Colors.redAccent),
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
