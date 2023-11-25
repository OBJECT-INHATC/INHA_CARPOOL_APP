import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/dialog/d_complain_show.dart';

import '../../dto/ReportRequstDTO.dart';
import '../../service/api/Api_repot.dart';
import 'd_complain_complete.dart';

class ComplainAlert extends StatefulWidget {
     const ComplainAlert({super.key, required this.reportedUserNickName, required this.myId, required this.carpoolId});

  final String reportedUserNickName; // 이름 따라보내기
  final String myId;
  final String carpoolId; // 카풀 ID 따라보내기

  @override
  State<ComplainAlert> createState() => _ComplainAlertState();
}

class _ComplainAlertState extends State<ComplainAlert> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final apiService = ApiService();
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _checkBoxItems = [
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

    double heightPercentage = 0.4; // 70% 화면 높이 사용
    double widthPercentage = 0.9; // 90% 화면 너비 사용

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: SingleChildScrollView(
        child: Builder(
          builder: (context) {
            return SizedBox(
              height: heightPercentage * height + 40,
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
                          widget.reportedUserNickName.replaceFirst(' ', '').toString(),
                          style: const TextStyle(
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: _buildCheckBoxes(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _controller,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                labelText: '신고내용',
                                prefixIcon: const Icon(Icons.edit, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async {

                if(_controller.text.isNotEmpty && getCheckedItems().isNotEmpty){
                  final reportRequstDTO = ReportRequstDTO(
                    content: _controller.text,
                    carpoolId: widget.carpoolId,
                    reportedUser: widget.reportedUserNickName.replaceAll(' 님', ''),
                    reporter: widget.myId,
                    reportType: getCheckedItems().toString(),
                    reportDate: DateTime.now().toString(),
                  );
                  
                  // API 호출
                  bool isOpen = await apiService.saveReport(reportRequstDTO);
                  if(isOpen) {
                    print("스프링부트 서버 성공 #############");
                    if(!mounted) return;
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => const ComplainComplete(
                        isReport: false,
                      ),
                    );
                  }else{
                    print("스프링부트 서버 실패 #############");
                    if(!mounted) return;
                    showDialog(context: context, builder: (BuildContext context) => const ComplainShow(
                        cautionText: "서버가 불안정합니다.\n잠시 후 다시 시도해주세요."));
                  }
                }else{
                    showDialog(context: context, builder: (BuildContext context) => const ComplainShow(
                      cautionText: "체크박스와 신고내용을 모두 입력 해주세요",));
                }

              },
              child: const Text('신고하기', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
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
                Text(label1, style: const TextStyle(fontSize: 13)),
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
                  Text(label2, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
        ],
      );
    }
    );
  }

  // 체크된 리스트 확인
  List<String> getCheckedItems() {
    List<String> checkedItems = [];

    for (var item in _checkBoxItems) {
      if (item['value'] == true) {
        checkedItems.add(item['label']);
      }
    }

    return checkedItems;
  }

}
