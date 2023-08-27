import 'package:flutter/material.dart';
import 'package:inha_Carpool/fragment/setting/f_setting.dart';
import 'package:nav/nav.dart';



class VerificationDialog extends StatelessWidget {
  const VerificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;//화면의 가로길이

    return  AlertDialog(//경고창
        backgroundColor: null,
      insetPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),//경고창의 내부여백
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),//모서리 둥글게
      content: SizedBox(//경고창의 크기
        width: width - 20,// -20을 해주는 이유는 경고창의 내부여백이 20이기 때문
        height: 150, //경고창의 높이
        child: Column(//열
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,//가로로 꽉 채우기
              children: [
                RichText(//텍스트의 일부분만 스타일 적용
                  text: TextSpan(//텍스트 일부분에 스타일 적용
                    children: [
                      WidgetSpan(//위젯을 텍스트 일부분에 적용
                        child: Icon(Icons.check_circle, color: Colors.green[400]),
                      ),
                      WidgetSpan(child: SizedBox(width: 10)),
                      TextSpan(
                        text: "확인",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.clear),
                ),
              ],
            ),
            Divider(//구분선
              height: 1.5,
              color: Colors.grey,
            ),
            SizedBox(height: 15),
            Text(
              '이메일 인증 전송!!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '이메일에서 인증을 누르시고 로그인 하여 카풀을 이용하세요!',
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
                backgroundColor:
                MaterialStateProperty.all(Colors.green.shade400),
              ),
              onPressed: () {

                Navigator.pop(context);
              },
              child: const Text('OK')),
        )
      ],
    );
  }
}

