import 'package:flutter/material.dart';
// 지도 api 연결 예정
class LocationInputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('위치 선택'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, '선택한 위치');
          },
          child: Text('위치 선택 완료'),
        ),
      ),
    );
  }
}
