import 'package:flutter/material.dart';

class ComplainDialog extends StatefulWidget {
  const ComplainDialog({super.key});

  @override
  State<ComplainDialog> createState() => _ComplainDialogState();
}

class _ComplainDialogState extends State<ComplainDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 5),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new),
              ),
              Text(
                '신고하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.clear),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: Colors.grey,
        ),
        Container(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 10),
            shrinkWrap: true,
            // itemCount: context.watch<States>().name.length,
            itemCount: 2,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                color: Colors.grey[200],
                child: ListTile(
                  leading: Icon(Icons.account_circle_rounded, size: 48),
                  iconColor: Colors.deepPurple,
                  title:
                  Text('민지', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing:
                  Icon(Icons.priority_high, color: Colors.red, size: 35),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ComplainAlert(index: index);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

//신고 다이얼로그창
class ComplainAlert extends StatefulWidget {
  const ComplainAlert({super.key, this.index});

  final index; //이름 따라보내기

  @override
  State<ComplainAlert> createState() => _ComplainAlertState();
}

class _ComplainAlertState extends State<ComplainAlert> {
  bool? _isCheck1 = false;
  bool? _isCheck2 = false;
  bool? _isCheck3 = false;
  bool? _isCheck4 = false;
  bool? _isCheck5 = false;
  bool? _isCheck6 = false;
  bool? _isCheck7 = false;

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return AlertDialog(
      insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      contentPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: Builder(
        builder: (context) {
          return SizedBox(
            height: height - 350,
            width: width - 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 180,
                  height: 60,
                  child: ListTile(
                    leading: Icon(Icons.account_circle_rounded, size: 48),
                    iconColor: Colors.deepPurple,
                    title: Text('민지'),
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: (width - 100) / 2,
                        height: height - 600,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    value: _isCheck1,
                                    onChanged: (value) {
                                      setState(() {
                                        _isCheck1 = value;
                                      });
                                    }),
                                const Text('욕설/인신공격', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    value: _isCheck2,
                                    onChanged: (value) {
                                      setState(() {
                                        _isCheck2 = value;
                                      });
                                    }),
                                const Text('영리목적/홍보성',
                                    style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    value: _isCheck3,
                                    onChanged: (value) {
                                      setState(() {
                                        _isCheck3 = value;
                                      });
                                    }),
                                const Text('개인정보노출', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    value: _isCheck4,
                                    onChanged: (value) {
                                      setState(() {
                                        _isCheck4 = value;
                                      });
                                    }),
                                const Text('기타', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: (width - 100) / 2,
                        height: height - 600,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    value: _isCheck5,
                                    onChanged: (value) {
                                      setState(() {
                                        _isCheck5 = value;
                                      });
                                    }),
                                const Text('선정성/음란성', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    value: _isCheck6,
                                    onChanged: (value) {
                                      setState(() {
                                        _isCheck6 = value;
                                      });
                                    }),
                                const Text('채팅도배', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    value: _isCheck7,
                                    onChanged: (value) {
                                      setState(() {
                                        _isCheck7 = value;
                                      });
                                    }),
                                const Text('불법정보', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: width - 100,
                  height: 85,
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
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
                    builder: (BuildContext context) =>
                        complainComplete(context));
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

  //신고완료 알림 다이얼로그
  Widget complainComplete(context) {
    var width = MediaQuery.of(context).size.width;

    return AlertDialog(
      insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: width - 20,
        height: 150,
        child: const Column(
          children: [
            SizedBox(
                height: 40,
                child: Text(
                  '신고완료',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
            Divider(
              height: 1.5,
              color: Colors.grey,
            ),
            SizedBox(height: 15),
            Text(
              '신고가 정상적으로 완료되었습니다.\n더 나은 서비스를 위해 노력하겠습니다.\n감사합니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          padding: EdgeInsets.only(right: 10),
          child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK')),
        )
      ],
    );
  }
}
