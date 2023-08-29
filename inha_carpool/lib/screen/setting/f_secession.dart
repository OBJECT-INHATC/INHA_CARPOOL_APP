import 'package:flutter/material.dart';

class SecessionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 56,
        leading: Center(
          child: BackButton(
            color: Colors.black,
          ),
        ),
        title: Text(
          "회원탈퇴",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "가나다라마바사님\n정말 탈퇴하시겠어요?",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 22,
            ),
            SizedBox(height: 10),
            Text(
              "지금 탈퇴하시면 더이상 카풀 서비스를 이용할 수 없어요!",
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "탈퇴하시려는 이유를 알려주세요!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "이유를 입력해주세요",
                  border: InputBorder.none,
                ),
                maxLines: 10,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 탈퇴 처리 로직 구현 예정(아직안함ㅎ)
              },
              child: Text('탈퇴하기'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                primary: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: SecessionPage()));
