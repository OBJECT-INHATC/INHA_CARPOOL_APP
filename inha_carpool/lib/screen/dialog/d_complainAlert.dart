import 'package:flutter/material.dart';

import 'd_complain_complete.dart';

class ComplainAlert extends StatefulWidget {
  const ComplainAlert({super.key, required this.index});

  final String index; // 이름 따라보내기

  @override
  State<ComplainAlert> createState() => _ComplainAlertState();
}

class _ComplainAlertState extends State<ComplainAlert> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _checkBoxItems = [
    {'value': false, 'label': '욕설'},
    {'value': false, 'label': '영리목적'},
    {'value': false, 'label': '개인정보노출'},
    {'value': false, 'label': '불법정보'},
    {'value': false, 'label': '선정성'},
    {'value': false, 'label': '채팅도배'},
    {'value': false, 'label': '지각'},
    {'value': false, 'label': '기타'},
  ];

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    double heightPercentage = 0.5; // 70% 화면 높이 사용
    double widthPercentage = 0.9; // 90% 화면 너비 사용

    return AlertDialog(
      insetPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Builder(
        builder: (context) {
          return SizedBox(
            height: height * heightPercentage,
            width: width * widthPercentage,
            child: Column(
              children: [
                SizedBox(
                  width: 180,
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey,
                      ),
                      Text(
                        widget.index.replaceFirst(' ', '').toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          children: _buildCheckBoxes(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    maxLines: 3, // 크기를 조절하기 위해 maxLines를 3으로 설정
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: '문의사항',
                      prefixIcon: Icon(Icons.edit, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) => ComplainComplete(),
                );
              },
              child: const Text('신고하기', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildCheckBoxes() {
    final int itemCount = _checkBoxItems.length;
    final int halfCount = (itemCount / 2).ceil();

    return List.generate(halfCount, (index) {
      final int rowIndex = index * 2;
      final bool isChecked1 = _checkBoxItems[rowIndex]['value'];
      final String label1 = _checkBoxItems[rowIndex]['label'];

      // 두 번째 열의 항목이 있는지 확인
      final bool hasSecondItem = rowIndex + 1 < itemCount;
      final bool isChecked2 = hasSecondItem ? _checkBoxItems[rowIndex + 1]['value'] : false;
      final String label2 = hasSecondItem ? _checkBoxItems[rowIndex + 1]['label'] : '';

      return Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  value: isChecked1,
                  onChanged: (value) {
                    setState(() {
                      _checkBoxItems[rowIndex]['value'] = value;
                    });
                  },
                ),
                Text(label1, style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          if (hasSecondItem)
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    value: isChecked2,
                    onChanged: (value) {
                      setState(() {
                        _checkBoxItems[rowIndex + 1]['value'] = value;
                      });
                    },
                  ),
                  Text(label2, style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
        ],
      );
    });
  }

  // 신고완료 알림 다이얼로그

}
