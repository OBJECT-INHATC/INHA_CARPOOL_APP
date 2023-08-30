import 'package:flutter/material.dart';

class ChangePasswordPage extends StatelessWidget {
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
          "비밀번호 변경",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              '현재 비밀번호',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: '현재 비밀번호 입력',
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            Text(
              '새 비밀번호',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: '새로운 비밀번호 입력',
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            Text(
              '새 비밀번호 확인',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: '새로운 비밀번호 다시 입력',
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // 비밀번호 변경 로직 구현 예정
              },
              child: Text('비밀번호 변경'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                primary: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
