import 'package:flutter/material.dart';

/// 검새 결과 없을 때 반환할 위젯
class EmptySearched extends StatelessWidget {
  const EmptySearched({super.key});

  @override
  Widget build(BuildContext context) {
    const String message = '검색 결과가 없습니다.';
    return  const SafeArea(
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
